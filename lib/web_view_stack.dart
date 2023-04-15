import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewStack extends StatefulWidget {
  const WebViewStack({Key? key}) : super(key: key);

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  var loadingPercentage = 0;
  late final WebViewController controller;


  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
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
        }
      ))..loadRequest(Uri.parse('https://flutter.dev'),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller,),
        if (loadingPercentage < 100)
          LinearProgressIndicator(value: loadingPercentage / 100.0,),
        // 이 문장만으로도 100 이 되면 더이상 이문장은 실행이 안되는거지.. 거기다. Stack 을 사용하였고..
/*
        if (loadingPercentage < 100)
          Center(child: CircularProgressIndicator(value: loadingPercentage / 100.0,))
*/
      ],
    );
  }
}
