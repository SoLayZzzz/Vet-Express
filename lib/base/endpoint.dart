class Endpoint {
  static const String authLogin = 'auth/login';
  static const String authLogout = 'auth/logout';
  static const String authCheckToken = 'auth/checkToken';
  static const String authCheckVersion = 'auth/checkVersion';
  static const String authDeleteAccount = 'auth/deleteAccount';

  static const String userRegister = 'user/register';
  static const String userVerification = 'user/verification';
  static const String userResendCodeVerify = 'user/resend-code-verify';
  static const String userResetPasswordSendSms = 'user/reset-password-send-sms';
  static const String userResetPassword = 'user/reset-password';
  static const String userResendCode = 'user/resend-code';
  static const String userNewPassword = 'user/new-password';
  static const String userMe = 'user/me';
  static const String userUpdate = 'user/update';
  static const String userSendOtpForgetPassword =
      'user/send-otp-forget-password';
  static const String userSendOtpRegister = 'user/send-otp-register';
  static const String userNationalityList = 'user/nationalityList';

  static const String membershipList = 'membership/list';
  static const String membershipGetTicketMemberCard =
      'membership/getTicketMemberCard';

  static const String branchList = 'branch/list';

  static const String provinceList = 'province/list';
  static const String branchListByProvince = 'branch/listByProvince';

  static const String chinaCustomerAdd = 'china-customer/add';
  static const String chinaCustomerUpdate = 'china-customer/update';
  static const String chinaCustomerList = 'china-customer/list';
  static const String chinaCustomerWarehouseList =
      'china-customer/warehouseList';

  static const String goodsTransferSearchCode = 'goods-transfer/search-code';
  static const String goodsTransferList = 'goods-transfer/list';
  static String goodsTransferFind(String id) => 'goods-transfer/find/$id';

  static const String requestTransferGoodsList = 'request-transfer/goodsList';
  static const String requestTransferAddGoods = 'request-transfer/addGoods';
  static const String requestTransferAdd = 'request-transfer/add';
  static const String requestTransferSaveSurvey = 'request-transfer/saveSurvey';

  static const String savingPointAccount = 'saving-point/account';
  static const String savingPointList = 'saving-point/list';

  static const String destinationsList = 'destinations/list';
  static const String destinationsListTo = 'destinations/list-to';
  static const String destinationsProvince = 'destinations/province';
  static const String destinationsDestinationByProvince =
      'destinations/destinationByProvince';

  static const String uomList = 'uom/list';

  static const String notificationList = 'notification/list';
  static const String notificationReadAll = 'notification/read-all';
  static const String notificationRead = 'notification/read';
  static const String notificationRegister = 'notification/register';
  static const String notificationCountUnread = 'notification/count-unread';

  static const String slideShowsList = 'slide-shows/list';
  static const String userAdvHome = 'user/advHome';
  static const String slideShowsBusList = 'slide-shows/busList';
  static const String slideShowsBuvaSeaList = 'slide-shows/buvaSeaList';

  static const String vehicleRentalBusType = 'vehicle-rental/busType';
  static const String vehicleRentalProvince = 'vehicle-rental/province';
  static const String vehicleRentalAdd = 'vehicle-rental/add';

  static const String scheduleRateSave = 'schedule-rate/save';

  static const String ticketResortsList = 'resorts/list';
  static const String ticketScheduleListByDate = 'schedule/listByDate';
  static const String ticketScheduleRateListByJourney =
      'schedule-rate/listByJourney';
  static const String ticketScheduleRateTotalByJourney =
      'schedule-rate/totalByJourney';

  static const String ticketDestinationsFrom = 'destinations/from';
  static const String ticketDestinationsTo = 'destinations/to';

  static const String ticketBookingConfirm = 'booking/confirm';
  static const String ticketBookingCancel = 'booking/cancel';
  static const String ticketBookingList = 'booking/list';
  static String ticketBookingFind(String id) => 'booking/find/$id';
  static const String ticketBookingProcessPayment = 'booking/processPayment';
  static const String ticketBookingCheckCoupon = 'booking/checkCoupon';
  static const String ticketBookingCheckPackageApply =
      'booking/checkPackageApply';
  static const String ticketBookingCheckTicketStatus =
      'booking/checkTicketStatus';

  static const String ticketSeatUnavailable = 'seat/unavailable';
  static const String ticketSeatLayout = 'seat/layout';

  static const String ticketTravelPackageList = 'travelPackage/list';
  static const String ticketTravelPackageContent = 'travelPackage/content';
  static String ticketTravelPackageFind(String id) => 'travelPackage/find/$id';
  static const String ticketTravelPackageConfirm = 'travelPackage/confirm';
  static const String ticketTravelPackageGetPackage =
      'travelPackage/getPackage';
  static const String ticketTravelPackageProcessPayment =
      'travelPackage/processPayment';

  static const String ticketUserNationalityList = 'user/nationalityList';

  static const String ticketBoardingPointListByScheduleDate =
      'boarding-point/listByScheduleDate';
  static String ticketDropOffPointFindBySchedule(String id) =>
      'drop-off-point/findBySchedule/$id';

  static const String ticketEvStationList = 'evStation/list';
  static const String ticketProvinceList = 'province/list';

  static const String evDropdownContactUsList = 'dropdown/contact-us/list';
  static const String evDropdownFaqsList = 'dropdown/faqs/list';
  static const String evDropdownPrivacyPolicyList =
      'dropdown/privacy-policy/list';
  static const String evDropdownSlideShowsList = 'dropdown/slide-shows/list';
  static const String evDropdownNewFeedList = 'dropdown/new-feed/list';
  static const String evDropdownProvinceList = 'dropdown/province/list';
  static const String evStationList = 'station/list';
  static String evStationAddFavorites(String id) => 'station/add-favorites/$id';
  static const String evSaleOrderWalletList = 'sale-order/wallet/list';
  static const String evSaleOrderWalletAmount = 'sale-order/wallet/amount';
  static const String evSaleOrderWalletTopUp = 'sale-order/wallet/top-up';
  static String evSaleOrderWalletTopUpStatus(String transactionId) =>
      'sale-order/wallet/top-up/status/$transactionId';
  static String evSaleOrderFind(String transactionId) =>
      'sale-order/find/$transactionId';
  static String evPaymentConfirmPayment(String transactionId) =>
      'payment/confirm-payment/$transactionId';

  static const String uploadPhotoTravelPackageOrder =
      'uploads/uploadPhotoTravelPackageOrder';
  static const String uploadPhotoUserProfile = 'uploads/uploadPhotoUserProfile';
}
