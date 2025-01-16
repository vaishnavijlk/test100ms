import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_state.dart';
import 'package:videoconsult/components/teleconsultation/peer_tile.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';
import 'package:videoconsult/observers/hms_room_observer.dart';

class DoctorTiles extends StatelessWidget {
  final List<PeerTrackNode> peerTrackNodes;

  const DoctorTiles({super.key, required this.peerTrackNodes});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<PeerTrackNode> remoteNodes = peerTrackNodes
        .where((node) => node.peer != null && !node.peer!.isLocal)
        .toList();

    return BlocListener<RoomOverviewBloc, RoomOverviewState>(
      listenWhen: (previous, current) =>
          previous.peerTrackNodes != current.peerTrackNodes,
      listener: (context, state) {},
      child: remoteNodes.isEmpty
          ? Center(
              child: Text(
                "Please wait for the doctor to join the call",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: max(screenWidth * 0.02, 16),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: remoteNodes.length,
              itemBuilder: (context, index) {
                final peerNode = remoteNodes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PeerTile(
                          key: Key(
                              peerNode.hmsVideoTrack?.trackId ?? "mainVideo"),
                          videoTrack: peerNode.hmsVideoTrack,
                          peer: peerNode.peer,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
