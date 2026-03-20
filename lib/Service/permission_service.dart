import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<bool> requestCallPermissions() async {

    PermissionStatus mic = await Permission.microphone.request();
    PermissionStatus cam = await Permission.camera.request();

    if (mic.isGranted && cam.isGranted) {
      return true;
    } else {
      return false;
    }

  }

}