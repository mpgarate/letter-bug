import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

import 'package:letter_bug/game_board.dart';

class BitPacker {
  BigInt data = BigInt.zero;
  int posBits = 0;

  void add(int data, int numBits) {
    this.data += (BigInt.from(data) << this.posBits);
    this.posBits += numBits;
  }

  String asBase64() {
    return base64Url.encode(ZLibEncoder().encode(bigIntToBytes(this.data)));
  }

  // see https://github.com/dart-lang/sdk/issues/32803#issuecomment-387405784
  Uint8List bigIntToBytes(BigInt number) {
    int bytes = (number.bitLength + 7) >> 3;
    var b256 = new BigInt.from(256);
    var result = new Uint8List(bytes);
    for (int i = 0; i < bytes; i++) {
      result[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }
    return result;
  }
}

class BitReader {
  BigInt data;

  BitReader(String data) {
    this.data = bytesToBigInt(
        ZLibDecoder().decodeBytes(base64Url.decode(data)).reversed.toList());
  }

  int read(int sizeBits) {
    final result = this.data & ((BigInt.one << sizeBits) - BigInt.one);
    this.data = this.data >> sizeBits;

    return result.toInt();
  }

  // see https://github.com/bcgit/pc-dart/blob/master/lib/src/utils.dart#L19
  BigInt bytesToBigInt(List<int> bytes) {
    var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;

    BigInt result;

    if (bytes.length == 1) {
      result = BigInt.from(bytes[0]);
    } else {
      result = BigInt.zero;
      for (var i = 0; i < bytes.length; i++) {
        var item = bytes[bytes.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }
    return result != BigInt.zero
        ? negative
            ? result.toSigned(result.bitLength)
            : result
        : BigInt.zero;
  }
}

class BoardSerializer {
  static String toBase64(GameBoard board) {
    var bits = BitPacker();
    bits.add(board.seed, MAX_SEED_BITS);

    // assume not more than 256 words found
    bits.add(board.words.length, 8);

    board.words.forEach((word) {
      bits.add(word.startRow, 3);
      bits.add(word.startCol, 3);

      // assume no words longer than 15 chars
      bits.add(word.moves.length, 4);

      word.moves.forEach((move) {
        bits.add(move.index, 3);
      });
    });

    return bits.asBase64();
  }

  static GameBoard fromBase64(String data) {
    final bits = BitReader(data);

    final seed = bits.read(MAX_SEED_BITS);

    final numWords = bits.read(8);

    final words = Iterable<int>.generate(numWords).map((_) {
      final startRow = bits.read(3);
      final startCol = bits.read(3);
      final numMoves = bits.read(4);
      final moves = Iterable<int>.generate(numMoves)
          .map((_) => Move.values[bits.read(3)])
          .toList();

      return Word(startRow, startCol, moves);
    }).toList();

    return GameBoard(seed, words: words);
  }
}
