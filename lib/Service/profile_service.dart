import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_name", name);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_name") ?? "User";
  }

  static Future<void> saveImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_image", path);
  }

  static Future<String?> getImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("profile_image");
  }

}