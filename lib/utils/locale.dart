import 'package:get/get.dart';
import 'translations/en_us.dart';
import 'translations/km_kh.dart';
import 'translations/zh_cn.dart';

class LocaleString extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'km_KH': kmKH,
        'zh_CN': zhCN,
      };
}
