import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'generator.dart';

class GameState {
  final int n;
  final GameMode mode;
  final List<List<int>> puzzle;
  final List<List<int>> board;
  final List<List<List<int>>> notes;
  final int mistakes;
  final bool finished;

  GameState({
    required this.n,
    required this.mode,
    required this.puzzle,
    required this.board,
    required this.notes,
    required this.mistakes,
    required this.finished,
  });

  Map<String, dynamic> toJson() => {
        'n': n,
        'mode': mode.index,
        'puzzle': puzzle,
        'board': board,
        'notes': notes,
        'mistakes': mistakes,
        'finished': finished,
      };

  factory GameState.fromJson(Map<String, dynamic> j) {
    return GameState(
      n: j['n'] as int,
      mode: GameMode.values[j['mode'] as int],
      puzzle: (j['puzzle'] as List)
          .map((r) => List<int>.from(r as List))
          .toList(),
      board: (j['board'] as List)
          .map((r) => List<int>.from(r as List))
          .toList(),
      notes: (j['notes'] as List)
          .map((row) => (row as List)
              .map((cell) => List<int>.from(cell as List))
              .toList())
          .toList(),
      mistakes: (j['mistakes'] as int?) ?? 0,
      finished: (j['finished'] as bool?) ?? false,
    );
  }
}

class Storage {
  static const _key = 'sudoku_save_v2';

  static Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }

  static Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}