import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة الديون',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DebtManagerHome(),
    );
  }
}

class Debt {
  String id;
  String name;
  String type; // 'individual', 'wholesale', 'representative'
  double amount;
  String description;
  DateTime date;
  bool isPaid;

  Debt({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      isPaid: json['isPaid'] ?? false,
    );
  }
}

class DebtManagerHome extends StatefulWidget {
  const DebtManagerHome({Key? key}) : super(key: key);

  @override
  _DebtManagerHomeState createState() => _DebtManagerHomeState();
}

class _DebtManagerHomeState extends State<DebtManagerHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Debt> debts = [];
  List<Debt> individualDebts = [];
  List<Debt> wholesaleDebts = [];
  List<Debt> representativeDebts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDebts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = prefs.getString('debts') ?? '[]';
    final List<dynamic> debtsList = json.decode(debtsJson);
    
    setState(() {
      debts = debtsList.map((debt) => Debt.fromJson(debt)).toList();
      _filterDebts();
    });
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = json.encode(debts.map((debt) => debt.toJson()).toList());
    await prefs.setString('debts', debtsJson);
  }

  void _filterDebts() {
    individualDebts = debts.where((debt) => debt.type == 'individual').toList();
    wholesaleDebts = debts.where((debt) => debt.type == 'wholesale').toList();
    representativeDebts = debts.where((debt) => debt.type == 'representative').toList();
  }

  void _addDebt(Debt debt) {
    setState(() {
      debts.add(debt);
      _filterDebts();
    });
    _saveDebts();
  }

  void _updateDebt(Debt updatedDebt) {
    setState(() {
      int index = debts.indexWhere((debt) => debt.id == updatedDebt.id);
      if (index != -1) {
        debts[index] = updatedDebt;
        _filterDebts();
      }
    });
    _saveDebts();
  }

  void _deleteDebt(String id) {
    setState(() {
      debts.removeWhere((debt) => debt.id == id);
      _filterDebts();
    });
    _saveDebts();
  }

  void _payDebt(String id) {
    setState(() {
      int index = debts.indexWhere((debt) => debt.id == id);
      if (index != -1) {
        debts[index].isPaid = true;
        _filterDebts();
      }
    });
    _saveDebts();
  }

  double _getTotalAmount(List<Debt> debtList) {
    return debtList.where((debt) => !debt.isPaid).fold(0.0, (sum, debt) => sum + debt.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إدارة الديون',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                  labelColor: Color(0xFF667eea),
                  unselectedLabelColor: Colors.white,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  tabs: [
                    Tab(text: 'الكل'),
                    Tab(text: 'المفرد'),
                    Tab(text: 'الجملة'),
                    Tab(text: 'المندوب'),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDebtList(debts, 'جميع الديون'),
                      _buildDebtList(individualDebts, 'ديون المفرد'),
                      _buildDebtList(wholesaleDebts, 'ديون الجملة'),
                      _buildDebtList(representativeDebts, 'ديون المندوب'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(),
        backgroundColor: Color(0xFF667eea),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDebtList(List<Debt> debtList, String title) {
    double totalAmount = _getTotalAmount(debtList);
    
    return Column(
      children: [
        // Summary Card
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'إجمالي المبلغ المستحق',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                '${NumberFormat('#,##0.00').format(totalAmount)} ج.م',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Debt List
        Expanded(
          child: debtList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'لا توجد ديون',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: debtList.length,
                  itemBuilder: (context, index) {
                    final debt = debtList[index];
                    return _buildDebtCard(debt);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDebtCard(Debt debt) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: debt.isPaid ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: debt.isPaid 
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (debt.isPaid)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green.withOpacity(0.1),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        debt.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: debt.isPaid ? Colors.grey : Colors.black87,
                          decoration: debt.isPaid 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(debt.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTypeText(debt.type),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 10),
                
                Text(
                  debt.description,
                  style: TextStyle(
                    color: debt.isPaid ? Colors.grey : Colors.grey[600],
                    fontSize: 14,
                    decoration: debt.isPaid 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                ),
                
                SizedBox(height: 15),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${NumberFormat('#,##0.00').format(debt.amount)} ج.م',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: debt.isPaid ? Colors.grey : Color(0xFF667eea),
                        decoration: debt.isPaid 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(debt.date),
                      style: TextStyle(
                        color: debt.isPaid ? Colors.grey : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                if (debt.isPaid)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          'تم التسديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                if (!debt.isPaid)
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _payDebt(debt.id),
                            icon: Icon(Icons.payment, size: 16),
                            label: Text('تسديد'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _showEditDebtDialog(debt),
                          icon: Icon(Icons.edit, size: 16),
                          label: Text('تعديل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _confirmDelete(debt.id),
                          icon: Icon(Icons.delete, size: 16),
                          label: Text('حذف'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'individual':
        return Colors.blue;
      case 'wholesale':
        return Colors.orange;
      case 'representative':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'individual':
        return 'مفرد';
      case 'wholesale':
        return 'جملة';
      case 'representative':
        return 'مندوب';
      default:
        return 'غير محدد';
    }
  }

  void _showAddDebtDialog() {
    _showDebtDialog(null);
  }

  void _showEditDebtDialog(Debt debt) {
    _showDebtDialog(debt);
  }

  void _showDebtDialog(Debt? debt) {
    final nameController = TextEditingController(text: debt?.name ?? '');
    final amountController = TextEditingController(
        text: debt?.amount.toString() ?? '');
    final descriptionController = TextEditingController(
        text: debt?.description ?? '');
    String selectedType = debt?.type ?? 'individual';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                debt == null ? 'إضافة دين جديد' : 'تعديل الدين',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المدين',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.money),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'نوع الدين',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        DropdownMenuItem(value: 'individual', child: Text('مفرد')),
                        DropdownMenuItem(value: 'wholesale', child: Text('جملة')),
                        DropdownMenuItem(value: 'representative', child: Text('مندوب')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        amountController.text.isNotEmpty) {
                      if (debt == null) {
                        // Add new debt
                        final newDebt = Debt(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          type: selectedType,
                          amount: double.parse(amountController.text),
                          description: descriptionController.text,
                          date: DateTime.now(),
                        );
                        _addDebt(newDebt);
                      } else {
                        // Update existing debt
                        final updatedDebt = Debt(
                          id: debt.id,
                          name: nameController.text,
                          type: selectedType,
                          amount: double.parse(amountController.text),
                          description: descriptionController.text,
                          date: debt.date,
                          isPaid: debt.isPaid,
                        );
                        _updateDebt(updatedDebt);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(debt == null ? 'إضافة' : 'تحديث'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'تأكيد الحذف',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text('هل تريد حذف هذا الدين؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteDebt(id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
