import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/**
 * Class to track each peer in a 100ms room.
 */
class PeerTrackNode extends Equatable {
  final HMSVideoTrack? hmsVideoTrack;
  final HMSPeer? peer;
  final bool isOffScreen;

  const PeerTrackNode(this.hmsVideoTrack, this.peer, this.isOffScreen);

  // 100ms did not override hmsPeer, hmsVideoTrack equals operator.
  // This causes flutter to think the hmsPeer or hmsVideoTrack is unchanged even though the fields are different.
  // Hence we include all the fields here so that equatable correctly detects the 2 objects have changed.
  @override
  List<Object?> get props => [
        hmsVideoTrack,
        peer,
        isOffScreen,
        hmsVideoTrack?.isDegraded,
        hmsVideoTrack?.kind,
        hmsVideoTrack?.source,
        hmsVideoTrack?.trackId,
        hmsVideoTrack?.trackDescription,
        hmsVideoTrack?.isMute,
        peer?.audioTrack,
        peer?.audioTrack?.kind,
        peer?.audioTrack?.source,
        peer?.audioTrack?.trackDescription,
        peer?.audioTrack?.trackId,
        peer?.audioTrack?.isMute,
      ];

  PeerTrackNode copyWith({
    HMSVideoTrack? hmsVideoTrack,
    HMSPeer? peer,
    bool? isOffScreen,
  }) {
    return PeerTrackNode(
      hmsVideoTrack ?? this.hmsVideoTrack,
      peer ?? this.peer,
      isOffScreen ?? this.isOffScreen,
    );
  }
}
