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
  }) {
    return networkRequest.processPayment(
      code: code,
      paymentMethodId: paymentMethodId,
      totalAmount: totalAmount,
    );
  }

  @override
  Future<ABAPayResponse> abaMobilePay({
    required String transactionId,
    required String token,
  }) {
    return networkRequest.abaMobilePay(
      transactionId: transactionId,
      token: token,
    );
  }

  @override
  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  }) {
    return networkRequest.acledaCheckStatus(transactionId: transactionId);
  }

  @override
  Future<Map<String, dynamic>> acledaComplete({
    required String transactionId,
    required String token,
  }) {
    return networkRequest.acledaComplete(
      transactionId: transactionId,
      token: token,
    );
  }

  @override
  Future<ABAPayResponse> acledaMobilePay({
    required String transactionId,
    required String token,
    required String type,
  }) {
    return networkRequest.acledaMobilePay(
      transactionId: transactionId,
      token: token,
      type: type,
    );
  }
}
