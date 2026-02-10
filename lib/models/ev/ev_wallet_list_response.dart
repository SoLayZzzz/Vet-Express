// Update your model with proper class names to avoid conflicts
import 'dart:convert';

EvWalletListResponse evWalletListResponseFromJson(String str) =>
    EvWalletListResponse.fromJson(json.decode(str));

String evWalletListResponseToJson(EvWalletListResponse data) => json.encode(data.toJson());

class EvWalletListResponse {
  Header? header;
  EvWalletListBody? body;

  EvWalletListResponse({this.header, this.body});

  factory EvWalletListResponse.fromJson(Map<String, dynamic> json) => EvWalletListResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvWalletListBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {"header": header?.toJson(), "body": body?.toJson()};
}

class EvWalletListBody {
  bool? status;
  String? message;
  Pagination? pagination;
  WalletData? data;

  EvWalletListBody({this.status, this.message, this.pagination, this.data});

  factory EvWalletListBody.fromJson(Map<String, dynamic> json) => EvWalletListBody(
    status: json["status"],
    message: json["message"],
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    data: json["data"] == null ? null : WalletData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data?.toJson(),
  };
}

class WalletData {
  double? totalBalance;
  List<TransactionGroup>? groups;

  WalletData({this.totalBalance, this.groups});

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
    totalBalance: json["totalBalance"]?.toDouble(),
    groups:
        json["groups"] == null
            ? []
            : List<TransactionGroup>.from(json["groups"]!.map((x) => TransactionGroup.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "totalBalance": totalBalance,
    "groups": groups == null ? [] : List<dynamic>.from(groups!.map((x) => x.toJson())),
  };
}

class TransactionGroup {
  // Renamed to avoid conflict
  String? date;
  List<WalletTransaction>? transactions;

  TransactionGroup({this.date, this.transactions});

  factory TransactionGroup.fromJson(Map<String, dynamic> json) => TransactionGroup(
    date: json["date"],
    transactions:
        json["transactions"] == null
            ? []
            : List<WalletTransaction>.from(
              json["transactions"]!.map((x) => WalletTransaction.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "transactions":
        transactions == null ? [] : List<dynamic>.from(transactions!.map((x) => x.toJson())),
  };
}

class WalletTransaction {
  int? id;
  int? type;
  String? transactionId;
  String? code;
  double? amount;
  String? description;
  String? createdDate;

  WalletTransaction({
    this.id,
    this.type,
    this.transactionId,
    this.code,
    this.amount,
    this.description,
    this.createdDate,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json["id"],
    type: json["type"],
    transactionId: json["transactionId"],
    code: json["code"],
    amount: json["amount"] is int ? (json["amount"] as int).toDouble() : json["amount"]?.toDouble(),
    description: json["description"],
    createdDate: json["createdDate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "transactionId": transactionId,
    "code": code,
    "amount": amount,
    "description": description,
    "createdDate": createdDate,
  };
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({this.page, this.rowsPerPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      Pagination(page: json["page"], rowsPerPage: json["rowsPerPage"], total: json["total"]);

  Map<String, dynamic> toJson() => {"page": page, "rowsPerPage": rowsPerPage, "total": total};
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  factory Header.fromJson(Map<String, dynamic> json) => Header(
    serverTimestamp: json["serverTimestamp"],
    result: json["result"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "serverTimestamp": serverTimestamp,
    "result": result,
    "statusCode": statusCode,
  };
}

// Add aliases for compatibility with existing code
typedef Group = TransactionGroup;
typedef Transaction = WalletTransaction;
typedef EvWalletListDatum = TransactionGroup;
