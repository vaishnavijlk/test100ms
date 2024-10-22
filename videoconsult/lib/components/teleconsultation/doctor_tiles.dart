import 'dart:math';
import 'package:flutter/material.dart';
import 'package:videoconsult/components/teleconsultation/peer_tile.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';

class DoctorTiles extends StatelessWidget {
  final List<PeerTrackNode> peerTrackNodes;

  const DoctorTiles({super.key, required this.peerTrackNodes});

  double getAspectRatio(
      {required double containerWidth,
      required double containerHeight,
      required int numTiles}) {
    final ratio = containerWidth / containerHeight;
    if (numTiles == 1) {
      return ratio;
    } else if (numTiles == 2) {
      if (containerWidth > containerHeight) {
        return ratio / 2;
      }
      return 2 * ratio;
    } else {
      return ratio;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final List<PeerTrackNode> remoteNodes = [];

    for (final node in peerTrackNodes) {
      final peer = node.peer;
      if (peer != null) {
        if (!peer.isLocal) {
          // Omit doctors with same username to workaround the bug where remote peer leave events arrive late
          final toReplaceIndex = remoteNodes
              .indexWhere((p) => p.peer != null && p.peer?.name == peer.name);
          if (toReplaceIndex >= 0) {
            final otherPeer = remoteNodes[toReplaceIndex].peer;
            if (otherPeer != null &&
                (otherPeer.joinedAt ?? DateTime.now())
                    .isBefore(peer.joinedAt ?? DateTime.now())) {
              remoteNodes[toReplaceIndex] = node;
            }
          } else {
            remoteNodes.add(node);
          }
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
        : remoteNodes.length == 1
            ? SizedBox.expand(
                child: PeerTile(
                  key: Key(remoteNodes.isNotEmpty
                      ? remoteNodes[0].hmsVideoTrack?.trackId ?? "mainVideo"
                      : "noRemotePeers"),
                  videoTrack: remoteNodes.isNotEmpty
                      ? remoteNodes[0].hmsVideoTrack
                      : null,
                  peer: remoteNodes.isNotEmpty ? remoteNodes[0].peer : null,
                ),
              )
            : LayoutBuilder(builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;
                final containerHeight = constraints.maxHeight;

                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: remoteNodes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: containerWidth > containerHeight
                          ? min(remoteNodes.length, 2)
                          : max(remoteNodes.length - 1, 1),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: getAspectRatio(
                          containerWidth: containerWidth,
                          containerHeight: containerHeight,
                          numTiles: remoteNodes.length)),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                  bottom: Radius.circular(10)),
                              child: PeerTile(
                                key: Key(
                                    remoteNodes[index].hmsVideoTrack?.trackId ??
                                        "mainVideo"),
                                videoTrack: remoteNodes[index].hmsVideoTrack,
                                peer: remoteNodes[index].peer,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              remoteNodes[index].peer?.name ?? 'Doctor',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              });
  }
}
