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
  var _qrString = "Empty Scan Code";
  var _appTitle = "쏘~쿨한 탄소생활";
  var _qrTestUrl = "https://webapp-vxemf.run.goorm.io/WebApp/index.html";
  var _homeUrl = "https://coolest-shade-of-green-python-version.martianappletre.repl.co/home";

  Future<bool> _getStatuses() async {
    Map<Permission, PermissionStatus> statuses =
    await [Permission.storage, Permission.camera].request();

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
    if (_controller != null) {
      _controller.evaluateJavascript('window.fromFlutter("$_qrString")');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f3f9),
      appBar: AppBar(
          title: Text(_appTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 600,
            child: WebView(
              initialUrl: _qrTestUrl,
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
          ),
          SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    tooltip: 'Home',
                    onPressed: () {
                      _controller.loadUrl(_homeUrl);
                    },
                    child: const Icon(Icons.home),
                  ),
                  FloatingActionButton(
                    tooltip: 'Scan QR Code',
                    onPressed: () {
                      _controller.loadUrl(_qrTestUrl);
                      _scan();
                    },
                    child: const Icon(Icons.qr_code),
                  ),
                  FloatingActionButton(
                    tooltip: 'QR Test Home',
                    onPressed: () {
                      _controller.loadUrl(_qrTestUrl);
                    },
                    child: const Icon(Icons.thumb_up),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}