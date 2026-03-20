import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class UserSigService {
  static String generateUserSig({
    required int sdkAppId,
    required String userId,
    required String secretKey,
    int expireTime = 604800,
  }) {
    int currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String sig = _hmacSha256(
      identifier: userId,
      currTime: currTime,
      expire: expireTime,
      base64UserBuf: '',
      sdkAppId: sdkAppId,
      secretKey: secretKey,
    );

    Map<String, dynamic> userSig = {
      'TLS.ver': '2.0',
      'TLS.identifier': userId,
      'TLS.sdkappid': sdkAppId,
      'TLS.expire': expireTime,
      'TLS.time': currTime,
      'TLS.sig': sig,
    };

    String jsonUserSig = jsonEncode(userSig);
    return _base64UrlEncode(utf8.encode(jsonUserSig));
  }

  static String _hmacSha256({
    required String identifier,
    required int currTime,
    required int expire,
    required String base64UserBuf,
    required int sdkAppId,
    required String secretKey,
  }) {
    String contentToBeSigned =
        'TLS.identifier:$identifier\n'
        'TLS.sdkappid:$sdkAppId\n'
        'TLS.time:$currTime\n'
        'TLS.expire:$expire\n';

    if (base64UserBuf.isNotEmpty) {
      contentToBeSigned += 'TLS.userbuf:$base64UserBuf\n';
    }

    var key = utf8.encode(secretKey);
    var bytes = utf8.encode(contentToBeSigned);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);

    return base64Encode(digest.bytes);
  }

  static String _base64UrlEncode(List<int> data) {
    String base64 = base64Encode(data);
    return base64
        .replaceAll('+', '*')
        .replaceAll('/', '-')
        .replaceAll('=', '_');
  }
}
