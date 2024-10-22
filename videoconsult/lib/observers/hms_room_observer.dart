import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';

class HmsRoomObserver implements HMSUpdateListener, HMSActionResultListener {
  late HMSSDK hmsSdk;
  RoomOverviewBloc roomOverviewBloc;

  HmsRoomObserver(this.roomOverviewBloc) {
    // Disable auto resize of video tracks
    HMSVideoTrackSetting? videoTrackSetting =
        HMSVideoTrackSetting(disableAutoResize: true);
    HMSTrackSetting? trackSetting =
        HMSTrackSetting(videoTrackSetting: videoTrackSetting);

    hmsSdk = HMSSDK(hmsTrackSetting: trackSetting);
    init();
  }

  Future<void> init() async {
    hmsSdk.addUpdateListener(listener: this);
    await hmsSdk.build();
  }

  final _peerNodeStreamController =
      BehaviorSubject<List<PeerTrackNode>>.seeded(const []);

  final _audioDeviceStreamController =
      BehaviorSubject<List<HMSAudioDevice>>.seeded(const []);

  final _currentAudioDeviceStreamController =
      BehaviorSubject<HMSAudioDevice>.seeded(HMSAudioDevice.AUTOMATIC);

  // final _peerStreamController =
  //     BehaviorSubject<List<HMSPeer>>.seeded(const []);

  Stream<List<PeerTrackNode>> getTracks() =>
      _peerNodeStreamController.asBroadcastStream();

  Stream<List<HMSAudioDevice>> getAudioDevices() =>
      _audioDeviceStreamController.asBroadcastStream();

  Stream<HMSAudioDevice> getCurrentAudioDevice() =>
      _currentAudioDeviceStreamController.asBroadcastStream();

  Future<HMSRoom?> _getRoom() async {
    HMSRoom? currRoom;
    try {
      currRoom = await hmsSdk.getRoom();
    } catch (e) {
      if (kDebugMode) {
        print('hmsSdk.getRoom exception $e');
      }
    }
    return currRoom;
  }

  Future<void> joinMeeting(String authToken, String userName) async {
    HMSRoom? room = await _getRoom();
    if (room != null) {
      if (kDebugMode) {
        print("Join meeting ignored, user is already in a meeting");
      }
      return;
    }

    hmsSdk.join(
        config: HMSConfig(
      authToken: authToken,
      userName: userName,
    ));
  }

  Future<void> leaveMeeting() async {
    HMSRoom? room = await _getRoom();
    if (room == null) {
      if (kDebugMode) {
        print("Leave meeting ignored, user is not in a meeting");
      }
      return;
    }
    if (room != null) {
      hmsSdk.leave(hmsActionResultListener: this);
    }
  }

  Future<void> setOffScreen(int index, bool setOffScreen) async {
    final tracks = [..._peerNodeStreamController.value];

    if (index >= 0) {
      tracks[index] = tracks[index].copyWith(isOffScreen: setOffScreen);
    }
    _peerNodeStreamController.add(tracks);
  }

  Future<HMSException?> toggleMicMuteState() async {
    return hmsSdk.toggleMicMuteState();
  }

  Future<HMSException?> toggleCameraMuteState() async {
    return hmsSdk.toggleCameraMuteState();
  }

  Future<void> toggleAudioMuteState() async {
    if (roomOverviewBloc.state.isAudioMute) {
      return hmsSdk.unMuteRoomAudioLocally();
    } else {
      return hmsSdk.muteRoomAudioLocally();
    }
  }

  Future<void> switchCamera() async {
    return hmsSdk.switchCamera();
  }

  Future<void> switchAudioOutputUsingiOSUI() async {
    return hmsSdk.switchAudioOutputUsingiOSUI();
  }

  Future<void> switchAudioOutputUsingAndriod(HMSAudioDevice audioDevice) async {
    return hmsSdk.switchAudioOutput(audioDevice: audioDevice);
  }

  Future<void> startScreenShare() async {
    return hmsSdk.startScreenShare();
  }

  Future<void> stopScreenShare() async {
    return hmsSdk.stopScreenShare();
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // TODO: implement onChangeTrackStateRequest
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onError
  }

  @override
  void onJoin({required HMSRoom room}) {
    //_peerStreamController.add(room.peers ?? []);
    if (!roomOverviewBloc.isClosed) {
      roomOverviewBloc.add(RoomOverviewOnJoinSuccess(room));
    }
  }

  @override
  void onMessage({required HMSMessage message}) {
    // TODO: implement onMessage
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    // final tracks = [..._peerNodeStreamController.value];
    // switch (update) {
    //   case HMSPeerUpdate.peerLeft:

    //     print("peers: onPeerUpdate!!!!!!! peer left");
    //     final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
    //     if (todoIndex >= 0) {
    //       tracks.removeAt(todoIndex);
    //     }
    //     print("peers: onPeerUpdate!!!!!!!  $tracks");
    //     break;
    //   default:
    //     break;
    // }

    // _peerNodeStreamController.add(tracks);
  }

  @override
  void onReconnected() {
    // TODO: implement onReconnected
  }

  @override
  void onReconnecting() {
    // TODO: implement onReconnecting
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    // TODO: implement onRemovedFromRoom
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // TODO: implement onRoleChangeRequest
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  // @override
  // void onTrackUpdate(
  //     {required HMSTrack track,
  //     required HMSTrackUpdate trackUpdate,
  //     required HMSPeer peer}) {
  //   if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
  //     if (trackUpdate == HMSTrackUpdate.trackRemoved) {
  //       final tracks = [..._peerNodeStreamController.value];
  //       final todoIndex =
  //           tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
  //       if (todoIndex >= 0) {
  //         tracks.removeAt(todoIndex);
  //       }
  //       _peerNodeStreamController.add(tracks);
  //     } else {
  //       final tracks = [..._peerNodeStreamController.value];
  //       final todoIndex =
  //           tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
  //       if (todoIndex >= 0) {
  //         tracks[todoIndex] =
  //             PeerTrackNode(track as HMSVideoTrack, peer, false);
  //       } else {
  //         tracks.add(PeerTrackNode(track as HMSVideoTrack, peer, false));
  //       }

  //       _peerNodeStreamController.add(tracks);
  //     }
  //   } else if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
  //       final tracks = [..._peerNodeStreamController.value];
  //       final todoIndex =
  //           tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
  //       if (todoIndex >= 0) {
  //         tracks[todoIndex].peer?.audioTrack = track as HMSAudioTrack;
  //       }

  //       _peerNodeStreamController.add(tracks);
  //   }
  // }
  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    final tracks = [..._peerNodeStreamController.value];

    // Identify if it's a local peer or remote peer update
    if (peer.isLocal) {
      // Update or remove local peer tracks accordingly
      _updateLocalPeerTrack(tracks, peer, track, trackUpdate);
    } else {
      // Update or remove remote peer tracks
      _updateRemotePeerTrack(tracks, peer, track, trackUpdate);
    }

    _peerNodeStreamController.add(tracks);
  }

// Helper function to update local peer tracks
  void _updateLocalPeerTrack(
    List<PeerTrackNode> tracks,
    HMSPeer peer,
    HMSTrack track,
    HMSTrackUpdate trackUpdate,
  ) {
    if (trackUpdate == HMSTrackUpdate.trackRemoved) {
      tracks.removeWhere((node) => node.peer?.peerId == peer.peerId);
    } else {
      final index =
          tracks.indexWhere((node) => node.peer?.peerId == peer.peerId);
      if (index >= 0) {
        tracks[index] = PeerTrackNode(track as HMSVideoTrack, peer, false);
      } else {
        tracks.add(PeerTrackNode(track as HMSVideoTrack, peer, false));
      }
    }
  }

// Helper function to update remote peer tracks
  void _updateRemotePeerTrack(
    List<PeerTrackNode> tracks,
    HMSPeer peer,
    HMSTrack track,
    HMSTrackUpdate trackUpdate,
  ) {
    if (trackUpdate == HMSTrackUpdate.trackRemoved) {
      tracks.removeWhere((node) => node.peer?.peerId == peer.peerId);
    } else {
      final index =
          tracks.indexWhere((node) => node.peer?.peerId == peer.peerId);
      if (index >= 0) {
        tracks[index] = PeerTrackNode(track as HMSVideoTrack, peer, false);
      } else {
        tracks.add(PeerTrackNode(track as HMSVideoTrack, peer, false));
      }
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // TODO: implement onUpdateSpeakers
  }

  @override
  void onException(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    // TODO: implement onException
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments}) {
    _peerNodeStreamController.add([]);
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {
    if (availableAudioDevice != null) {
      _audioDeviceStreamController.add(availableAudioDevice);
    }
    if (currentAudioDevice != null) {
      _currentAudioDeviceStreamController.add(currentAudioDevice);
    }
  }

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {
    // TODO: implement onSessionStoreAvailable
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {
    // TODO: implement onPeerListUpdate
  }
}
