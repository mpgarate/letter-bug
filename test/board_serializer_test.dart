import 'package:letter_bug/board_serializer.dart';
import 'package:letter_bug/game_board.dart';
import 'package:test/test.dart';

void main() {
  test('BoardSerializer can serialize and deserialize a board', () {
    var words = [
      Word(1, 2, [Move.nw, Move.n, Move.e]),
      Word(0, 1, [Move.se, Move.e, Move.s]),
      Word(3, 2, [Move.w, Move.sw]),
      Word(4, 1, [Move.e, Move.ne, Move.n, Move.s, Move.n, Move.se]),
      Word(2, 1, [Move.e, Move.e]),
      Word(1, 4, [Move.s, Move.nw, Move.n, Move.se]),
    ];

    var game = GameBoard(123, words: words);

    print(BoardSerializer.toBase64(game));
    print(BoardSerializer.toBase64(game).length);

    expect(BoardSerializer.fromBase64(BoardSerializer.toBase64(game)).seed,
        equals(123));
    expect(BoardSerializer.fromBase64(BoardSerializer.toBase64(game)).words,
        equals(words));
  });
}
