import 'package:cloud_firestore/cloud_firestore.dart';

class ChatLogger {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logMessage({
    required String userMessage,
    required String aiResponse,
  }) async {
    try {
      await _firestore.collection('conversations').add({
        'user_query': userMessage,
        'ai_reply': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        // ممكن نضيف userId لو عملنا login
      });
    } catch (e) {
      print("Error logging chat: $e");
    }
  }
}