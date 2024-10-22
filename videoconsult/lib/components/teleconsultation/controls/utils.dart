import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_state.dart';
import 'package:videoconsult/components/teleconsultation/controls/audio_settings_bottom_sheet.dart';

String getAudioDeviceName(HMSAudioDevice? hmsAudioDevice) {
  switch (hmsAudioDevice) {
    case HMSAudioDevice.SPEAKER_PHONE:
      return "Speaker";
    case HMSAudioDevice.WIRED_HEADSET:
      return "Earphone";
    case HMSAudioDevice.EARPIECE:
      return "Phone";
    case HMSAudioDevice.BLUETOOTH:
      return "Bluetooth Device";
    default:
      return "Auto";
  }
}

IconData getAudioDeviceIcon(HMSAudioDevice? hmsAudioDevice) {
  switch (hmsAudioDevice) {
    case HMSAudioDevice.SPEAKER_PHONE:
      return Icons.volume_up_outlined;
    case HMSAudioDevice.WIRED_HEADSET:
      return Icons.headset_outlined;
    case HMSAudioDevice.EARPIECE:
      return Icons.phone;
    case HMSAudioDevice.BLUETOOTH:
      return Icons.bluetooth_audio_outlined;
    default:
      return Icons.volume_up_outlined;
  }
}

void handleAudioSwitchToggle(BuildContext context, RoomOverviewState state) {
  showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      context: context,
      builder: (ctx) => AudioSettingsBottomSheet<HMSAudioDevice>(
            audioDevices: state.audioDevices,
            currentAudioDevice: state.currentAudioDevice,
            isMuted: state.isAudioMute,
            switchAudioOutputUsingAndriod: (audioDevice) => {
              context.read<RoomOverviewBloc>().add(
                  RoomOverviewLocalPeerAudioSwitchAndriodRequested(audioDevice))
            },
            switchAudioOutputUsingiOSUI: () => {
              context
                  .read<RoomOverviewBloc>()
                  .add(const RoomOverviewLocalPeerAudioSwitchIOSRequested())
            },
            toggleRoomAudio: () => {
              context
                  .read<RoomOverviewBloc>()
                  .add(const RoomOverviewLocalPeerAudioToggled()),
            },
            getAudioDeviceIcon: getAudioDeviceIcon,
            getAudioDeviceName: getAudioDeviceName,
          ));
}
