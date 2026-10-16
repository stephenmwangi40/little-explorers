// Tiny static server for previewing the web build: dart run tool/serve.dart
import 'dart:io';

Future<void> main(List<String> args) async {
  final root = Directory(args.isNotEmpty ? args[0] : 'build/web').absolute.path;
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8765;
  const types = {
    'html': 'text/html', 'js': 'application/javascript', 'mjs': 'application/javascript', 'json': 'application/json',
    'wasm': 'application/wasm', 'png': 'image/png', 'otf': 'font/otf', 'ttf': 'font/ttf', 'wav': 'audio/wav',
    'css': 'text/css', 'ico': 'image/x-icon', 'svg': 'image/svg+xml',
  };
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Serving $root at http://localhost:$port');
  await for (final req in server) {
    var path = Uri.decodeComponent(req.uri.path);
    if (path == '/' || path.isEmpty) path = '/index.html';
    final f = File('$root$path');
    if (!f.path.startsWith(root) || !await f.exists()) {
      req.response.statusCode = 404;
      await req.response.close();
      continue;
    }
    req.response.headers.contentType = ContentType.parse(types[path.split('.').last] ?? 'application/octet-stream');
    await req.response.addStream(f.openRead());
    await req.response.close();
  }
}
