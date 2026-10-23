import 'package:shared_preferences/shared_preferences.dart';

class DeveloperModePreferences {
  DeveloperModePreferences._();

  static const _enabledKey = 'developer_mode_enabled';

  static Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? false;
  }

  static Future<void> enable() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, true);
  }

  static Future<void> disable() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_enabledKey);
  }
}
