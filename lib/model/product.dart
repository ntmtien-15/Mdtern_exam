class Product {
  String id;
  String name;
  String category;
  double price;
  String imageUrl;

  Product({required this.id, required this.name, required this.category, required this.price, required this.imageUrl});

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'],
      name: data['name'],
      category: data['category'],
      price: data['price'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
