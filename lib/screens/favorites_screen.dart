import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);

    // Filter matches that are favorited
    final favoriteMatches = matchProvider.matches
        .where((match) => favProvider.isFavorite(match.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
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
                border: Border.all(color: Colors.red.withOpacity(0.15), width: 1.5),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
