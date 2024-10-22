import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class PeerTile extends StatelessWidget {
  final HMSVideoTrack? videoTrack;
  final HMSPeer? peer;

  const PeerTile({super.key, this.videoTrack, this.peer});

  String getPeerNamePrefix(HMSPeer? peer) {
    if (peer != null) {
      if (peer.name.isNotEmpty) {
        return peer.name.substring(0, 1);
      } else if (peer.isLocal) {
        return 'P';
      }
      return "D";
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final containerSize = min(constraints.maxWidth, constraints.maxHeight);

      return Container(
          key: key,
          child: Stack(
            children: [
              (videoTrack != null && !(videoTrack?.isMute ?? true))
                  ? HMSVideoView(
                      track: videoTrack!,
                      scaleType: ScaleType.SCALE_ASPECT_FILL,
                    )
                  : Center(
                      child: SizedBox(
                        width: max(screenWidth * 0.1, 40),
                        height: max(screenWidth * 0.1, 40),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              getPeerNamePrefix(peer),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
              if (peer?.audioTrack?.isMute ?? true)
                Positioned(
                    // top: min(screenWidth * 0.01, 10),
                    // left: min(screenWidth * 0.01, 10),
                    top: min(max(containerSize * 0.12, 10), 60),
                    left: min(max(containerSize * 0.12, 10), 20),
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black26),
                        child: Icon(
                          Icons.mic_off,
                          size: min(max(containerSize * 0.15, 20), 30),
                          color: Colors.white70,
                        )))
            ],
          ));
    });
  }
}
