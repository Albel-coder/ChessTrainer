// Этот файл — заглушка, чтобы JS-компилятор Flutter не падал при сборке веба.
// Когда приложение запустится в WebAssembly или на Android/Windows,
// этот код будет полностью проигнорирован.

class Position {
  static get initial => Position();
  String get fen => 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  dynamic get turn => null;
  bool get isCheck => false;
  dynamic playUnchecked(dynamic move) => this;
  get board => Board();
}

class Board {
  dynamic kingOf(dynamic turn) => null;
}

enum Side { white, black }

Map<String, List<String>> makeLegalMoves(Position position) {
  return {};
}

class Move {}
class NormalMove extends Move {
  dynamic get from => null;
  dynamic get to => null;
}
