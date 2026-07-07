class ScanQrUiState {
  final int scanFrom;
  final bool flash;
  final bool isScanning;
  final bool isProcessing;

  const ScanQrUiState({
    this.scanFrom = 0,
    this.flash = false,
    this.isScanning = false,
    this.isProcessing = false,
  });

  ScanQrUiState copyWith({
    int? scanFrom,
    bool? flash,
    bool? isScanning,
    bool? isProcessing,
  }) => ScanQrUiState(
    scanFrom: scanFrom ?? this.scanFrom,
    flash: flash ?? this.flash,
    isScanning: isScanning ?? this.isScanning,
    isProcessing: isProcessing ?? this.isProcessing,
  );
}
