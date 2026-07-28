import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/tournament_model.dart';
import '../../widgets/team_logo_helper.dart';
import 'history_details_screen.dart';
import 'champions_list_screen.dart';
import 'finals_history_screen.dart';
import 'golden_boot_screen.dart';
import 'host_countries_screen.dart';
import 'history_search_screen.dart';

class HistoryHomeScreen extends StatefulWidget {
  const HistoryHomeScreen({super.key});

  @override
  State<HistoryHomeScreen> createState() => _HistoryHomeScreenState();
}

class _HistoryHomeScreenState extends State<HistoryHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      if (provider.allTournaments.isEmpty) {
        provider.loadData();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_edu,
                color: isDark ? const Color(0xFF10B981) : Colors.white, size: 22),
            const SizedBox(width: 8),
            const Text('World Cup History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorySearchScreen()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildQuickStats(context, provider)),
                  SliverToBoxAdapter(child: _buildQuickLinks(context)),
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(context, 'All Tournaments', Icons.emoji_events_outlined),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tournament = provider.tournaments[index];
                        return _buildTournamentCard(context, tournament, index);
                      },
                      childCount: provider.tournaments.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickStats(BuildContext context, HistoryProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final champions = provider.championCounts;
    final topChamp = champions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalGoals = provider.allTournaments
        .fold<int>(0, (sum, t) => sum + t.goals);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF131A22), const Color(0xFF0D1518)]
              : [Colors.white, const Color(0xFFF0F7F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'FIFA WORLD CUP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1930 - 2026',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(context, '${provider.allTournaments.length}', 'Tournaments'),
              _buildStatItem(context, '$totalGoals', 'Goals'),
              _buildStatItem(context, '${champions.length}', 'Champions'),
            ],
          ),
          const SizedBox(height: 12),
          if (topChamp.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Most successful: ${topChamp.first.key} (${topChamp.first.value} titles)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final links = [
      _QuickLink('Champions', Icons.emoji_events, Colors.amber, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChampionsListScreen()));
      }),
      _QuickLink('Finals', Icons.sports_soccer, Colors.blue, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FinalsHistoryScreen()));
      }),
      _QuickLink('Golden Boot', Icons.stars, Colors.orange, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GoldenBootScreen()));
      }),
      _QuickLink('Hosts', Icons.public, Colors.teal, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HostCountriesScreen()));
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: links.map((link) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: link.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: link.color.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: link.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(link.icon, color: link.color, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        link.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: link.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentCard(BuildContext context, TournamentModel t, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(
          (index * 0.05).clamp(0.0, 0.8),
          ((index * 0.05) + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Hero(
          tag: 'tournament_${t.year}',
          child: Card(
            elevation: isDark ? 2 : 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryDetailsScreen(tournament: t),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.15),
                            primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${t.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.hostDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  TeamLogoHelper.getLogo(t.winner),
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => CircleAvatar(
                                    radius: 10,
                                    child: Text(t.winner[0], style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.isTBD ? 'TBD' : t.winner,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.isTBD
                                ? '${t.teams} teams'
                                : 'vs ${t.runnerUp} (${t.final_.scoreDisplay})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!t.isTBD)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.upcoming,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickLink {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QuickLink(this.label, this.icon, this.color, this.onTap);
}
