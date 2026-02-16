import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

void main() {
  final w = 512;
  final h = 512;

  // Create raw RGBA pixels with filter bytes
  final raw = BytesBuilder();

  for (int y = 0; y < h; y++) {
    raw.addByte(0); // PNG filter: none
    for (int x = 0; x < w; x++) {
      final t = y / h;
      int r = (13 * (1 - t)).round().clamp(0, 255);
      int g = (71 + 6 * t).round().clamp(0, 255);
      int b = (28 + 36 * t).round().clamp(0, 255);

      final cx = w / 2.0;
      final cy = h / 2.0 - 20;
      final dx = x - cx;
      final dy = y - cy;
      final distMoon = sqrt(dx * dx + dy * dy);
      final dx2 = x - (cx + 60);
      final distCut = sqrt(dx2 * dx2 + dy * dy);
      final isMoon = distMoon <= 140 && distCut > 130;

      final sx = cx + 90;
      final sy = cy - 100;
      final isStar = sqrt((x - sx) * (x - sx) + (y - sy) * (y - sy)) <= 15;

      if (isMoon || isStar) {
        raw.add([255, 255, 255, 255]);
      } else {
        raw.add([r, g, b, 255]);
      }
    }
  }

  final rawBytes = raw.toBytes();
  final compressed = ZLibCodec(level: 9).encode(rawBytes);

  final png = BytesBuilder();
  png.add([137, 80, 78, 71, 13, 10, 26, 10]); // PNG signature
  png.add(_makeChunk([73, 72, 68, 82], _ihdr(w, h))); // IHDR
  png.add(_makeChunk([73, 68, 65, 84], Uint8List.fromList(compressed))); // IDAT
  png.add(_makeChunk([73, 69, 78, 68], Uint8List(0))); // IEND

  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final file = File('assets/icon/ramadhan_tracker_icon.png');
  file.writeAsBytesSync(png.toBytes());
  print('Icon generated: ${file.lengthSync()} bytes');
}

Uint8List _ihdr(int w, int h) {
  final data = ByteData(13);
  data.setUint32(0, w);
  data.setUint32(4, h);
  data.setUint8(8, 8); // bit depth
  data.setUint8(9, 6); // RGBA
  data.setUint8(10, 0);
  data.setUint8(11, 0);
  data.setUint8(12, 0);
  return data.buffer.asUint8List();
}

List<int> _makeChunk(List<int> type, Uint8List data) {
  final result = BytesBuilder();
  final lenData = ByteData(4);
  lenData.setUint32(0, data.length);
  result.add(lenData.buffer.asUint8List());
  result.add(type);
  result.add(data);

  // CRC32
  final crcInput = BytesBuilder();
  crcInput.add(type);
  crcInput.add(data);
  final crc = _crc32(crcInput.toBytes());
  final crcData = ByteData(4);
  crcData.setUint32(0, crc);
  result.add(crcData.buffer.asUint8List());

  return result.toBytes();
}

int _crc32(List<int> data) {
  int crc = 0xFFFFFFFF;
  for (int i = 0; i < data.length; i++) {
    int byte = data[i];
    for (int j = 0; j < 8; j++) {
      if (((crc ^ byte) & 1) == 1) {
        crc = ((crc >> 1) & 0x7FFFFFFF) ^ 0xEDB88320;
      } else {
        crc = (crc >> 1) & 0x7FFFFFFF;
      }
      byte >>= 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}
