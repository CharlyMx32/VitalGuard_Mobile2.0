import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
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
import 'services/medication_service.dart';
import 'services/notification_service.dart';
import 'services/notification_initializer.dart';
import 'services/fcm_service.dart';
import 'services/realtime_service.dart';
import 'services/onboarding_service.dart';
import 'services/patient_current_service.dart';
import 'services/invitation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationInitializer.initialize();
  await FcmService.initialize();
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
        ChangeNotifierProvider(create: (_) => PatientCurrentService()),
        Provider(create: (_) => StorageService()),
        ProxyProvider<AuthService, ApiClient>(
          create: (context) => ApiClient(context.read<AuthService>()),
          update: (context, auth, previous) => previous ?? ApiClient(auth),
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
        ProxyProvider2<ApiClient, StorageService, MedicationService>(
          update: (context, apiClient, storage, previous) =>
              previous ?? MedicationService(apiClient, storage),
        ),
        ChangeNotifierProxyProvider<ApiClient, NotificationService>(
          create: (context) => NotificationService(context.read<ApiClient>()),
          update: (context, apiClient, previous) =>
              previous ?? NotificationService(apiClient),
        ),
        ProxyProvider<ApiClient, OnboardingService>(
          update: (context, apiClient, previous) =>
              previous ?? OnboardingService(apiClient),
        ),
        ChangeNotifierProxyProvider2<ApiClient, NotificationService, FcmService>(
          create: (context) => FcmService(
            context.read<ApiClient>(),
            context.read<NotificationService>(),
          ),
          update: (context, apiClient, notificationService, previous) =>
              previous ?? FcmService(apiClient, notificationService),
        ),
        ChangeNotifierProxyProvider2<AuthService, NotificationService, RealtimeService>(
          create: (context) => RealtimeService(
            context.read<AuthService>(),
            context.read<NotificationService>(),
          ),
          update: (context, auth, notif, previous) =>
              previous ?? RealtimeService(auth, notif),
        ),
        ProxyProvider<ApiClient, InvitationService>(
          update: (context, apiClient, previous) =>
              previous ?? InvitationService(apiClient),
        ),
      ],
      child: const VitalGuardApp(),
    ),
  );
}
