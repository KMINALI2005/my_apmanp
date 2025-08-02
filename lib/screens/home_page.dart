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
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد ديون لعرضها',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'اضغط على + لإضافة دين جديد',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
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
            MaterialPageRoute(builder: (context) => const AddEditDebtPage()),
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
                        fontSize: 20,
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
                        fontSize: 20,
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
                        fontSize: 20,
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
          if (provider.filteredDebts.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => FileService.generatePdf(provider.filteredDebts, context),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('تصدير PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => FileService.generateExcel(provider.filteredDebts, context),
                  icon: const Icon(Icons.description),
                  label: const Text('تصدير Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
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
              _showDeleteConfirmation(context, debt);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'حذف',
          ),
          SlidableAction(
            onPressed: (context) {
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
            Provider.of<DebtProvider>(context, listen: false).toggleDebtPaid(debt);
          },
          leading: Icon(
            debt.isPaid ? Icons.check_circle : Icons.error_outline,
            color: debt.isPaid ? Colors.green : Colors.red,
            size: 30,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'التاريخ: ${DateFormat('yyyy-MM-dd').format(debt.date)}',
                style: TextStyle(
                  decoration: debt.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (debt.description.isNotEmpty)
                Text(
                  debt.description,
                  style: TextStyle(
                    decoration: debt.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Chip(
            label: Text(
              debt.category,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getCategoryColor(debt.category),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ديون المفرد':
        return Colors.blue.shade100;
      case 'ديون الجملة':
        return Colors.orange.shade100;
      case 'ديون المندوبين':
        return Colors.purple.shade100;
      default:
        return Colors.teal.shade100;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنت متأكد من حذف دين "${debt.name}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<DebtProvider>(context, listen: false).deleteDebt(debt.id!);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }
}
