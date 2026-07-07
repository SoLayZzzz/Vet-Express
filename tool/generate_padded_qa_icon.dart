import 'dart:io';

import 'package:image/image.dart' as img;

 void generatePaddedIcon({
   required String inputPath,
   required String outputPath,
 }) {
   final inputFile = File(inputPath);
   final outputFile = File(outputPath);
 
   final bytes = inputFile.readAsBytesSync();
   final source = img.decodeImage(bytes);
   if (source == null) {
     stderr.writeln('Unable to decode $inputPath');
     exit(1);
   }
 
   const canvasSize = 1024;
   const logoSize = 720;
   final resized = img.copyResize(
     source,
     width: logoSize,
     height: logoSize,
     interpolation: img.Interpolation.average,
   );
   final canvas = img.Image(width: canvasSize, height: canvasSize);
 
   img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
 
   final offsetX = (canvasSize - resized.width) ~/ 2;
   final offsetY = (canvasSize - resized.height) ~/ 2;
   img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
 
   outputFile.writeAsBytesSync(img.encodePng(canvas));
   stdout.writeln('Created ${outputFile.path}');
 }
 
void main() {
  generatePaddedIcon(
    inputPath: 'assets/images/vet_logo_qa.jpg',
    outputPath: 'assets/images/vet_logo_qa.jpgg',
  );
  generatePaddedIcon(
    inputPath: 'assets/images/VET_Express_logo.png',
    outputPath: 'assets/images/VET_Express_logo.jpg',
  );
}
