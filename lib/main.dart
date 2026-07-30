import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/theme_provider.dart';
import 'services/patient_service.dart';
import 'services/treatment_service.dart';
import 'services/device_service.dart';
import 'services/sos_service.dart';
import 'services/voice_service.dart';
import 'services/caregiver_service.dart';
import 'services/avatar_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => StorageService()),
        ProxyProvider<AuthService, ApiClient>(
          create: (context) => ApiClient(context.read<AuthService>()),
          update: (context, auth, previous) => previous!,
        ),
        ProxyProvider2<ApiClient, StorageService, PatientService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? PatientService(apiClient, storage),
        ),
        ProxyProvider2<ApiClient, StorageService, TreatmentService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? TreatmentService(apiClient, storage),
        ),
        ProxyProvider2<ApiClient, StorageService, DeviceService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? DeviceService(apiClient, storage),
        ),
        ProxyProvider<ApiClient, SosService>(
          update: (context, apiClient, previous) =>
              previous ?? SosService(apiClient),
        ),
        ProxyProvider2<ApiClient, StorageService, VoiceService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? VoiceService(apiClient, storage),
        ),
        ProxyProvider2<ApiClient, StorageService, CaregiverService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? CaregiverService(apiClient, storage),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AvatarService()),
      ],
      child: const VitalGuardApp(),
    ),
  );
}
