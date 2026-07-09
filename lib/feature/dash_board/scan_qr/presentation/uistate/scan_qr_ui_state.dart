// import 'dart:ui';

// class ScanQrUiState {
//   final int scanFrom;
//   final bool flash;
//   final bool isScanning;
//   final bool isProcessing;
//   final bool isCaptureZooming;
//   final String detectedCode;
//   final Rect? detectedQrRect;
//   final Size? detectedCaptureSize;

//   const ScanQrUiState({
//     this.scanFrom = 0,
//     this.flash = false,
//     this.isScanning = false,
//     this.isProcessing = false,
//     this.isCaptureZooming = false,
//     this.detectedCode = '',
//     this.detectedQrRect,
//     this.detectedCaptureSize,
//   });

//   ScanQrUiState copyWith({
//     int? scanFrom,
//     bool? flash,
//     bool? isScanning,
//     bool? isProcessing,
//     bool? isCaptureZooming,
//     String? detectedCode,
//     Rect? detectedQrRect,
//     Size? detectedCaptureSize,
//     bool clearDetectedQrRect = false,
//   }) => ScanQrUiState(
//     scanFrom: scanFrom ?? this.scanFrom,
//     flash: flash ?? this.flash,
//     isScanning: isScanning ?? this.isScanning,
//     isProcessing: isProcessing ?? this.isProcessing,
//     isCaptureZooming: isCaptureZooming ?? this.isCaptureZooming,
//     detectedCode: detectedCode ?? this.detectedCode,
//     detectedQrRect:
//         clearDetectedQrRect ? null : detectedQrRect ?? this.detectedQrRect,
//     detectedCaptureSize:
//         clearDetectedQrRect
//             ? null
//             : detectedCaptureSize ?? this.detectedCaptureSize,
//   );
// }


import 'dart:typed_data';
import 'dart:ui';

class ScanQrUiState {
  final int scanFrom;
  final bool flash;
  final bool isScanning;
  final bool isProcessing;
  final bool isCaptureZooming;
  final bool isQrDetected;  
  final bool isLaserActive; 
  final String detectedCode;
  final Rect? detectedQrRect;
  final Size? detectedCaptureSize;
  final Uint8List? capturedImage; // <-- Add this to store the frozen frame

  const ScanQrUiState({
    this.scanFrom = 0,
    this.flash = false,
    this.isScanning = false,
    this.isProcessing = false,
    this.isCaptureZooming = false,
    this.isQrDetected = false,
    this.isLaserActive = false,
    this.detectedCode = '',
    this.detectedQrRect,
    this.detectedCaptureSize,
    this.capturedImage,
  });

  ScanQrUiState copyWith({
    int? scanFrom,
    bool? flash,
    bool? isScanning,
    bool? isProcessing,
    bool? isCaptureZooming,
    bool? isQrDetected,
    bool? isLaserActive,
    String? detectedCode,
    Rect? detectedQrRect,
    Size? detectedCaptureSize,
    Uint8List? capturedImage,
    bool clearDetectedQrRect = false,
  }) => ScanQrUiState(
    scanFrom: scanFrom ?? this.scanFrom,
    flash: flash ?? this.flash,
    isScanning: isScanning ?? this.isScanning,
    isProcessing: isProcessing ?? this.isProcessing,
    isCaptureZooming: isCaptureZooming ?? this.isCaptureZooming,
    isQrDetected: isQrDetected ?? this.isQrDetected,
    isLaserActive: isLaserActive ?? this.isLaserActive,
    detectedCode: detectedCode ?? this.detectedCode,
    capturedImage: capturedImage ?? this.capturedImage,
    detectedQrRect:
        clearDetectedQrRect ? null : detectedQrRect ?? this.detectedQrRect,
    detectedCaptureSize:
        clearDetectedQrRect
            ? null
            : detectedCaptureSize ?? this.detectedCaptureSize,
  );
}