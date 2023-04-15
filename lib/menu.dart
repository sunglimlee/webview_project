import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
  userAgent,
  javascriptChannel,
  listCookies,
  clearCookies,
  addCookie,
  setCookie,
  removeCookie,
  loadFlutterAsset,
  loadLocalFile,
  loadHtmlString,
}


const String kExamplePage = '''
<!DOCTYPE html>
<html lang="en">
<head>
<title>Load file or HTML string example</title>
</head>
<body>

<h1>Local demo page</h1>
<p>
 This is an example page used to demonstrate how to load a local file or HTML
 string using the <a href="https://pub.dev/packages/webview_flutter">Flutter
 webview</a> plugin.
</p>

</body>
</html>
''';



class Menu extends StatefulWidget {
  final WebViewController controller;
  const Menu({Key? key, required this.controller}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final cookieManager = WebViewCookieManager();


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
        case _MenuOptions.clearCookies:
          await _onClearCookies();
          break;
        case _MenuOptions.listCookies:
          await _onListCookies(widget.controller);
          break;
        case _MenuOptions.addCookie:
          await _onAddCookie(widget.controller);
          break;
        case _MenuOptions.setCookie:
          await _onSetCookie(widget.controller);
          break;
        case _MenuOptions.removeCookie:
          await _onRemoveCookie(widget.controller);
          break;
        case _MenuOptions.loadFlutterAsset:
          await _onLoadFlutterAssetExample(widget.controller, context);
          break;
        case _MenuOptions.loadLocalFile:
          await _onLoadLocalFileExample(widget.controller, context);
          break;
        case _MenuOptions.loadHtmlString:
          await _onLoadHtmlStringExample(widget.controller, context);
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
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.clearCookies,
          child: Text('Clear cookies'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.listCookies,
          child: Text('List cookies'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.addCookie,
          child: Text('Add cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.setCookie,
          child: Text('Set cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.removeCookie,
          child: Text('Remove cookie'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadFlutterAsset,
          child: Text('Load Flutter Asset'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadHtmlString,
          child: Text('Load HTML string'),
        ),
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loadLocalFile,
          child: Text('Load local file'),
        ),
      ];
    });
  }

  Future<void> _onListCookies(WebViewController controller) async {
    final String cookies = await controller
        .runJavaScriptReturningResult('document.cookie') as String;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
    Text(cookies.isNotEmpty ? cookies : 'There are no cookies')));
  }

  Future<void> _onClearCookies() async {
    final hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now , they are gone!';
    if (!hadCookies) {
      message = 'There weere no cookies to clear';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onAddCookie(WebViewController controller) async {
    await controller.runJavaScript('''
    var date = new Date();
  date.setTime(date.getTime()+(30*24*60*60*1000));
  document.cookie = "FirstName=John; expires=" + date.toGMTString();'''
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom cookie added')));
  }

  // add 도 되고 set 도 된다. set 은 cookieManager 로 가능하고
  Future<void> _onSetCookie(WebViewController controller) async {
    await cookieManager.setCookie(
      const WebViewCookie(name: 'foo', value: 'bar', domain: 'flutter.dev'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie is set.'),
      ),
    );
  }

  // You can delete a cookie by updating its expiration time to zero. 0 으로 만들면 지울 수 있다.
  Future<void> _onRemoveCookie(WebViewController controller) async {
    await controller.runJavaScript(
        'document.cookie="FirstName=John; expires=Thu, 01 Jan 1970 00:00:00 UTC" ');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Custom cookie removed.'),
      ),
    );
  }

  Future<void> _onLoadFlutterAssetExample(WebViewController controller, BuildContext context) async {
    await controller.loadFlutterAsset('assets/www/index.html');
  }

  Future<void> _onLoadLocalFileExample(WebViewController controller, BuildContext context) async {
    final String pathToIndex = await _prepareLocalFile();
    await controller.loadFile(pathToIndex);
  }

  static Future<String> _prepareLocalFile() async {
    final String tmpDir = (await getTemporaryDirectory()).path;
    final File indexFile = File('$tmpDir/www/index.html');
    await Directory('$tmpDir/www').create(recursive: true);
    await indexFile.writeAsString(kExamplePage);

    return indexFile.path;
  }

  Future<void> _onLoadHtmlStringExample(WebViewController controller, BuildContext context) async {
    await controller.loadHtmlString(kExamplePage);
  }
}

