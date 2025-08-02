// screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../providers/debt_provider.dart';
import '../models/debt_model.dart';
import '../services/file_service.dart';
import '../screens/add_edit_debt_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدير الديون'),
        centerTitle: true,
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildSummaryCards(context, provider),
                _buildFilterAndSearch(context, provider),
                Expanded(
                  child: provider.filteredDebts.isEmpty
                      ? const Center(child: Text('لا توجد ديون لعرضها.'))
                      : ListView.builder(
                          itemCount: provider.filteredDebts.length,
                          itemBuilder: (context, index) {
                            final debt = provider.filteredDebts[index];
                            return _buildDebtListItem(context, debt);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditDebtPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, DebtProvider provider) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'د.ع.',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 4,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي الديون',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(provider.totalDebt),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 4,
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'الديون المتبقية',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(provider.remainingDebt),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 4,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'الديون المدفوعة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(provider.paidDebt),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearch(BuildContext context, DebtProvider provider) {
    final categories = ['الكل', 'ديون المفرد', 'ديون الجملة', 'ديون المندوبين'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => provider.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'البحث عن دين...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 8),
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: provider.selectedCategory == category,
                    selectedColor: Colors.teal,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: provider.selectedCategory == category ? Colors.white : Colors.black,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        provider.setCategory(category);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => FileService.generatePdf(provider.filteredDebts),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('تصدير PDF'),
              ),
              ElevatedButton.icon(
                onPressed: () => FileService.generateExcel(provider.filteredDebts),
                icon: const Icon(Icons.description),
                label: const Text('تصدير Excel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtListItem(BuildContext context, Debt debt) {
    return Slidable(
      key: ValueKey(debt.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Delete debt
              Provider.of<DebtProvider>(context, listen: false).deleteDebt(debt.id!);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
          ),
          SlidableAction(
            onPressed: (context) {
              // Edit debt
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddEditDebtPage(debt: debt)),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'تعديل',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 2,
        child: ListTile(
          onTap: () {
            // Toggle paid status
            Provider.of<DebtProvider>(context, listen: false).toggleDebtPaid(debt);
          },
          leading: Icon(
            debt.isPaid ? Icons.check_circle : Icons.error_outline,
            color: debt.isPaid ? Colors.green : Colors.red,
          ),
          title: Text(
            debt.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: debt.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
              color: debt.isPaid ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المبلغ: ${NumberFormat.currency(locale: 'ar_SA', symbol: 'د.ع.', decimalDigits: 0).format(debt.amount)}',
                style: TextStyle(
                  decoration: debt.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              Text(
                'التاريخ: ${DateFormat('yyyy-MM-dd').format(debt.date)}',
                style: TextStyle(
                  decoration: debt.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ],
          ),
          trailing: Chip(
            label: Text(debt.category),
            backgroundColor: Colors.teal.shade100,
          ),
        ),
      ),
    );
  }
}
