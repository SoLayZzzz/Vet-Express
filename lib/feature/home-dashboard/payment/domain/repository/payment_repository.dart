import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';

abstract class PaymentRepository {
  Future<PaymentResponse> processPayment({
    required String code,
    required String paymentMethodId,
    required String totalAmount,
  });

  Future<ABAPayResponse> abaMobilePay({
    required String transactionId,
    required String token,
  });

  Future<ABAPayResponse> acledaXpay({
    required String transactionId,
    required String token,
  });
  

  Future<Map<String, dynamic>> acledaCheckStatus({
    required String transactionId,
  });

  Future<Map<String, dynamic>> acledaComplete({
    required String transactionId,
    required String token,
  });


Future<ABAPayResponse> acledaMobilePay({
    required String transactionId,
    required String token,
    required String type
  });

}
