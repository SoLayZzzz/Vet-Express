import '../repository/payment_repository.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';

class PaymentUscase {
  final PaymentRepository repository;

  PaymentUscase(this.repository);

  Future<PaymentResponse> processPayment({
    required String code,
    required String paymentMethodId,
    required String totalAmount,
  }) {
    return repository.processPayment(
      code: code,
      paymentMethodId: paymentMethodId,
      totalAmount: totalAmount,
    );
  }

  Future<ABAPayResponse> abaMobilePay({
    required String transactionId,
    required String token,
  }) {
    return repository.abaMobilePay(transactionId: transactionId, token: token);
  }

  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  }) {
    return repository.acledaCheckStatus(transactionId: transactionId);
  }

  Future<Map<String, dynamic>> acledaComplete({
    required String transactionId,
    required String token,
  }) {
    return repository.acledaComplete(
      transactionId: transactionId,
      token: token,
    );
  }

  Future<ABAPayResponse> acledaMobilePay({
    required String transactionId,
    required String token,
    required String type
  }) {
    return repository.acledaMobilePay(transactionId: transactionId, token: token, type: type);
  }


  
}
