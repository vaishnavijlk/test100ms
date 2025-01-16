import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';

class HmsRoomObserver implements HMSUpdateListener, HMSActionResultListener {
  HMSSDK hmsSdk = HMSSDK();
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

  final BehaviorSubject<List<HMSMessage>> _messagesStreamController =
      BehaviorSubject<List<HMSMessage>>.seeded([]);

  Stream<List<HMSMessage>> getMessages() => _messagesStreamController.stream;

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
    // Append the new message to the stream
    final messages = [..._messagesStreamController.value];
    messages.add(message);
    _messagesStreamController.add(messages);
  }

  void sendDirectMessage(String message, HMSPeer peerTo, String type) {
    // Create a local message object
    final localMessage = HMSMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: HMSPeer(
          peerId: peerTo.peerId,
          name: peerTo.name,
          isLocal: true,
          role: peerTo.role,
          isHandRaised: peerTo.isHandRaised),
      message: message,
      type: type,
      time: DateTime.now(),
      hmsMessageRecipient: HMSMessageRecipient(
        recipientPeer: peerTo,
        recipientRoles: null,
        hmsMessageRecipientType: HMSMessageRecipientType.DIRECT,
      ),
    );

    // Add the local message to the stream immediately
    final messages = [..._messagesStreamController.value];
    messages.add(localMessage);
    _messagesStreamController.add(messages);

    // Send the message using HMSSDK
    hmsSdk.sendDirectMessage(
      message: message,
      peerTo: peerTo,
      type: type,
      hmsActionResultListener: this,
    );
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {}

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

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (!roomOverviewBloc.isClosed) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          roomOverviewBloc
              .add(RoomOverviewOnPeerLeave(track as HMSVideoTrack, peer));
        } else if (trackUpdate == HMSTrackUpdate.trackAdded ||
            trackUpdate == HMSTrackUpdate.trackMuted ||
            trackUpdate == HMSTrackUpdate.trackUnMuted) {
          final peerAlreadyExists = roomOverviewBloc.state.peerTrackNodes
              .any((node) => node.peer?.peerId == peer.peerId);

          if (!peerAlreadyExists ||
              trackUpdate == HMSTrackUpdate.trackUnMuted) {
            roomOverviewBloc
                .add(RoomOverviewOnPeerJoin(track as HMSVideoTrack, peer));
          }
        }
      }
    }
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

    if (!_peerNodeStreamController.isClosed) {
      _peerNodeStreamController.add(tracks);
    }
  }

  Future<void> deletePeer(String id) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == id);
    if (todoIndex >= 0) {
      tracks.removeAt(todoIndex);
    }
    if (!_peerNodeStreamController.isClosed) {
      _peerNodeStreamController.add(tracks);
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
    if (methodType == HMSActionResultListenerMethod.sendDirectMessage) {
      print("Failed to send direct message: ${hmsException.message}");
    }
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments}) {
    if (!_peerNodeStreamController.isClosed) {
      _peerNodeStreamController.add([]);
    }
    if (methodType == HMSActionResultListenerMethod.sendDirectMessage) {
      // Optional: Notify the UI of successful message delivery
      print("Direct message sent successfully");
    }
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
