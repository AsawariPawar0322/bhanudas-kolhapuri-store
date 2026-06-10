class Product {
  final String id;
  final String name;
  final String category;
  final String material;
  final String color;
  final double price;
  final int stock;
  final double rating;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.material,
    required this.color,
    required this.price,
    required this.stock,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      material: json['material'],
      color: json['color'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      rating: json['rating'].toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}
