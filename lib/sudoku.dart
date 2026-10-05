import 'dart:math';

class Board {
  final int n;
  final int N;

  Board(this.n) : N = n * n;

  List<List<int>> empty() =>
      List.generate(N, (_) => List.filled(N, 0));

  List<List<int>> copy(List<List<int>> b) =>
      [for (final row in b) List<int>.from(row)];

  bool isValid(List<List<int>> b, int row, int col, int value) {
    for (int c = 0; c < N; c++) {
      if (b[row][c] == value) return false;
    }
    for (int r = 0; r < N; r++) {
      if (b[r][col] == value) return false;
    }
    final br = (row ~/ n) * n;
    final bc = (col ~/ n) * n;
    for (int r = br; r < br + n; r++) {
      for (int c = bc; c < bc + n; c++) {
        if (b[r][c] == value) return false;
      }
    }
    return true;
  }

  int countSolutions(List<List<int>> board, {int limit = 2}) {
    final b = copy(board);
    int count = 0;

    bool solve() {
      int row = -1, col = -1;
      outer:
      for (int r = 0; r < N; r++) {
        for (int c = 0; c < N; c++) {
          if (b[r][c] == 0) { row = r; col = c; break outer; }
        }
      }
      if (row == -1) { count++; return count >= limit; }
      for (int v = 1; v <= N; v++) {
        if (isValid(b, row, col, v)) {
          b[row][col] = v;
          if (solve()) return true;
          b[row][col] = 0;
        }
      }
      return false;
    }
    solve();
    return count;
  }

  bool solveInPlace(List<List<int>> b, [Random? rnd]) {
    int row = -1, col = -1;
    outer:
    for (int r = 0; r < N; r++) {
      for (int c = 0; c < N; c++) {
        if (b[r][c] == 0) { row = r; col = c; break outer; }
      }
    }
    if (row == -1) return true;

    final values = List.generate(N, (i) => i + 1);
    if (rnd != null) values.shuffle(rnd);

    for (final v in values) {
      if (isValid(b, row, col, v)) {
        b[row][col] = v;
        if (solveInPlace(b, rnd)) return true;
        b[row][col] = 0;
      }
    }
    return false;
  }

  Set<int> candidates(List<List<int>> b, int row, int col) {
    if (b[row][col] != 0) return {};
    final s = <int>{};
    for (int v = 1; v <= N; v++) {
      if (isValid(b, row, col, v)) s.add(v);
    }
    return s;
  }

  bool solveLogically(List<List<int>> board) {
    final b = copy(board);

    bool madeProgress = true;
    while (madeProgress) {
      madeProgress = false;


      for (int r = 0; r < N; r++) {
        for (int c = 0; c < N; c++) {
          if (b[r][c] != 0) continue;
          final cand = candidates(b, r, c);
          if (cand.length == 1) {
            b[r][c] = cand.first;
            madeProgress = true;
          }
        }
      }

      for (int v = 1; v <= N; v++) {

        for (int r = 0; r < N; r++) {
          int cnt = 0, lastC = -1;
          bool alreadyInRow = false;
          for (int c = 0; c < N; c++) {
            if (b[r][c] == v) { alreadyInRow = true; break; }
            if (b[r][c] == 0 && isValid(b, r, c, v)) { cnt++; lastC = c; }
          }
          if (!alreadyInRow && cnt == 1) {
            b[r][lastC] = v;
            madeProgress = true;
          }
        }

        for (int c = 0; c < N; c++) {
          int cnt = 0, lastR = -1;
          bool alreadyInCol = false;
          for (int r = 0; r < N; r++) {
            if (b[r][c] == v) { alreadyInCol = true; break; }
            if (b[r][c] == 0 && isValid(b, r, c, v)) { cnt++; lastR = r; }
          }
          if (!alreadyInCol && cnt == 1) {
            b[lastR][c] = v;
            madeProgress = true;
          }
        }

        for (int br = 0; br < N; br += n) {
          for (int bc = 0; bc < N; bc += n) {
            int cnt = 0, lastR = -1, lastC = -1;
            bool alreadyInBox = false;
            for (int r = br; r < br + n; r++) {
              for (int c = bc; c < bc + n; c++) {
                if (b[r][c] == v) { alreadyInBox = true; break; }
                if (b[r][c] == 0 && isValid(b, r, c, v)) {
                  cnt++; lastR = r; lastC = c;
                }
              }
              if (alreadyInBox) break;
            }
            if (!alreadyInBox && cnt == 1) {
              b[lastR][lastC] = v;
              madeProgress = true;
            }
          }
        }
      }
    }

    for (int r = 0; r < N; r++) {
      for (int c = 0; c < N; c++) {
        if (b[r][c] == 0) return false;
      }
    }
    return true;
  }
}