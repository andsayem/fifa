import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/tournament_model.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/team_logo_helper.dart';
import 'history_details_screen.dart';

class HostCountriesScreen extends StatelessWidget {
  const HostCountriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);
    final tournaments = List<TournamentModel>.from(provider.allTournaments)
      ..sort((a, b) => a.year.compareTo(b.year));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, color: Colors.teal.shade300, size: 22),
            const SizedBox(width: 8),
            const Text('Host Countries'),
          ],
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final t = tournaments[index];
                return _buildHostCard(context, t, index == tournaments.length - 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostCard(BuildContext context, TournamentModel t, bool isLast) {
    final primaryColor = Theme.of(context).primaryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    '${t.year.toString().substring(2)}s',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: primaryColor.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryDetailsScreen(tournament: t)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${t.year}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          if (!t.isTBD)
                            ClipOval(
                              child: Image.network(
                                TeamLogoHelper.getLogo(t.winner),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const CircleAvatar(radius: 12, child: Icon(Icons.flag, size: 12)),
                              ),
                            ),
                          const SizedBox(width: 6),
                          if (!t.isTBD)
                            Text(
                              t.winner,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.teal.shade400),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t.hostDisplay,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.groups_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${t.teams} teams',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.sports_soccer, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${t.matches} matches',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
