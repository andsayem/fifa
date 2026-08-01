import 'package:fifa/common/admob_helper.dart';
import 'package:fifa/presentation/controllers/purchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({
    super.key,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final EdgeInsets padding;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late final PurchaseController _purchaseController;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _purchaseController = Get.find<PurchaseController>();

    ever<bool>(_purchaseController.adsRemoved, (removed) {
      if (removed && mounted) {
        _bannerAd?.dispose();
        setState(() {
          _bannerAd = null;
          _isBannerAdLoaded = false;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted || _purchaseController.adsRemoved.value) return;
      final width = MediaQuery.of(context).size.width.toInt();
      final banner = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 27, height: 220),
      );
      if (!mounted || _purchaseController.adsRemoved.value) {
        banner.dispose();
        return;
      }
      setState(() {
        _bannerAd = banner;
        _isBannerAdLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_purchaseController.adsRemoved.value ||
          !_isBannerAdLoaded ||
          _bannerAd == null) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: widget.padding,
        child: Center(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    });
  }
}
