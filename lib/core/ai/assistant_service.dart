import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'voice_triggers.dart' as vt;
import 'tts.dart';
import 'chat_logger.dart';
import 'system_prompt.dart';

class VoiceAssistant extends ChangeNotifier {
  late stt.SpeechToText _speech;
  final String userId;
  final String sessionId;
  late final ChatLogger _logger;

  // بيانات المستخدم (يمكن جلبها من البروفايل لاحقاً)
  final String userName = "اوتو مينتور";
  final String carModel = "كيا سيراتو";
  final String location = "القاهرة";

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isProcessing => _isProcessing;

  final ElevenLabsTTS _tts = ElevenLabsTTS(
    apiKey: Secrets.elevenLabsApiKey,
    voiceId: Secrets.elevenLabsVoiceId,
    modelId: Secrets.elevenLabsModelId,
  );

  // قائمة الرسائل (History)
  final List<Map<String, String>> chatHistory = [];
  void Function(String route)? onRouteDetected;

  VoiceAssistant({required this.userId, required this.sessionId}) {
    _speech = stt.SpeechToText();
    OpenAI.apiKey = Secrets.openAiApiKey;
    _logger = ChatLogger();
  }

Future<void> _logToFirebase(String text, String sender) async {
    try {
      await FirebaseFirestore.instance.collection('chat_logs').add({
        'sessionId': sessionId,      // عشان نعرف أي جلسة دي
        'userId': userId,            // مين المستخدم
        'text': text,                // نص الرسالة
        'sender': sender,            // user ولا assistant
        'timestamp': FieldValue.serverTimestamp(), // الوقت بالظبط
        'date': DateTime.now().toString(), // للتسهيل في القراءة
      });
    } catch (e) {
      print("Error logging to Firestore: $e");
      // لن نوقف التطبيق إذا فشل التسجيل (Fail Silently)
    }
  }
  void stopAll() {
    if (_isListening) _speech.stop();
    if (_isSpeaking) _tts.stop();
    _isListening = false;
    _isSpeaking = false;
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> startListening({Function(String)? onPartialResult}) async {
    if (_isSpeaking || _isProcessing || _isListening) return;

    bool available = await _speech.initialize();
    if (!available) return;

    _isListening = true;
    notifyListeners();

    _speech.listen(
      onResult: (val) {
        onPartialResult?.call(val.recognizedWords);
      },
      localeId: 'ar-EG',
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 30),
    );
  }

  Future<void> processRequest(String userQuery, BuildContext context) async {
    if (userQuery.trim().isEmpty) return;
    if (_isListening) await stopListening();

    _isProcessing = true;
    notifyListeners();

    // إضافة رسالة المستخدم
    chatHistory.add({"sender": "user", "text": userQuery});
    _logger.logMessage(userMessage: userQuery, aiResponse: "...");

    // 1. فحص التوجيه (Routing) والرد الذكي
    final intent = vt.detectRouteIntent(userQuery);
    if (intent.route != null) {
      // الرد بالرسالة المحددة في voice_triggers
      String reply = intent.reply ?? "حاضر يا هندسة، جاري الفتح.";
      
      chatHistory.add({"sender": "assistant", "text": reply});
      _logToFirebase(reply, "assistant");
      onRouteDetected?.call(intent.route!); // تنفيذ التوجيه
      
      _isProcessing = false;
      await _speakResponse(reply);
      return;
    }

    // 2. OpenAI Chat (مع الذاكرة)
    try {
      // بناء سجل المحادثة لإرساله (آخر 6 رسائل فقط لتوفير التوكينز)
      List<OpenAIChatCompletionChoiceMessageModel> messages = [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            SystemPrompts.getCarConsultant(userName, carModel, location)
          )],
        ),
      ];

      // إضافة آخر 6 رسائل من الهيستوري
      int start = chatHistory.length > 6 ? chatHistory.length - 6 : 0;
      for (int i = start; i < chatHistory.length; i++) {
        final msg = chatHistory[i];
        messages.add(OpenAIChatCompletionChoiceMessageModel(
          role: msg['sender'] == 'user' ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(msg['text']!)],
        ));
      }

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.5, // إبداع متوازن
        maxTokens: 120,   // ردود قصيرة ومفيدة
      );

      String response = chatCompletion.choices.first.message.content?.first.text ?? "معلش مسمعتش كويس";
      
      chatHistory.add({"sender": "assistant", "text": response});
      _logger.logMessage(userMessage: userQuery, aiResponse: response);

_logToFirebase(response, "assistant");

      _isProcessing = false;
      await _speakResponse(response);

    } catch (e) {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _speakResponse(String text) async {
    _isSpeaking = true;
    notifyListeners();
    
    await _tts.speak(text, onComplete: () {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.dispose();
    super.dispose();
  }
}