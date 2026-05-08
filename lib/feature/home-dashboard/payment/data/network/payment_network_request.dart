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
    final base = paymentApi.baseUrl.endsWith('/')
        ? paymentApi.baseUrl
        : '${paymentApi.baseUrl}/';
    debugPrint(
      'PaymentNetworkRequest.abaMobilePay.request url=${base}payments/abaMobilePay/$transactionId/$token',
    );
    final json = await paymentApi.postFormUrlEncoded(
      'payments/abaMobilePay/$transactionId/$token',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return ABAPayResponse.fromJson(json);
  }

  Future<ABAPayResponse> acledaXpay({
    required String transactionId,
    required String token,
  }) async {
    final base = paymentApi.baseUrl.endsWith('/')
        ? paymentApi.baseUrl
        : '${paymentApi.baseUrl}/';
    debugPrint(
      '>>>>>>> PaymentNetworkRequest.acledaXpay.request url=${base}payments/acledaXpay/$transactionId/$token',
    );
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaXpay/$transactionId/$token',
      fields: const <String, String>{},
      attachAuth: true,
    );

    debugPrint('=====>> PaymentNetworkRequest.acledaXpay.response json=$json');

    return ABAPayResponse.fromJson(json);
  }

  Future<ABAPayResponse> acledaMobilepay({
    required String transactionId,
    required String token,
    required String type
  }) async {
    
     final base = paymentApi.baseUrl.endsWith('/')
        ? paymentApi.baseUrl
        : '${paymentApi.baseUrl}/';
    debugPrint(
      '>>>>>>> PaymentNetworkRequest.acledaMobilepay.request url=${base}payments/acledaMobilePay/$transactionId/$token/$type',
    );
    
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaMobilePay/$transactionId/$token/$type',
      fields: const <String, String>{},
      attachAuth: true,
    );


    return ABAPayResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  }) async {
    final base = paymentApi.baseUrl.endsWith('/')
        ? paymentApi.baseUrl
        : '${paymentApi.baseUrl}/';
    debugPrint(
      'PaymentNetworkRequest.acledaCheckStatus.request url=${base}payments/acledaCheckStatus/$transactionId',
    );
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
    final base = paymentApi.baseUrl.endsWith('/')
        ? paymentApi.baseUrl
        : '${paymentApi.baseUrl}/';
    debugPrint(
      'PaymentNetworkRequest.acledaComplete.request url=${base}payments/acledaComplete/$transactionId/$token',
    );
    final json = await paymentApi.postFormUrlEncoded(
      'payments/acledaComplete/$transactionId/$token',
      fields: const <String, String>{},
      attachAuth: true,
    );

    return json;
  }

}
