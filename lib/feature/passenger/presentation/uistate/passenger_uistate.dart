class PassengerUistate {
  final bool luckyDraw;
  final bool isTravelPackage;
  final bool isLoaded;
  final bool isTravelPackageOk;
  final bool isPhone;
  final bool isNoPackage;

  final String msgPackage;
  final int packageTypeOneWay;
  final int packageTypeTwoWay;

  final int status;
  final String balance;

  final String selectedBoardingPointOneWay;
  final String selectedBoardingPointAddressOneWay;
  final int isSelectedIndexBoardingOneWay;
  final int isSelectedIndexDropOffOneWay;

  final String selectBoardingPointTwoWay;
  final String selectBoardingPointAddressTwoWay;
  final int isSelectIndexBoardingTwoWay;
  final int isSelectIndexDropOffTwoWay;

  final String selectedDropPointOneWay;
  final String selectedDropPointAddressOneWay;
  final String selectDropPointTwoWay;
  final String selectDropPointAddressTwoWay;

  const PassengerUistate({
    this.luckyDraw = false,
    this.isTravelPackage = false,
    this.isLoaded = false,
    this.isTravelPackageOk = false,
    this.isPhone = false,
    this.isNoPackage = false,
    this.msgPackage = '',
    this.packageTypeOneWay = 0,
    this.packageTypeTwoWay = 0,
    this.status = 0,
    this.balance = '',
    this.selectedBoardingPointOneWay = '',
    this.selectedBoardingPointAddressOneWay = '',
    this.isSelectedIndexBoardingOneWay = -1,
    this.isSelectedIndexDropOffOneWay = -1,
    this.selectBoardingPointTwoWay = '',
    this.selectBoardingPointAddressTwoWay = '',
    this.isSelectIndexBoardingTwoWay = -1,
    this.isSelectIndexDropOffTwoWay = -1,
    this.selectedDropPointOneWay = '',
    this.selectedDropPointAddressOneWay = '',
    this.selectDropPointTwoWay = '',
    this.selectDropPointAddressTwoWay = '',
  });

  PassengerUistate copyWith({
    bool? luckyDraw,
    bool? isTravelPackage,
    bool? isLoaded,
    bool? isTravelPackageOk,
    bool? isPhone,
    bool? isNoPackage,
    String? msgPackage,
    int? packageTypeOneWay,
    int? packageTypeTwoWay,
    int? status,
    String? balance,
    String? selectedBoardingPointOneWay,
    String? selectedBoardingPointAddressOneWay,
    int? isSelectedIndexBoardingOneWay,
    int? isSelectedIndexDropOffOneWay,
    String? selectBoardingPointTwoWay,
    String? selectBoardingPointAddressTwoWay,
    int? isSelectIndexBoardingTwoWay,
    int? isSelectIndexDropOffTwoWay,
    String? selectedDropPointOneWay,
    String? selectedDropPointAddressOneWay,
    String? selectDropPointTwoWay,
    String? selectDropPointAddressTwoWay,
  }) => PassengerUistate(
    luckyDraw: luckyDraw ?? this.luckyDraw,
    isTravelPackage: isTravelPackage ?? this.isTravelPackage,
    isLoaded: isLoaded ?? this.isLoaded,
    isTravelPackageOk: isTravelPackageOk ?? this.isTravelPackageOk,
    isPhone: isPhone ?? this.isPhone,
    isNoPackage: isNoPackage ?? this.isNoPackage,
    msgPackage: msgPackage ?? this.msgPackage,
    packageTypeOneWay: packageTypeOneWay ?? this.packageTypeOneWay,
    packageTypeTwoWay: packageTypeTwoWay ?? this.packageTypeTwoWay,
    status: status ?? this.status,
    balance: balance ?? this.balance,
    selectedBoardingPointOneWay:
        selectedBoardingPointOneWay ?? this.selectedBoardingPointOneWay,
    selectedBoardingPointAddressOneWay:
        selectedBoardingPointAddressOneWay ??
        this.selectedBoardingPointAddressOneWay,
    isSelectedIndexBoardingOneWay:
        isSelectedIndexBoardingOneWay ?? this.isSelectedIndexBoardingOneWay,
    isSelectedIndexDropOffOneWay:
        isSelectedIndexDropOffOneWay ?? this.isSelectedIndexDropOffOneWay,
    selectBoardingPointTwoWay:
        selectBoardingPointTwoWay ?? this.selectBoardingPointTwoWay,
    selectBoardingPointAddressTwoWay:
        selectBoardingPointAddressTwoWay ??
        this.selectBoardingPointAddressTwoWay,
    isSelectIndexBoardingTwoWay:
        isSelectIndexBoardingTwoWay ?? this.isSelectIndexBoardingTwoWay,
    isSelectIndexDropOffTwoWay:
        isSelectIndexDropOffTwoWay ?? this.isSelectIndexDropOffTwoWay,
    selectedDropPointOneWay:
        selectedDropPointOneWay ?? this.selectedDropPointOneWay,
    selectedDropPointAddressOneWay:
        selectedDropPointAddressOneWay ?? this.selectedDropPointAddressOneWay,
    selectDropPointTwoWay: selectDropPointTwoWay ?? this.selectDropPointTwoWay,
    selectDropPointAddressTwoWay:
        selectDropPointAddressTwoWay ?? this.selectDropPointAddressTwoWay,
  );
}
