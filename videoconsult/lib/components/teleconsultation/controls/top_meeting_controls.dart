import 'dart:math';

import 'package:flutter/material.dart';

class TopMeetingControls extends StatefulWidget {
  const TopMeetingControls(
      {super.key,
      required this.onSwitchCameraButtonPress,
      required this.onSwitchAudioButtonPress,
      required this.isKiosk});

  final void Function() onSwitchCameraButtonPress;
  final void Function() onSwitchAudioButtonPress;
  final bool isKiosk;

  @override
  State<TopMeetingControls> createState() => _TopMeetingControlsState();
}

class _TopMeetingControlsState extends State<TopMeetingControls> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(color: Colors.black12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            widget.isKiosk
                ? Container()
                : SizedBox(
                    width: 0.1 * screenWidth,
                    height: 0.1 * screenWidth,
                    child: RawMaterialButton(
                      onPressed: widget.onSwitchCameraButtonPress,
                      elevation: 2.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Icon(
                        Icons.cameraswitch,
                        size: max(25, screenWidth * 0.035),
                        color: Colors.white,
                      ),
                    ),
                  ),
            SizedBox(
              width: 0.03 * screenWidth,
              height: 0.03 * screenWidth,
            ),
            SizedBox(
              width: 0.1 * screenWidth,
              height: 0.1 * screenWidth,
              child: RawMaterialButton(
                onPressed: widget.onSwitchAudioButtonPress,
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
          ],
        ),
      ),
    );
  }
}
