import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // للترجمة
import '../../core/ai/assistant_service.dart';
import '../../core/constants/app_colors.dart';

class AssistantFab extends StatefulWidget {
  final VoiceAssistant va;
  final GlobalKey<NavigatorState> navKey;

  const AssistantFab({
    super.key, 
    required this.va, 
    required this.navKey
  });

  @override
  State<AssistantFab> createState() => _AssistantFabState();
}

class _AssistantFabState extends State<AssistantFab> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  VoiceAssistant get _va => widget.va;

  void _onVaChanged() { if (mounted) setState(() {}); }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _va.addListener(_onVaChanged);
  }

  @override
  void dispose() {
    _va.removeListener(_onVaChanged);
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _closePanel();
    } else {
      _openPanel();
    }
  }

  void _openPanel() {
    if (_overlayEntry != null) return;
    
    final overlay = widget.navKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 90.0,
        right: context.locale.languageCode == 'ar' ? null : 20.0,
        left: context.locale.languageCode == 'ar' ? 20.0 : null,
        child: FadeTransition(
          opacity: _animationController,
          child: SlideTransition(
            position: _slideAnimation,
            child: _AssistantPanel(va: _va, onClose: _closePanel),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _animationController.forward();
    _va.stopAll(); 
  }

  Future<void> _closePanel() async {
    if (_overlayEntry == null || !_overlayEntry!.mounted) return;
    _va.stopAll();
    await _animationController.reverse();
    _removeOverlay();
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // حالة الزر العائم الخارجي
    bool isBusy = _va.isListening || _va.isSpeaking || _va.isProcessing;
    
    // تحديد النص بناء على الحالة
    String label = "ask_me".tr(); // الوضع الافتراضي
    if (_va.isListening) {
      label = "listening".tr();
    } else if (_va.isSpeaking) label = "speaking".tr();
    else if (_va.isProcessing) label = "...";

    return FloatingActionButton.extended(
      heroTag: 'assistant_fab',
      onPressed: _toggleOverlay,
      backgroundColor: isBusy ? AppColors.accent : AppColors.primary,
      icon: Icon(
        _va.isSpeaking ? Icons.volume_up : (_va.isListening ? Icons.graphic_eq : Icons.mic), 
        color: Colors.white
      ),
      label: Text(
        label, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
    );
  }
}

class _AssistantPanel extends StatefulWidget {
  final VoiceAssistant va;
  final VoidCallback onClose;
  const _AssistantPanel({required this.va, required this.onClose});

  @override
  State<_AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<_AssistantPanel> {
  String _liveTranscript = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.va.addListener(_scrollDown);
  }
  
  void _scrollDown() {
    if(mounted) setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
       }
    });
  }

  @override
  void dispose() {
    widget.va.removeListener(_scrollDown);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleTextSubmit() {
    if (_textController.text.trim().isEmpty) return;
    widget.va.processRequest(_textController.text, context);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final va = widget.va;
    
    // تحديد حالة الزر والنص والأيقونة
    String btnText = "ask_me".tr(); // "اضغط للتحدث"
    IconData btnIcon = Icons.mic;
    Color btnColor = AppColors.primary;

    if (va.isListening) {
      btnText = "listening".tr(); // "جاري الاستماع"
      btnIcon = Icons.graphic_eq;
      btnColor = Colors.redAccent;
    } else if (va.isSpeaking) {
      btnText = "speaking".tr(); // "يتحدث"
      btnIcon = Icons.volume_up;
      btnColor = Colors.green;
    } else if (va.isProcessing) {
      btnText = "...";
      btnIcon = Icons.hourglass_empty;
      btnColor = Colors.grey;
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Container(
        width: 340,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(children: [
              Text("Auto Mentor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose)
            ]),
            const Divider(),
            
            // Chat List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: va.chatHistory.length,
                itemBuilder: (ctx, i) {
                  final msg = va.chatHistory[i];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 260),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.accent.withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(msg['text'] ?? '', style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  );
                },
              ),
            ),
            
            // Live Transcript (نص الكلام المسموع لحظياً)
            if (va.isListening && _liveTranscript.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_liveTranscript, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            
            const Divider(),

            // Input Area (Text & Voice)
            // التعديل هنا: استخدام Flexible و ConstrainedBox لمنع الـ Overflow
            Row(
              children: [
                // 1. Text Field
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: "type_message".tr(), // "اكتب رسالتك..."
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleTextSubmit(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // 2. Send Button (for text)
                // تحجيم الزر ليأخذ مساحة ثابتة لا تزيد
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 40, maxWidth: 40),
                  child: CircleAvatar(
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    child: IconButton(
                      icon: Icon(Icons.send, color: AppColors.accent, size: 20),
                      onPressed: _handleTextSubmit,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 3. PTT Button (Push to Talk)
                GestureDetector(
                  onLongPressStart: (_) {
                    setState(() => _liveTranscript = '');
                    va.startListening(
                      onPartialResult: (p) => setState(() => _liveTranscript = p)
                    );
                  },
                  onLongPressEnd: (_) async {
                    await va.stopListening();
                    if (_liveTranscript.isNotEmpty) {
                       va.processRequest(_liveTranscript, context);
                       setState(() => _liveTranscript = '');
                    }
                  },
                  onTap: () {
                    if (va.isSpeaking) {
                      va.stopAll();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50,
                    // تقليل العرض قليلاً لضمان عدم الخروج عن الشاشة
                    width: va.isListening ? 110 : 50, 
                    decoration: BoxDecoration(
                      color: btnColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: btnColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(btnIcon, color: Colors.white),
                        if (va.isListening) ...[
                          const SizedBox(width: 4),
                          // استخدام Flexible لمنع النص من كسر التصميم
                          Flexible(
                            child: Text(
                              btnText, 
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, // قص النص لو طويل
                              maxLines: 1,
                            ),
                          )
                        ]
                      ],
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
}