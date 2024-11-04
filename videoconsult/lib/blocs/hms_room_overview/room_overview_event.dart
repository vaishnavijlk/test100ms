import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

/// Events for 100ms room state manangement.
abstract class RoomOverviewEvent extends Equatable {
  const RoomOverviewEvent();

  @override
  List<Object> get props => [];
}

class RoomOverviewSubscriptionRequested extends RoomOverviewEvent {
  const RoomOverviewSubscriptionRequested();
}

class RoomOverviewLocalPeerVideoToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerVideoToggled();
}

class RoomOverviewLocalPeerScreenshareToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerScreenshareToggled();
}

class RoomOverviewLocalPeerAudioToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerAudioToggled();
}

class RoomOverviewLocalPeerMicToggled extends RoomOverviewEvent {
  const RoomOverviewLocalPeerMicToggled();
}

class RoomOverviewLocalPeerCameraSwitchRequested extends RoomOverviewEvent {
  const RoomOverviewLocalPeerCameraSwitchRequested();
}

class RoomOverviewLocalPeerAudioSwitchIOSRequested extends RoomOverviewEvent {
  const RoomOverviewLocalPeerAudioSwitchIOSRequested();
}

class RoomOverviewLocalPeerAudioSwitchAndriodRequested
    extends RoomOverviewEvent {
  final HMSAudioDevice audioDevice;
  const RoomOverviewLocalPeerAudioSwitchAndriodRequested(this.audioDevice);
}

class RoomOverviewJoinRequested extends RoomOverviewEvent {
  final String userName;
  final String authToken;
  const RoomOverviewJoinRequested(this.userName, this.authToken);
}

class RoomOverviewLeaveRequested extends RoomOverviewEvent {
  const RoomOverviewLeaveRequested();
}

class RoomOverviewSetOffScreen extends RoomOverviewEvent {
  final int index;
  final bool setOffScreen;
  const RoomOverviewSetOffScreen(this.setOffScreen, this.index);
}

class RoomOverviewOnJoinSuccess extends RoomOverviewEvent {
  final HMSRoom hmsRoom;
  const RoomOverviewOnJoinSuccess(this.hmsRoom);
}

class RoomOverviewOnPeerLeave extends RoomOverviewEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack hmsVideoTrack;
  const RoomOverviewOnPeerLeave(this.hmsVideoTrack, this.hmsPeer);
}

class RoomOverviewOnPeerJoin extends RoomOverviewEvent {
  final HMSPeer hmsPeer;
  final HMSVideoTrack hmsVideoTrack;
  const RoomOverviewOnPeerJoin(this.hmsVideoTrack, this.hmsPeer);
}
