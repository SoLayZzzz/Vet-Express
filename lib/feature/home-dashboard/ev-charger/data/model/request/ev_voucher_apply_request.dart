class EvVoucherRequest {
  final String code;

  EvVoucherRequest({
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code
    };
  }

  Map<String, String> toFormFields() {
    return <String, String>{
      'code': code
    };
  }
}
