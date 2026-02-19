class ScanQrUiState {
  final int scanFrom;
  final bool flash;
  final bool isScanning;

  const ScanQrUiState({
    this.scanFrom = 0,
    this.flash = false,
    this.isScanning = false,
  });

  ScanQrUiState copyWith({
    int? scanFrom,
    bool? flash,
    bool? isScanning,
  }) => ScanQrUiState(
    scanFrom: scanFrom ?? this.scanFrom,
    flash: flash ?? this.flash,
    isScanning: isScanning ?? this.isScanning,
  );
}
