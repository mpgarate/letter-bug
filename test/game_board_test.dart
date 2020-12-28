import 'package:letter_bug/game_board.dart';
import 'package:test/test.dart';

void main() {
  test('GameBoard.letterAtIndex() returns a letter', () {
    final gameboard = GameBoard(123);
    expect(gameboard.letterAtIndex(0), equals('K'));
    expect(gameboard.letterAtIndex(1), equals('F'));
    expect(gameboard.letterAtIndex(2), equals('D'));
  });

  test('GameBoard.addWord adds a word', () {
    final gameboard = GameBoard(123);
    // TOOO use a real word in the board, and validate with dictionary
    gameboard.addWord(Word(0, 1, [Move.s, Move.s, Move.e]));
    expect(gameboard.words[0].startRow, equals(0));
    expect(gameboard.words[0].startCol, equals(1));
    expect(gameboard.words[0].moves[2], equals(Move.e));
  });
}
