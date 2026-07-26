import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/product.dart';

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final res = await ApiClient.get('/products');
  if (res['success'] == true) {
    return (res['data'] as List).map((x) => ProductModel.fromJson(x)).toList();
  }
  return [];
});

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add(ProductModel product) {
    final idx = state.indexWhere((x) => x.product.id == product.id);
    if (idx != -1) {
      state[idx].quantity += 1;
      state = [...state];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void remove(int index) {
    state[index].quantity -= 1;
    if (state[index].quantity <= 0) {
      state = [...state]..removeAt(index);
    } else {
      state = [...state];
    }
  }

  void clear() {
    state = [];
  }

  double get subTotal => state.fold(0, (sum, i) => sum + (i.product.price * i.quantity));
  double get gst => subTotal * 0.05;
  double get grandTotal => subTotal + gst;
}
