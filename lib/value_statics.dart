class ValueStatic {
  // Ticket data
  static String ticketType = '';
  static int companyTypeOneWay = 0;
  static int companyTypeTwoWay = 0;
  static int vehicleTypeOneWay = 0;
  static int vehicleTypeTwoWay = 0;

  static String desfrom = '';
  static String desfromId = '';
  static String desTo = '';
  static String desToId = '';
  static String goDate = '';
  static String backDate = '';
  static String departureGoTime = '';
  static String departureBackTime = '';
  static String carGoType = '';
  static String carBackType = '';
  static String journeyIdGo = '';
  static String journeyIdBack = '';
  static String seatPriceGo = '';
  static String seatPriceBack = '';
  static bool seatPriceGoDiscount = false;
  static bool seatPriceBackDiscount = false;
  static double totalPriceGo = 0;
  static double totalPriceBack = 0;
  static double totalPriceDiscount = 0;
  static String priceOriginalOneWay = '';
  static String priceOriginalTwoWay = '';

  static String totalPrice = '';
  static int journeyType = 1; // 1 is one way 2 is two way
  static String national = '1';
  static bool luckyDraw = false;
  static double luckyDrawValue = 0;
  static int travelPackageDis = 0;

  static List<String> oneWaySelectedSeat = [];
  static List<String> oneWaySelectedSeatValue = [];
  static List<String> twoWaySelectedSeat = [];
  static List<String> twoWaySelectedSeatValue = [];

  static String username = '';
  static String phone = '';
  static String email = '';
  static String dob = '';
  static int gender = 0;
  static String nationalityName = '';
  static int nationalityId = 0;

  static String boardingPointOneWay = '';
  static String boardingPointOneWayId = '';
  static String dropOffPointOneWay = '';
  static String dropOffPointOneWayId = '';

  static String boardingPointTwoWay = '';
  static String boardingPointTwoWayId = '';
  static String dropOffPointTwoWay = '';
  static String dropOffPointTwoWayId = '';

  void clearDataTicket() {
    ValueStatic.desfrom = '';
    ValueStatic.desfromId = '';
    ValueStatic.desTo = '';
    ValueStatic.desToId = '';
    ValueStatic.goDate = '';
    ValueStatic.backDate = '';
    ValueStatic.departureGoTime = '';
    ValueStatic.departureBackTime = '';
    ValueStatic.carGoType = '';
    ValueStatic.carBackType = '';
    ValueStatic.journeyIdGo = '';
    ValueStatic.journeyIdBack = '';
    ValueStatic.seatPriceGo = '';
    ValueStatic.seatPriceBack = '';
    ValueStatic.journeyType = 1;
    ValueStatic.national = '1';
    ValueStatic.ticketType = '1';
    ValueStatic.oneWaySelectedSeat = [];
    ValueStatic.oneWaySelectedSeatValue = [];
    ValueStatic.twoWaySelectedSeat = [];
    ValueStatic.twoWaySelectedSeatValue = [];
    ValueStatic.boardingPointOneWay = '';
    ValueStatic.boardingPointOneWayId = '';
    ValueStatic.dropOffPointOneWay = '';
    ValueStatic.dropOffPointOneWayId = '';
    ValueStatic.boardingPointTwoWay = '';
    ValueStatic.boardingPointTwoWayId = '';
    ValueStatic.dropOffPointTwoWay = '';
    ValueStatic.dropOffPointTwoWayId = '';
    ValueStatic.seatPriceGoDiscount = false;
    ValueStatic.seatPriceBackDiscount = false;
    ValueStatic.totalPriceGo = 0;
    ValueStatic.totalPriceBack = 0;
    ValueStatic.totalPriceDiscount = 0;

    // Ticket data
    ValueStatic.ticketType = '';
    ValueStatic.companyTypeOneWay = 0;
    ValueStatic.companyTypeTwoWay = 0;
    ValueStatic.vehicleTypeOneWay = 0;
    ValueStatic.vehicleTypeTwoWay = 0;
  }

  // Self service
  static String provinceName = '';
  static String provinceId = '';
  static String locationName = '';
  static String locationId = '';
  static String uomName = '';
  static String uomId = '';

  void clearSelfService() {
    ValueStatic.provinceName = '';
    ValueStatic.provinceId = '';
    ValueStatic.locationName = '';
    ValueStatic.locationId = '';
    ValueStatic.uomName = '';
    ValueStatic.uomId = '';
  }

  ///Car Rental
  static String provinceRentalFromName = '';
  static String provinceRentalFromId = '';
  static String provinceRentalToName = '';
  static String provinceRentalToId = '';

  void clearCarRental() {
    ValueStatic.provinceRentalFromName = '';
    ValueStatic.provinceRentalFromId = '';
    ValueStatic.provinceRentalToName = '';
    ValueStatic.provinceRentalToId = '';
  }
}
