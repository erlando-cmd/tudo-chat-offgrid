import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'devices/devices_wizard_page.dart';

actions: [
  IconButton(
    tooltip: "Pesquisar",
    onPressed: () {},
    icon: const Icon(Icons.search),
  ),
  IconButton(
    tooltip: "Dispositivos",
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DevicesWizardPage()),
      );
    },
    icon: const Icon(Icons.bluetooth),
  ),
],


class ConversationItem {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int unread;
  ConversationItem({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    this.unread = 0,
  });
}

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final List<ConversationItem> _items = [
    ConversationItem(id:"1", title:"Equipe Segurança", lastMessage:"Ronda ok no bloco B.",
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)), unread: 2),
    ConversationItem(id:"2", title:"Base Repetidora", lastMessage:"Canal 3 configurado.",
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10))),
    ConversationItem(id:"3", title:"Erlando – TUDO TECH", lastMessage:"Fechou! Teste às 19h.",
      updatedAt: DateTime.now().subtract(const Duration(hours: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TUDO Chat"), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.bluetooth)),
      ]),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = _items[i];
          return ListTile(
            leading: CircleAvatar(
              radius: 22, backgroundColor: Colors.amber,
              child: Text(c.title.characters.first.toUpperCase(),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
            title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_fmtTime(c.updatedAt), style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 6),
              if (c.unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(999)),
                  child: Text("${c.unread}",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
            ]),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatPage(conversationId: c.id, title: c.title),
            )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      final h = dt.hour.toString().padLeft(2,'0');
      final m = dt.minute.toString().padLeft(2,'0');
      return "$h:$m";
    }
    return "${dt.day}/${dt.month}";
  }
}
