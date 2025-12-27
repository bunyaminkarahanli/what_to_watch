import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseCreditsView extends StatefulWidget {
  const PurchaseCreditsView({super.key});

  @override
  State<PurchaseCreditsView> createState() => _PurchaseCreditsViewState();
}

class _PurchaseCreditsViewState extends State<PurchaseCreditsView> {
  static const String _kProductId = 'credits_10';
  static const String _packageName = 'com.hangi.app';
  static const String _backendBaseUrl =
      'https://what-to-watch-backend.onrender.com';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _loading = true;
  bool _available = false;
  ProductDetails? _product;

  bool _verifying = false; // UI kilidi
  bool _processing = false; // gerçek işlem kilidi (kritik)

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  Future<void> _initIAP() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (Object error) {
          debugPrint("Purchase stream error: $error");
          if (mounted) setState(() => _verifying = false);
        },
      );

      final response = await _iap.queryProductDetails({_kProductId});

      if (response.error != null) {
        debugPrint("Product query error: ${response.error}");
        if (mounted) {
          setState(() {
            _loading = false;
            _product = null;
          });
        }
        return;
      }

      _product = response.productDetails.isNotEmpty
          ? response.productDetails.first
          : null;

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint("IAP init error: $e");
      if (mounted) {
        setState(() {
          _loading = false;
          _available = false;
          _product = null;
        });
      }
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> list) async {
    for (final purchase in list) {
      if (purchase.productID != _kProductId) continue;

      if (purchase.status == PurchaseStatus.pending) {
        if (mounted) setState(() => _verifying = true);
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _handleSuccessfulPurchase(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          setState(() => _verifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Satın alma sırasında hata oluştu.")),
          );
        }
      }

      // canceled case'i bazı sürümlerde yok → eklemiyoruz
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    // ✅ KRİTİK: gerçek kilit bu (stream birden fazla tetiklenebiliyor)
    if (_processing) return;

    _processing = true;
    if (mounted) setState(() => _verifying = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _verifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş yapmadan kredi eklenemez.")),
        );
        return;
      }

      // ✅ KRİTİK DÜZELTME: token'ı refresh ederek al
      final idToken = await user.getIdToken(true);

      final purchaseToken = purchase.verificationData.serverVerificationData;

      final response = await http.post(
        Uri.parse("$_backendBaseUrl/api/cars/add-credits"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "platform": "android",
          "packageName": _packageName,
          "productId": purchase.productID,
          "purchaseToken": purchaseToken,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ Backend OK → finalize
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        if (!mounted) return;
        setState(() => _verifying = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("10 araç önerisi hakkı eklendi!")),
        );
        Navigator.pop(context);
      } else {
        String msg = "Satın alma doğrulanamadı. Kredi eklenmedi.";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body["message"] != null) {
            msg = body["message"].toString();
          }
        } catch (_) {}

        if (!mounted) return;
        setState(() => _verifying = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));

        // Backend onaylamadı → completePurchase yapmıyoruz
      }
    } catch (e) {
      debugPrint("Handle purchase error: $e");
      if (!mounted) return;
      setState(() => _verifying = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      _processing = false;
    }
  }

  Future<void> _buy() async {
    if (_product == null) return;
    if (_verifying) return;

    final purchaseParam = PurchaseParam(productDetails: _product!);

    // ✅ B seçeneği: autoConsume true
    // ✅ Backend idempotency: purchaseToken tekrar gelirse kredi eklenmez
    await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Öneri Paketi Satın Al")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_available || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Öneri Paketi Satın Al")),
        body: const Center(
          child: Text(
            "Şu anda satın alma özelliği kullanılamıyor.\n\n"
            "• Google hesabınızla giriş yaptığınızdan\n"
            "• Cihazda Google Play Store bulunduğundan\n"
            "• Ürünün Play Console'da aktif olduğundan emin olun.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Öneri Paketi Satın Al")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "10 araç önerisi hakkı",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Kalan hakkınız bittiğinde bu paketi alarak 10 yeni araç önerisi hakkı kazanabilirsiniz.",
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifying ? null : _buy,
                child: _verifying
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("${_product!.price} karşılığında satın al"),
              ),
            ),
            const SizedBox(height: 10),
            if (_verifying)
              Text(
                "Satın alma doğrulanıyor…",
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
