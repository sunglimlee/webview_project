import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  final WebViewController _controller;
  const WebViewStack({Key? key, required WebViewController controller}) : _controller = controller, super(key: key);

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  //late final WebViewController controller;


  @override
  void initState() {
    super.initState();
    widget._controller..setNavigationDelegate(
        NavigationDelegate(
        onPageStarted: (url) {setState(() {
          loadingPercentage = 0;
        });},
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            if (host.contains('youtube.com')) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blocking navigation to $host'),),);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
      ))..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 여기 addJavaScriptChannel 을 이 함수를 가지고 넣어 놓으면 콜백을 실행하면서 동시에 여기 채널을 통해서 있는 객체를 가지고 Dart 에 값을 넘길 수 있게 된다.
    ..addJavaScriptChannel('SnackBar', onMessageReceived: (message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.message),));
    });

  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: widget._controller,),
        if (loadingPercentage < 100)
          LinearProgressIndicator(value: loadingPercentage / 100.0,),
      ],
    );
  }
}
