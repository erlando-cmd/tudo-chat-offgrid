import 'package:flutter/material.dart';
import '../features/chat_page.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  final String time;
  final MsgStatus? status;

  const ChatBubble({
    super.key,
    required this.text,
    required this.mine,
    required this.time,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    const mineBg   = Color(0xFFFFCC00); // amarelo
    const mineText = Color(0xFF0F1115); // preto
    const otherBg  = Color(0xFF1C2230); // grafite
    const otherTxt = Color(0xFFE5E7EB);

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: mine ? mineBg : otherBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SelectableText(
            text,
            style: TextStyle(
              color: mine ? mineText : otherTxt,
              fontSize: 16,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: (mine ? mineText : otherTxt).withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              if (mine && status != null) ...[
                const SizedBox(width: 6),
                _StatusIcon(status: status!),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [bubble],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MsgStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (status) {
      case MsgStatus.sending:
        icon = Icons.access_time_rounded; break;      // relógio
      case MsgStatus.sent:
        icon = Icons.check_rounded; break;            // um tique
      case MsgStatus.delivered:
        icon = Icons.done_all_rounded; break;         // dois tiques
    }
    return Icon(icon, size: 16);
  }
}
