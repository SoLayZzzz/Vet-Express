import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/location-dashboard/presentation/screen/location_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:express_vet/utils/app_colors.dart';
import '../../data/model/response/ticket_detail_response.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/check_input.dart';
import '../controller/ticket_detail_controller.dart';

class TicketDetailScreen extends StatefulWidget {
  final int id;
  final int? journeyType;

  const TicketDetailScreen({super.key, required this.id, this.journeyType});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late TicketDetailController controller;

  final CarouselSliderController _controller = CarouselSliderController();
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TicketDetailController>();
    controller.loadTicketDetail(context: context, id: widget.id);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final shouldShow = _scrollController.offset > 200;
    if (shouldShow == _showAppBar) return;
    if (!mounted) return;
    setState(() {
      _showAppBar = shouldShow;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final future = controller.state.futureTicketDetail;
        if (future == null) {
          return const Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          );
        }

        return FutureBuilder<TicketDetailScreenReponse>(
          future: future,
          builder: (context, bookingData) {
            if (bookingData.hasData) {
              final telephone = _getTelephoneForDisplay(
                bookingData.data?.body?.data?[0].telephone,
              );

              final topPadding = MediaQuery.of(context).padding.top;

              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // * stack qr
                        Stack(
                          children: [
                            // * background image
                            SizedBox(
                              height: 460,
                              width: double.infinity,
                              child: Image.asset(
                                AssetImages.img_background_car,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // * qrCode slider
                            _buildQrCode(bookingData),

                            // * container value
                            _buildDestination(bookingData),
                          ],
                        ),

                        // * detail value
                        _buildticketDetail(bookingData),
                      ],
                    ),
                  ),

                  // * button back
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: topPadding + kToolbarHeight,
                      decoration: BoxDecoration(
                        color:
                            _showAppBar
                                ? AppColors.primaryColor
                                : Colors.transparent,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: topPadding),
                          SizedBox(
                            height: kToolbarHeight,
                            child: AppBar(
                              primary: false,
                              toolbarHeight: kToolbarHeight,
                              automaticallyImplyLeading: false,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              centerTitle: true,
                              leading: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(
                                  Ionicons.chevron_back_outline,
                                  color: Colors.white,
                                ),
                              ),
                              title: AnimatedOpacity(
                                opacity: _showAppBar ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  telephone,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (bookingData.hasError) {}

            return const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildticketDetail(
    AsyncSnapshot<TicketDetailScreenReponse> bookingData,
  ) {
    final transportationType = bookingData.data?.body?.data?[0].transportationType;
    final transportationTypeLower = (transportationType ?? '').toLowerCase();
    final isBoatByJourneyType = widget.journeyType == 2 || widget.journeyType == 4;
    final isBoatByTransportType =
        transportationTypeLower.contains('boat') ||
        transportationTypeLower.contains('sea') ||
        transportationTypeLower.contains('ferry');
    final isBoatTransport = isBoatByJourneyType || isBoatByTransportType;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          // Header of ticket detail
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  isBoatTransport
                      ? AssetImages.ic_boat_history
                      : AssetImages.ic_bus_history,
                  height: 24,
                  width: 24,
                  // color: Colors.grey.shade500, // softer icon color
                ),
                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      transportationType.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        // color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Subtitle (pill style)
                    if (!isBoatTransport)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EBFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // "Type of bus",
                        child: Text(
                          _seatTypeText(
                            bookingData.data?.body?.data?[0].seatType,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A56A6),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // const SizedBox(height: 10),
          _item(
            label: "transaction_id".tr,
            value:
                (bookingData.data?.body?.data?[0].transactionId)
                        .toString()
                        .isEmpty
                    ? '-'
                    : (bookingData.data?.body?.data?[0].transactionId)
                        .toString(),
          ),
          _item(
            label: "booking_date".tr,
            value: (bookingData.data?.body?.data?[0].bookingDate).toString(),
          ),

         
          _item(
            label: 'email'.tr,
            value:
                _getEmailForDisplay(bookingData.data?.body?.data?[0].email) ==
                        '*@gmail.com'
                    ? '-'
                    : _getEmailForDisplay(
                        bookingData.data?.body?.data?[0].email,
                      ),
            color: AppColors.secondaryColor,
          ),
          _item(
            label: 'telephone_num'.tr,
            value: _getTelephoneForDisplay(
              bookingData.data?.body?.data?[0].telephone,
            ),
            color: AppColors.secondaryColor,
          ),

          _item(
            label: "payment_method".tr,
            value: (bookingData.data?.body?.data?[0].paymentType).toString(),
            color: AppColors.secondaryColor,
          ),

          const SizedBox(height: 12),

          // * destination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // * boarding point
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "boarding_point".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if ((bookingData
                                      .data
                                      ?.body
                                      ?.data?[0]
                                      .boardingPointLat)
                                  .toString() !=
                              '')
                            InkWell(
                              onTap: () {
                                Get.to(
                                  () => LocationDetailScreen(
                                    lats:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .boardingPointLat)
                                            .toString(),
                                    longs:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .boardingPointLong)
                                            .toString(),
                                    type: 3,
                                    nameKh: '',
                                    name: '',
                                    telephone: '',
                                  ),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(
                                    milliseconds: Constrains.duration,
                                  ),
                                );
                              },
                              child: Text(
                                'view_map'.tr,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.viewMapColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${(bookingData.data?.body?.data?[0].boardingPoint).toString()} (${(bookingData.data?.body?.data?[0].departure).toString()})",
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ". ${(bookingData.data?.body?.data?[0].boardingPointAddress).toString()}",
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // * drop off point
                Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "drop_off_point".tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if ((bookingData.data?.body?.data?[0].dropOffPointLat)
                                  .toString() !=
                              '')
                            InkWell(
                              onTap: () {
                                Get.to(
                                  () => LocationDetailScreen(
                                    lats:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .dropOffPointLat)
                                            .toString(),
                                    longs:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .dropOffPointLong)
                                            .toString(),
                                    type: 3,
                                    nameKh: '',
                                    name: '',
                                    telephone: '',
                                  ),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(
                                    milliseconds: Constrains.duration,
                                  ),
                                );
                              },
                              child: Text(
                                'view_map'.tr,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.viewMapColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${(bookingData.data?.body?.data?[0].dropOffPoint).toString()} (${(bookingData.data?.body?.data?[0].arrival).toString()})",
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ". ${(bookingData.data?.body?.data?[0].dropOffPointAddress).toString()}",
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //* bookingSeatDetailList
          Padding(
            padding: const EdgeInsets.all(15),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  bookingData
                      .data!
                      .body!
                      .data![0]
                      .bookingSeatDetailList!
                      .length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _listSeat(
                      label: "seat_number".tr,
                      value:
                          '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].seatNumber}',
                    ),

                    if (bookingData
                        .data!
                        .body!
                        .data![0]
                        .bookingSeatDetailList![index]
                        .dob!
                        .isNotEmpty)
                      _listSeat(
                        label: 'name_pro'.tr,
                        value:
                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].name}',
                      ),
                    _listSeat(
                      label: 'gender'.tr,
                      value:
                          bookingData
                                      .data!
                                      .body!
                                      .data![0]
                                      .bookingSeatDetailList![index]
                                      .gender ==
                                  'Male'
                              ? 'male'.tr
                              : 'female'.tr,
                    ),
                    _listSeat(
                      label: 'nationality'.tr,
                      value:
                          '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].nationalityName}',
                    ),

                    if (bookingData
                        .data!
                        .body!
                        .data![0]
                        .bookingSeatDetailList![index]
                        .dob!
                        .isNotEmpty)
                      _listSeat(
                        label: 'dob'.tr,
                        value:
                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].dob}',
                      ),
                    if (bookingData
                        .data!
                        .body!
                        .data![0]
                        .bookingSeatDetailList![index]
                        .passport!
                        .isNotEmpty)
                      _listSeat(
                        label: 'passport'.tr,
                        value:
                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].passport}',
                      ),
                  ],
                );
              },
              separatorBuilder:
                  (BuildContext context, int index) => const Divider(),
            ),
          ),

          // * price
          Image.asset(AssetImages.line),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _listPrice(
                  label: "sub_total".tr,
                  value: (bookingData.data?.body?.data?[0].subTotal).toString(),
                ),
                const SizedBox(height: 10),
                if (_shouldShowDiscount(
                  bookingData.data?.body?.data?[0].discount,
                )) ...[
                  _listPrice(
                    label: "discount".tr,
                    value:
                        (bookingData.data?.body?.data?[0].discount).toString(),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_shouldShowServiceFee(
                  bookingData.data?.body?.data?[0].serviceFee,
                )) ...[
                  _listPrice(
                    label: "service_fee".tr,
                    value:
                        (bookingData.data?.body?.data?[0].serviceFee).toString(),
                  ),
                  const SizedBox(height: 10),
                ],
                _listPrice(
                  label: "total_ticket_price".tr,
                  value:
                      (bookingData.data?.body?.data?[0].totalAmount).toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(
    AsyncSnapshot<TicketDetailScreenReponse> bookingData,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color(0xff000000).withValues(alpha: 0.8),
        child: Column(
          children: [
            Text(
              "${(bookingData.data?.body?.data?[0].destinationFrom).toString()} - ${(bookingData.data?.body?.data?[0].destinationTo).toString()}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              (bookingData.data?.body?.data?[0].code).toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${(bookingData.data?.body?.data?[0].travelDate)}  (${(bookingData.data?.body?.data?[0].departure)})"
                  .toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCode(AsyncSnapshot<TicketDetailScreenReponse> bookingData) {
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: SizedBox(
        width: double.infinity,
        child: CarouselSlider.builder(
          carouselController: _controller,
          itemCount:
              (bookingData.data?.body?.data?[0].bookingSeatDetailList)!.length,
          options: CarouselOptions(
            height: 250,
            initialPage: 0,
            viewportFraction: 1,
            enableInfiniteScroll: false,
          ),
          itemBuilder: (context, i, realIndex) {
            final isFirstIndex = i == 0;
            final isLastIndex =
                i ==
                (bookingData.data?.body?.data?[0].bookingSeatDetailList)!
                        .length -
                    1;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                !isFirstIndex
                    ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: back,
                        icon: const Icon(Icons.arrow_back, size: 24),
                      ),
                    )
                    : const SizedBox(width: 50, height: 50),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 15,
                    ),
                    child: Column(
                      children: [
                        QrImageView(
                          data:
                              '${(bookingData.data?.body?.data?[0].code).toString()}_${(bookingData.data?.body?.data?[0].bookingSeatDetailList)![i].seatNumber}',
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        Text(
                          // '${(bookingData.data?.body?.data?[0].bookingSeatDetailList?[i].seatNumber).toString()}-${(bookingData.data?.body?.data?[0].bookingSeatDetailList?[i].gender).toString() == 'Male' ? 'male'.tr : 'female'.tr}',
                          (bookingData
                                  .data
                                  ?.body
                                  ?.data?[0]
                                  .bookingSeatDetailList?[i]
                                  .seatNumber)
                              .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                !isLastIndex
                    ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: next,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    )
                    : const SizedBox(width: 50, height: 50),
              ],
            );
          },
        ),
      ),
    );
  }

  _listPrice({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  _listSeat({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textColor)),
          Text(value, style: const TextStyle(color: AppColors.textColor)),
        ],
      ),
    );
  }

  Widget _item({
    required String label,
    required String value,
    Color? color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void next() {
    _controller.nextPage(duration: const Duration(milliseconds: 200));
  }

  void back() {
    _controller.previousPage(duration: const Duration(milliseconds: 200));
  }

  String _getTelephoneForDisplay(dynamic telephoneValue) {
    final raw = telephoneValue?.toString() ?? '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'null') return '-';
    return _formatTelephone(trimmed);
  }

  String _getEmailForDisplay(dynamic emailValue) {
    final raw = emailValue?.toString() ?? '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'null') return '-';
    return trimmed;
  }

  String _formatTelephone(String input) {
    return CheckInput.formatPhoneNumber(input);
  }

  String _seatTypeText(int? seatType) {
    if (seatType == 1) return 'Seater Bus';
    if (seatType == 2) return 'Sleeper Bus';
    return '-';
  }

  bool _shouldShowDiscount(String? discountString) {
    if (discountString == null) return false;
    final clean = discountString.replaceAll(r'$', '').trim();
    final value = double.tryParse(clean) ?? 0.0;
    return value > 0;
  }

  bool _shouldShowServiceFee(String? feeString) {
    if (feeString == null) return false;
    final clean = feeString.replaceAll(r'$', '').trim();
    final value = double.tryParse(clean) ?? 0.0;
    return value > 0;
  }
}
