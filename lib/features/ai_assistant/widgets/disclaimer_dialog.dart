import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccepted;
  const DisclaimerDialog({super.key, required this.onAccepted});

  static const _prefKey = 'ai_disclaimer_accepted';

  static Future<bool> wasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('☪',
                    style: TextStyle(fontSize: 30, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Important Notice',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.amber.shade900.withValues(alpha: 0.2)
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade400.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'This AI Assistant is designed to help you explore Islamic knowledge. However:\n\n'
                '• AI can make mistakes and may sometimes provide incorrect information.\n'
                '• Always double-check Islamic rulings with a qualified scholar.\n'
                '• This tool does NOT replace a real Islamic scholar (Mufti/Alim).\n'
                '• Verify important answers from trusted sources such as IslamQA, Dar al-Ifta, or a local mosque.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: isDark
                      ? Colors.amber.shade200
                      : Colors.orange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await DisclaimerDialog.markAccepted();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onAccepted();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'I Understand, Continue',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
