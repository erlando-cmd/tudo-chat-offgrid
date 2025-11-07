import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/ble_mock_service.dart';
import '../../services/app_prefs.dart';

class DevicesWizardPage extends StatefulWidget {
  const DevicesWizardPage({super.key});

  @override
  State<DevicesWizardPage> createState() => _DevicesWizardPageState();
}

class _DevicesWizardPageState extends State<DevicesWizardPage> {
  final _page = PageController();
  final _ble = BleMockService();
  StreamSubscription? _sub;

  // Estado do wizard
  List<BleDevice> _found = [];
  BleDevice? _selected;
  bool _connecting = false;

  int _channel = 7;
  final _keyCtrl = TextEditingController(text: "TUDO-TECH-0001");
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _sub?.cancel();
    _sub = _ble.scanStream().listen((list) {
      setState(() => _found = list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _page.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _goStep2(BleDevice d) async {
    setState(() {
      _selected = d;
      _connecting = true;
    });
    final ok = await _ble.connect(d.id);
    setState(() => _connecting = false);
    if (ok && mounted) _page.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final ok = await _ble.configure(
      deviceId: _selected!.id,
      channel: _channel,
      meshKey: _keyCtrl.text.trim(),
    );
    setState(() => _saving = false);

    if (ok && mounted) {
      final prefs = AppPrefs();
      prefs.pairedDeviceId = _selected!.id;
      prefs.pairedDeviceName = _selected!.name;
      prefs.channel = _channel;
      prefs.meshKey = _keyCtrl.text.trim();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Configuração concluída"),
          content: Text(
            "Dispositivo: ${prefs.pairedDeviceName}\n"
            "Canal: ${prefs.channel}\n"
            "Chave: ${prefs.meshKey}",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
          ],
        ),
      ).then((_) => Navigator.of(context).pop(true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurar Dispositivo")),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1Scan(
            devices: _found,
            onRefresh: _startScan,
            onSelect: _goStep2,
            connectingId: _connecting ? _selected?.id : null,
          ),
          _Step2Channel(
            device: _selected,
            channel: _channel,
            onChangeChannel: (v) => setState(() => _channel = v),
            onNext: () => _page.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
            onBack: () => _page.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
          ),
          _Step3Key(
            device: _selected,
            keyCtrl: _keyCtrl,
            saving: _saving,
            onBack: () => _page.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
            onFinish: _finish,
          ),
        ],
      ),
    );
  }
}

class _Step1Scan extends StatelessWidget {
  final List<BleDevice> devices;
  final VoidCallback onRefresh;
  final void Function(BleDevice) onSelect;
  final String? connectingId;

  const _Step1Scan({
    required this.devices,
    required this.onRefresh,
    required this.onSelect,
    required this.connectingId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(title: "1/3 • Procurar dispositivo"),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final d = devices[i];
                final isConnecting = connectingId == d.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber, foregroundColor: Colors.black,
                    child: Text(d.name.characters.first.toUpperCase()),
                  ),
                  title: Text(d.name),
                  subtitle: Text("RSSI ${d.rssi} dBm"),
                  trailing: isConnecting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: () => onSelect(d),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Procurar novamente"),
          ),
        ),
      ],
    );
  }
}

class _Step2Channel extends StatelessWidget {
  final BleDevice? device;
  final int channel;
  final ValueChanged<int> onChangeChannel;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2Channel({
    required this.device,
    required this.channel,
    required this.onChangeChannel,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final channels = const [1, 3, 5, 7, 9, 12];
    return Column(
      children: [
        const _Header(title: "2/3 • Conectar e escolher canal"),
        if (device != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.bluetooth_connected, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text("Conectado a: ${device!.name}")),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: "Canal LoRa Mesh"),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: channel,
                isExpanded: true,
                items: channels.map((c) => DropdownMenuItem(value: c, child: Text("Canal $c"))).toList(),
                onChanged: (v) => v != null ? onChangeChannel(v) : null,
              ),
            ),
          ),
        ),
        const Spacer(),
        _NavBar(
          left: TextButton(onPressed: onBack, child: const Text("Voltar")),
          right: FilledButton.icon(onPressed: onNext, icon: const Icon(Icons.arrow_forward), label: const Text("Avançar")),
        ),
      ],
    );
  }
}

class _Step3Key extends StatelessWidget {
  final BleDevice? device;
  final TextEditingController keyCtrl;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  const _Step3Key({
    required this.device,
    required this.keyCtrl,
    required this.saving,
    required this.onBack,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Header(title: "3/3 • Definir chave da rede"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: keyCtrl,
            decoration: const InputDecoration(
              labelText: "Chave (mesh key)",
              hintText: "Ex.: TUDO-TECH-0001",
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Use a mesma chave em todos os nós para participarem da mesma rede. "
            "Depois podemos trocar por pareamento seguro.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Spacer(),
        _NavBar(
          left: TextButton(onPressed: onBack, child: const Text("Voltar")),
          right: FilledButton.icon(
            onPressed: saving ? null : onFinish,
            icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                         : const Icon(Icons.check_rounded),
            label: Text(saving ? "Salvando..." : "Concluir"),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _NavBar extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _NavBar({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            left,
            const Spacer(),
            right,
          ],
        ),
      ),
    );
  }
}
