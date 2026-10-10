import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Board Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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
  // Контроллер, который управляет доской
  late final ChessboardController _controller;
  // Текущая позиция
  Position position = Chess.initial;
  // Последний сделанный ход (для подсветки)
  NormalMove? lastMove;
  // Ориентация доски
  Side orientation = Side.white;

  @override
  void initState() {
    super.initState();
    _controller = ChessboardController(game: _buildGame());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Создаём GameData из текущего состояния
  GameData _buildGame() => GameData(
    fen: position.fen,
    lastMove: lastMove,
    playerSide: PlayerSide.white,
    sideToMove: position.turn,
    kingSquareInCheck:
    position.isCheck ? position.board.kingOf(position.turn) : null,
    validMoves: makeLegalMoves(position),
  );

  // Колбэк при перемещении фигуры
  void _onMove(Move move, {bool? viaDragAndDrop}) {
    // Применяем ход к позиции
    position = position.playUnchecked(move);
    // Обновляем подсветку последнего хода
    lastMove = move is NormalMove ? move : null;
    // Сообщаем контроллеру о новой позиции
    _controller.updatePosition(_buildGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматная доска'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            onPressed: () {
              setState(() {
                orientation = orientation == Side.white ? Side.black : Side.white;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Chessboard(
            controller: _controller,
            size: MediaQuery.of(context).size.width - 32,
            orientation: orientation,
            onMove: _onMove,
          ),
        ),
      ),
    );
  }
}