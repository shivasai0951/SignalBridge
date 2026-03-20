import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"}
    ]
  };

  Future<void> init() async {
    peerConnection = await createPeerConnection(configuration);

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    for (var track in localStream!.getTracks()) {
      peerConnection!.addTrack(track, localStream!);
    }

    peerConnection!.onIceCandidate = (candidate) {
      print("ICE CANDIDATE: ${candidate.candidate}");
    };

    peerConnection!.onTrack = (event) {
      print("Remote track received");
    };
  }

  /// Caller creates offer
  Future<String> createOffer() async {
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    return offer.sdp!;
  }

  /// Receiver handles offer and creates answer
  Future<String> createAnswer(String offerSDP) async {
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(offerSDP, "offer"),
    );

    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    return answer.sdp!;
  }

  /// Caller receives answer
  Future<void> setAnswer(String answerSDP) async {
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(answerSDP, "answer"),
    );
  }
}