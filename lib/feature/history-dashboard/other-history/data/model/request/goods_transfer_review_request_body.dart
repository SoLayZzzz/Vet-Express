class GoodsTransferReviewRequestBody {
  final String goodsTransferId;
  final String comment;
  final String score;
  final String type;

  const GoodsTransferReviewRequestBody({
    required this.goodsTransferId,
    required this.comment,
    required this.score,
    required this.type,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'goodsTransferId': goodsTransferId,
    'comment': comment,
    'score': score,
    'type': type,
  };
}
