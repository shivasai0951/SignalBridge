import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class IdService {

  static Future<String> getOrCreateUserId() async {

    final prefs = await SharedPreferences.getInstance();

    String? savedId = prefs.getString("user_id");

    if (savedId != null) {
      return savedId;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? "";
    }

    final random = Random(deviceId.hashCode);
    String newId = (10000000 + random.nextInt(90000000)).toString();

    await prefs.setString("user_id", newId);

    return newId;
  }
}