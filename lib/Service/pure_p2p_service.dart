import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screens/incoming_call_screen.dart';
import '../models/call_log_model.dart';
import '../database/call_log_db.dart';

class PureP2PService {
  static final PureP2PService instance = PureP2PService();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  BuildContext? _context;
  String? _myUserId;
  bool _isCallActive = false;
  String? _currentCallerId;
  String? _pendingOffer;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ]
  };

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> init(String userId) async {
    _myUserId = userId;
    _startListeningForOffers();
  }

  void _startListeningForOffers() async {
    final prefs = await SharedPreferences.getInstance();
    
    Stream.periodic(const Duration(seconds: 2)).listen((_) async {
      if (_isCallActive) return;
      
      final offerData = prefs.getString('incoming_offer_$_myUserId');
      if (offerData != null && offerData != _pendingOffer) {
        _pendingOffer = offerData;
        final data = jsonDecode(offerData);
        final callerId = data['callerId'] as String;
        final offer = data['offer'] as String;
        
        print("📞 Incoming call from $callerId");
        _handleIncomingCall(callerId, offer);
        
        await prefs.remove('incoming_offer_$_myUserId');
      }
    });
  }

  void _handleIncomingCall(String callerId, String offer) {
    _currentCallerId = callerId;
    if (_context != null && _context!.mounted) {
      Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(callerId: callerId),
        ),
      );
    }
  }

  Future<Map<String, String>> callUser(String targetId, {bool isVideo = false}) async {
    try {
      _isCallActive = true;
      
      await _createPeerConnection();
      await _getUserMedia(isVideo);

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await _saveCallLog(targetId, 'outgoing', isVideo ? 'video' : 'audio');

      print("📞 Calling $targetId...");
      
      return {
        'callerId': _myUserId!,
        'offer': offer.sdp!,
        'targetId': targetId,
      };
    } catch (e) {
      print("❌ Error calling user: $e");
      _isCallActive = false;
      rethrow;
    }
  }

  Future<void> sendOfferToContact(String targetId, Map<String, String> offerData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('incoming_offer_$targetId', jsonEncode(offerData));
  }

  Future<Map<String, String>> acceptCall() async {
    try {
      if (_pendingOffer == null) return {};

      await _createPeerConnection();
      await _getUserMedia(false);

      final data = jsonDecode(_pendingOffer!);
      final offerSdp = data['offer'] as String;
      _currentCallerId = data['callerId'] as String;

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offerSdp, 'offer'),
      );

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _isCallActive = true;
      
      await _saveCallLog(_currentCallerId!, 'incoming', 'audio');
      
      print("✅ Call accepted");
      
      return {
        'answer': answer.sdp!,
        'callerId': _myUserId!,
      };
    } catch (e) {
      print("❌ Error accepting call: $e");
      rethrow;
    }
  }

  Future<void> receiveAnswer(String answerSdp) async {
    try {
      if (_peerConnection != null) {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(answerSdp, 'answer'),
        );
        print("✅ Answer received, call connected");
      }
    } catch (e) {
      print("❌ Error receiving answer: $e");
    }
  }

  Future<void> rejectCall() async {
    _pendingOffer = null;
    _currentCallerId = null;
    await _cleanup();
  }

  Future<void> endCall() async {
    await _cleanup();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print("🧊 ICE Candidate: ${candidate.candidate}");
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      print("🎵 Remote track received");
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print("🔗 Connection state: $state");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print("✅ Call connected successfully!");
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _cleanup();
      }
    };
  }

  Future<void> _getUserMedia(bool isVideo) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
              'facingMode': 'user',
            }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  Future<void> _saveCallLog(String contactId, String type, String callType) async {
    final callLog = CallLogModel(
      contactId: contactId,
      callType: type,
      mediaType: callType,
      timestamp: DateTime.now(),
      duration: 0,
    );
    await CallLogDB().insertCallLog(callLog);
  }

  Future<void> _cleanup() async {
    _isCallActive = false;
    _currentCallerId = null;
    
    await _localStream?.dispose();
    _localStream = null;

    await _remoteStream?.dispose();
    _remoteStream = null;

    await _peerConnection?.close();
    _peerConnection = null;
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isCallActive => _isCallActive;
  String? get currentCallerId => _currentCallerId;
}
