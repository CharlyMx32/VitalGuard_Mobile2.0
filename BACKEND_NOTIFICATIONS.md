# Backend - Sistema de Notificaciones Push

> Guía de implementación para el backend de VitalGuard.
> El frontend ya tiene integrado Firebase Cloud Messaging (FCM).

---

## 1. Dependencias necesarias

```bash
# Node.js
npm install firebase-admin

# Python
pip install firebase-admin

# O usar el SDK de Firebase Admin de tu lenguaje preferido
```

## 2. Inicializar Firebase Admin SDK

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Descargar de Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
```

> Descargar `serviceAccountKey.json` desde:
> Firebase Console → Configuración del proyecto → Pestaña "Cuentas de servicio" → Generar nueva clave privada

---

## 3. Endpoints requeridos

### 3.1 Registrar token FCM del dispositivo

```
POST /notifications/token
```

**Request:**
```json
{
  "token": "fcm_token_del_dispositivo"
}
```

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Lógica:**
- Obtener el `user_id` del JWT token
- Guardar/actualizar el `fcm_token` en la tabla `users` o `device_tokens`
- Un usuario puede tener múltiples dispositivos → tabla separada recomendada

**Tabla sugerida `device_tokens`:**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| id | INT (PK) | Auto-increment |
| user_id | INT (FK) | Referencia al usuario |
| fcm_token | TEXT | Token FCM del dispositivo |
| platform | VARCHAR | "android" / "ios" |
| created_at | TIMESTAMP | Fecha de registro |
| updated_at | TIMESTAMP | Última actualización |

**Response:**
```json
{
  "success": true
}
```

---

### 3.2 Obtener conteo de no-leídas

```
GET /notifications/unread-count
```

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Lógica:**
- Contar notificaciones donde `is_read = false` para el usuario actual
- Si el usuario es cuidador: contar notificaciones de todos sus pacientes
- Si el usuario es paciente: contar solo sus notificaciones

**Response:**
```json
{
  "count": 5
}
```

---

### 3.3 Obtener lista de notificaciones (ya existe)

```
GET /notifications
```

Verificar que retorne los campos del modelo Flutter:

```json
[
  {
    "id": 1,
    "title": "Dosis pendiente",
    "message": "Juan no ha tomado su medicamento de las 14:00",
    "type": "DOSIS_RECORDATORIO",
    "isRead": false,
    "patient": {
      "id": 1,
      "fullName": "Juan Pérez",
      "age": 72
    },
    "createdAt": "2026-08-15T14:30:00Z"
  }
]
```

**Tipos de notificación válidos:**
| Valor | Descripción |
|-------|-------------|
| `MEDICAMENTO_SOLICITUD` | Cuidador solicita confirmar dosis |
| `DOSIS_RECORDATORIO` | Recordatorio de hora de dosis |
| `SOS_ALERTA` | Alguien presionó SOS |
| `SISTEMA` | Alertas del sistema (offline, batería, firmware) |

---

### 3.4 Marcar como leída (ya existe)

```
PATCH /notifications/:id/read
```

### 3.5 Marcar todas como leídas (ya existe)

```
PATCH /notifications/read-all
```

---

## 4. Envío de notificaciones push

### 4.1 Función helper para enviar push

```javascript
async function sendPushNotification(userId, { title, body, type, data = {} }) {
  // 1. Obtener todos los tokens del usuario
  const tokens = await db.query(
    'SELECT fcm_token FROM device_tokens WHERE user_id = ?', 
    [userId]
  );

  if (tokens.length === 0) return;

  // 2. Construir el mensaje
  const message = {
    notification: {
      title,
      body,
    },
    data: {
      type,           // "DOSIS_RECORDATORIO", "SOS_ALERTA", etc.
      route: data.route || '',  // Ruta para deep linking
      id: String(data.id || ''),
      ...data,
    },
    tokens: tokens.map(t => t.fcm_token),
  };

  // 3. Enviar (multicast para múltiples dispositivos)
  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    
    // 4. Limpiar tokens inválidos
    response.responses.forEach((resp, idx) => {
      if (resp.error?.code === 'messaging/registration-token-not-registered') {
        db.query('DELETE FROM device_tokens WHERE fcm_token = ?', 
          [tokens[idx].fcm_token]);
      }
    });
  } catch (error) {
    console.error('Error sending push:', error);
  }
}
```

---

### 4.2 Cuando enviar notificaciones

#### Dosis (tipo `DOSIS_RECORDATORIO`)

```javascript
// Programar con cron job o worker cada minuto
async function checkPendingDoses() {
  const now = new Date();
  const schedules = await db.query(`
    SELECT s.*, t.patient_id, u.id as caregiver_id
    FROM schedules s
    JOIN treatments t ON s.treatment_id = t.id
    JOIN users u ON t.caregiver_id = u.id
    WHERE s.time = ? AND s.status = 'pending'
  `, [now.toTimeString().slice(0, 5)]);

  for (const schedule of schedules) {
    // Guardar notificación en BD
    await db.query(`
      INSERT INTO notifications (title, message, type, is_read, user_id, patient_id)
      VALUES (?, ?, 'DOSIS_RECORDATORIO', false, ?, ?)
    `, [
      'Dosis pendiente',
      `${schedule.patient_name} debe tomar ${schedule.medication_name}`,
      schedule.caregiver_id,
      schedule.patient_id,
    ]);

    // Enviar push
    await sendPushNotification(schedule.caregiver_id, {
      title: 'Dosis pendiente',
      body: `${schedule.patient_name} debe tomar ${schedule.medication_name}`,
      type: 'DOSIS_RECORDATORIO',
      data: { route: '/medications', id: schedule.id },
    });
  }
}
```

#### SOS (tipo `SOS_ALERTA`)

```javascript
async function triggerSOS(patientId, userId) {
  // Obtener cuidadores del paciente
  const caregivers = await db.query(`
    SELECT u.id FROM users u
    JOIN patients p ON p.caregiver_id = u.id
    WHERE p.id = ?
  `, [patientId]);

  // Guardar notificación
  await db.query(`
    INSERT INTO notifications (title, message, type, is_read, user_id, patient_id)
    VALUES (?, ?, 'SOS_ALERTA', false, ?, ?)
  `, [
    'Alerta SOS activada',
    'Un paciente ha presionado el botón de emergencia',
    userId,
    patientId,
  ]);

  // Enviar push a todos los cuidadores (URGENTE - siempre se entrega)
  for (const caregiver of caregivers) {
    await sendPushNotification(caregiver.id, {
      title: '🚨 Alerta SOS',
      body: 'Un paciente ha presionado el botón de emergencia',
      type: 'SOS_ALERTA',
      data: { route: '/sos/alarm', id: patientId },
    });
  }
}
```

#### Solicitud de medicamento (tipo `MEDICAMENTO_SOLICITUD`)

```javascript
async function requestMedicationConfirmation(caregiverId, patientId, medicationName) {
  await sendPushNotification(caregiverId, {
    title: 'Solicitud de medicamento',
    body: `Se requiere confirmar la dosis de ${medicationName}`,
    type: 'MEDICAMENTO_SOLICITUD',
    data: { route: '/medications', id: patientId },
  });
}
```

#### Alertas del sistema (tipo `SISTEMA`)

```javascript
// Dispositivo offline
async function notifyDeviceOffline(userId, deviceName) {
  await sendPushNotification(userId, {
    title: 'Dispositivo desconectado',
    body: `${deviceName} se ha desconectado`,
    type: 'SISTEMA',
    data: { route: '/settings/my-vitalguard' },
  });
}

// Batería baja
async function notifyLowBattery(userId, deviceName, batteryLevel) {
  await sendPushNotification(userId, {
    title: 'Batería baja',
    body: `${deviceName} tiene ${batteryLevel}% de batería`,
    type: 'SISTEMA',
    data: { route: '/settings/my-vitalguard' },
  });
}
```

---

## 5. Filtro de notificaciones según configuración del usuario

El frontend guarda preferencias en `SharedPreferences` (local). El backend debe respetar:

```javascript
// Antes de enviar push, verificar preferencias del usuario
async function shouldSendNotification(userId, notificationType) {
  const preferences = await db.query(
    'SELECT * FROM notification_preferences WHERE user_id = ?', 
    [userId]
  );

  if (!preferences || !preferences.notif_general) return false;

  switch (notificationType) {
    case 'DOSIS_RECORDATORIO':
      return preferences.notif_doses;
    case 'SOS_ALERTA':
      return true; // SOS siempre se envía
    case 'MEDICAMENTO_SOLICITUD':
      return preferences.notif_general;
    case 'SISTEMA':
      return preferences.notif_general;
    default:
      return true;
  }
}

// Verificar horario de silencio (DND)
function isDndActive(preferences) {
  if (!preferences.notif_dnd) return false;
  
  const now = new Date();
  const hour = now.getHours();
  
  // DND de 22:00 a 07:00
  return hour >= 22 || hour < 7;
}
```

> Nota: SOS siempre se entrega aunque DND esté activo.

---

## 6. Tabla `notification_preferences` (opcional pero recomendada)

```sql
CREATE TABLE notification_preferences (
  user_id INT PRIMARY KEY,
  notif_general BOOLEAN DEFAULT true,
  notif_doses BOOLEAN DEFAULT true,
  notif_emergency BOOLEAN DEFAULT true,
  notif_reminders BOOLEAN DEFAULT false,
  notif_dnd BOOLEAN DEFAULT false,
  dnd_start TIME DEFAULT '22:00',
  dnd_end TIME DEFAULT '07:00',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 7. Estructura completa de la tabla `notifications`

```sql
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  patient_id INT,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL,
  is_read BOOLEAN DEFAULT false,
  data JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (patient_id) REFERENCES patients(id)
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
```

---

## 8. Cron jobs recomendados

| Job | Frecuencia | Descripción |
|-----|------------|-------------|
| `checkPendingDoses` | Cada 1 minuto | Verificar dosis pendientes y enviar recordatorios |
| `checkDeviceStatus` | Cada 5 minutos | Verificar si dispositivos están online y alertar si están offline |
| `cleanOldNotifications` | Diario (03:00) | Eliminar notificaciones mayores a 30 días |
| `cleanupTokens` | Semanal | Eliminar tokens FCM inválidos |

---

## 9. Testing

### Probar envío de push desde Firebase Console

1. Ir a Firebase Console → Cloud Messaging
2. Enviar notificación de prueba
3. Verificar que llega el pop-up en la app

### Probar con curl

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/vitalguard-c1b6f/messages:send \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "TOKEN_FCM_DEL_DISPOSITIVO",
      "notification": {
        "title": "Test",
        "body": "Notificación de prueba"
      },
      "data": {
        "type": "SISTEMA",
        "route": "/dashboard"
      }
    }
  }'
```

---

## 10. Resumen de endpoints

| Método | Ruta | Descripción | Estado |
|--------|------|-------------|--------|
| POST | `/notifications/token` | Registrar FCM token | **NUEVO** |
| GET | `/notifications/unread-count` | Conteo no-leídas | **NUEVO** |
| GET | `/notifications` | Lista notificaciones | Existe |
| PATCH | `/notifications/:id/read` | Marcar leída | Existe |
| PATCH | `/notifications/read-all` | Marcar todas leídas | Existe |

**El frontend está listo. Solo falta implementar estos 2 endpoints en el backend + la lógica de envío de push.**
