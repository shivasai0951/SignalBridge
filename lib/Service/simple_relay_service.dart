import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../Screens/incoming_call_screen.dart';
import '../models/call_log_model.dart';
import '../database/call_log_db.dart';

class SimpleRelayService {
  static final SimpleRelayService instance = SimpleRelayService();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  BuildContext? _context;
  String? _myUserId;
  bool _isCallActive = false;
  String? _currentCallerId;
  Timer? _pollingTimer;

  // Free public API for temporary data storage (JSONBin.io alternative)
  // Using a simple GitHub Gist as relay (you can replace with any free API)
  static const String relayUrl = 'https://api.jsonbin.io/v3/b';
  static const String apiKey = '\$2a\$10\$your_free_api_key_here'; // Get free at jsonbin.io

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ]
  };

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> init(String userId) async {
    _myUserId = userId;
    _startPollingForCalls();
  }

  void _startPollingForCalls() {
    // Poll every 3 seconds for incoming calls
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_isCallActive) {
        await _checkForIncomingCalls();
      }
    });
  }

  Future<void> _checkForIncomingCalls() async {
    try {
      // Check for offers addressed to this user
      final response = await http.get(
        Uri.parse('$relayUrl/call_$_myUserId'),
        headers: {'X-Master-Key': apiKey},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final record = data['record'];
        
        if (record != null && record['type'] == 'offer') {
          final callerId = record['from'];
          final offer = record['offer'];
          
          _currentCallerId = callerId;
          
          print('📞 Incoming call from $callerId');
          
          await _createPeerConnection();
          await _getUserMedia(false);
          
          await _peerConnection!.setRemoteDescription(
            RTCSessionDescription(offer, 'offer'),
          );
          
          // Delete the offer after reading
          await http.delete(
            Uri.parse('$relayUrl/call_$_myUserId'),
            headers: {'X-Master-Key': apiKey},
          );
          
          if (_context != null && _context!.mounted) {
            Navigator.push(
              _context!,
              MaterialPageRoute(
                builder: (_) => IncomingCallScreen(callerId: callerId),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Silently ignore polling errors
    }
  }

  Future<void> callUser(String targetId, {bool isVideo = false}) async {
    try {
      _isCallActive = true;
      
      await _createPeerConnection();
      await _getUserMedia(isVideo);

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer to relay server
      await http.post(
        Uri.parse(relayUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': apiKey,
          'X-Bin-Name': 'call_$targetId',
        },
        body: jsonEncode({
          'type': 'offer',
          'from': _myUserId,
          'to': targetId,
          'offer': offer.sdp,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      await _saveCallLog(targetId, 'outgoing', isVideo ? 'video' : 'audio');

      print('📞 Calling $targetId... Waiting for answer...');
      
      // Start polling for answer
      _pollForAnswer(targetId);
    } catch (e) {
      print('❌ Error calling user: $e');
      _isCallActive = false;
      rethrow;
    }
  }

  Future<void> _pollForAnswer(String targetId) async {
    int attempts = 0;
    while (attempts < 20 && _isCallActive) {
      await Future.delayed(const Duration(seconds: 3));
      
      try {
        final response = await http.get(
          Uri.parse('$relayUrl/answer_$_myUserId'),
          headers: {'X-Master-Key': apiKey},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final record = data['record'];
          
          if (record != null && record['type'] == 'answer') {
            final answer = record['answer'];
            
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(answer, 'answer'),
            );
            
            // Delete answer after reading
            await http.delete(
              Uri.parse('$relayUrl/answer_$_myUserId'),
              headers: {'X-Master-Key': apiKey},
            );
            
            print('✅ Call connected');
            return;
          }
        }
      } catch (e) {
        // Continue polling
      }
      
      attempts++;
    }
  }

  Future<void> acceptCall() async {
    try {
      if (_currentCallerId == null) return;

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer to relay server
      await http.post(
        Uri.parse(relayUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': apiKey,
          'X-Bin-Name': 'answer_$_currentCallerId',
        },
        body: jsonEncode({
          'type': 'answer',
          'from': _myUserId,
          'to': _currentCallerId,
          'answer': answer.sdp,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      _isCallActive = true;
      
      await _saveCallLog(_currentCallerId!, 'incoming', 'audio');
      
      print('✅ Call accepted');
    } catch (e) {
      print('❌ Error accepting call: $e');
      rethrow;
    }
  }

  Future<void> rejectCall() async {
    _currentCallerId = null;
    await _cleanup();
  }

  Future<void> endCall() async {
    await _cleanup();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print('🧊 ICE Candidate: ${candidate.candidate}');
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      print('🎵 Remote track received');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('✅ Call connected successfully!');
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

  void dispose() {
    _pollingTimer?.cancel();
    _cleanup();
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isCallActive => _isCallActive;
  String? get currentCallerId => _currentCallerId;
}
