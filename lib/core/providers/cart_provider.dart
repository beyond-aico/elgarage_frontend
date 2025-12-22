import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  // المفتاح هو الـ ID بتاع المنتج، والقيمة هي الكمية
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  // عدد المنتجات في السلة
  int get itemCount => _items.length;

  // إجمالي السعر
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // إضافة منتج
  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      // لو المنتج موجود، زود الكمية
      _items.update(
        product.id,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      // لو جديد، ضيفه
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: product.id,
          title: product.title,
          price: product.price,
          quantity: 1,
          imageUrl: product.imageUrl,
        ),
      );
    }
    notifyListeners(); // نبه التطبيق كله إن فيه تغيير حصل
  }

  // حذف منتج
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }
  
  // تقليل الكمية
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity - 1,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // تفريغ السلة (بعد الدفع الناجح)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });
}