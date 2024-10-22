import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_state.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';
import 'package:videoconsult/observers/hms_room_observer.dart';

/// Bloc for 100ms room state management.
class RoomOverviewBloc extends Bloc<RoomOverviewEvent, RoomOverviewState> {
  late HmsRoomObserver roomObserver;

  RoomOverviewBloc(bool isCameraMute, bool isMicMute, bool isAudioMute,
      bool isScreenShareActive)
      : super(RoomOverviewState(
            isMicMute: isMicMute,
            isCameraMute: isCameraMute,
            isAudioMute: isAudioMute,
            isScreenShareActive: isScreenShareActive)) {
    roomObserver = HmsRoomObserver(this);
    on<RoomOverviewSubscriptionRequested>(_onSubscription);
    on<RoomOverviewLocalPeerAudioToggled>(_onLocalAudioToggled);
    on<RoomOverviewLocalPeerMicToggled>(_onLocalMicToggled);
    on<RoomOverviewLocalPeerVideoToggled>(_onLocalVideoToggled);
    on<RoomOverviewLocalPeerCameraSwitchRequested>(_onLocalCameraSwitch);
    on<RoomOverviewLocalPeerAudioSwitchIOSRequested>(_onLocalAudioSwitchIOS);
    on<RoomOverviewLocalPeerAudioSwitchAndriodRequested>(
        _onLocalAudioSwitchAndriod);
    on<RoomOverviewLocalPeerScreenshareToggled>(_onScreenShareToggled);
    on<RoomOverviewOnJoinSuccess>(_onJoinSuccess);
    on<RoomOverviewJoinRequested>(_joinRequested);
    on<RoomOverviewLeaveRequested>(_leaveRequested);
    on<RoomOverviewSetOffScreen>(_setOffScreen);
  }

  Future<void> _onSubscription(RoomOverviewSubscriptionRequested event,
      Emitter<RoomOverviewState> emit) async {
    await Future.wait([
      emit.forEach<List<PeerTrackNode>>(
        roomObserver.getTracks(),
        onData: (tracks) {
          return state.copyWith(
              status: RoomOverviewStatus.success, peerTrackNodes: tracks);
        },
        onError: (_, __) => state.copyWith(
          status: RoomOverviewStatus.failure,
        ),
      ),
      emit.forEach<List<HMSAudioDevice>>(
        roomObserver.getAudioDevices(),
        onData: (audioDevices) {
          return state.copyWith(
              status: RoomOverviewStatus.success, audioDevices: audioDevices);
        },
        onError: (_, __) => state.copyWith(
          status: RoomOverviewStatus.failure,
        ),
      ),
      emit.forEach<HMSAudioDevice>(
        roomObserver.getCurrentAudioDevice(),
        onData: (currentAudioDevice) {
          return state.copyWith(
              status: RoomOverviewStatus.success,
              currentAudioDevice: currentAudioDevice);
        },
        onError: (_, __) => state.copyWith(
          status: RoomOverviewStatus.failure,
        ),
      )
    ]);
  }

  Future<void> _onLocalVideoToggled(RoomOverviewLocalPeerVideoToggled event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.toggleCameraMuteState();
    emit(state.copyWith(isCameraMute: !state.isCameraMute));
  }

  Future<void> _onLocalCameraSwitch(
      RoomOverviewLocalPeerCameraSwitchRequested event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.switchCamera();
  }

  Future<void> _onLocalAudioSwitchIOS(
      RoomOverviewLocalPeerAudioSwitchIOSRequested event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.switchAudioOutputUsingiOSUI();
  }

  Future<void> _onLocalAudioSwitchAndriod(
      RoomOverviewLocalPeerAudioSwitchAndriodRequested event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.switchAudioOutputUsingAndriod(event.audioDevice);
  }

  void _onScreenShareToggled(RoomOverviewLocalPeerScreenshareToggled event,
      Emitter<RoomOverviewState> emit) async {
    if (!state.isScreenShareActive) {
      roomObserver.startScreenShare();
    } else {
      roomObserver.stopScreenShare();
    }
    emit(state.copyWith(isScreenShareActive: !state.isScreenShareActive));
  }

  Future<void> _onLocalMicToggled(RoomOverviewLocalPeerMicToggled event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.toggleMicMuteState();
    emit(state.copyWith(isMicMute: !state.isMicMute));
  }

  Future<void> _onLocalAudioToggled(RoomOverviewLocalPeerAudioToggled event,
      Emitter<RoomOverviewState> emit) async {
    roomObserver.toggleAudioMuteState();
    emit(state.copyWith(isAudioMute: !state.isAudioMute));
  }

  Future<void> _onJoinSuccess(
      RoomOverviewOnJoinSuccess event, Emitter<RoomOverviewState> emit) async {
    if (state.isMicMute) {
      await roomObserver.toggleMicMuteState();
    }

    if (state.isCameraMute) {
      await roomObserver.toggleCameraMuteState();
    }
  }

  Future<void> _joinRequested(
      RoomOverviewJoinRequested event, Emitter<RoomOverviewState> emit) async {
    roomObserver.joinMeeting(event.authToken, event.userName);
  }

  Future<void> _leaveRequested(
      RoomOverviewLeaveRequested event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.leaveMeeting();
    emit(state.copyWith(leaveMeeting: true));
  }

  Future<void> _setOffScreen(
      RoomOverviewSetOffScreen event, Emitter<RoomOverviewState> emit) async {
    await roomObserver.setOffScreen(event.index, event.setOffScreen);
  }
}
