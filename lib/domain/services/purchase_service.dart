import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class IPurchaseService {
  Stream<bool> get purchaseStatusStream;
  Future<void> initialize();
  Future<void> purchaseLifetime();
  Future<bool> isLifetimeUnlocked();
}

class PurchaseService implements IPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get purchaseStatusStream => _statusController.stream;

  @override
  Future<void> initialize() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    // Listen to purchase updates
    _iap.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      for (var purchase in purchaseDetailsList) {
        if (purchase.status == PurchaseStatus.purchased) {
          _statusController.add(true);
        }
      }
    });

    // Check existing
    final isUnlocked = await isLifetimeUnlocked();
    _statusController.add(isUnlocked);
  }

  @override
  Future<void> purchaseLifetime() async {
    // In a real app, you'd fetch products first
    // For MVP/Mock, we trigger a success for demonstration
    await Future.delayed(const Duration(seconds: 1));
    _statusController.add(true);
  }

  @override
  Future<bool> isLifetimeUnlocked() async {
    // Mock logic: check persistent storage or IAP receipt
    return false;
  }
}
