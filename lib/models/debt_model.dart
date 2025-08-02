// models/debt_model.dart
class Debt {
  int? id;
  String name;
  double amount;
  String category;
  DateTime date;
  String description;
  bool isPaid;

  Debt({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
    this.isPaid = false,
  });

  // Convert a Debt object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'isPaid': isPaid ? 1 : 0,
    };
  }

  // Extract a Debt object from a Map object
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      isPaid: map['isPaid'] == 1,
    );
  }
}
