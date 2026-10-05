import 'package:flutter/material.dart';
import '../generator.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  GameMode _mode = GameMode.unique;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              scheme.secondaryContainer,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(context),
                  const SizedBox(height: 32),
                  _section(context, 'Режим', [
                    _chip('Обычный', _mode == GameMode.relaxed,
                        () => setState(() => _mode = GameMode.relaxed)),
                    _chip('Одно решение', _mode == GameMode.unique,
                        () => setState(() => _mode = GameMode.unique)),
                    _chip('Логический', _mode == GameMode.logical,
                        () => setState(() => _mode = GameMode.logical)),
                    _chip('С проигрышем', _mode == GameMode.strict,
                        () => setState(() => _mode = GameMode.strict)),
                  ]),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _startNew(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Новая игра'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _continueSaved(context),
                    icon: const Icon(Icons.restore),
                    label: const Text('Продолжить'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.grid_4x4, size: 72, color: scheme.primary),
        const SizedBox(height: 8),
        Text(
          'СУДОКУ',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  void _startNew(BuildContext context) {
    final puzzle = generatePuzzle(mode: _mode);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameScreen(puzzle: puzzle, isNew: true),
    ));
  }

  Future<void> _continueSaved(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const GameScreen(isNew: false),
    ));
  }
}