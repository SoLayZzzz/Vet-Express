import 'dart:developer';
import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/utils/contains.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';
import 'package:flutter/material.dart';

class PaymentNetworkRequest {
  final NetworkDataSource paymentApi;
  final NetworkDataSource ticketApi;

  PaymentNetworkRequest({required this.paymentApi, required this.ticketApi});

  Future<PaymentResponse> processPayment({
    required String code,
    required String paymentMethodId,
    required String totalAmount,
  }) async {
    final fields = <String, String>{
      'code': code,
      'paymentMethodId': paymentMethodId,
      'totalAmount': totalAmount,
    };
    try {
      debugPrint(
        'PaymentNetworkRequest.processPayment.request '
        'url=${ticketApi.baseUrl}${Endpoint.ticketBookingProcessPayment} '
        'fields=$fields',
      );
    } catch (_) {}
    final json = await ticketApi.postFormUrlEncoded(
      Endpoint.ticketBookingProcessPayment,
      fields: fields,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );

    return PaymentResponse.fromJson(json);
  }

  Future<ABAPayResponse> abaMobilePay({
    required String transactionId,
    required String token,
  }) async {
    final json = await paymentApi.postFormUrlEncoded(
      'payments/abaMobilePay/$transactionId/$token',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return ABAPayResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  }) async {
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaCheckStatus/$transactionId',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return json;
  }

  Future<Map<String, dynamic>> acledaComplete({
    required String transactionId,
    required String token,
  }) async {
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaComplete/$transactionId/$token',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return json;
  }

  Future<ABAPayResponse> acledaMobilePay({
    required String transactionId,
    required String token,
    required String type,
  }) async {
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaMobilePay/$transactionId/$token/$type',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return ABAPayResponse.fromJson(json);
  }
}
