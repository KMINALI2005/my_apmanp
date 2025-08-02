// providers/debt_provider.dart
import 'package:flutter/material.dart';

import '../models/debt_model.dart';
import '../services/database_helper.dart';

class DebtProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Debt> _debts = [];
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  List<Debt> get debts => _debts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Constructor to load debts on startup
  DebtProvider() {
    loadDebts();
  }

  Future<void> loadDebts() async {
    _debts = await _dbHelper.getDebts();
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await _dbHelper.insertDebt(debt);
    await loadDebts();
  }

  Future<void> updateDebt(Debt debt) async {
    await _dbHelper.updateDebt(debt);
    await loadDebts();
  }

  Future<void> deleteDebt(int id) async {
    await _dbHelper.deleteDebt(id);
    await loadDebts();
  }

  void toggleDebtPaid(Debt debt) async {
    debt.isPaid = !debt.isPaid;
    await _dbHelper.updateDebt(debt);
    await loadDebts();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Debt> get filteredDebts {
    final filtered = _debts.where((debt) {
      final matchesCategory = _selectedCategory == 'الكل' || debt.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          debt.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          debt.amount.toString().contains(_searchQuery) ||
          debt.date.toString().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    // Sort debts by date, newest first
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  double get totalDebt => _debts.fold(0, (sum, item) => sum + item.amount);
  double get remainingDebt => _debts.where((debt) => !debt.isPaid).fold(0, (sum, item) => sum + item.amount);
  double get paidDebt => _debts.where((debt) => debt.isPaid).fold(0, (sum, item) => sum + item.amount);
}
