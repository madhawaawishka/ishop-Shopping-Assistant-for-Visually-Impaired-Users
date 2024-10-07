import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String tutorId;
  final String tutorName;
  final String studentId;
  final String studentName;

  ChatScreen({
    required this.tutorId,
    required this.tutorName,
    required this.studentId,
    required this.studentName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  FlutterSoundRecorder? _recorder;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _chatId;
  bool _isRecording = false;
  bool _isRecorderInitialized = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;
  String? _playingMessageId; // Track which message is currently being played
  Set<String> _selectedMessages = {}; // Set for selected messages
  bool _selectionMode = false; // Selection mode flag
  bool _isFirstLoad = true; // To check if the chat is loaded for the first time

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializeChat();
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _playingMessageId = null;
      });
    });
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();

    await _recorder!.openRecorder();
    _isRecorderInitialized = true;

    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    setState(() {});
  }

  Future<void> _initializeChat() async {
    final tutorId = widget.tutorId;
    final studentId = widget.studentId;
    _chatId = studentId.compareTo(tutorId) < 0
        ? '$studentId\_$tutorId'
        : '$tutorId\_$studentId';

    final chatDoc = _firestore.collection('chats').doc(_chatId);
    final chatSnapshot = await chatDoc.get();

    if (!chatSnapshot.exists) {
      await chatDoc.set({
        'participants': [studentId, tutorId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() {});
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) return;

    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/${Uuid().v4()}.aac';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacMP4,
    );

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized) return;

    String? path = await _recorder!.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      File audioFile = File(path);
      await _uploadVoiceMessage(audioFile);
    }
  }

  Future<void> _uploadVoiceMessage(File file) async {
    String fileName = Uuid().v4();
    Reference ref = _storage
        .ref()
        .child('voice_messages')
        .child(_chatId!)
        .child('$fileName.aac');

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'voiceUrl': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isPlayed': false, // New field to track if the message has been played
    });
  }

  Future<void> _playVoiceMessage(String url, String messageId) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playingMessageId = null;
      });
    }

    await _audioPlayer.play(UrlSource(url));

    setState(() {
      _isPlaying = true;
      _playingMessageId = messageId;
      _currentPosition = Duration.zero;
    });

    // Mark the message as played
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isPlayed': true});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _deleteSelectedMessages() async {
    // Batch to delete multiple messages
    WriteBatch batch = _firestore.batch();

    for (String messageId in _selectedMessages) {
      DocumentReference docRef = _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId);

      // Add each deletion to the batch
      batch.delete(docRef);
    }

    // Commit the batch
    await batch.commit();

    // Clear selected messages and exit selection mode
    setState(() {
      _selectedMessages.clear();
      _selectionMode = false;
    });

    // Show a snackbar to confirm deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected messages deleted!')),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;
    final voiceUrl = data['voiceUrl'];
    final messageId = doc.id;
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    bool isCurrentMessage = _playingMessageId == messageId;
    bool isSelected = _selectedMessages.contains(messageId);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selectionMode = true;
          _selectedMessages.add(messageId);
        });
      },
      onTap: () {
        if (_selectionMode) {
          setState(() {
            if (isSelected) {
              _selectedMessages.remove(messageId);
              if (_selectedMessages.isEmpty) {
                _selectionMode = false; // Exit selection mode if no messages are selected
              }
            } else {
              _selectedMessages.add(messageId);
            }
          });
        } else {
          if (isCurrentMessage && _isPlaying) {
            _audioPlayer.pause();
            setState(() {
              _isPlaying = false;
            });
          } else {
            _playVoiceMessage(voiceUrl, messageId);
          }
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.red[100]
                : isMe
                    ? const Color.fromARGB(255, 217, 169, 225)
                    : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCurrentMessage && _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: isMe ? const Color.fromARGB(255, 217, 169, 225) : Colors.blue,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Voice Message',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (isCurrentMessage)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                      setState(() {
                        _currentPosition = Duration(seconds: value.toInt());
                      });
                    },
                  ),
                ),
              SizedBox(height: 5),
              Text(
                DateFormat('hh:mm a').format(timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _autoPlayNewMessages(QuerySnapshot snapshot) {
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var doc in snapshot.docs.reversed) {
          final data = doc.data() as Map<String, dynamic>;
          final isPlayed = data['isPlayed'] ?? false;
          final senderId = data['senderId'];

          if (!isPlayed && senderId != FirebaseAuth.instance.currentUser!.uid) {
            _playVoiceMessage(data['voiceUrl'], doc.id);
            break; // Auto-play the first unplayed message
          }
        }
        _isFirstLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isTutor = currentUser != null && currentUser.uid == widget.tutorId;
    final chatPartnerName = isTutor ? widget.studentName : widget.tutorName;

    if (_chatId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(chatPartnerName),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(chatPartnerName),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (_selectedMessages.isNotEmpty) {
                      _deleteSelectedMessages();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                // Auto-play new messages
                _autoPlayNewMessages(snapshot.data!);

                return ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      _startRecording();
                    },
                    onLongPressEnd: (details) {
                      _stopRecording();
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red[300] : const Color.fromRGBO(156, 39, 176, 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _isRecording ? 'Recording...' : 'Hold to Talk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
}
