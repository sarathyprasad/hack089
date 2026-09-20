import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_provider.dart';
import '../../providers/chat_provider.dart';

class AIChatBotSheet extends StatefulWidget {
  const AIChatBotSheet({super.key});

  @override
  State<AIChatBotSheet> createState() => _AIChatBotSheetState();
}

class _AIChatBotSheetState extends State<AIChatBotSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    final lang = context.read<LanguageProvider>().currentLocale;
    context.read<ChatProvider>().sendMessage(text, lang);
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.primaryNavy,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.secondarySaffron, shape: BoxShape.circle),
                  child: const Icon(Icons.smart_toy, size: 20, color: Colors.black),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prithvi Fix AI Sahayak',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Instant Assistance in English, Hindi & Odia',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                  tooltip: 'Reset Chat',
                  onPressed: () => chatProv.clearChat(),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Suggested Prompts Chips
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: isDark ? AppColors.darkCard : null,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: chatProv.promptChips.length,
              itemBuilder: (context, index) {
                final prompt = chatProv.promptChips[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(prompt, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextPrimary : null)),
                    backgroundColor: isDark ? AppColors.darkCardAlt : const Color(0xFFF1F5F9),
                    side: isDark ? const BorderSide(color: AppColors.darkBorder) : null,
                    onPressed: () => _handleSend(prompt),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.borderLight),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatProv.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProv.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? (isDark ? AppColors.secondarySaffron.withValues(alpha: 0.9) : AppColors.primaryNavy)
                          : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(msg.isUser ? 12 : 2),
                        bottomRight: Radius.circular(msg.isUser ? 2 : 12),
                      ),
                      border: !msg.isUser && isDark ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: msg.isUser
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (chatProv.isSending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.secondarySaffron : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Sahayak is researching cooperative database...',
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ask in English, हिंदी, or ଓଡ଼ିଆ...',
                      hintStyle: TextStyle(color: isDark ? AppColors.darkTextMuted : null),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: isDark,
                      fillColor: isDark ? AppColors.darkBackground : null,
                      enabledBorder: isDark
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.darkBorder),
                            )
                          : null,
                    ),
                    onSubmitted: _handleSend,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppColors.secondarySaffron : AppColors.primaryNavy,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                  ),
                  onPressed: () => _handleSend(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
