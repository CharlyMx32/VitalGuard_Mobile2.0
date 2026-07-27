import 'package:flutter/material.dart';

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

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingFlowScreen(),
    onboarding1: (_) => const OnboardingFlowScreen(),
    vitalIdLogin: (_) => const VitalIdLoginScreen(),
    vitalIdRegister: (_) => const VitalIdRegisterScreen(),
    vitalIdOtp: (_) => const VitalIdOtpScreen(),
    vitalIdForgot: (_) => const VitalIdForgotScreen(),
    vitalIdReset: (_) => const VitalIdResetScreen(),
    vitalIdSecurity: (_) => const VitalIdSecurityScreen(),
    login: (_) => const LoginScreen(),
    completeProfile: (_) => const CompleteProfileScreen(),
    firstPatient: (_) => const FirstPatientScreen(),
    selfCareProfile: (_) => const SelfCareProfileScreen(),
    linkDevice: (_) => const LinkDeviceScreen(),
    wifiSetup: (_) => const WifiSetupScreen(),
    registerPatient: (_) => const RegisterPatientScreen(),
    sendRequests: (_) => const SendRequestsScreen(),
    dashboard: (_) => const MainShell(),
    patientList: (_) => const PatientListScreen(),
    patientDetail: (_) => const PatientDetailScreen(),
    editPatient: (_) => const EditPatientScreen(),
    medications: (_) => const MainShell(), // MainShell with tab 1
    treatmentDetail: (_) => const TreatmentDetailScreen(),
    addMedication: (_) => const AddMedicationScreen(),
    configureDispenser: (_) => const ConfigureDispenserScreen(),
    history: (_) => const HistoryScreen(),
    notifications: (_) => const NotificationsScreen(),
    scheduleConfig: (_) => const ScheduleConfigScreen(),
    schedule: (_) => const ScheduleScreen(),
    voiceMessages: (_) => const VoiceMessagesScreen(),
    sosEmergency: (_) => const SosEmergencyScreen(),
    selfCare: (_) => const SelfCareScreen(),
    myProfile: (_) => const MyProfileScreen(),
    settings: (_) => const MainShell(), // MainShell with tab 2
    myVitalGuard: (_) => const MyVitalGuardScreen(),
    notificationsConfig: (_) => const NotificationsConfigScreen(),
    voiceAssistant: (_) => const VoiceAssistantScreen(),
    sosConfig: (_) => const SosConfigScreen(),
    helpSupport: (_) => const HelpSupportScreen(),
    familyMembers: (_) => const FamilyMembersScreen(),
    securitySettings: (_) => const SecuritySettingsScreen(),
    sosAlarm: (_) => const SosAlarmScreen(),
    errorNetwork: (_) => const ErrorNetworkScreen(),
    errorServer: (_) => const ErrorServerScreen(),
    errorAuth: (_) => const ErrorAuthScreen(),
    errorDevice: (_) => const ErrorDeviceScreen(),
    errorTreatment: (_) => const ErrorTreatmentScreen(),
    errorGeneric: (_) => const ErrorGenericScreen(),
  };
}
