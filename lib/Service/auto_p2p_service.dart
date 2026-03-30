import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Screens/incoming_call_screen.dart';
import '../models/call_log_model.dart';
import '../database/call_log_db.dart';

class AutoP2PService {
  static final AutoP2PService instance = AutoP2PService();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  BuildContext? _context;
  String? _myUserId;
  bool _isCallActive = false;
  String? _currentCallerId;
  
  WebSocketChannel? _wsChannel;
  bool _isConnected = false;

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
    _connectToSignalingServer();
  }

  void _connectToSignalingServer() {
    try {
      // Using a free public WebSocket echo server for signaling
      // In production, you'd use your own simple signaling server
      _wsChannel = WebSocketChannel.connect(
        Uri.parse('wss://echo.websocket.org'),
      );

      _wsChannel!.stream.listen(
        (message) {
          _handleSignalingMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          print('🔌 WebSocket disconnected');
          _reconnect();
        },
      );

      _isConnected = true;
      print('✅ Connected to signaling server');

      // Register user ID
      _sendSignalingMessage({
        'type': 'register',
        'userId': _myUserId,
      });
    } catch (e) {
      print('❌ Failed to connect to signaling server: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _connectToSignalingServer();
      }
    });
  }

  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_wsChannel != null && _isConnected) {
      _wsChannel!.sink.add(jsonEncode(message));
    }
  }

  void _handleSignalingMessage(dynamic message) async {
    try {
      final data = jsonDecode(message);
      final type = data['type'];

      switch (type) {
        case 'offer':
          if (!_isCallActive) {
            final callerId = data['from'];
            final offer = data['offer'];
            _currentCallerId = callerId;
            
            print('📞 Incoming call from $callerId');
            
            await _createPeerConnection();
            await _getUserMedia(false);
            
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(offer, 'offer'),
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
          break;

        case 'answer':
          final answer = data['answer'];
          if (_peerConnection != null) {
            await _peerConnection!.setRemoteDescription(
              RTCSessionDescription(answer, 'answer'),
            );
            print('✅ Call connected');
          }
          break;

        case 'ice-candidate':
          final candidate = data['candidate'];
          if (_peerConnection != null && candidate != null) {
            await _peerConnection!.addCandidate(
              RTCIceCandidate(
                candidate['candidate'],
                candidate['sdpMid'],
                candidate['sdpMLineIndex'],
              ),
            );
          }
          break;
      }
    } catch (e) {
      print('❌ Error handling signaling message: $e');
    }
  }

  Future<void> callUser(String targetId, {bool isVideo = false}) async {
    try {
      _isCallActive = true;
      
      await _createPeerConnection();
      await _getUserMedia(isVideo);

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _sendSignalingMessage({
        'type': 'offer',
        'from': _myUserId,
        'to': targetId,
        'offer': offer.sdp,
      });

      await _saveCallLog(targetId, 'outgoing', isVideo ? 'video' : 'audio');

      print('📞 Calling $targetId...');
    } catch (e) {
      print('❌ Error calling user: $e');
      _isCallActive = false;
      rethrow;
    }
  }

  Future<void> acceptCall() async {
    try {
      if (_currentCallerId == null) return;

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _sendSignalingMessage({
        'type': 'answer',
        'from': _myUserId,
        'to': _currentCallerId,
        'answer': answer.sdp,
      });

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
      if (_currentCallerId != null) {
        _sendSignalingMessage({
          'type': 'ice-candidate',
          'from': _myUserId,
          'to': _currentCallerId,
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
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
    _wsChannel?.sink.close();
    _cleanup();
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isCallActive => _isCallActive;
  String? get currentCallerId => _currentCallerId;
}
