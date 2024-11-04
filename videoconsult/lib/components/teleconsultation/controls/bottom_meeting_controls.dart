import 'dart:math';

import 'package:flutter/material.dart';

class BottomMeetingControls extends StatefulWidget {
  const BottomMeetingControls({
    super.key,
    required this.isVideoMuted,
    required this.isAudioMuted,
    required this.onVideoButtonPress,
    required this.onAudioButtonPress,
    required this.onLeaveButtonPress,
    required this.isKioskMode,
  });

  final bool isVideoMuted;
  final bool isAudioMuted;
  final void Function() onVideoButtonPress;
  final void Function() onAudioButtonPress;
  final void Function() onLeaveButtonPress;
  final bool isKioskMode;

  @override
  State<BottomMeetingControls> createState() => _BottomMeetingControlsState();
}

class _BottomMeetingControlsState extends State<BottomMeetingControls> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = max(50, 0.07 * screenWidth);
    final double iconSize = max(20, screenWidth * 0.025);

    return Container(
      decoration: BoxDecoration(color: Colors.black54),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!widget.isKioskMode)
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: RawMaterialButton(
                  onPressed: widget.onLeaveButtonPress,
                  elevation: 2.0,
                  fillColor: Colors.red,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.logout,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: RawMaterialButton(
                onPressed: widget.onAudioButtonPress,
                elevation: 2.0,
                fillColor: Colors.grey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Icon(
                    widget.isAudioMuted ? Icons.mic_off : Icons.mic,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: RawMaterialButton(
                onPressed: widget.onVideoButtonPress,
                elevation: 2.0,
                fillColor: Colors.grey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Icon(
                    widget.isVideoMuted ? Icons.videocam_off : Icons.videocam,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
