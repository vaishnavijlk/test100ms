import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_state.dart';
import 'package:videoconsult/components/teleconsultation/controls/bottom_meeting_controls.dart';
import 'package:videoconsult/components/teleconsultation/controls/utils.dart';
import 'package:videoconsult/components/teleconsultation/doctor_tiles.dart';
import 'package:videoconsult/components/teleconsultation/peer_tile.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({
    super.key,
    required this.onLeaveButtonPress,
    required this.showOnlyRemotePeer,
    required this.meetingWidgetHeight,
  });

  final void Function() onLeaveButtonPress;
  final bool showOnlyRemotePeer;
  final double meetingWidgetHeight;

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  void handleExit(BuildContext context) {
    context.read<RoomOverviewBloc>().add(const RoomOverviewLeaveRequested());
    widget.onLeaveButtonPress();
  }

  Future<bool> _onWillPop() async {
    handleExit(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = widget.meetingWidgetHeight;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<RoomOverviewBloc, RoomOverviewState>(
        builder: (context, state) {
      HMSPeer? localPeer;
      HMSVideoTrack? localPeerVideoTrack;

      for (final node in state.peerTrackNodes) {
        if (node.peer != null) {
          if (!widget.showOnlyRemotePeer && node.peer!.isLocal) {
            localPeer = node.peer;
            localPeerVideoTrack = node.hmsVideoTrack;
          }
        }
      }

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
     DoctorTiles(peerTrackNodes: state.peerTrackNodes),

              if (localPeer != null &&
                  localPeerVideoTrack != null &&
                  state.peerTrackNodes.length > 1
                  )
                Positioned(
                  top:  10,
                  bottom:  null,
                  right: 10,
                  child: Container(
                    width: screenWidth * 0.23,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: PeerTile(
                        key: Key(localPeerVideoTrack.trackId),
                        videoTrack: localPeerVideoTrack,
                        peer: localPeer,
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 0.1 * screenWidth,
                  height: 0.1 * screenWidth,
                  child: RawMaterialButton(
                    onPressed: () {
                      handleAudioSwitchToggle(context, state);
                    },
                    elevation: 2.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Icon(
                      Icons.headphones_outlined,
                      size: max(25, screenWidth * 0.035),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!widget.showOnlyRemotePeer)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomMeetingControls(
                    isKioskMode: false,
                    isVideoMuted: state.isCameraMute,
                    isAudioMuted: state.isMicMute,
                    onVideoButtonPress: () => {
                      context
                          .read<RoomOverviewBloc>()
                          .add(const RoomOverviewLocalPeerVideoToggled()),
                     
                    },
                    onAudioButtonPress: () => {
                      context
                          .read<RoomOverviewBloc>()
                          .add(const RoomOverviewLocalPeerMicToggled())
                    },
                    onLeaveButtonPress: () => {handleExit(context)},
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}


