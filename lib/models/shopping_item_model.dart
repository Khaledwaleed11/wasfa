class ShoppingItemModel {
  final String id;
  final String name;
  final String quantity;
  final bool isCompleted;

  const ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    this.isCompleted = false,
  });

  ShoppingItemModel copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isCompleted,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isCompleted': isCompleted,
    };
  }

  factory ShoppingItemModel.fromJson(Map<dynamic, dynamic> json) {
    return ShoppingItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
    );
  }
}
