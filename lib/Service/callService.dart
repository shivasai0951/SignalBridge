import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import '../Screens/incoming_call_screen.dart';

class CallService {
  static final CallService instance = CallService();

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> init(int sdkAppId, String userId, String userSig) async {
    await TUICallEngine.instance.init(sdkAppId, userId, userSig);

    TUICallEngine.instance.addObserver(
      TUICallObserver(
        onCallReceived: (
          String callerId,
          List<String> calleeIdList,
          String groupId,
          TUICallMediaType callMediaType,
          String? userData,
        ) {
          print("📞 Incoming call from $callerId");
          _handleIncomingCall(callerId);
        },
        onCallBegin: (
          TUIRoomId roomId,
          TUICallMediaType callMediaType,
          TUICallRole callRole,
        ) {
          print("✅ Call connected - Room: ${roomId.intRoomId}");
        },
        onCallEnd: (
          TUIRoomId roomId,
          TUICallMediaType callMediaType,
          TUICallRole callRole,
          double totalTime,
        ) {
          print("📴 Call ended - Duration: ${totalTime}s");
        },
        onCallCancelled: (String callerId) {
          print("❌ Call cancelled by $callerId");
        },
        onUserReject: (String userId) {
          print("🚫 User $userId rejected the call");
        },
        onUserNoResponse: (String userId) {
          print("⏰ User $userId did not respond");
        },
        onUserLineBusy: (String userId) {
          print("📵 User $userId is busy");
        },
        onUserJoin: (String userId) {
          print("👤 User $userId joined the call");
        },
        onUserLeave: (String userId) {
          print("👋 User $userId left the call");
        },
        onError: (int code, String message) {
          print("❗ Call error: $code - $message");
        },
      ),
    );
  }

  void _handleIncomingCall(String callerId) {
    if (_context != null && _context!.mounted) {
      Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(callerId: callerId),
        ),
      );
    }
  }

  Future<void> callUser(String targetId, {bool isVideo = false}) async {
    await TUICallEngine.instance.call(
      targetId,
      isVideo ? TUICallMediaType.video : TUICallMediaType.audio,
      TUICallParams(),
    );
  }

  Future<void> acceptCall() async {
    await TUICallEngine.instance.accept();
  }

  Future<void> rejectCall() async {
    await TUICallEngine.instance.reject();
  }

  Future<void> endCall() async {
    await TUICallEngine.instance.hangup();
  }
}
