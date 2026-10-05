import 'dart:math';
import 'sudoku.dart';

enum GameMode {
  relaxed,
  unique,
  logical,
  strict,
}

class Puzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;
  final GameMode mode;
  final int n;

  Puzzle({
    required this.puzzle,
    required this.solution,
    required this.mode,
    required this.n,
  });
}

const int kMaxMistakes = 3;

Puzzle generatePuzzle({
  int n = 3,
  required GameMode mode,
  int clues = 30,
  int? seed,
}) {
  final board = Board(n);
  final rnd = Random(seed);
  final total = board.N * board.N;

  final solution = board.empty();
  board.solveInPlace(solution, rnd);

  final puzzle = board.copy(solution);

  final positions = <List<int>>[];
  for (int r = 0; r < board.N; r++) {
    for (int c = 0; c < board.N; c++) {
      positions.add([r, c]);
    }
  }
  positions.shuffle(rnd);

  int currentClues = total;


  final effective = mode == GameMode.strict ? GameMode.unique : mode;

  for (final pos in positions) {
    if (currentClues <= clues) break;
    final r = pos[0], c = pos[1];
    final backup = puzzle[r][c];
    puzzle[r][c] = 0;

    bool ok;
    switch (effective) {
      case GameMode.relaxed:
        ok = currentClues - 1 >= (board.N * board.N * 0.2).round();
        break;
      case GameMode.unique:
      case GameMode.strict:
        ok = board.countSolutions(puzzle, limit: 2) == 1;
        break;
      case GameMode.logical:
        ok = board.solveLogically(puzzle);
        break;
    }

    if (ok) {
      currentClues--;
    } else {
      puzzle[r][c] = backup;
    }
  }

  return Puzzle(puzzle: puzzle, solution: solution, mode: mode, n: n);
}