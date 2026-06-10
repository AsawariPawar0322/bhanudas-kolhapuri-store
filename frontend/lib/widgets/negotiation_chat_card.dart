import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'hover_lift_wrapper.dart';

class Message {
  final String sender;
  final String text;
  final String time;
  final bool isMe;
  final Widget? customWidget;

  Message({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    this.customWidget,
  });
}

class NegotiationChatCard extends StatefulWidget {
  const NegotiationChatCard({super.key});

  @override
  State<NegotiationChatCard> createState() => _NegotiationChatCardState();
}

class _NegotiationChatCardState extends State<NegotiationChatCard> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _dealAccepted = false;

  @override
  void initState() {
    super.initState();
    // Seed initial message history
    _messages.addAll([
      Message(
        sender: 'Eleanor Vance',
        text: 'Hello, I am coordinating global sourcing for a boutique in London. We would like to order 50 pairs of Classic Tan Kolhapuris.',
        time: '2:15 PM',
        isMe: true,
      ),
      Message(
        sender: 'Sanand Master (AI Co-pilot)',
        text: 'Namaste! Sanand Master is currently hand-stitching a festival batch. I am his AI Sourcing assistant. 🧵\n\nFor 50 pairs, standard cost is ₹90,000. But since you are partnering with our co-op, I can offer a direct wholesale pricing: **₹76,500 (15% discount)** + free dispatch in our next logistics slot.',
        time: '2:16 PM',
        isMe: false,
      ),
    ]);

    // Add negotiation trigger widget to the second message
    _messages.add(
      Message(
        sender: 'System Offer',
        text: '',
        time: '2:16 PM',
        isMe: false,
        customWidget: _buildNegotiationOfferWidget(),
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final userText = _textController.text.trim();
    setState(() {
      _messages.add(
        Message(
          sender: 'Eleanor Vance',
          text: userText,
          time: 'Just now',
          isMe: true,
        ),
      );
      _textController.clear();
    });

    _scrollToBottom();

    // Simulated AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        if (userText.toLowerCase().contains('discount') || userText.toLowerCase().contains('cheaper')) {
          _messages.add(
            Message(
              sender: 'Sanand Master (AI Co-pilot)',
              text: 'Since we use 100% premium vegetable-tanned leather, we cannot reduce below 15%. However, I can bundle 2 extra customized pairs for free! Let me know if that works.',
              time: 'Just now',
              isMe: false,
            ),
          );
        } else {
          _messages.add(
            Message(
              sender: 'Sanand Master (AI Co-pilot)',
              text: 'Perfect! I have recorded that in our workshop logs. Feel free to complete the transaction or ask any customization details.',
              time: 'Just now',
              isMe: false,
            ),
          );
        }
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildNegotiationOfferWidget() {
    return StatefulBuilder(
      builder: (context, setOfferState) {
        if (_dealAccepted) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Text('✅', style: TextStyle(fontSize: 18)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Wholesale Sourcing Agreement Locked at ₹76,500! Sourcing order synced to ledger.',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('🤝 WHOLESALE DEAL PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                  Text('15% OFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '50× Classic Tan Kolhapuris',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Negotiated Offer: ₹76,500 (Standard: ₹90,000)',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _messages.add(Message(
                            sender: 'Eleanor Vance',
                            text: 'We would like to request an additional discount or bundle.',
                            time: 'Just now',
                            isMe: true,
                          ));
                        });
                        _sendMessage();
                      },
                      child: const Text('Counter Offer', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _dealAccepted = true;
                          _messages.add(
                            Message(
                              sender: 'Eleanor Vance',
                              text: 'Deal accepted! We agree to ₹76,500 for 50 pairs.',
                              time: 'Just now',
                              isMe: true,
                            ),
                          );
                          _messages.add(
                            Message(
                              sender: 'Sanand Master (AI Co-pilot)',
                              text: 'Shukriya! Sourcing order #1249 created. Checkout and deposits ledger has been updated.',
                              time: 'Just now',
                              isMe: false,
                            ),
                          );
                        });
                        _scrollToBottom();
                      },
                      child: const Text('Accept Price ✅', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HoverLiftWrapper(
      child: Container(
        height: 400,
        decoration: AppDecorations.glassCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👨‍🎨', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Sanand Master Workshop',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'AI Co-Pilot online • Sourcing portal active',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 20, color: AppTheme.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg.customWidget != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: msg.customWidget!,
                    );
                  }

                  return _buildChatBubble(msg);
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type message or counter offer...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(Message msg) {
    final bg = msg.isMe ? AppTheme.primaryColor : const Color(0xFFF1F5F9);
    final textCol = msg.isMe ? Colors.white : AppTheme.textPrimary;
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: msg.isMe ? const Radius.circular(16) : Radius.zero,
                bottomRight: msg.isMe ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(fontSize: 12.5, color: textCol, height: 1.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${msg.sender} • ${msg.time}',
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
