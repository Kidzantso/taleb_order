import 'package:riverpod/riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String photoUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.photoUrl,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      photoUrl: photoUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    final index = state.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      final updated = state[index].copyWith(
        quantity: state[index].quantity + 1,
      );
      final newState = [...state];
      newState[index] = updated;
      state = newState;
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    final index = state.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity > 1) {
        final updated = item.copyWith(quantity: item.quantity - 1);
        final newState = [...state];
        newState[index] = updated;
        state = newState;
      } else {
        state = state.where((i) => i.id != id).toList();
      }
    }
  }

  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void clearCart() {
    state = [];
  }

  int totalItems() => state.fold(0, (sum, item) => sum + item.quantity);

  double totalPrice() =>
      state.fold(0, (sum, item) => sum + item.price * item.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  () => CartNotifier(),
);
