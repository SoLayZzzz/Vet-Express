import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../utils/app_bar.dart';

class WebViewScreen extends StatefulWidget {
  final int type;
  final String ticketId;

  const WebViewScreen({super.key, required this.type, required this.ticketId});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;
  String url = '';
  String appBarTitle = 'VET Express';
  String appBarTitleSurvey = 'title_survey'.tr;

  @override
  void initState() {
    super.initState();
    checkUrl(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBarVET().appBar(
          context,
          widget.type == 20 ? appBarTitleSurvey : appBarTitle,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
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

  Future<void> checkUrl(int type) async {
    switch (type) {
      case 1:
        url = 'https://www.vireakbuntham.com/terms-conditions-ticket';
        appBarTitle = 'agree'.tr;
        break;
      case 2:
        url = 'https://www.vtenh.com/km/';
        break;
      case 5:
        url = 'https://www.vtenh.com/';
        break;
      case 3:
        url = 'https://instagram.com/vireak_buntham?igshid=YmMyMTA2M2Y=';
        break;
      case 4:
        url = 'https://vireakbuntham.com/feed-back?ticketId=${widget.ticketId}';
        break;
      default:
        url = '';
        break;
    }
    setState(() {});
  }
}
