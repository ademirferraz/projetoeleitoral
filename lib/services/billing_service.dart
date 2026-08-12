import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingService {
  static const String _compradoKey = 'acesso_vitalicio_comprado';
  static const String _produtoId = 'acesso_vitalicio';
  static const String _codigoAcessoHash =
      'faa483545da6a98944b120190dbe05926f71e60cf4338a22c3c792c180c990b6';

  static bool _comprado = false;
  static bool _initialized = false;
  static ProductDetails? _produto;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  static bool get isComprado => _comprado;
  static bool get isInitialized => _initialized;
  static ProductDetails? get produto => _produto;
  static String get produtoId => _produtoId;

  static Future<void> init() async {
    if (_initialized || kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    _comprado = prefs.getBool(_compradoKey) ?? false;

    final iap = InAppPurchase.instance;

    final disponivel = await iap.isAvailable();
    if (!disponivel) return;

    _subscription = iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e) => debugPrint('[Billing] Erro no stream: $e'),
    );

    final resposta = await iap.queryProductDetails({_produtoId});
    if (resposta.productDetails.isNotEmpty) {
      _produto = resposta.productDetails.first;
    }

    _initialized = true;
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  static Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.productID != _produtoId) return;

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      await _liberarAcesso();
    } else if (purchase.status == PurchaseStatus.error) {
      debugPrint('[Billing] Erro na compra: ${purchase.error}');
    }
  }

  static Future<void> _liberarAcesso() async {
    _comprado = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_compradoKey, true);
  }

  static Future<bool> iniciarCompra() async {
    if (_produto == null) return false;
    final iap = InAppPurchase.instance;
    final param = PurchaseParam(productDetails: _produto!);
    return iap.buyNonConsumable(purchaseParam: param);
  }

  static Future<bool> liberarPorCodigo(String codigo) async {
    final digitado = codigo.trim();
    if (digitado.isEmpty) return false;

    final hash = sha256.convert(utf8.encode(digitado)).toString();
    if (hash != _codigoAcessoHash) return false;

    await _liberarAcesso();
    return true;
  }

  static Future<void> restaurarCompras() async {
    final iap = InAppPurchase.instance;
    await iap.restorePurchases();
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @visibleForTesting
  static void resetParaTeste() {
    _comprado = false;
    _initialized = false;
    _produto = null;
  }
}
