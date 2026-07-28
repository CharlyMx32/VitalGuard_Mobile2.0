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
        ChangeNotifierProxyProvider2<ApiClient, StorageService, PatientService>(
          create: (context) =>
              PatientService(context.read<ApiClient>(), context.read<StorageService>()),
          update: (context, apiClient, storage, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, StorageService, TreatmentService>(
          create: (context) =>
              TreatmentService(context.read<ApiClient>(), context.read<StorageService>()),
          update: (context, apiClient, storage, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, StorageService, DeviceService>(
          create: (context) =>
              DeviceService(context.read<ApiClient>(), context.read<StorageService>()),
          update: (context, apiClient, storage, previous) => previous!,
        ),
        ChangeNotifierProxyProvider<ApiClient, SosService>(
          create: (context) => SosService(context.read<ApiClient>()),
          update: (context, apiClient, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, StorageService, VoiceService>(
          create: (context) =>
              VoiceService(context.read<ApiClient>(), context.read<StorageService>()),
          update: (context, apiClient, storage, previous) => previous!,
        ),
        ChangeNotifierProxyProvider2<ApiClient, StorageService, CaregiverService>(
          create: (context) =>
              CaregiverService(context.read<ApiClient>(), context.read<StorageService>()),
          update: (context, apiClient, storage, previous) => previous!,
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const VitalGuardApp(),
    ),
  );
}
