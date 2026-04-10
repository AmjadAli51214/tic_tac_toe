import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProTicTacToe());
}

class ProTicTacToe extends StatelessWidget {
  const ProTicTacToe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A2A33),
      ),
      home: const RoomSelectionScreen(),
    );
  }
}

class RoomSelectionScreen extends StatelessWidget {
  const RoomSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController roomController = TextEditingController(text: "1234");
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("ONLINE TIC TAC TOE",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3AB4B4))),
              const SizedBox(height: 40),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Enter Room ID to Play with Friend",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.door_front_door),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2B137),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (c) => GameScreen(roomId: roomController.text))),
                child: const Text("JOIN GAME ROOM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String roomId;
  const GameScreen({super.key, required this.roomId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DatabaseReference _gameRef;
  late DatabaseReference _chatRef;

  // Game Logic
  List<String> board = List.filled(9, "");
  bool xTurn = true;
  int scoreX = 0;
  int scoreO = 0;
  String status = "Connecting...";
  String myIdentity = "X";
  bool vsMachine = false;

  // Chat & UI
  double _chatHeight = 220.0;
  final List<Map<dynamic, dynamic>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color xColor = const Color(0xFF3AB4B4);
  final Color oColor = const Color(0xFFF2B137);
  final Color tieColor = const Color(0xFFA8BFC9);
  final Color cellColor = const Color(0xFF1F3641);

  @override
  void initState() {
    super.initState();

    // Pointing to your specific Singapore Database URL:
    final String databaseUrl = 'https://tick-tac-toe-2c4d5-default-rtdb.asia-southeast1.firebasedatabase.app';

    _gameRef = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: databaseUrl)
        .ref().child('rooms/${widget.roomId}/game');

    _chatRef = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: databaseUrl)
        .ref().child('rooms/${widget.roomId}/messages');

    _listenToFirebase();
  }

  void _listenToFirebase() {
    // Sync Game State
    _gameRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null && mounted) {
        setState(() {
          board = List<String>.from(data['board']);
          xTurn = data['xTurn'];
          scoreX = data['scoreX'] ?? 0;
          scoreO = data['scoreO'] ?? 0;
          status = data['status'] ?? "Playing...";
          vsMachine = data['vsMachine'] ?? false;
        });

        if (vsMachine && !xTurn && !status.contains("Wins")) {
          _triggerMachineMove();
        }
      } else {
        _resetFirebase(hard: true);
      }
    });

    // Sync Chat
    _chatRef.onChildAdded.listen((event) {
      final msg = event.snapshot.value as Map<dynamic, dynamic>;
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    });
  }

  void handleTap(int index) {
    if (board[index] != "" || status.contains("Wins")) return;

    List<String> newBoard = List.from(board);
    newBoard[index] = xTurn ? "X" : "O";

    String nextStatus = "";
    int nextX = scoreX;
    int nextO = scoreO;

    if (_checkWinner(newBoard, xTurn ? "X" : "O")) {
      String winnerName = xTurn ? "X" : (vsMachine ? "CPU" : "O");
      nextStatus = "$winnerName Wins!";
      xTurn ? nextX++ : nextO++;
    } else if (!newBoard.contains("")) {
      nextStatus = "Draw!";
    } else {
      nextStatus = !xTurn ? "Player X's Turn" : (vsMachine ? "CPU's Turn" : "Player O's Turn");
    }

    _gameRef.update({
      'board': newBoard,
      'xTurn': !xTurn,
      'status': nextStatus,
      'scoreX': nextX,
      'scoreO': nextO,
    });
  }

  void _triggerMachineMove() {
    Future.delayed(const Duration(milliseconds: 700), () {
      List<int> empty = [];
      for (int i = 0; i < 9; i++) if (board[i] == "") empty.add(i);
      if (empty.isNotEmpty) handleTap(empty[Random().nextInt(empty.length)]);
    });
  }

  void _resetFirebase({bool hard = false}) {
    _gameRef.set({
      'board': List.filled(9, ""),
      'xTurn': true,
      'status': "Player X's Turn",
      'scoreX': hard ? 0 : scoreX,
      'scoreO': hard ? 0 : scoreO,
      'vsMachine': vsMachine,
    });
  }

  void _sendMsg({String? text, String type = "user"}) {
    String content = text ?? _chatController.text;
    if (content.isEmpty) return;

    _chatRef.push().set({
      'sender': myIdentity,
      'text': content,
      'type': type,
    });
    _chatController.clear();

    if (vsMachine) {
      Future.delayed(const Duration(seconds: 1), () {
        _chatRef.push().set({
          'sender': 'CPU',
          'text': type == 'gift' ? "Thank you for the gift! 🎁" : "Nice move, but I'm smarter!",
          'type': 'user',
        });
      });
    }
  }

  bool _checkWinner(List<String> b, String p) {
    List<List<int>> lines = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    return lines.any((l) => b[l[0]] == p && b[l[1]] == p && b[l[2]] == p);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP SCOREBAR
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _scoreBox("X (${myIdentity == "X" ? "YOU" : "P1"})", scoreX, xColor),
                  _scoreBox(vsMachine ? "O (CPU)" : "O (${myIdentity == "O" ? "YOU" : "P2"})", scoreO, oColor),
                ],
              ),
            ),

            // 2. GAME STATUS
            Text(status, style: TextStyle(fontSize: 24, color: tieColor, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ActionChip(
              backgroundColor: cellColor,
              label: Text("Playing as $myIdentity", style: const TextStyle(color: Colors.white)),
              onPressed: () => setState(() => myIdentity = myIdentity == "X" ? "O" : "X"),
            ),

            // 3. GAME GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15),
                    itemCount: 9,
                    itemBuilder: (context, i) => _buildCell(i),
                  ),
                ),
              ),
            ),

            // 4. CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconBtn(Icons.refresh, () => _resetFirebase()),
                const SizedBox(width: 40),
                _iconBtn(vsMachine ? Icons.person : Icons.smart_toy,
                        () => _gameRef.update({'vsMachine': !vsMachine})),
              ],
            ),
            const SizedBox(height: 20),

            // 5. RESIZABLE CHAT
            GestureDetector(
              onVerticalDragUpdate: (d) => setState(() =>
              _chatHeight = (_chatHeight - d.delta.dy).clamp(120.0, screenHeight * 0.5)),
              child: Container(
                width: double.infinity, height: 35,
                decoration: BoxDecoration(color: cellColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
                child: const Icon(Icons.drag_handle, color: Colors.white24),
              ),
            ),
            Container(
              height: _chatHeight,
              color: const Color(0xFF142026),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _chatBubble(_messages[i]),
                    ),
                  ),
                  _chatInputArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(int i) {
    return GestureDetector(
      onTap: () => handleTap(i),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 5))],
        ),
        child: Center(
          child: board[i] == "" ? null : Icon(
            board[i] == "X" ? Icons.close : Icons.circle_outlined,
            size: 50, color: board[i] == "X" ? xColor : oColor,
          ),
        ),
      ),
    );
  }

  Widget _scoreBox(String label, int val, Color col) {
    return Container(
      width: 110, padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          Text("$val", style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: tieColor, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF1A2A33)),
      ),
    );
  }

  Widget _chatBubble(Map msg) {
    bool isMe = msg['sender'] == myIdentity;
    bool isGift = msg['type'] == 'gift';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isGift ? Colors.pink.withOpacity(0.2) : cellColor,
          borderRadius: BorderRadius.circular(12),
          border: isGift ? Border.all(color: Colors.pinkAccent) : null,
        ),
        child: Text(
          isGift ? "🎁 ${msg['sender']} sent a gift!" : "${msg['sender']}: ${msg['text']}",
          style: TextStyle(color: isGift ? Colors.pinkAccent : (msg['sender'] == "X" ? xColor : oColor)),
        ),
      ),
    );
  }

  Widget _chatInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: cellColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
            onPressed: () => _sendMsg(type: 'gift', text: 'Gift'),
          ),
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: const InputDecoration(hintText: "Type message...", border: InputBorder.none),
              onSubmitted: (_) => _sendMsg(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.white70), onPressed: () => _sendMsg()),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }
}