import 'package:flutter/material.dart';
import '../theme/app_transitions.dart';

// ── Onboarding ──
import '../screens/onboarding/splash_screen.dart';
import '../screens/onboarding/onboarding_flow_screen.dart';

// ── Auth ──
import '../screens/auth/vital_id_login_screen.dart';
import '../screens/auth/vital_id_register_screen.dart';
import '../screens/auth/vital_id_otp_screen.dart';
import '../screens/auth/vital_id_forgot_screen.dart';
import '../screens/auth/vital_id_reset_screen.dart';
import '../screens/auth/vital_id_security_screen.dart';
import '../screens/auth/login_screen.dart';

// ── Profile ──
import '../screens/profile/complete_profile_screen.dart';
import '../screens/profile/first_patient_screen.dart';
import '../screens/profile/self_care_profile_screen.dart';

// ── Setup ──
import '../screens/setup/link_device_screen.dart';
import '../screens/setup/wifi_setup_screen.dart';
import '../screens/setup/register_patient_screen.dart';
import '../screens/setup/send_requests_screen.dart';

// ── Main Shell ──
import '../screens/main_shell.dart';

// ── Dashboard (content-only, used in sub-navigation) ──
import '../screens/dashboard/patient_list_screen.dart';
import '../screens/dashboard/patient_detail_screen.dart';
import '../screens/dashboard/edit_patient_screen.dart';

// ── Treatments (content-only, used in sub-navigation) ──
import '../screens/treatments/treatment_detail_screen.dart';
import '../screens/treatments/add_medication_screen.dart';
import '../screens/treatments/configure_dispenser_screen.dart';
import '../screens/treatments/history_screen.dart';
import '../screens/treatments/notifications_screen.dart';
import '../screens/treatments/schedule_config_screen.dart';
import '../screens/treatments/schedule_screen.dart';

// ── Utilities ──
import '../screens/utilities/voice_messages_screen.dart';
import '../screens/utilities/sos_emergency_screen.dart';
import '../screens/utilities/self_care_screen.dart';
import '../screens/utilities/my_profile_screen.dart';

// ── Settings (sub-screens only) ──
import '../screens/settings/my_vitalguard_screen.dart';
import '../screens/settings/notifications_config_screen.dart';
import '../screens/settings/voice_assistant_screen.dart';
import '../screens/settings/sos_config_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/family_members_screen.dart';
import '../screens/settings/security_settings_screen.dart';

// ── SOS ──
import '../screens/sos/sos_alarm_screen.dart';

// ── Errors ──
import '../screens/errors/error_network_screen.dart';
import '../screens/errors/error_server_screen.dart';
import '../screens/errors/error_auth_screen.dart';
import '../screens/errors/error_device_screen.dart';
import '../screens/errors/error_treatment_screen.dart';
import '../screens/errors/error_generic_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String onboarding1 = '/onboarding/1';

  static const String vitalIdLogin = '/vital-id/login';
  static const String vitalIdRegister = '/vital-id/register';
  static const String vitalIdOtp = '/vital-id/otp';
  static const String vitalIdForgot = '/vital-id/forgot';
  static const String vitalIdReset = '/vital-id/reset';
  static const String vitalIdSecurity = '/vital-id/security';
  static const String login = '/login';

  static const String completeProfile = '/profile/complete';
  static const String firstPatient = '/profile/first-patient';
  static const String selfCareProfile = '/profile/self-care';

  static const String linkDevice = '/setup/link-device';
  static const String wifiSetup = '/setup/wifi';
  static const String registerPatient = '/setup/register-patient';
  static const String sendRequests = '/setup/send-requests';

  static const String dashboard = '/dashboard';
  static const String patientList = '/patients';
  static const String patientDetail = '/patients/detail';
  static const String editPatient = '/patients/edit';

  static const String medications = '/medications';
  static const String treatmentDetail = '/medications/detail';
  static const String addMedication = '/medications/add';
  static const String configureDispenser = '/medications/dispenser';
  static const String history = '/medications/history';
  static const String notifications = '/medications/notifications';
  static const String scheduleConfig = '/medications/schedule';
  static const String schedule = '/schedule';

  static const String voiceMessages = '/utilities/voice';
  static const String sosEmergency = '/utilities/sos';
  static const String selfCare = '/utilities/self-care';
  static const String myProfile = '/utilities/profile';

  static const String settings = '/settings';
  static const String myVitalGuard = '/settings/my-vitalguard';
  static const String notificationsConfig = '/settings/notifications';
  static const String voiceAssistant = '/settings/voice-assistant';
  static const String sosConfig = '/settings/sos';
  static const String helpSupport = '/settings/help';
  static const String familyMembers = '/settings/family';
  static const String securitySettings = '/settings/security';

  static const String sosAlarm = '/sos/alarm';

  static const String errorNetwork = '/errors/network';
  static const String errorServer = '/errors/server';
  static const String errorAuth = '/errors/auth';
  static const String errorDevice = '/errors/device';
  static const String errorTreatment = '/errors/treatment';
  static const String errorGeneric = '/errors/generic';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    Widget page;
    switch (routeSettings.name) {
      case splash: page = const SplashScreen(); break;
      case onboarding:
      case onboarding1: page = const OnboardingFlowScreen(); break;
      case vitalIdLogin: page = const VitalIdLoginScreen(); break;
      case vitalIdRegister: page = const VitalIdRegisterScreen(); break;
      case vitalIdOtp: page = const VitalIdOtpScreen(); break;
      case vitalIdForgot: page = const VitalIdForgotScreen(); break;
      case vitalIdReset: page = const VitalIdResetScreen(); break;
      case vitalIdSecurity: page = const VitalIdSecurityScreen(); break;
      case login: page = const LoginScreen(); break;
      case completeProfile: page = const CompleteProfileScreen(); break;
      case firstPatient: page = const FirstPatientScreen(); break;
      case selfCareProfile: page = const SelfCareProfileScreen(); break;
      case linkDevice: page = const LinkDeviceScreen(); break;
      case wifiSetup: page = const WifiSetupScreen(); break;
      case registerPatient: page = const RegisterPatientScreen(); break;
      case sendRequests: page = const SendRequestsScreen(); break;
      case dashboard:
      case medications:
      case settings: page = const MainShell(); break;
      case patientList: page = const PatientListScreen(); break;
      case patientDetail: page = const PatientDetailScreen(); break;
      case editPatient: page = const EditPatientScreen(); break;
      case treatmentDetail: page = const TreatmentDetailScreen(); break;
      case addMedication: page = const AddMedicationScreen(); break;
      case configureDispenser: page = const ConfigureDispenserScreen(); break;
      case history: page = const HistoryScreen(); break;
      case notifications: page = const NotificationsScreen(); break;
      case scheduleConfig: page = const ScheduleConfigScreen(); break;
      case schedule: page = const ScheduleScreen(); break;
      case voiceMessages: page = const VoiceMessagesScreen(); break;
      case sosEmergency: page = const SosEmergencyScreen(); break;
      case selfCare: page = const SelfCareScreen(); break;
      case myProfile: page = const MyProfileScreen(); break;
      case myVitalGuard: page = const MyVitalGuardScreen(); break;
      case notificationsConfig: page = const NotificationsConfigScreen(); break;
      case voiceAssistant: page = const VoiceAssistantScreen(); break;
      case sosConfig: page = const SosConfigScreen(); break;
      case helpSupport: page = const HelpSupportScreen(); break;
      case familyMembers: page = const FamilyMembersScreen(); break;
      case securitySettings: page = const SecuritySettingsScreen(); break;
      case sosAlarm: page = const SosAlarmScreen(); break;
      case errorNetwork: page = const ErrorNetworkScreen(); break;
      case errorServer: page = const ErrorServerScreen(); break;
      case errorAuth: page = const ErrorAuthScreen(); break;
      case errorDevice: page = const ErrorDeviceScreen(); break;
      case errorTreatment: page = const ErrorTreatmentScreen(); break;
      case errorGeneric: page = const ErrorGenericScreen(); break;
      default: page = const ErrorGenericScreen(); break;
    }

    final name = routeSettings.name ?? '';
    if (name == sosAlarm || name.startsWith('/errors/')) {
      return AppTransitions.scale(routeSettings, (_) => page);
    }
    if (name.startsWith('/settings/') || name.startsWith('/utilities/')) {
      return AppTransitions.fade(routeSettings, (_) => page);
    }
    if (name.startsWith('/patients/') || name.startsWith('/medications/') || name.startsWith('/profile/') || name.startsWith('/setup/')) {
      return AppTransitions.slideRight(routeSettings, (_) => page);
    }
    return AppTransitions.slideUp(routeSettings, (_) => page);
  }
}
