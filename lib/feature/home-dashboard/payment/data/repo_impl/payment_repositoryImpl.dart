import 'dart:developer';
import 'package:express_vet/feature/home-dashboard/payment/data/network/payment_network_request.dart';
import 'package:express_vet/feature/home-dashboard/payment/domain/repository/payment_repository.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentNetworkRequest networkRequest;

  PaymentRepositoryImpl(this.networkRequest);

  @override
  Future<PaymentResponse> processPayment({
    required String code,
    required String paymentMethodId,
    required String totalAmount,
  }) async {
    log(
      'PaymentRepository.processPayment.request code=$code, '
      'paymentMethodId=$paymentMethodId, totalAmount=$totalAmount',
    );
    final res = await networkRequest.processPayment(
      code: code,
      paymentMethodId: paymentMethodId,
      totalAmount: totalAmount,
    );
    log(
      'PaymentRepository.processPayment.response '
      'statusCode=${res.header?.statusCode}, result=${res.header?.result}, '
      'bodyStatus=${res.body?.status}, hasToken=${res.body?.token != null}',
    );
    return res;
  }

  @override
  Future<ABAPayResponse> acledaXpay({
    required String transactionId,
    required String token,
  }) async {
    log(
      'PaymentRepository.acledaXpay.request '
      'transactionId=$transactionId, token=$token',
    );
    final res = await networkRequest.acledaXpay(
      transactionId: transactionId,
      token: token,
    );
    log(
      'PaymentRepository.acledaXpay.response status=${res.status}, '
      'hasDeeplink=${(res.abapayDeeplink ?? '').isNotEmpty}',
    );
    return res;
  }

  @override
  Future<ABAPayResponse> abaMobilePay({
    required String transactionId,
    required String token,
  }) async {
    log(
      'PaymentRepository.abaMobilePay.request '
      'transactionId=$transactionId, token=$token',
    );
    final res = await networkRequest.abaMobilePay(
      transactionId: transactionId,
      token: token,
    );
    log(
      'PaymentRepository.abaMobilePay.response status=${res.status}, '
      'hasDeeplink=${(res.abapayDeeplink ?? '').isNotEmpty}, '
      'hasCheckoutQr=${(res.checkout_qr_url ?? '').isNotEmpty}',
    );
    return res;
  }

  @override
  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  }) async {
    log(
      'PaymentRepository.acledaCheckStatus.request '
      'transactionId=$transactionId',
    );
    final res = await networkRequest.acledaCheckStatus(
      transactionId: transactionId,
    );
    log('PaymentRepository.acledaCheckStatus.response status=${res['status']}');
    return res;
  }

  @override
  Future<Map<String, dynamic>> acledaComplete({
    required String transactionId,
    required String token,
  }) async {
    log(
      'PaymentRepository.acledaComplete.request '
      'transactionId=$transactionId, token=$token',
    );
    final res = await networkRequest.acledaComplete(
      transactionId: transactionId,
      token: token,
    );
    log('PaymentRepository.acledaComplete.response status=${res['status']}');
    return res;
  }
  
  // @override
  // Future<ABAPayResponse> acledaMobilePay({required String transactionId, required String token, required String type}) {
  //   // TODO: implement acledaMobilePay
  //   throw UnimplementedError();
  // }

  @override
  Future<ABAPayResponse> acledaMobilePay({
    required String transactionId,
    required String token,
    required String type,
  }) async {
    log(
      'PaymentRepository.acledaMobilePay.request '
      'transactionId=$transactionId, token=$token, type=$type',
    );
    final res = await networkRequest.acledaMobilepay(
      transactionId: transactionId,
      token: token,
      type: type,
    );
    log(
      'PaymentRepository.acledaMobilePay.response status=${res.status}, '
      'hasDeeplink=${(res.abapayDeeplink ?? '').isNotEmpty}',
    );
    return res;
  }
}
