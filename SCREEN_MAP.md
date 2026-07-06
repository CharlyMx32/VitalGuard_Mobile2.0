# VitalGuard Flutter - Screen Map

> Referencia rapida para implementar pantallas.
> Cada pantalla usa widgets del design system en `lib/widgets/` y colores de `lib/theme/`.

---

## Design System (lib/theme/)

| Archivo | Contenido |
|---------|-----------|
| `app_colors.dart` | Todos los colores: primary, accent, danger, backgrounds, text, gradients |
| `app_typography.dart` | Estilos de texto: headers, body, buttons, badges, settings, errors |
| `app_dimensions.dart` | Spacing, radii, shadows, tamanos de avatar/icon/button |
| `app_theme.dart` | ThemeData completo para MaterialApp |

## Widgets Disponibles (lib/widgets/)

| Widget | Uso | Reemplaza en CSS |
|--------|-----|------------------|
| `VitalButton` | .btn-primary, .btn-ghost, .btn-outline | Botones principales |
| `VitalCard` | .card | Tarjetas blancas con shadow |
| `VitalBadge` | .dose-badge, pills de estado | Badges verdes/amarillos/azules |
| `VitalToggle` | .toggle | Switches 48x28 |
| `VitalInput` | .form-input, .form-label | Campos de formulario |
| `VitalAvatar` | .header-avatar, .profile-avatar | Avatares circulares |
| `VitalIconContainer` | .cmd-icon, .settings-icon | Contenedores de icono 36x36 |
| `VitalBottomNav` | .bottom-nav | Navegacion inferior 4 items |
| `VitalHeader` | .header (colored/white) | Headers de pagina |
| `VitalFilterTabs` | .filter-tabs | Pills de filtro horizontales |
| `VitalSettingsItem` | .settings-item | Filas de ajustes |
| `VitalSettingsGroup` | .settings-group | Grupo de ajustes con fondo blanco |
| `VitalModal` | .modal-overlay + .modal-content | Modales de confirmacion |
| `VitalToast` | .toast | Notificaciones flotantes |
| `VitalErrorWidget` | .error-screen | Pantallas de error completas |
| `SectionHeader` | .section-header | "Titulo" + "Ver todos" |

---

## FASE 0: Onboarding (5 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 01 | `onboarding/splash_screen.dart` | SplashScreen | Logo + texto | 02 (auto 3s) |
| 02 | `onboarding/onboarding_1_screen.dart` | Onboarding1Screen | [IMG] + titulo + Siguiente | 03 |
| 03 | `onboarding/onboarding_2_screen.dart` | Onboarding2Screen | [IMG] + titulo + Siguiente | 04 |
| 04 | `onboarding/onboarding_3_screen.dart` | Onboarding3Screen | [IMG] + titulo + Siguiente | 05 |
| 05 | `onboarding/onboarding_4_screen.dart` | Onboarding4Screen | [IMG] + titulo + Comenzar | vitalIdLogin |

---

## FASE 1: Vital ID Auth (6 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| V1 | `auth/vital_id_login_screen.dart` | VitalIdLoginScreen | VitalInput (email+pass) + VitalToggle (recordarme) + VitalButton.primary | V3 (OTP) |
| V2 | `auth/vital_id_register_screen.dart` | VitalIdRegisterScreen | VitalInput (nombre+email+pass+confirm) + VitalButton.primary | V3 |
| V3 | `auth/vital_id_otp_screen.dart` | VitalIdOtpScreen | 6 inputs OTP + timer + VitalButton.primary | completeProfile |
| V4 | `auth/vital_id_forgot_screen.dart` | VitalIdForgotScreen | VitalInput (email) + VitalButton.primary | V1 |
| V5 | `auth/vital_id_reset_screen.dart` | VitalIdResetScreen | VitalInput (pass+confirm) + VitalButton.primary | V1 |
| V6 | `auth/vital_id_security_screen.dart` | VitalIdSecurityScreen | VitalInput (pass) + VitalToggle (2FA) + sesiones | V1 |

---

## FASE 2: Perfil y Login (3 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 06 | `auth/login_screen.dart` | LoginScreen | VitalButton "Acceder con Vital ID" | V1 |
| 44 | `profile/complete_profile_screen.dart` | CompleteProfileScreen | VitalInput (tel+fecha) + VitalButton | dashboard (Cuidador) o 44b (Paciente) |
| 44b | `profile/self_care_profile_screen.dart` | SelfCareProfileScreen | VitalInput (sangre+notas) + VitalButton | dashboard |

---

## FASE 3: Setup (4 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 12 | `setup/link_device_screen.dart` | LinkDeviceScreen | VitalInput (codigo) + VitalButton | 13 |
| 13 | `setup/wifi_setup_screen.dart` | WifiSetupScreen | VitalInput (red+pass) + VitalButton | 14 |
| 14 | `setup/register_patient_screen.dart` | RegisterPatientScreen | VitalInput (nombre+fecha+sangre+notas) + VitalButton | 25 |
| 25 | `setup/send_requests_screen.dart` | SendRequestsScreen | VitalButton (cuidador/autocuidado/medico) | dashboard |

---

## FASE 4: Dashboard + Pacientes (4 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 15 | `dashboard/dashboard_screen.dart` | DashboardScreen | VitalHeader.colored + VitalCard (stats+pacientes+dosis) + VitalBottomNav | 16, 18, 22, 23 |
| 16 | `dashboard/patient_list_screen.dart` | PatientListScreen | VitalHeader.white + VitalCard (lista pacientes) | 17 |
| 17 | `dashboard/patient_detail_screen.dart` | PatientDetailScreen | VitalHeader.colored (avatar grande) + VitalCard (stats+acciones) | 43, 20 |
| 43 | `dashboard/edit_patient_screen.dart` | EditPatientScreen | VitalInput (7 campos) + VitalButton | 17 |

---

## FASE 5: Tratamientos (7 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 18 | `treatments/medications_screen.dart` | MedicationsScreen | VitalBottomNav + VitalCard (medicamentos) + VitalButton | addMedication, configureDispenser, history |
| 21v2 | `treatments/treatment_detail_screen.dart` | TreatmentDetailScreen | VitalCard (detalle tratamiento + meds) | scheduleConfig |
| 18_3 | `treatments/add_medication_screen.dart` | AddMedicationScreen | VitalInput (nombre+dosis+tipo+horario) + VitalButton | medications |
| 19 | `treatments/configure_dispenser_screen.dart` | ConfigureDispenserScreen | 5 compartimentos | medications |
| 20 | `treatments/history_screen.dart` | HistoryScreen | VitalBottomNav + lista historial | — |
| 21 | `treatments/notifications_screen.dart` | NotificationsScreen | VitalBottomNav + lista notificaciones | — |
| 21b | `treatments/schedule_config_screen.dart` | ScheduleConfigScreen | VitalInput (hora+frecuencia+dias) + VitalButton | treatmentDetail |

---

## FASE 6: Utilidades (4 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 23 | `utilities/voice_messages_screen.dart` | VoiceMessagesScreen | VitalBottomNav + VitalCard (grabar+mensajes) | — |
| 24 | `utilities/sos_emergency_screen.dart` | SosEmergencyScreen | VitalBottomNav + boton SOS grande | — |
| 26 | `utilities/self_care_screen.dart` | SelfCareScreen | VitalBottomNav + VitalCard (tratamientos propio) | — |
| 27 | `utilities/my_profile_screen.dart` | MyProfileScreen | VitalBottomNav + VitalCard (perfil) | — |

---

## FASE 7: Ajustes (9 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 22 | `settings/settings_screen.dart` | SettingsScreen | VitalBottomNav + VitalSettingsGroup (5 secciones) | 27-35 |
| 28 | `settings/my_vitalguard_screen.dart` | MyVitalGuardScreen | VitalHeader.white + info dispositivo | 22 |
| 29 | `settings/wifi_screen.dart` | WifiScreen | VitalHeader.white + VitalInput (red+pass) | 22 |
| 30 | `settings/notifications_config_screen.dart` | NotificationsConfigScreen | VitalToggle (4 toggles + DND) | 22 |
| 31 | `settings/voice_assistant_screen.dart` | VoiceAssistantScreen | VitalCard (Alexa status) + opciones | 22 |
| 32 | `settings/sos_config_screen.dart` | SosConfigScreen | VitalToggle (SOS) + VitalCard (contactos) | 22 |
| 33 | `settings/help_support_screen.dart` | HelpSupportScreen | VitalSettingsItem (FAQ, guia, soporte) | 22 |
| 34 | `settings/family_members_screen.dart` | FamilyMembersScreen | VitalCard (familiares lista) | 22 |
| 35 | `settings/security_settings_screen.dart` | SecuritySettingsScreen | Redirects a Vital ID | V6 |

---

## FASE 8: SOS (1 pantalla)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 36 | `sos/sos_alarm_screen.dart` | SosAlarmScreen | VitalButton.danger (CANCELAR) + contador | — |

---

## FASE 9: Errores (6 pantallas)

| # | Archivo | Clase | Widgets clave | Nav hacia |
|---|---------|-------|---------------|-----------|
| 37 | `errors/error_network_screen.dart` | ErrorNetworkScreen | VitalErrorWidget.network | retry |
| 38 | `errors/error_server_screen.dart` | ErrorServerScreen | VitalErrorWidget.server | retry |
| 39 | `errors/error_auth_screen.dart` | ErrorAuthScreen | VitalErrorWidget.auth | V1 |
| 40 | `errors/error_device_screen.dart` | ErrorDeviceScreen | VitalErrorWidget.device | retry |
| 41 | `errors/error_treatment_screen.dart` | ErrorTreatmentScreen | VitalErrorWidget.treatment | retry |
| 42 | `errors/error_generic_screen.dart` | ErrorGenericScreen | VitalErrorWidget.generic | retry |

---

## Modales (4 modals)

| # | Archivo | Tipo | Uso |
|---|---------|------|-----|
| M1 | `vital_modal.dart` (showModal) | VitalModal + VitalInput | Confirmaciones con input |
| M2 | `vital_modal.dart` (showModal) | VitalModal + icono info | Deteccion de dispositivo |
| M3 | `vital_modal.dart` (showModal) | VitalModal + icono grabar | Grabacion de audio |
| M4 | `vital_modal.dart` (showModal) | VitalModal + icono permiso | Permisos del sistema |

---

## Flujo de Navegacion Principal

```
01 Splash → 02-05 Onboarding → V1 Login Vital ID
  → V3 OTP → 06 VitalGuard Login → 44 Complete Profile
    → [Cuidador] → Dashboard 15
    → [Paciente] → 44b Autocuidado → Dashboard 15

Dashboard 15 → 16 Lista Pacientes → 17 Detalle → 43 Editar
Dashboard 15 → 18 Medicamentos → add/dispenser/history
Dashboard 15 → 22 Ajustes → 27-35 sub-pantallas
Dashboard 15 → 23 Voz / 24 SOS
```
