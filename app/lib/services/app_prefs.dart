class AppPrefs {
  String? pairedDeviceName;
  String? pairedDeviceId;
  int? channel;
  String? meshKey;

  static final AppPrefs _i = AppPrefs._internal();
  AppPrefs._internal();
  factory AppPrefs() => _i;

  bool get isConfigured =>
      pairedDeviceId != null && channel != null && (meshKey?.isNotEmpty ?? false);
}
