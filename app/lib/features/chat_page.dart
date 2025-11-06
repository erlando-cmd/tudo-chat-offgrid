import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';

enum MsgStatus { sending, sent, delivered }

class Message {
  final String id, text;
  final bool mine;
  final DateTime ts;
  final MsgStatus status;
  Message({required this.id, required this.text, required this.mine, required this.ts, required this.status});
  Message copyWith({MsgStatus? status}) =>
      Message(id: id, text: text, mine: mine, ts: ts, status: status ?? this.status);
}

class ChatPage extends StatefulWidget {
  final String conversationId, title;
  const ChatPage({super.key, required this.conversationId, required this.title});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    Message(id:"a1", text:"Canal 7 ativo?", mine:true,  ts:DateTime.now().subtract(const Duration(minutes:5)), status:MsgStatus.delivered),
    Message(id:"a2", text:"Sim. Sinal bom aqui.", mine:false, ts:DateTime.now().subtract(const Duration(minutes:4)), status:MsgStatus.delivered),
  ];
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() { _input.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final txt = _input.text.trim();
    if (txt.isEmpty) return;
    final msg = Message(id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: txt, mine: true, ts: DateTime.now(), status: MsgStatus.sending);
    setState(()=> _messages.add(msg));
    _input.clear(); _scrollToEnd();

    Future.delayed(const Duration(milliseconds:800), (){
      final i = _messages.indexWhere((m)=>m.id==msg.id);
      if (i>=0) setState(()=> _messages[i] = _messages[i].copyWith(status: MsgStatus.sent));
    });
    Future.delayed(const Duration(seconds:2), (){
      final i = _messages.indexWhere((m)=>m.id==msg.id);
      if (i>=0) setState(()=> _messages[i] = _messages[i].copyWith(status: MsgStatus.delivered));
    });
    Future.delayed(const Duration(seconds:3), (){
      setState(()=> _messages.add(Message(
        id:"${msg.id}-r", text:"Recebido ✅", mine:false, ts:DateTime.now(), status:MsgStatus.delivered)));
      _scrollToEnd();
    });
  }

  void _scrollToEnd(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent+120,
          duration: const Duration(milliseconds:250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.info_outline))]),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal:12, vertical:16),
          itemCount: _messages.length,
          itemBuilder: (_, i){
            final m = _messages[i];
            return ChatBubble(text:m.text, mine:m.mine, time:_fmtTime(m.ts), status: m.mine? m.status:null);
          },
        )),
        _InputBar(controller:_input, onSend:_send),
      ]),
    );
  }

  String _fmtTime(DateTime dt){
    final h = dt.hour.toString().padLeft(2,'0');
    final m = dt.minute.toString().padLeft(2,'0');
    return "$h:$m";
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top:false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12,8,12,12),
        child: Row(children: [
          Expanded(child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_)=> onSend(),
            decoration: const InputDecoration(hintText: "Mensagem"),
          )),
          const SizedBox(width:10),
          FilledButton(
            onPressed: onSend,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal:18, vertical:14)),
            child: const Icon(Icons.send_rounded),
          )
        ]),
      ),
    );
  }
}
