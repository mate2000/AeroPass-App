import 'package:aeropass_app/data/services/system_settings_launcher.dart';

/// Records calls instead of invoking a real platform channel.
class FakeSystemSettingsLauncher implements SystemSettingsLauncher {
  int openCallCount = 0;

  @override
  Future<void> open() async {
    openCallCount++;
  }
}
