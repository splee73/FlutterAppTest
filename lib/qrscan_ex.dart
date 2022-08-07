import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:webview_flutter/webview_flutter.dart';

class QrView extends StatefulWidget {
  const QrView({Key? key}) : super(key: key);

  @override
  _QrViewState createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  late WebViewController _controller;
  var _qrString = "";
  final _homeUrl = "https://Coolest-Shade-of-Green-Cannon-Fodder-1.seungpillee.repl.co";

  Future<bool> _getStatuses() async {
    if (await Permission.camera.isGranted &&
        await Permission.storage.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future _scan() async {
    await _getStatuses();
    String? qrString = await scanner.scan();
    if (qrString != null) {
      setState(() {
        _qrString = qrString;
        _sendQRCode2WebView();
      });
    }
  }

  Future _sendQRCode2WebView() async {
    _controller.runJavascript('window.getQRCode("$_qrString")');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f3f9),
      body: WebView(
        initialUrl: _homeUrl,
        onWebViewCreated: (WebViewController webviewController) {
          _controller = webviewController;
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(name: 'JavaScriptChannel', onMessageReceived: (JavascriptMessage message) {
            _scan();
          })
        },
      ),
    );
  }
}