import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pockettracer/services/storage_service.dart';
import 'package:pockettracer/vo/transaction.dart';

class Balance extends ChangeNotifier {
  static const String balanceKey = 'balance';
  static const String transactionsKey = 'transactions';

  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  Balance() {
    _initializeData();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  double get balance => _balance;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> _initializeData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final storedBalance = await StorageService.getData<double>(balanceKey);
      _balance = storedBalance ?? 0.0;

      final storedTransactions =
          await StorageService.getData<List<Map<String, dynamic>>>(
              transactionsKey);
      if (storedTransactions != null) {
        _transactions = storedTransactions
            .map((json) => Transaction.fromJson(json))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }

      _isLoading = false;
      _error = null;
    } catch (e) {
      _error = 'Failed to load data: $e';
      _isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      _transactions.insert(0, transaction);
      _updateBalance(transaction, isAddition: true);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add transaction: $e';
      _transactions.removeWhere((t) => t.id == transaction.id);
      _updateBalance(transaction, isAddition: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeTransaction(Transaction transaction) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index == -1) return;

      _transactions.removeAt(index);
      _updateBalance(transaction, isAddition: false);
      await _saveData();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove transaction: $e';
      notifyListeners();
      rethrow;
    }
  }

  void _updateBalance(Transaction transaction, {required bool isAddition}) {
    if (transaction.isExpense) {
      _balance += isAddition ? -transaction.amount : transaction.amount;
    } else {
      _balance += isAddition ? transaction.amount : -transaction.amount;
    }
  }

  Future<void> _saveData() async {
    await StorageService.storeData(balanceKey, _balance);
    final transactionsJson = _transactions.map((t) => t.toJson()).toList();
    await StorageService.storeData(transactionsKey, transactionsJson);
  }

  Future<void> clearAllData() async {
    _balance = 0;
    _transactions.clear();
    await _saveData();
    notifyListeners();
  }
}
