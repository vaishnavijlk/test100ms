import 'dart:math';
import 'package:flutter/material.dart';
import 'package:videoconsult/components/teleconsultation/peer_tile.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';

class DoctorTiles extends StatelessWidget {
  final List<PeerTrackNode> peerTrackNodes;

  const DoctorTiles({super.key, required this.peerTrackNodes});


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<PeerTrackNode> remoteNodes = [];

    for (final node in peerTrackNodes) {
      final peer = node.peer;
      if (peer != null) {
        if (!peer.isLocal) {
          remoteNodes.add(node);
        }
      }
    }

    return remoteNodes.isEmpty
        ? SizedBox.expand(
            child: Center(
              child: Text(
                "Please wait for the doctor to join the call",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: max(screenWidth * 0.02, 16),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          )
        :  SizedBox.expand(
                child: PeerTile(
                  key: Key(remoteNodes.isNotEmpty
                      ? remoteNodes[0].hmsVideoTrack?.trackId ?? "mainVideo"
                      : "noRemotePeers"),
                  videoTrack: remoteNodes.isNotEmpty
                      ? remoteNodes[0].hmsVideoTrack
                      : null,
                  peer: remoteNodes.isNotEmpty ? remoteNodes[0].peer : null,
                ),
              );
          
  }
}
