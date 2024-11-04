import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_event.dart';
import 'package:videoconsult/meeting_room.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TCMeetingScreen(),
    );
  }
}

class TCMeetingScreen extends StatelessWidget {
  final String? displayName;
  final String? appointmentId;

  const TCMeetingScreen({Key? key, this.displayName, this.appointmentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomOverviewBloc(false, false, false, false)
        ..add(const RoomOverviewSubscriptionRequested()),
      child: TCMeetingScreenContent(
        displayName: displayName,
        appointmentId: appointmentId,
      ),
    );
  }
}

class TCMeetingScreenContent extends StatefulWidget {
  final String? displayName;
  final String? appointmentId;

  const TCMeetingScreenContent({Key? key, this.displayName, this.appointmentId})
      : super(key: key);

  @override
  _TCMeetingScreenContentState createState() => _TCMeetingScreenContentState();
}

class _TCMeetingScreenContentState extends State<TCMeetingScreenContent> {
  bool startButtonPressed = false;
  bool deviceStart = false;
  late String videoUrl;
  int selectedDevice = 3;
  String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoyLCJ0eXBlIjoiYXBwIiwiYXBwX2RhdGEiOm51bGwsImFjY2Vzc19rZXkiOiI2NjQ1YTAyNzhmOWU5YTNiM2M2MDM5N2UiLCJyb2xlIjoiZ3Vlc3QiLCJyb29tX2lkIjoiNjcyNDgxY2ZlMWM3N2ZjYzRjMjc3MGIxIiwidXNlcl9pZCI6IjlhYmQ0OTQ2LTMwMGQtNGVjYy1iMjYyLWNjZDVjZWVhNjI2YiIsImV4cCI6MTczMDc3NDI0OSwianRpIjoiYmJlYTRkZDAtOGFhZS00ZTI3LTg1MjAtOWJjOWU1YzFmMTNkIiwiaWF0IjoxNzMwNjg3ODQ5LCJpc3MiOiI2NjQ1YTAyNzhmOWU5YTNiM2M2MDM5N2MiLCJuYmYiOjE3MzA2ODc4NDksInN1YiI6ImFwaSJ9.e2hD8eK9SzLDh0QcxFPgctWaM-LK9lSaFQhjEeVJA5c';
  String header = '';
  String videoName = '';
  bool isUIRendered = false;
  String deviceHeader = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isUIRendered = true;
      });
      getPermissions();
    });
    context
        .read<RoomOverviewBloc>()
        .add(RoomOverviewJoinRequested('P', authToken));
  }

  Future<void> getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.bluetoothConnect.request();
    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
    while ((await Permission.bluetoothConnect.isDenied)) {
      await Permission.bluetoothConnect.request();
    }
  }

  hangUp() {}

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      body: authToken.isNotEmpty
          ?  SizedBox(
            height: 500,
            child: MeetingPage(
                      onLeaveButtonPress: () {},
                      showOnlyRemotePeer: false,
                      meetingWidgetHeight: MediaQuery.of(context).size.height,
                    ),
          )
          : Center(child: CircularProgressIndicator()),
    )
    );
  }
}
