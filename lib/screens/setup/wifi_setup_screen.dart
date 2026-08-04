import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../widgets/vital_modal.dart';

class WifiSetupScreen extends StatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  int _selectedNetwork = 0;
  final _passwordController = TextEditingController();
  bool _isSaving = false;

  final _networks = [
    _Network(name: 'MiWiFi_5G', signal: 4, label: 'Excelente'),
    _Network(name: 'Vecino_WiFi', signal: 2, label: 'Regular'),
    _Network(name: 'Casa_Garcia', signal: 3, label: 'Buena'),
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  const Text('Conectar a WiFi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  const Text('Tu VitalGuard necesita conexion a internet para funcionar',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildStep(1, true, 'Conectate a la red del dispositivo', 'Busca la red "VitalGuard-XXXX" en tu telefono y conectate'),
                  const SizedBox(height: 20),
                  _buildStep(2, false, 'Selecciona tu red WiFi', 'Elige tu red domestica e ingresa la contrasena'),
                  const SizedBox(height: 12),
                  ...List.generate(_networks.length, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildNetworkItem(i),
                  )),
                  const SizedBox(height: 12),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildConnectButton(),
                  const SizedBox(height: 12),
                  const Text('Configurar despues', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primary))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildStep(int number, bool completed, String title, String desc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: completed ? AppColors.accent : AppColors.primary, shape: BoxShape.circle),
          child: completed ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : Center(child: Text('$number', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ]),
      Padding(
        padding: const EdgeInsets.only(left: 38),
        child: Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
      ),
    ]);
  }

  Widget _buildNetworkItem(int index) {
    final net = _networks[index];
    final selected = _selectedNetwork == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNetwork = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight, width: 1.5),
        ),
        child: Row(children: [
          const Icon(LucideIcons.wifi, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(net.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            Row(children: [
              ...List.generate(4, (i) => Container(
                width: 3, height: [4.0, 7.0, 10.0, 13.0][i],
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(color: i < net.signal ? AppColors.accent : AppColors.borderLight, borderRadius: BorderRadius.circular(1)),
              )),
              const SizedBox(width: 4),
              Text(net.label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ]),
          ])),
          if (selected) const Icon(LucideIcons.checkCircle, size: 20, color: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          hintText: 'Ingresa la contrasena de tu red',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _onConnect,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Conectar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _onConnect() async {
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la contrasena de la red WiFi'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wifi_ssid', _networks[_selectedNetwork].name);
    await prefs.setString('wifi_password', _passwordController.text);

    if (mounted) {
      VitalFeedback.success(
        context,
        code: 'WIFI_CONNECTED',
        message: 'Configuración WiFi guardada correctamente',
        onAction: () => Navigator.pop(context),
      );
    }
  }
}

class _Network {
  final String name;
  final int signal;
  final String label;
  const _Network({required this.name, required this.signal, required this.label});
}
