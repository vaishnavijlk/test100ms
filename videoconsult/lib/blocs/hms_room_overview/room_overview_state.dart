import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';

enum RoomOverviewStatus { initial, loading, success, failure }

class RoomOverviewState extends Equatable {
  final RoomOverviewStatus status;
  final List<PeerTrackNode> peerTrackNodes;
  final List<HMSAudioDevice> audioDevices;
  final HMSAudioDevice currentAudioDevice;
  final bool isAudioMute;
  final bool isCameraMute;
  final bool isMicMute;
  final bool leaveMeeting;
  final bool isScreenShareActive;
  const RoomOverviewState(
      {this.status = RoomOverviewStatus.initial,
      this.peerTrackNodes = const [],
      this.audioDevices = const [],
      this.currentAudioDevice = HMSAudioDevice.AUTOMATIC,
      this.isAudioMute = false,
      this.isCameraMute = false,
      this.isMicMute = false,
      this.leaveMeeting = false,
      this.isScreenShareActive = false});

  @override
  List<Object?> get props => [
        status,
        peerTrackNodes,
        identityHashCode(peerTrackNodes),
        audioDevices,
        currentAudioDevice,
        isAudioMute,
        isCameraMute,
        isMicMute,
        leaveMeeting,
        isScreenShareActive
      ];

  RoomOverviewState copyWith(
      {RoomOverviewStatus? status,
      List<PeerTrackNode>? peerTrackNodes,
      List<HMSAudioDevice>? audioDevices,
      HMSAudioDevice? currentAudioDevice,
      bool? isAudioMute,
      bool? isCameraMute,
      bool? isMicMute,
      bool? leaveMeeting,
      bool? isScreenShareActive}) {
    return RoomOverviewState(
        status: status ?? this.status,
        peerTrackNodes: peerTrackNodes ?? this.peerTrackNodes,
        audioDevices: audioDevices ?? this.audioDevices,
        currentAudioDevice: currentAudioDevice ?? this.currentAudioDevice,
        isAudioMute: isAudioMute ?? this.isAudioMute,
        isCameraMute: isCameraMute ?? this.isCameraMute,
        isMicMute: isMicMute ?? this.isMicMute,
        leaveMeeting: leaveMeeting ?? this.leaveMeeting,
        isScreenShareActive: isScreenShareActive ?? this.isScreenShareActive);
  }
}
