import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../logic/parser.dart';

class NudgeDataEndpoint extends Endpoint {
  Future<String> create(Session session, String rawInput) async {
    var analysis = await NudgeParser.analyze(rawInput, session);

    var nudge = NudgeData(
      category: analysis['type'],
      title: analysis['val'],
      isDone: false,
    );

    await NudgeData.db.insertRow(session, nudge);

    // 3. Return the JSON string to your phone
    return jsonEncode(analysis);
  }

  Future<void> delete(Session session, NudgeData nudge) async {
    await NudgeData.db.deleteRow(session, nudge);
  }

  Future<List<NudgeData>> getAll(Session session) async {
    return await NudgeData.db.find(
      session,
      orderBy: (t) => t.id,
    );
  }
}
