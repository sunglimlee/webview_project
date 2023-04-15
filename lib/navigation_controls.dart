import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControls extends StatelessWidget {
  final WebViewController _controller;
  const NavigationControls({Key? key, required WebViewController controller}) : _controller = controller, super(key: key);

  @override
  Widget build(BuildContext context) {
    // Row 를 이용해서 AppBar 에다가 Controller 를 만들어서 넣었다.
    return Row(
      children: [
        IconButton(onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          if (await _controller.canGoBack()) {
            await _controller.goBack();
          } else {
            messenger.showSnackBar(const SnackBar(content: Text('no Back History Item'),));
          }
          return;
        }, icon: const Icon(Icons.arrow_back_ios),),

        IconButton(onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          if (await _controller.canGoForward()) {
            await _controller.goForward();
          } else {
            messenger.showSnackBar(const SnackBar(content: Text('no Forward History Item'),));
          }
          return;
        }, icon: const Icon(Icons.arrow_forward_ios),),
        
        IconButton(onPressed: () => _controller.reload(), icon: const Icon(Icons.replay))
      ],
    );
  }
}
