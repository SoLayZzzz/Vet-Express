import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../utils/app_bar.dart';

class ResortWebViewScreen extends StatefulWidget {
  final String? url;

  const ResortWebViewScreen({super.key, required this.url});

  @override
  State<ResortWebViewScreen> createState() => _ResortWebViewScreenState();
}

class _ResortWebViewScreenState extends State<ResortWebViewScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'accommodation'.tr),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url ?? "")),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                ),
                onProgressChanged:
                    (_, load) => setState(
                      () =>
                          isLoading == 100
                              ? isLoading = true
                              : isLoading = false,
                    ),
                onReceivedServerTrustAuthRequest:
                    (_, __) async => ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED,
                    ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 3.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
