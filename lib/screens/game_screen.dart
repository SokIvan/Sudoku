import 'package:flutter/material.dart';
import '../generator.dart';
import '../sudoku.dart';
import '../storage.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/numpad.dart';

class GameScreen extends StatefulWidget {
  final Puzzle? puzzle;
  final bool isNew;

  const GameScreen({super.key, this.puzzle, required this.isNew});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Board _engine;
  late List<List<int>> _puzzle;
  late List<List<int>> _board;
  late List<List<int>> _solution;
  late List<List<List<int>>> _notes;
  late int _n;
  late GameMode _mode;
  bool _notesMode = false;
  int? _selR, _selC;
  int _mistakes = 0;
  bool _finished = false;
  bool _noSave = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNew && widget.puzzle != null) {
      _initFromPuzzle(widget.puzzle!);
      _loaded = true;
    } else {
      _loadSaved();
    }
  }

  void _initFromPuzzle(Puzzle p) {
    _n = p.n;
    _mode = p.mode;
    _engine = Board(p.n);
    _puzzle = _engine.copy(p.puzzle);
    _board = _engine.copy(p.puzzle);
    _solution = _engine.copy(p.solution);
    _notes = List.generate(
      _engine.N,
      (_) => List.generate(_engine.N, (_) => <int>[]),
    );
    _selR = null;
    _selC = null;
    _mistakes = 0;
    _finished = false;
  }

  Future<void> _loadSaved() async {
    final saved = await Storage.load();
    if (saved == null) {
      setState(() {
        _loaded = true;
        _noSave = true;
      });
      return;
    }
    _n = saved.n;
    _mode = saved.mode;
    _engine = Board(saved.n);
    _puzzle = _engine.copy(saved.puzzle);
    _board = _engine.copy(saved.board);
    _solution = _engine.copy(saved.puzzle);
    _engine.solveInPlace(_solution);
    _notes = saved.notes
        .map((row) => row.map((cell) => List<int>.from(cell)).toList())
        .toList();
    _mistakes = saved.mistakes;
    _finished = saved.finished;
    setState(() => _loaded = true);
  }

  Future<void> _persist() async {
    await Storage.save(GameState(
      n: _n,
      mode: _mode,
      puzzle: _puzzle,
      board: _board,
      notes: _notes,
      mistakes: _mistakes,
      finished: _finished,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: SizedBox.shrink());
    }
    if (_noSave) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Нет сохранённой игры'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('В меню'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_engine.N}×${_engine.N} · ${_modeLabel(_mode)}'),
        actions: [
          if (_mode == GameMode.strict)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  'Ошибки: $_mistakes / $kMaxMistakes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _mistakes >= kMaxMistakes
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Очистить',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildGrid())),
          NumPad(
            N: _engine.N,
            notesMode: _notesMode,
            onToggleNotes: () => setState(() => _notesMode = !_notesMode),
            onDigit: _onDigit,
            onErase: _onErase,
          ),
        ],
      ),
    );
  }

  String _modeLabel(GameMode m) => switch (m) {
        GameMode.relaxed => 'Обычный',
        GameMode.unique => 'Одно решение',
        GameMode.logical => 'Логический',
        GameMode.strict => 'С проигрышем',
      };

  Widget _buildGrid() => SudokuGrid(
        n: _n,
        N: _engine.N,
        board: _board,
        given: _puzzle,
        notes: _notes,
        solution: _solution,
        selectedRow: _selR,
        selectedCol: _selC,
        onTap: _onTap,
      );

  void _onTap(int r, int c) {
    if (_finished) return;
    if (_puzzle[r][c] != 0) return;
    setState(() {
      _selR = r;
      _selC = c;
    });
  }

  void _onDigit(int d) {
    if (_finished) return;
    final r = _selR, c = _selC;
    if (r == null || c == null) return;

    setState(() {
      if (_notesMode) {
        if (_board[r][c] != 0) return;
        final list = _notes[r][c];
        if (list.contains(d)) {
          list.remove(d);
        } else {
          list.add(d);
          list.sort();
        }
      } else {
        final wasEmptyOrSame = _board[r][c] == 0 || _board[r][c] == d;
        final willClear = _board[r][c] == d;
        if (!willClear && !wasEmptyOrSame) {
        }
        if (!willClear) {
          final isWrong = d != _solution[r][c];
          if (isWrong) {
            _mistakes++;
          }
        }
        _board[r][c] = willClear ? 0 : d;
        _notes[r][c].clear();
      }
    });

    _persist();
    _checkEnd();
  }

  void _onErase() {
    if (_finished) return;
    final r = _selR, c = _selC;
    if (r == null || c == null) return;
    setState(() {
      _board[r][c] = 0;
      _notes[r][c].clear();
    });
    _persist();
  }

  void _clearAll() {
    setState(() {
      for (int r = 0; r < _engine.N; r++) {
        for (int c = 0; c < _engine.N; c++) {
          if (_puzzle[r][c] == 0) {
            _board[r][c] = 0;
            _notes[r][c].clear();
          }
        }
      }
      _selR = null;
      _selC = null;
      _mistakes = 0;
      _finished = false;
    });
    _persist();
  }

  bool _isSolved() {
    for (int r = 0; r < _engine.N; r++) {
      for (int c = 0; c < _engine.N; c++) {
        if (_board[r][c] != _solution[r][c]) return false;
      }
    }
    return true;
  }

  void _checkEnd() {
    if (_finished) return;

    if (_isSolved()) {
      _finished = true;
      _persist();
      _showEndDialog(win: true);
      return;
    }

    if (_mode == GameMode.strict && _mistakes >= kMaxMistakes) {
      _finished = true;
      _persist();
      _showEndDialog(win: false);
    }
  }

  void _showEndDialog({required bool win}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          win ? 'Победа!' : 'Игра окончена',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: win ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(win
                ? 'Вы успешно решили судоку.'
                : 'Вы допустили $kMaxMistakes ошибки.'),
            const SizedBox(height: 8),
            Text(
              'Ошибок: $_mistakes',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              _startAnother();
            },
            child: const Text('Новая'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop();
            },
            child: const Text('В меню'),
          ),
        ],
      ),
    );
  }

  void _startAnother() {
    final p = generatePuzzle(mode: _mode);
    setState(() {
      _initFromPuzzle(p);
    });
    _persist();
  }
}