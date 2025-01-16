import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:intl/intl.dart';
import 'package:videoconsult/blocs/hms_room_overview/room_overview_bloc.dart';
import 'package:videoconsult/models/teleconsultation/peer_track_node.dart';
import 'package:videoconsult/observers/hms_room_observer.dart';

class ChatWindow extends StatefulWidget {
  final List<PeerTrackNode> peerTrackNodes;
  final HmsRoomObserver roomObserver;

  const ChatWindow(
      {super.key, required this.peerTrackNodes, required this.roomObserver});

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSending = false; // Prevent duplicate sends

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade900,
      body: Column(
        children: [
          // Header with Close Button
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Messages Display
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade800),
              child: StreamBuilder<List<HMSMessage>>(
                stream: widget.roomObserver.getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Start a conversation",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "There are no messages yet. Send a message to start chatting.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredMessages = snapshot.data!
                      .where((message) =>
                          message.sender?.peerId !=
                          null) // Filter out invalid messages
                      .toList();

// Remove duplicates using messageId
                  final uniqueMessages = {
                    for (var msg in filteredMessages) msg.messageId: msg
                  }.values.toList();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    itemCount: uniqueMessages.length,
                    itemBuilder: (context, index) {
                      final message = uniqueMessages[index];
                      final formattedTime =
                          DateFormat('hh:mm a').format(DateTime.now());

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    message.sender!.name ?? 'Unknown',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                message.message,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Message Input Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.shade800),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Say something...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade700,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (isSending) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      isSending = true;
    });

    try {
      for (final node in widget.peerTrackNodes) {
        if (node.peer != null && node.peer!.isLocal) {
          widget.roomObserver.sendDirectMessage(message, node.peer!, "chat");
          print(
              "Sending message to peer: ${node.peer!}, ID: ${node.peer!.peerId}, message: $message");
        }
      }
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print("Failed to send message: $e");
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
