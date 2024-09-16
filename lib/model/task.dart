class Task {
  final int id;
  final String name;
  final String telNumber;
  final String product;
  final String reason;
  final double cost;
  final int qty;
  final String image;

  Task({
    required this.id,
    required this.name,
    required this.telNumber,
    required this.product,
    required this.reason,
    required this.cost,
    required this.qty,
    required this.image,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        telNumber: json['telNumber'] ?? '',
        product: json['product'] ?? '',
        reason: json['reason'] ?? '',
        cost: double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
        qty: json['qty'] != null && json['qty'].toString().isNotEmpty
            ? double.parse(json['qty'].toString()).toInt()
            : 0, // or any default value you prefer      // Handle 'image' field to accept both String and List<String>
        // image: json['image'] is String
        //     ? [json['image']]
        //     : List<String>.from(json['image'] ?? []),
        image: json['image']);
  }
}
