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
  static const String _kProductId = 'credits_20'; // Play Console ID
  final InAppPurchase _iap = InAppPurchase.instance;

  bool _loading = true;
  bool _available = false;
  ProductDetails? _product;

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
        setState(() {
          _loading = false;
        });
        return;
      }

      // Satın alma güncellemelerini dinle
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (Object error) {
          debugPrint("Purchase stream error: $error");
        },
      );

      // Ürünü çek
      final response = await _iap.queryProductDetails({_kProductId});

      if (response.error != null) {
        debugPrint("Product query error: ${response.error}");
        setState(() {
          _loading = false;
          _product = null;
        });
        return;
      }

      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
      } else {
        debugPrint("Product $_kProductId not found in store.");
      }

      setState(() {
        _loading = false;
      });
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

  // Satın alma güncellemeleri
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.productID == _kProductId) {
        if (purchase.status == PurchaseStatus.purchased) {
          // Satın alma başarılı → krediyi backend'e bildir
          await _handleSuccessfulPurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Satın alma hatası oluştu.")),
            );
          }
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  // Satın alma başarılı → backend'e kredi eklettir
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Giriş yapmadan kredi eklenemez.")),
        );
        return;
      }

      const int creditsToAdd = 20;

      final uri = Uri.parse(
        "https://what-to-watch-backend.onrender.com/api/cars/add-credits",
      );

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": user.uid,
          "amount": creditsToAdd,
          // İleride purchaseToken vs. de gönderebiliriz
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("20 araç önerisi hakkı eklendi!")),
        );
        Navigator.pop(context); // Ekranı kapat
      } else {
        debugPrint(
            "Add-credits backend error: ${response.statusCode} - ${response.body}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kredi eklenirken hata oluştu.")),
        );
      }
    } catch (e) {
      debugPrint("Handle purchase error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  // Satın alma başlat
  Future<void> _buy() async {
    if (_product == null) return;

    final purchaseParam = PurchaseParam(productDetails: _product!);
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
        appBar: AppBar(title: Text("Öneri Paketi Satın Al 9.99₺")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Mağaza yoksa veya ürün bulunamadıysa
    if (!_available || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Öneri Paketi Satın Al")),
        body: const Center(
          child: Text(
            "Şu anda satın alma özelliği kullanılamıyor.\n\n"
            "• Google hesabınızla giriş yaptığınızdan\n"
            "• Cihazda Google Play Store bulunduğundan\n"
            "• Ürünün Play Console'da yayınlandığından emin olun.",
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
              "20 araç önerisi hakkı",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Kalan hakkınız bittiğinde bu paketi alarak 20 yeni araç önerisi hakkı kazanabilirsiniz.",
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _buy,
                child: Text(
                  "${_product!.price} karşılığında satın al", // Örn: ₺9,99
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
