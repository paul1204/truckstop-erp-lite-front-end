import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class HouseAccount {
  final String houseAccountId;
  final String companyName;
  final String phoneNumber;
  final String address;
  final double creditLimit;
  final String accountStanding; // GOOD, WARNING, DELINQUENT
  final int goodStandingDuration;
  final int accountAge;
  final String createdAt;
  final String updatedAt;
  final double amountDue;
  final double gallonsDue;

  HouseAccount({
    required this.houseAccountId,
    required this.companyName,
    required this.phoneNumber,
    required this.address,
    required this.creditLimit,
    required this.accountStanding,
    required this.goodStandingDuration,
    required this.accountAge,
    required this.createdAt,
    required this.updatedAt,
    required this.amountDue,
    required this.gallonsDue,
  });

  factory HouseAccount.fromJson(Map<String, dynamic> json) {
    return HouseAccount(
      houseAccountId: json['houseAccountId'] as String,
      companyName: json['companyName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      accountStanding: json['accountStanding'] as String,
      goodStandingDuration: (json['goodStandingDuration'] as num).toInt(),
      accountAge: (json['accountAge'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      amountDue: (json['amountDue'] as num).toDouble(),
      gallonsDue: (json['gallonsDue'] as num).toDouble(),
    );
  }
}

class HouseAccountsNotifier extends ChangeNotifier {
  List<HouseAccount> _accounts = [];
  List<HouseAccount> get accounts => _accounts;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  HouseAccountsNotifier() {
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await ApiCatalog.getHouseAccounts();
      _accounts = raw.map((json) => HouseAccount.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addHouseAccount(Map<String, dynamic> payload) async {
    try {
      final jsonResponse = await ApiCatalog.postHouseAccount(payload);
      final newAccount = HouseAccount.fromJson(jsonResponse);
      _accounts.insert(0, newAccount);
      notifyListeners();
      return true;
    } catch (e) {
      print('HouseAccountsNotifier: error adding house account: $e');
      return false;
    }
  }
}
