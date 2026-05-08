class PaymentUistate {
  final int paymentMethodId;
  final int paymentMethodSelected;
  final bool showFareSummary;
  final bool loop;
  final String newToken;
  final bool acledaPaymentInitiated;

  const PaymentUistate({
    this.paymentMethodId = 0,
    this.paymentMethodSelected = 0,
    this.showFareSummary = false,
    this.loop = true,
    this.newToken = '',
    this.acledaPaymentInitiated = false,
  });
}
