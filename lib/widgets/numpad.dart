import 'package:flutter/material.dart';

class NumPad extends StatelessWidget {
  final int N;
  final bool notesMode;
  final VoidCallback onToggleNotes;
  final ValueChanged<int> onDigit;
  final VoidCallback onErase;

  const NumPad({
    super.key,
    required this.N,
    required this.notesMode,
    required this.onToggleNotes,
    required this.onDigit,
    required this.onErase,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pill(
                  context,
                  active: notesMode,
                  icon: Icons.edit_note,
                  label: notesMode ? 'Пометки ВКЛ' : 'Пометки',
                  color: notesMode ? Colors.orange : scheme.primary,
                  onTap: onToggleNotes,
                ),
                const SizedBox(width: 8),
                _pill(
                  context,
                  active: false,
                  icon: Icons.backspace_outlined,
                  label: 'Стереть',
                  color: Colors.redAccent,
                  onTap: onErase,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (int d = 1; d <= N; d++)
                  SizedBox(
                    width: 44,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => onDigit(d),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: scheme.surfaceContainerHighest,
                        foregroundColor: scheme.onSurface,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '$d',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required bool active,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}