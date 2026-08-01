import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/team_logo_helper.dart';

class ChampionsListScreen extends StatelessWidget {
  const ChampionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);
    final championCounts = provider.championCounts;
    final sorted = championCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade400, size: 22),
            const SizedBox(width: 8),
            const Text('Champions'),
          ],
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final entry = sorted[index];
                final country = entry.key;
                final titles = entry.value;
                final years = provider.championsOnly
                    .where((t) => t.winner == country)
                    .map((t) => t.year)
                    .toList()
                  ..sort();
                final rank = index + 1;

                return _buildChampionTile(context, country, titles, years, rank);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChampionTile(
      BuildContext context, String country, int titles, List<int> years, int rank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
    } else {
      rankColor = Theme.of(context).primaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipOval(
              child: Image.network(
                TeamLogoHelper.getLogo(country),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const CircleAvatar(radius: 20, child: Icon(Icons.flag, size: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    years.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    titles > 1 ? '$titles titles' : '1 title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
