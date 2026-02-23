class AppRoutes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const home = '/home';

  // Booking route
  static const ticketMenu = '/ticket-menu';
  static const selectTicket = '/select-ticket';
  static const scheduleList = '/ticket/schedule-list';
  static const ticketScheduleCarDetail = '/ticket/schedule-car-detail';
  static const reviewRate = '/ticket/review-rate';
  static const selectSeat = '/ticket/select-seat';
  static const passengerDetail = '/ticket/passenger-detail';

  // Payment route
  static const payment = '/payment';
  static const paymentWing = '/payment/wing';
  static const paymentAba = '/payment/aba';
  static const paymentAbaPackage = '/payment/aba-package';

  // Ev charger route
  static const evCharger = '/ev-charger';
  static const evWallet = '/ev-charger/wallet';
  static const evTopUp = '/ev-charger/top-up';
  static const evPayment = '/ev-charger/payment';
  static const evPaymentSuccess = '/ev-charger/payment-success';
  static const evQrScanner = '/ev-charger/qr-scanner';
  static const evFaq = '/ev-charger/faq';
  static const evPolicy = '/ev-charger/policy';
  static const evNewsFeed = '/ev-charger/news-feed';
  static const evAllStations = '/ev-charger/stations';
  static const evFavorites = '/ev-charger/favorites';
  static const evSearchStations = '/ev-charger/search-stations';
  static const evSelectProvince = '/ev-charger/select-province';

  // Menu route
  static const contactUs = '/contact-us';
  static const notifications = '/notifications';
  static const carRentalList = '/car-rental/list';
  static const carRentalDetail = '/car-rental/detail';
  static const carRentalInfo = '/car-rental/info';
  static const carRentalSelectProvince = '/car-rental/select-province';
  static const travelPackageList = '/travel-package/list';
  static const selfService = '/self-service';
  static const selfServiceSelect = '/self-service/select';
  static const selfServiceCheck = '/self-service/check';
  static const selfServiceQr = '/self-service/qr';
  static const selfServiceQrList = '/self-service/qr-list';
  static const scanQr = '/scan-qr';
  static const bookingDelivery = '/booking-delivery';
  static const warehouseAddress = '/china/warehouse-address';
  static const chinaRegistration = '/china/registration';
  static const chinaProvinceSelection = '/china/province-selection';
  static const chinaBranchSelection = '/china/branch-selection';
  static const vetAirway = '/vet-airway';

  // History route
  static const ticketHistory = '/history/ticket';
  static const packageHistory = '/history/package';
  static const goodsTransferHistory = '/history/goods-transfer';

  // Member dashboard routes
  static const memberAccountDetail = '/member/account-detail';
}
