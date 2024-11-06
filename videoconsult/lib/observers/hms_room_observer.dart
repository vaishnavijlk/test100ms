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

  Future<void> addPeer(HMSVideoTrack hmsVideoTrack, HMSPeer peer) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
    if (todoIndex >= 0) {
      print("onTrackUpdate ${peer.name} ${hmsVideoTrack.isMute}");
      tracks[todoIndex] = PeerTrackNode(hmsVideoTrack, peer, false);
    } else {
      tracks.add(PeerTrackNode(hmsVideoTrack, peer, false));
    }

    _peerNodeStreamController.add(tracks);
  }

  Future<void> deletePeer(String id) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == id);
    if (todoIndex >= 0) {
      tracks.removeAt(todoIndex);
    }
    _peerNodeStreamController.add(tracks);
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
  
  }

  @override
  void onHMSError({required HMSException error}) {
   
  }

  @override
  void onJoin({required HMSRoom room}) {
  
    if (!roomOverviewBloc.isClosed) {
      roomOverviewBloc.add(RoomOverviewOnJoinSuccess(room));
    }
  }

  @override
  void onMessage({required HMSMessage message}) {
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
   
  }

  @override
  void onReconnected() {
   
  }

  @override
  void onReconnecting() {
   
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
   
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
   
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
   
  }


      @override
    void onTrackUpdate(
        {required HMSTrack track,
        required HMSTrackUpdate trackUpdate,
        required HMSPeer peer}) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          roomOverviewBloc.add(RoomOverviewOnPeerLeave(track as HMSVideoTrack, peer));
        } else if (trackUpdate == HMSTrackUpdate.trackAdded ||
                  trackUpdate == HMSTrackUpdate.trackMuted ||
                  trackUpdate == HMSTrackUpdate.trackUnMuted ) {
                
          final peerAlreadyExists = roomOverviewBloc.state.peerTrackNodes
              .any((node) => node.peer?.peerId == peer.peerId);

          if (!peerAlreadyExists || trackUpdate == HMSTrackUpdate.trackUnMuted) {
            roomOverviewBloc.add(RoomOverviewOnPeerJoin(track as HMSVideoTrack, peer));
          }
        }
      }
    }

   


  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
  }

  @override
  void onException(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
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
  }

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {
  }
}
