import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';
import '../../services/device_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../services/caregiver_service.dart';
import '../../models/device.dart';
import '../../models/caregiver.dart';
import '../../widgets/vital_button.dart';
import '../../widgets/vital_modal.dart';
import '../../widgets/vital_header.dart';

class MyVitalGuardScreen extends StatefulWidget {
  const MyVitalGuardScreen({super.key});

  @override
  State<MyVitalGuardScreen> createState() => _MyVitalGuardScreenState();
}

class _MyVitalGuardScreenState extends State<MyVitalGuardScreen> {
  Device? _device;
  List<Caregiver>? _caregivers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  Future<void> _loadDevice() async {
    setState(() { _loading = true; _error = null; });
    try {
      final deviceService = context.read<DeviceService>();
      final patientCurrent = context.read<PatientCurrentService>();
      final auth = context.read<AuthService>();
      final patientId = patientCurrent.patientId ?? auth.patientId;
      if (patientId == null) {
        if (mounted) setState(() { _loading = false; });
        return;
      }
      final device = await deviceService.getPatientDevice(patientId);
      List<Caregiver>? caregivers;
      try {
        caregivers = await context.read<CaregiverService>().getCaregivers(patientId);
      } catch (_) {}
      if (mounted) setState(() { _device = device; _caregivers = caregivers; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Mi VitalGuard'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _device == null
                        ? _buildNoDeviceState()
                        : _buildDeviceContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(16)),
              child: const Icon(LucideIcons.alertTriangle, size: 32, color: AppColors.danger)),
            const SizedBox(height: 16),
            const Text('Error al cargar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text('No se pudo obtener la información del dispositivo', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            _buildButton('Reintentar', AppColors.primary, Colors.white, onTap: _loadDevice),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDeviceState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
              child: const Icon(LucideIcons.monitor, size: 40, color: AppColors.primary)),
            const SizedBox(height: 20),
            const Text('Sin dispositivo vinculado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Vincula tu VitalGuard para comenzar a gestionar los medicamentos de tus pacientes.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
            const SizedBox(height: 24),
            _buildButton('Vincular dispositivo', AppColors.primary, Colors.white,
                onTap: () => Navigator.pushNamed(context, AppRoutes.linkDevice, arguments: {'next': AppRoutes.myVitalGuard})),
            const SizedBox(height: 12),
            _buildButton('Omitir por ahora', Colors.white, AppColors.textDark, border: true,
                onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          _buildDeviceVisual(),
          const SizedBox(height: 20),
          _buildSectionTitle('Información del dispositivo'),
          const SizedBox(height: 8),
          _buildInfoGroup(),
          const SizedBox(height: 16),
          _buildResponsibleSection(),
          const SizedBox(height: 20),
          _buildWiFiStatus(context),
          const SizedBox(height: 20),
          _buildButton('Sincronizar ahora', AppColors.primary, Colors.white, onTap: _syncNow),
          const SizedBox(height: 12),
          _buildButton('Desconectar dispositivo', Colors.white, AppColors.textDark,
              border: true, onTap: _disconnectDevice),
        ],
      ),
    );
  }

  Widget _buildDeviceVisual() {
    final device = _device;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.bg]), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3A7BD5)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
            child: const Icon(LucideIcons.monitor, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: (device?.isOnline ?? false) ? AppColors.accent : AppColors.textMuted, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(
                _loading
                    ? 'Cargando dispositivo...'
                    : (device != null
                        ? (device.isOnline ?? false ? 'Dispositivo en línea' : 'Dispositivo sin conexión')
                        : 'Sin dispositivo vinculado'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            device != null
                ? 'Código: ${device.uniqueCode}'
                : 'Conecta tu VitalGuard para ver la información',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildInfoGroup() {
    final device = _device;
    final items = <(String, String)>[
      ('Estado', device == null ? '---' : (device.isOnline ?? false ? 'En línea' : 'Sin conexión')),
      ('Firmware', device?.firmwareVersion ?? '---'),
      ('Número de serie', device?.uniqueCode ?? '---'),
      ('Última sincronización', _formatSyncDate(device?.lastSyncAt)),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 16, color: AppColors.borderLight);
          final item = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.$2,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _formatSyncDate(DateTime? date) {
    if (date == null) return '---';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $h:$m';
  }

  Widget _buildResponsibleSection() {
    final device = _device;
    final repo = _caregivers;
    final respId = device?.responsibleCaregiverId;
    Caregiver? resp;
    if (respId != null && repo != null) {
      try { resp = repo.firstWhere((c) => c.id == respId); } catch (_) {}
    }
    final label = resp != null ? resp.label() : (respId == null ? 'Sin asignar' : 'Cuidador #$respId');
    final kinBadge = resp?.kinshipDisplay ?? resp?.kinship;
    final isUnassigned = respId == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusCard), boxShadow: AppDimensions.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppDimensions.radiusIcon)), child: const Icon(LucideIcons.shieldCheck, size: 18, color: AppColors.primary)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cuidador responsable', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            SizedBox(height: 2),
            Text('Recibe alertas críticas y puede transferir el pastillero', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.2)),
          ])),
          if (device != null)
            GestureDetector(
              onTap: _changeResponsible,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppDimensions.radiusButton)),
                child: const Text('Cambiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: isUnassigned ? AppColors.iconGrayBg : AppColors.iconBlueBg, shape: BoxShape.circle),
              child: Center(child: Text(isUnassigned ? '?' : resp!.initials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isUnassigned ? AppColors.textMuted : AppColors.iconBlueFg))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Row(children: [
                if (kinBadge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)), child: Text(kinBadge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                if (kinBadge != null) const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isUnassigned ? AppColors.warningBg : AppColors.accentLight, borderRadius: BorderRadius.circular(20)), child: Text(isUnassigned ? 'Sin asignar' : 'Actual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isUnassigned ? AppColors.warning : AppColors.accent))),
              ]),
            ])),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textLight),
          ]),
        ),
        if (isUnassigned) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Se auto-asigna al vincular. Solo el responsable puede transferir a otro cuidador vinculado.', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4))),
      ]),
    );
  }

  Future<void> _changeResponsible() async {
    final device = _device;
    if (device == null) return;
    final repo = context.read<CaregiverService>();
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final patientId = patientCurrent.patientId ?? auth.patientId;
    if (patientId == null) return;
    List<Caregiver> list = _caregivers ?? [];
    if (list.isEmpty) {
      try { list = await repo.getCaregivers(patientId); } catch (_) {}
    }
    if (list.isEmpty) {
      VitalFeedback.info(context, code: 'NO_CAREGIVERS', message: 'No hay cuidadores vinculados a este paciente. Invita a un familiar primero.');
      return;
    }
    int selected = device.responsibleCaregiverId ?? list.first.id;
    // Bottom sheet premium — lista con avatar, nombre + kinship, radio y badge Actual
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setSt) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 10),
                Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
                  Container(width: 36, height: 36, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle), child: const Icon(LucideIcons.users, size: 18, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Cambiar responsable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    SizedBox(height: 2),
                    Text('Solo el responsable actual puede transferir el pastillero', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ])),
                ])),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.borderLight),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, color: AppColors.borderLight),
                    itemBuilder: (_, i) {
                      final c = list[i];
                      final isResp = c.id == device.responsibleCaregiverId;
                      final isSel = c.id == selected;
                      return InkWell(
                        onTap: () => setSt(() => selected = c.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(children: [
                            Container(width: 44, height: 44, decoration: BoxDecoration(color: isSel ? AppColors.primaryLight : AppColors.iconGrayBg, shape: BoxShape.circle, border: Border.all(color: isSel ? AppColors.primary : Colors.transparent, width: 1.5)), child: Center(child: Text(c.initials, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSel ? AppColors.primary : AppColors.textMuted)))),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(c.label(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500, color: AppColors.textDark)),
                              const SizedBox(height: 2),
                              Row(children: [
                                if (c.kinshipDisplay != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)), child: Text(c.kinshipDisplay!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                                if (isResp) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(20)), child: const Text('Actual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)))],
                              ]),
                            ])),
                            const SizedBox(width: 8),
                            Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? AppColors.primary : Colors.white, border: Border.all(color: isSel ? AppColors.primary : AppColors.borderLight, width: 1.5)), child: isSel ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Row(children: [
                  Expanded(child: VitalButton.ghost(label: 'Cancelar', onPressed: () => Navigator.of(ctx2).pop())),
                  const SizedBox(width: 12),
                  Expanded(child: VitalButton.primary(label: 'Confirmar', onPressed: () => Navigator.of(ctx2).pop(selected))),
                ])),
                const SizedBox(height: 8),
              ]),
            ),
          );
        });
      },
    );
    if (result == null) return;
    selected = result;
    try {
      final ds = context.read<DeviceService>();
      final updated = await ds.updateResponsible(device.id, selected);
      if (mounted) setState(() { _device = updated; });
      VitalFeedback.success(context, code: 'RESPONSIBLE_UPDATED', message: 'Responsable actualizado correctamente.');
      // Refresca lista para reflejar kinship actualizado
      try { _caregivers = await repo.getCaregivers(patientId); if (mounted) setState(() {}); } catch (_) {}
    } catch (e) {
      final msg = e.toString();
      String title = 'No autorizado';
      String body = 'Solo el responsable actual puede transferir el pastillero.';
      if (msg.contains('404')) { title = 'No vinculado'; body = 'El cuidador seleccionado no está vinculado a este paciente.'; }
      else if (msg.contains('403')) { title = 'Permiso denegado'; body = 'Solo el responsable actual (Cuidador #${device.responsibleCaregiverId}) puede cambiarlo.'; }
      VitalFeedback.info(context, code: 'RESPONSIBLE_ERROR', title: title, message: body);
    }
  }

  Widget _buildWiFiStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.wifi, size: 18, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('WiFi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            SizedBox(height: 2),
            Text('No conectado', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Future<void> _syncNow() async {
    final deviceService = context.read<DeviceService>();
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final patientId = patientCurrent.patientId ?? auth.patientId;
    if (patientId == null) return;
    final device = await deviceService.getPatientDevice(patientId);
    if (mounted) {
      setState(() { _device = device; });
      VitalFeedback.success(
        context,
        code: 'DEVICE_SYNCED',
        message: device != null
            ? 'Dispositivo sincronizado correctamente'
            : 'Sin dispositivo vinculado. Conecta tu VitalGuard primero.',
      );
    }
  }

  Future<void> _disconnectDevice() async {
    final deviceService = context.read<DeviceService>();
    final confirmed = await VitalModal.show<bool>(
      context: context,
      title: 'Desconectar dispositivo',
      description: 'Se eliminará la vinculación del dispositivo. ¿Deseas continuar?',
      iconType: ModalIconType.warning,
      icon: LucideIcons.unlink,
      actions: [
        VitalButton.ghost(
          label: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(height: 8),
        VitalButton.danger(
          label: 'Desconectar',
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true && mounted) {
      final deviceId = _device?.id;
      if (deviceId != null) {
        try {
          await deviceService.unlinkDevice(deviceId);
        } catch (e) {
          if (!mounted) return;
          VitalFeedback.info(
            context,
            code: 'DEVICE_DISCONNECT_ERROR',
            title: 'Error',
            message: 'No se pudo desconectar el dispositivo. Intenta de nuevo.',
          );
          return;
        }
      } else {
        await deviceService.disconnect();
      }
      if (!mounted) return;
      setState(() => _device = null);
      VitalFeedback.info(
        context,
        code: 'DEVICE_DISCONNECTED',
        message: 'Dispositivo desconectado correctamente.',
      );
    }
  }

  Widget _buildButton(String label, Color bg, Color fg, {bool border = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 44,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border ? Border.all(color: AppColors.borderLight) : null),
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg))),
      ),
    );
  }
}
