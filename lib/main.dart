import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  // Контроллер управляет состоянием, логикой и валидацией ходов из коробки
  final ChessBoardController _controller = ChessBoardController();
  PlayerColor _boardOrientation = PlayerColor.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматная доска (Web Ready)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: 'Перевернуть доску',
            onPressed: () {
              setState(() {
                _boardOrientation = _boardOrientation == PlayerColor.white
                    ? PlayerColor.black
                    : PlayerColor.white;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final available = constraints.biggest.shortestSide - 24;
              final boardSize = available.clamp(240.0, 640.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: ChessBoard(
                      controller: _controller,
                      boardColor: BoardColor.brown, // Красивая классическая тема доски
                      boardOrientation: _boardOrientation,
                      arrows: const [], // Здесь можно будет рисовать тренировочные стрелки дебютов
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Пример подписи хода (интеграция с логикой движка)
                  ValueListenableBuilder<Chess>(
                    valueListenable: _controller,
                    builder: (context, game, child) {
                      return Text(
                        game.in_check ? 'Шах!' : 'Сделайте ход...',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}