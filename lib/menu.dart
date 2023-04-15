import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _MenuOptions {
  navigationDelegate,
}

class Menu extends StatelessWidget {
  final WebViewController controller;
  const Menu({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(onSelected: (value) async {
      switch (value) {
        case _MenuOptions.navigationDelegate :
          await controller.loadRequest(Uri.parse('https://www.youtube.com'));
          break;
      }
    } ,
        itemBuilder: (context) {
      return [
        const PopupMenuItem(value: _MenuOptions.navigationDelegate, child: Text('Navigate to YouTube'),)
      ];
    });
  }
}
