import 'package:fifa/common/admob_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    AdmobHelper.loadInterstitialAd();
    // ⚠️ delay banner load (important)
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      final width = MediaQuery.of(context).size.width.toInt();
      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 35, height: 100),
      );
      if (!mounted) return;

      setState(() {
        _bannerAd = ad;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);

    // Filter matches that are favorited
    final favoriteMatches = matchProvider.matches
        .where((match) => favProvider.isFavorite(match.id))
        .toList();

    return Scaffold(
      bottomNavigationBar: _bannerAd == null
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              // Set a fixed height for a balanced appearance across devices
              height: 80,
              alignment: Alignment.center,
              // Use a subtle background to blend with the app theme
              color: Colors.black.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
      appBar: AppBar(title: const Text('My Favorites')),
      body: favProvider.isLoading || matchProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteMatches.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteMatches.length,
              itemBuilder: (context, index) {
                final match = favoriteMatches[index];
                return MatchCard(match: match);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing heart container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.08),
                border: Border.all(
                  color: Colors.red.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 56,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description text
            Text(
              'Keep track of your favorite teams and matches! Tap the heart icon on any match card or details screen to add it here, offline-ready.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey : Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
