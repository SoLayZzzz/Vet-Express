import 'dart:developer';

import '../models/travel_package/buy_travel_package_list_response.dart';
import '../models/travel_package/confirm_travel_package_response.dart';
import '../models/travel_package/find_travel_package_response.dart';
import '../models/travel_package/travel_package_content.dart';
import '../models/travel_package/travel_package_list_response.dart';
import '../base/base_url.dart';
import '../base/endpoint.dart';
import '../base/network_data_source.dart';
import '../utils/contains.dart';

class TravelPackage {
  final NetWorkDataSource netWorkDataSource;

  TravelPackage({NetWorkDataSource? netWorkDataSource})
      : netWorkDataSource =
            netWorkDataSource ?? NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET);

  Future<TravelPackageListResponse> getList(context) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketTravelPackageList,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      try {
        log('This is response travel package list ==>>${json.toString()}');
      } catch (_) {
        // ignore logging errors
      }
      return TravelPackageListResponse.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  Future<TravelPackageContent> getContent(context) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketTravelPackageContent,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      try {
        log('This is response travel package content ==>>${json.toString()}');
      } catch (_) {
        // ignore logging errors
      }
      return TravelPackageContent.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  Future<FindTravelPackageResponse> find(context, int id) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketTravelPackageFind(id.toString()),
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      try {
        log('This is response travel package find id ==>>${json.toString()}');
      } catch (_) {
        // ignore logging errors
      }
      return FindTravelPackageResponse.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  void confirm({
    context,
    String? address,
    String? dob,
    String? email,
    required String name,
    required int nationality,
    required String photo,
    required int sex,
    required String telephone,
    required int travelPackageId,
    required void Function(ConfirmTravelPackageResponse) doOnSuccess,
    required void Function() doOnFailed,
  }) async {
    try {
      final fields = <String, dynamic>{
        if (address != null && address.isNotEmpty) 'address': address,
        if (dob != null && dob.isNotEmpty) 'dob': dob,
        if (email != null && email.isNotEmpty) 'email': email,
        'name': name,
        'nationality': nationality.toString(),
        'photo': photo,
        'sex': sex.toString(),
        'telephone': telephone,
        'travelPackageId': travelPackageId.toString(),
      };

      final json = await netWorkDataSource.postMultipart(
        Endpoint.ticketTravelPackageConfirm,
        fields: fields,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      try {
        log('This is response travel package confirm ==>>${json.toString()}');
      } catch (_) {
        // ignore logging errors
      }
      doOnSuccess.call(ConfirmTravelPackageResponse.fromJson(json));
    } catch (e) {
      log('An error occurred: $e');
      doOnFailed.call();
      rethrow;
    }
  }

  Future<BuyTravelPackageListResponse> getBuyList(context) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketTravelPackageGetPackage,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );

      try {
        log('This is response buy travel package list ==>>${json.toString()}');
      } catch (_) {
        // ignore logging errors
      }
      return BuyTravelPackageListResponse.fromJson(json);
    } catch (e) {
      rethrow;
    }
  }
}
