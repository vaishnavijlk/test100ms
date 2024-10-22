import 'dart:io';
import 'package:flutter/material.dart';

class AudioSettingsBottomSheet<T> extends StatefulWidget {
  const AudioSettingsBottomSheet(
      {super.key,
      this.isMuted = false,
      this.audioDevices = const [],
      this.currentAudioDevice,
      required this.getAudioDeviceIcon,
      required this.getAudioDeviceName,
      required this.switchAudioOutputUsingiOSUI,
      required this.switchAudioOutputUsingAndriod,
      required this.toggleRoomAudio});

  final bool isMuted;
  final List<T> audioDevices;
  final T? currentAudioDevice;
  final IconData Function(T? audioDevice) getAudioDeviceIcon;
  final String Function(T? audioDevice) getAudioDeviceName;
  final void Function() switchAudioOutputUsingiOSUI;
  final void Function(T audioDevice) switchAudioOutputUsingAndriod;
  final void Function() toggleRoomAudio;

  @override
  State<AudioSettingsBottomSheet<T>> createState() =>
      _AudioSettingsBottomSheetState<T>();
}

class _AudioSettingsBottomSheetState<T>
    extends State<AudioSettingsBottomSheet<T>> {
  T? selectedAudioDevice;

  @override
  void initState() {
    super.initState();
    selectedAudioDevice = widget.currentAudioDevice;
  }

  Widget getTitleText(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.1),
    );
  }

  Widget getSubtitleText(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.7,
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.15),
      ),
    );
  }

  Widget getAudioDeviceselect(BuildContext context, IconData iconData,
      String deviceName, bool isSelected) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Icon(
          iconData,
          size: screenWidth * 0.025,
          color: Colors.white,
        ),
      ),
      getSubtitleText(context, deviceName),
      if (isSelected)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Icon(
            Icons.check,
            size: screenWidth * 0.025,
            color: Colors.white,
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
        maxChildSize: (widget.audioDevices.length + 2.2) * 0.1,
        minChildSize: (widget.audioDevices.length + 2) * 0.1,
        initialChildSize: (widget.audioDevices.length + 2) * 0.1,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
                color: Colors.black,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getTitleText("Audio Output"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Divider(
                        height: 5,
                        color: Colors.blue,
                      ),
                    ),
                    Platform.isIOS
                        ? Expanded(
                            child: ListView(
                            children: [
                              GestureDetector(
                                  onTap: () => {
                                        widget.switchAudioOutputUsingiOSUI(),
                                        Navigator.pop(context)
                                      },
                                  child: getSubtitleText(context, "Auto")),
                              GestureDetector(
                                  onTap: () => {
                                        widget.toggleRoomAudio(),
                                        Navigator.pop(context)
                                      },
                                  child: getSubtitleText(
                                      context,
                                      widget.isMuted
                                          ? "Unmute Audio"
                                          : "Mute Audio"))
                            ],
                          ))
                        : Expanded(
                            child: ListView.builder(
                                controller: scrollController,
                                itemCount: widget.audioDevices.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == widget.audioDevices.length) {
                                    return GestureDetector(
                                        onTap: () => {
                                              widget.toggleRoomAudio(),
                                              Navigator.pop(context)
                                            },
                                        child: getAudioDeviceselect(
                                            context,
                                            Icons.volume_off,
                                            widget.isMuted
                                                ? "Unmute Audio"
                                                : "Mute Audio",
                                            false));
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedAudioDevice =
                                                  widget.audioDevices[index];
                                            });
                                            widget
                                                .switchAudioOutputUsingAndriod(
                                                    widget.audioDevices[index]);
                                            Navigator.pop(context);
                                          },
                                          child: getAudioDeviceselect(
                                            context,
                                            widget.getAudioDeviceIcon(
                                                widget.audioDevices[index]),
                                            widget.getAudioDeviceName(
                                                widget.audioDevices[index]),
                                            widget.audioDevices[index] ==
                                                selectedAudioDevice,
                                          )),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Divider(
                                            color: Colors.blue,
                                            height: 5,
                                          )),
                                    ],
                                  );
                                }),
                          )
                  ],
                ),
              ));
        });
  }
}
