import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  File? _image;
  final picker = ImagePicker();
  late WebViewController _controller;

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장
    });
  }

  // 이미지를 보여주는 위젯
  Widget showImage() {
    return Container(
        color: const Color(0xffd0cece),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Center(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(File(_image!.path))));
  }

  @override
  Widget build(BuildContext context) {
    // 화면 세로 고정
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
        backgroundColor: const Color(0xfff4f3f9),
        appBar: AppBar(
          title: ElevatedButton(
            child: Text('send to javascript'),
            onPressed: () {
              if (_controller != null) {
                _controller.evaluateJavascript('window.fromFlutter("this is title from Flutter")');
              }
            },
          )
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 500,
              child: WebView(
                initialUrl: 'https://webapp-vxemf.run.goorm.io/WebApp/',
                onWebViewCreated: (WebViewController webviewController) {
                  _controller = webviewController;
                },
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: Set.from([
                  JavascriptChannel(name: 'JavaScriptChannel', onMessageReceived: (JavascriptMessage message) {
                    print(message.message);
                  })
                ]),
              ),
            ),
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // 카메라 촬영 버튼
                  FloatingActionButton(
                    child: Icon(Icons.add_a_photo),
                    tooltip: 'pick Iamge',
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                  ),
                  // 갤러리에서 이미지를 가져오는 버튼
                  FloatingActionButton(
                    child: Icon(Icons.wallpaper),
                    tooltip: 'pick Iamge',
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                  ),
                ],
              )
            )
           ],
        ),
    );
  }
}