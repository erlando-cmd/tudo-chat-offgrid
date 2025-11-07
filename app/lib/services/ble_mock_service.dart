import 'dart:async';
import 'dart:math';

class BleDevice {
  final String id;
  final String name;
  final int rssi;
  BleDevice({required this.id, required this.name, required this.rssi});
}

class BleMockService {
  /// Simula varredura BLE emitindo listas de devices periodicamente
  Stream<List<BleDevice>> scanStream() async* {
    final rand = Random();
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final base = <BleDevice>[
        BleDevice(id: "D1", name: "TUDO Mesh Node", rssi: -45 - rand.nextInt(10)),
        BleDevice(id: "D2", name: "Repetidor Sala Técnica", rssi: -60 - rand.nextInt(20)),
        BleDevice(id: "D3", name: "HT Portaria", rssi: -70 - rand.nextInt(25)),
      ];
      // às vezes “some” 1 para simular ambiente real
      if (rand.nextBool()) base.removeAt(rand.nextInt(base.length));
      yield base;
    }
  }

  /// Simula conexão
  Future<bool> connect(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // sempre conecta no mock
  }

  /// Simula configuração de canal e chave
  Future<bool> configure({
    required String deviceId,
    required int channel,
    required String meshKey,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return true;
  }
}
