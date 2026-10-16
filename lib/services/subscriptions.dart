import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/state/app_state.dart';

/// Official store billing only (App Store / Google Play) via in_app_purchase.
/// Product IDs must match those created in App Store Connect / Play Console.
class Subscriptions {
  Subscriptions._();
  static final Subscriptions I = Subscriptions._();

  static const yearly = 'explorer_plus_yearly';
  static const monthly = 'explorer_plus_monthly';
  static const ids = {yearly, monthly};

  final ValueNotifier<Map<String, ProductDetails>> products = ValueNotifier({});
  final ValueNotifier<String> status = ValueNotifier('');
  final ValueNotifier<bool> busy = ValueNotifier(false);
  bool available = false;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  AppState? _state;

  Future<void> init(AppState state) async {
    _state = state;
    if (kIsWeb) return;
    try {
      final iap = InAppPurchase.instance;
      available = await iap.isAvailable();
      if (!available) return;
      _sub = iap.purchaseStream.listen(_onPurchases, onError: (Object e) => status.value = 'Store error: $e');
      final res = await iap.queryProductDetails(ids);
      products.value = {for (final p in res.productDetails) p.id: p};
      if (res.notFoundIDs.isNotEmpty) {
        debugPrint('Products not set up in the store yet: ${res.notFoundIDs}');
      }
    } catch (e) {
      debugPrint('Store unavailable: $e');
      available = false;
    }
  }

  Future<void> buy(String id) async {
    final p = products.value[id];
    if (!available || p == null) {
      status.value = 'The store is not available right now. Please try again later.';
      return;
    }
    busy.value = true;
    status.value = '';
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      busy.value = false;
      status.value = 'Purchase could not start: $e';
    }
  }

  Future<void> restore() async {
    if (!available) {
      status.value = 'The store is not available right now.';
      return;
    }
    busy.value = true;
    status.value = 'Checking your purchases…';
    try {
      await InAppPurchase.instance.restorePurchases();
      // If nothing is restored, the stream stays quiet.
      Future.delayed(const Duration(seconds: 6), () {
        if (busy.value) {
          busy.value = false;
          status.value = _state?.plus == true ? 'Explorer Plus is active.' : 'No active subscription found.';
        }
      });
    } catch (e) {
      busy.value = false;
      status.value = 'Restore failed: $e';
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          status.value = 'Waiting for the store to confirm…';
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (ids.contains(p.productID)) {
            // A new yearly/monthly purchase starts with the 7-day free trial.
            _state?.setPlus(active: true, trial: p.status == PurchaseStatus.purchased, product: p.productID);
            status.value = 'Thank you! Explorer Plus is active.';
          }
          busy.value = false;
        case PurchaseStatus.error:
          busy.value = false;
          status.value = 'The purchase did not go through. You have not been charged.';
        case PurchaseStatus.canceled:
          busy.value = false;
          status.value = 'Purchase cancelled.';
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  void dispose() => _sub?.cancel();
}
