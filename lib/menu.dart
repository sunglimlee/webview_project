
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
}

class Menu extends StatefulWidget {
  final WebViewController controller;
  const Menu({Key? key, required this.controller}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(onSelected: (value) async {
      switch (value) {
        case _MenuOptions.navigationDelegate :
          await widget.controller.loadRequest(Uri.parse('https://www.youtube.com'));
          break;
        case _MenuOptions.userAgent :
          // 말그대로 자바스크립트를 여기서 바로 실행시키는 거네.. 그래서 값을 받아와서 받은 값을 내가 처리하는 거네..
          final userAgent = await widget.controller
              .runJavaScriptReturningResult('navigator.userAgent');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$userAgent')));
          break;
        case _MenuOptions.javascriptChannel :
          // 이 메뉴를 선택함으로서 여기 콜백함수에 자바스크립트문을 넣어서 실제로 실행한다.
          // 그러면서 중요한게
          // 1. 콜백함수를 이용한다는 것
          // 2. 그 콜백함수에 자바스크립트를 사용한다는것
          // 3. 그 결과 값을 channel 에 정해진 객체의 이름을 통해 값을 넘겨준다는 것
          // 4. 받은 메세지의 값을 이용해서 내 앱에서 즉 Dart 에서 사용한다는 것
          await widget.controller.runJavaScript('''
          var req = new XMLHttpRequest();
          req.open('GET', "https://api.ipify.org/?format=json");
req.onload = function() {
  if (req.status == 200) {
    let response = JSON.parse(req.responseText);
    SnackBar.postMessage("IP Address: " + response.ip);
  } else {
    SnackBar.postMessage("Error: " + req.status);
  }
}
req.send();''');
          break;
      }
    } ,
        itemBuilder: (context) {
      return [
        const PopupMenuItem(value: _MenuOptions.navigationDelegate, child: Text('Navigate to YouTube'),),
        const PopupMenuItem(value: _MenuOptions.userAgent, child: Text('Show User Agent'),),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.javascriptChannel,
          child: Text('Lookup IP Address'),
        ),
      ];
    });
  }
}
