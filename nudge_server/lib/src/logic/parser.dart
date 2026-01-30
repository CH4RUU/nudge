import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:serverpod/serverpod.dart';

class NudgeParser {
  static const _apiKey = 'AIzaSyBssamC2Bx5vm_STP1GsBmCBoT88e8ipZQ';

  static Future<Map<String, dynamic>> analyze(
    String input,
    Session session,
  ) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: _apiKey,
      );

      final prompt =
          '''
Extract intent from: "$input"
Categories: TASK, GHOST, ASSET, CAPSULE, INTEL.

Rules for each type:
1. CAPSULE (Stopping/Freezing work):
   - "val": The current task being paused.
   - "delay": The specific NEXT step to take (String).
2. TASK (Reminders):
   - "val": The reminder title.
   - "delay": Minutes from now (Integer). Default to 5.
3. GHOST (Focus mode):
   - "val": The focus activity.
   - "delay": Duration in minutes (Integer). Default to 25.
4. ASSET (Warranty/Ownership):
   - "val": Item name.
   - "delay": Warranty years (Integer). Default to 1.
5. INTEL (Chat/Greetings/General Statements):
   - "val": A short, witty, and sophisticated one-sentence reply from the Butler to the user.
   - "delay": 0.

CRITICAL: For TASK, GHOST, and ASSET, the "delay" MUST be a raw number.

Format: {"type": "CATEGORY", "val": "value", "delay": "delay_value"}
''';
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null) throw Exception("AI response empty");

      session.log("GEMINI SUCCESS: ${response.text}");

      final cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanJson);
    } catch (e) {
      session.log("AI FAILURE: $e", level: LogLevel.error);
      session.log("AI FAILURE (Quota?): $e", level: LogLevel.error);

      // MASTER FALLBACK: If AI fails, we do a manual check so the demo doesn't die
      String inputLower = input.toLowerCase();
      if (inputLower.contains('remind') ||
          inputLower.contains('call') ||
          inputLower.contains('do')) {
        return {'type': 'TASK', 'val': input, 'delay': 1};
      } else if (inputLower.contains('focus') || inputLower.contains('work')) {
        return {'type': 'GHOST', 'val': input, 'delay': 25};
      }
      return {'type': 'INTEL', 'val': input, 'delay': 0};
    }
  }
}
