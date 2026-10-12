import 'package:flutter/material.dart';
import 'package:chessground/chessground.dart';

// Условный импорт: прячем 64-битные числа от JavaScript-компилятора
import 'package:dartchess/dartchess.dart'
if (dart.library.js) 'dartchess_web_stub.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Trainer',
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
  // Текущее состояние партии
  Position _position = Chess.initial;
  Side _orientation = Side.white;
  NormalMove? _lastMove;

  // Контроллер, который управляет доской
  late final ChessboardController _controller;

  @override
  void initState() {
    super.initState();
    // Передаём обязательный параметр game с начальной позицией
    _controller = ChessboardController(game: _buildGameData());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Собираем снимок состояния для chessground
  GameData _buildGameData() {
    return GameData(
      fen: _position.fen,
      lastMove: _lastMove,
      playerSide: PlayerSide.both,
      sideToMove: _position.turn,
      validMoves: makeLegalMoves(_position),
      kingSquareInCheck:
      _position.isCheck ? _position.board.kingOf(_position.turn) : null,
    );
  }

  // Обработка хода, сделанного пользователем
  void _onMove(Move move, {bool? viaDragAndDrop}) {
    setState(() {
      _position = _position.playUnchecked(move);
      _lastMove = move is NormalMove ? move : null;
    });
    // Обновляем доску новой позицией
    _controller.updatePosition(_buildGameData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматная доска'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: 'Перевернуть доску',
            onPressed: () {
              setState(() {
                _orientation = _orientation == Side.white
                    ? Side.black
                    : Side.white;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Берём минимальную сторону доступного пространства
              // и отнимаем немного места на отступы
              final available = constraints.biggest.shortestSide - 24;
              // Ограничиваем разумными рамками
              final boardSize = available.clamp(240.0, 640.0);

              return SizedBox(
                width: boardSize,
                height: boardSize,
                child: Chessboard(
                  controller: _controller,
                  size: boardSize,
                  orientation: _orientation,
                  onMove: _onMove,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}