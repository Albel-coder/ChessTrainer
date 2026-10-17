// Скрываем класс Color из material, чтобы не было конфликта
// с перечислением (enum) Color из пакета flutter_chess_board
import 'package:flutter/material.dart' hide Color;
import 'dart:convert';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:file_picker/file_picker.dart';

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
  final ChessBoardController _controller = ChessBoardController();
  PlayerColor _boardOrientation = PlayerColor.white;

  Future<void> _pickAndLoadPgn() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pgn', 'txt'],
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return;

      final bytes = result.files.single.bytes!;
      final pgnString = utf8.decode(bytes);

      setState(() {
        try {
          _controller.loadPGN(pgnString);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PGN успешно загружен!')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка в PGN: $e')),
            );
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка файла: $e')),
        );
      }
    }
  }

  void _flipBoard() {
    setState(() {
      _boardOrientation = _boardOrientation == PlayerColor.white
          ? PlayerColor.black
          : PlayerColor.white;
    });
  }

  void _undoMove() {
    // Используем правильный метод getSan() для проверки истории
    if (_controller.getSan().isNotEmpty) {
      setState(() => _controller.undoMove());
    }
  }

  void _resetGame() {
    setState(() => _controller.resetBoard());
  }

  String _statusText(Chess game) {
    if (game.in_checkmate) return 'Мат!';
    if (game.in_stalemate) return 'Пат — ничья';
    if (game.in_draw) return 'Ничья';
    if (game.in_check) return 'Шах!';
    // Исправлено: сравниваем с Color.WHITE (enum из flutter_chess_board)
    return game.turn == Color.WHITE ? 'Ход белых' : 'Ход чёрных';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Шахматная доска'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Загрузить PGN',
            onPressed: _pickAndLoadPgn,
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Отменить ход',
            onPressed: _controller.getSan().isEmpty ? null : _undoMove,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Начать заново',
            onPressed: _resetGame,
          ),
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: 'Перевернуть доску',
            onPressed: _flipBoard,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Вычисляем доступное пространство с учетом отступов для других элементов
            final availableWidth = constraints.maxWidth - 24;
            final availableHeight = constraints.maxHeight - 130; // ~130 пикселей под текст и историю

            final minAvailable = availableWidth < availableHeight
                ? availableWidth
                : availableHeight;

            // Ограничиваем размер доски
            final boardSize = minAvailable.clamp(240.0, 640.0);

            // SingleChildScrollView решает проблему с Overflow (переполнением) на Windows
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ValueListenableBuilder<Chess>(
                    valueListenable: _controller,
                    builder: (context, game, child) {
                      final sanHistory = _controller.getSan();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _statusText(game),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: game.in_check
                                    ? Colors.red.shade700
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: boardSize,
                            height: boardSize,
                            child: ChessBoard(
                              controller: _controller,
                              boardColor: BoardColor.brown,
                              boardOrientation: _boardOrientation,
                              arrows: const [],
                              enableUserMoves: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 40,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < sanHistory.length; i++)
                                    if (sanHistory[i] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Chip(
                                          label: Text(
                                            '${i + 1}. ${sanHistory[i]}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}