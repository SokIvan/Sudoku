import 'package:flutter/material.dart';

class SudokuGrid extends StatelessWidget {
  final int n;
  final int N;
  final List<List<int>> board;
  final List<List<int>> given;
  final List<List<List<int>>> notes;
  final List<List<int>> solution;
  final int? selectedRow;
  final int? selectedCol;
  final void Function(int r, int c) onTap;

  const SudokuGrid({
    super.key,
    required this.n,
    required this.N,
    required this.board,
    required this.given,
    required this.notes,
    required this.solution,
    required this.selectedRow,
    required this.selectedCol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth / N;
            return Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: N,
                  ),
                  itemCount: N * N,
                  itemBuilder: (context, index) {
                    final r = index ~/ N;
                    final c = index % N;
                    return _cell(context, r, c, size);
                  },
                ),
                ..._blockLines(constraints.maxWidth),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int r, int c, double size) {
    final value = board[r][c];
    final isGiven = given[r][c] != 0;
    final isSelected = selectedRow == r && selectedCol == c;
    final isSameRowCol = selectedRow == r || selectedCol == c;
    final isSameBlock = selectedRow != null &&
        selectedCol != null &&
        (selectedRow! ~/ n) == (r ~/ n) &&
        (selectedCol! ~/ n) == (c ~/ n);
    final isWrong = value != 0 && value != solution[r][c];

    final scheme = Theme.of(context).colorScheme;

    Color bg;
    if (isSelected) {
      bg = scheme.primary.withValues(alpha: 0.35);
    } else if (isSameRowCol || isSameBlock) {
      bg = scheme.primary.withValues(alpha: 0.08);
    } else {
      bg = Colors.transparent;
    }

    
    Widget content;
    if (value != 0) {
      content = Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: isGiven ? FontWeight.bold : FontWeight.w500,
            color: isWrong
                ? Colors.red.shade600
                : (isGiven ? Colors.black87 : scheme.primary),
          ),
        ),
      );
    } else if (notes[r][c].isNotEmpty) {
      content = Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: n,
          ),
          itemCount: n * n,
          itemBuilder: (_, i) {
            final v = i + 1;
            final show = v <= N && notes[r][c].contains(v);
            return Center(
              child: Text(
                show ? '$v' : '',
                style: TextStyle(
                  fontSize: size * 0.22,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            );
          },
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => onTap(r, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: content,
      ),
    );
  }

  List<Widget> _blockLines(double totalSize) {
    final cell = totalSize / N;
    final lines = <Widget>[];
    for (int i = n; i < N; i += n) {
      lines.add(Positioned(
        left: i * cell - 1,
        top: 0,
        bottom: 0,
        child: Container(width: 2, color: Colors.black87),
      ));
      lines.add(Positioned(
        top: i * cell - 1,
        left: 0,
        right: 0,
        child: Container(height: 2, color: Colors.black87),
      ));
    }
    return lines;
  }
}