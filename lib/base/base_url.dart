// ignore_for_file: non_constant_identifier_names

class BaseUrl {
  // Locale
  // static String BASE_URL = 'http://192.168.2.132:8035/UtLogVET/';
  // static String BASE_URL_TICKET = 'http://192.168.2.132:8035/UtLogVET/';
  // static String BASE_URL_EV = 'http://192.168.2.132:8035/UtLogVET/';
  // static String BASE_URL_UPLOAD_IMAGE = 'http://192.168.2.132:8035/UtLogVET';
  // static String BASE_URL_SLIDE_IMAGE = 'http://192.168.2.132:8035/UtLogVET/slide_photo/';
  // static String PAYMENT_URL = 'http://192.168.2.132:8035/0430_CamTicket/';

  // QA
  //   static String BASE_URL = 'https://qacltom.udaya-tech.com/UtLogVET/';
  // static String BASE_URL_TICKET =
  //     'https://qacltom.udaya-tech.com/vetExpressTicketApiQA/';
  // static String BASE_URL_EV =
  //     'https://qacltom.udaya-tech.com/vetEvChargerCustomerAPi/';
  // static String BASE_URL_SLIDE_IMAGE =
  //     'https://qacltom.udaya-tech.com/UtLogVET/slide_photo/';
  // static String PAYMENT_URL = 'https://qacl.udaya-tech.com/0430_CamTicket/';
  // static String BASE_URL_UPLOAD_IMAGE =
  //     'https://qacl.udaya-tech.com/0412_VETOc_Web/';

  // Local url
  // http://localhost:8512/vetExpressTicketApiLocal/swagger-ui.html#/16.%20Booking/saveBookingUsingPOST
  // http://localhost:8512/vetExpressTicketApiLocal/swagger-ui.html#/03.%20Destinations/getDestinationFromListUsingPOST

  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'qa',
  );
  static final String BASE_URL =
      _flavor == 'prod'
          ? 'https://tomapicaps.utlog.net/vetAppApi/'
          : 'https://qacltom.udaya-tech.com/UtLogVET/';
  static final String BASE_URL_TICKET =
      _flavor == 'prod'
          ? 'https://vettkexpapp.utlog.net/vetExpressTicketApi/'
          : 'https://qacltom.udaya-tech.com/vetExpressTicketApiQA/';
  static final String BASE_URL_EV =
      _flavor == 'prod'
          ? 'https://newpapi.utebi.com/vetEvChargerCustomerAPi/'
          : 'https://qacltom.udaya-tech.com/vetEvChargerCustomerAPi/';
  static final String BASE_URL_SLIDE_IMAGE =
      _flavor == 'prod'
          ? 'https://oc.utlog.net/public/slide_photo/'
          : 'https://qacltom.udaya-tech.com/UtLogVET/slide_photo/';
  static final String BASE_URL_SLIDE_IMAGE_EV =
      _flavor == 'prod'
          ? 'https://newpapisystem.utebi.com/vetEvChargerFrontendAPi/'
          : 'https://qacltom.udaya-tech.com/vetEvChargerCustomerAPi/';
  static final String PAYMENT_URL =
      _flavor == 'prod'
          ? 'https://vetticket.utlog.net/'
          : 'https://qacl.udaya-tech.com/0430_CamTicket/';
  static final String BASE_URL_UPLOAD_IMAGE =
      _flavor == 'prod'
          ? 'https://oc.utlog.net/'
          : 'https://qacl.udaya-tech.com/0412_VETOc_Web/';

  // https://vetticket.utlog.net/payments/acledaXpay/VTCK-tsYxzqBBEQHypA7/DsquDNFD3MpvDcOLeFLONyYZUjJZFKS6wxX

  // Production
  // static String BASE_URL = 'https://tomapicaps.utlog.net/vetAppApi/'; //logistic
  // static String BASE_URL_TICKET =
  //     'https://vettkexpapp.utlog.net/vetExpressTicketApi/'; //ticket
  // static String BASE_URL_EV =
  //     'https://vettkexpapp.utlog.net/vetExpressTicketApi/'; //ev
  // static String BASE_URL_SLIDE_IMAGE =
  //     'https://oc.utlog.net/public/slide_photo/';
  // static String PAYMENT_URL = 'https://vetticket.utlog.net/';
  // static String BASE_URL_UPLOAD_IMAGE = 'https://oc.utlog.net/';

  // Version App
  static String APP_VERSION_ANDROID = '2.1.4';
  static String APP_VERSION_IOS = '2.1.4';

  // for check app update must be double value
  static String APP_VERSION = '2.14';
}
