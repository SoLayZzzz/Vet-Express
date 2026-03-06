import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/passenger/presentation/controller/booking.dart';
import 'package:express_vet/feature/location-dashboard/presentation/screen/location_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:express_vet/utils/app_colors.dart';
import '../../../../home-dashboard/passenger/data/model/response/booking_detail_model.dart';
import '../../../../../utils/contains.dart';

class TicketDetailScreen extends StatefulWidget {
  final int id;

  const TicketDetailScreen({super.key, required this.id});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late Future<BookingDetailModel> futureBookingDetail;

  final CarouselSliderController _controller = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    futureBookingDetail = Booking().getTicketDetail(context, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<BookingDetailModel>(
            future: futureBookingDetail,
            builder: (context, bookingData) {
              if (bookingData.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // * stack qr
                      Stack(
                        children: [
                          // * background image
                          SizedBox(
                            height: 450,
                            width: double.infinity,
                            child: Image.asset(
                              AssetImages.img_background_car,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // * qrCode slider
                          Positioned(
                            top: 90,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              width: double.infinity,
                              child: CarouselSlider.builder(
                                carouselController: _controller,
                                itemCount:
                                    (bookingData
                                            .data
                                            ?.body
                                            ?.data?[0]
                                            .bookingSeatDetailList)!
                                        .length,
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
                                      (bookingData
                                                  .data
                                                  ?.body
                                                  ?.data?[0]
                                                  .bookingSeatDetailList)!
                                              .length -
                                          1;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      !isFirstIndex
                                          ? Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: IconButton(
                                              onPressed: back,
                                              icon: const Icon(
                                                Icons.arrow_back,
                                                size: 24,
                                              ),
                                            ),
                                          )
                                          : const SizedBox(
                                            width: 50,
                                            height: 50,
                                          ),
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
                                                '${(bookingData.data?.body?.data?[0].bookingSeatDetailList?[i].seatNumber).toString()}-${(bookingData.data?.body?.data?[0].bookingSeatDetailList?[i].gender).toString() == 'Male' ? 'male'.tr : 'female'.tr}',
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: IconButton(
                                              onPressed: next,
                                              icon: const Icon(
                                                Icons.arrow_forward,
                                              ),
                                            ),
                                          )
                                          : const SizedBox(
                                            width: 50,
                                            height: 50,
                                          ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // * container value
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: const Color(0xff000000).withOpacity(0.8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                    const SizedBox(height: 5),
                                    Text(
                                      (bookingData.data?.body?.data?[0].code)
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
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
                            ),
                          ),
                        ],
                      ),

                      // * detail value
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    bookingData
                                                    .data
                                                    ?.body
                                                    ?.data![0]
                                                    .journeyType ==
                                                2 ||
                                            bookingData
                                                    .data
                                                    ?.body
                                                    ?.data![0]
                                                    .journeyType ==
                                                4
                                        ? AssetImages.ic_buva_sea
                                        : AssetImages.ic_bus,
                                    height: 22,
                                    color: Colors.black38,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    (bookingData
                                            .data
                                            ?.body
                                            ?.data?[0]
                                            .transportationType)
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            _item(
                              label: "booking_date".tr,
                              value:
                                  (bookingData.data?.body?.data?[0].bookingDate)
                                      .toString(),
                            ),
                            _item(
                              label: "transaction_id".tr,
                              value:
                                  (bookingData
                                              .data
                                              ?.body
                                              ?.data?[0]
                                              .transactionId)
                                          .toString()
                                          .isEmpty
                                      ? '-'
                                      : (bookingData
                                              .data
                                              ?.body
                                              ?.data?[0]
                                              .transactionId)
                                          .toString(),
                            ),
                            _item(
                              label: 'telephone_num'.tr,
                              value:
                                  (bookingData.data?.body?.data?[0].telephone)
                                      .toString(),
                            ),

                            _item(
                              label: "payment".tr,
                              value:
                                  (bookingData.data?.body?.data?[0].paymentType)
                                      .toString(),
                            ),

                            const SizedBox(height: 12),

                            // * destination
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // * boarding point
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "boarding_point".tr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
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
                                                    transition:
                                                        Transition.rightToLeft,
                                                    duration: const Duration(
                                                      milliseconds:
                                                          Constrains.duration,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'view_map'.tr,
                                                  style: const TextStyle(
                                                    color: Color(0xff312783),
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
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
                                          style: const TextStyle(
                                            color: AppColors.textColor,
                                          ),
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
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "drop_off_point".tr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if ((bookingData
                                                        .data
                                                        ?.body
                                                        ?.data?[0]
                                                        .dropOffPointLat)
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
                                                    transition:
                                                        Transition.rightToLeft,
                                                    duration: const Duration(
                                                      milliseconds:
                                                          Constrains.duration,
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  'view_map'.tr,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff312783),
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
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
                                          style: const TextStyle(
                                            color: AppColors.textColor,
                                          ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _listSeat(
                                        label: 'name_pro'.tr,
                                        value:
                                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].name}',
                                      ),
                                      _listSeat(
                                        label: 'gender'.tr,
                                        value:
                                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].gender}',
                                      ),
                                      _listSeat(
                                        label: 'nationality'.tr,
                                        value:
                                            '${bookingData.data!.body!.data![0].bookingSeatDetailList![index].nationalityName}',
                                      ),
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
                                    (BuildContext context, int index) =>
                                        const Divider(),
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
                                    value:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .subTotal)
                                            .toString(),
                                  ),
                                  const SizedBox(height: 10),
                                  _listPrice(
                                    label: "discount".tr,
                                    value:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .discount)
                                            .toString(),
                                  ),
                                  const SizedBox(height: 10),
                                  _listPrice(
                                    label: "total_ticket_price".tr,
                                    value:
                                        (bookingData
                                                .data
                                                ?.body
                                                ?.data?[0]
                                                .totalAmount)
                                            .toString(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (bookingData.hasError) {}
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 5.0,
                  ),
                ),
              );
            },
          ),

          // * button back
          Positioned(
            left: 10,
            top: 40,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Ionicons.chevron_back_outline,
                color: Colors.white,
              ),
            ),
          ),
        ],
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

  _item({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                ":",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
}
