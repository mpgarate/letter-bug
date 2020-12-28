import 'dart:math';

const MAX_SEED_BITS = 64;
const MAX_SEED = 2 ^ (MAX_SEED_BITS - 1);
const BOARD_SIZE = 5;
final List<String> letters = List.from(
    Iterable.generate(26, (x) => String.fromCharCode('A'.codeUnitAt(0) + x)));

class GameBoard {
  final int seed;
  List<Word> words;
  List<String> board;

  GameBoard(this.seed, {List<Word> words}) {
    this.words = words ?? [];
    this.board = genBoard();
  }

  GameBoard generate() {
    return GameBoard(Random().nextInt(MAX_SEED));
  }

  String letterAtIndex(int i) {
    return this.board[i];
  }

  List<String> genBoard() {
    final rand = Random(this.seed);

    return List<String>.generate(
        BOARD_SIZE ^ 2, (i) => letters[rand.nextInt(letters.length)]);
  }

  void addWord(Word w) {
    this.words.add(w);
  }
}

class Word {
  final int startRow;
  final int startCol;
  final List<Move> moves;

  Word(this.startRow, this.startCol, this.moves);

  @override
  String toString() {
    var moves = this.moves.map((m) => m.toString()).join(",");
    var startCol = this.startCol;
    var startRow = this.startRow;
    return "$startRow, $startCol, [$moves]";
  }

  @override
  bool operator ==(Object other) {
    // TODO: consider a real == implementation
    return this.toString() == other.toString();
  }
}

enum Move { n, ne, e, se, s, sw, w, nw }
