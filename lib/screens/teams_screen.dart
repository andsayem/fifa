import 'package:fifa/common/admob_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../models/group_standing_model.dart';
import '../widgets/match_card.dart';
import '../widgets/team_logo_helper.dart';

import 'team_details_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
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
    final teamProvider = Provider.of<TeamProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
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
        appBar: AppBar(
          title: const Text('Tournament Groups'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: isDark ? Colors.grey : Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: groups.map((g) => Tab(text: 'GROUP $g')).toList(),
          ),
        ),
        body: teamProvider.isLoading || matchProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: groups.map((groupName) {
                  final standings =
                      teamProvider.groupStandings[groupName] ?? [];

                  // Filter matches for this group
                  final groupTeamNames = standings
                      .map((s) => s.team.name.toLowerCase())
                      .toList();
                  final groupMatches = matchProvider.matches.where((match) {
                    return groupTeamNames.contains(
                          match.homeTeam.toLowerCase(),
                        ) &&
                        groupTeamNames.contains(match.awayTeam.toLowerCase());
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      await teamProvider.loadData();
                      await matchProvider.loadMatches();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Beautified Group Teams Grid
                          _buildGroupTeamsGrid(context, standings),

                          // Section: Group Fixtures
                          _buildSectionTitle(
                            context,
                            'Group Fixtures & Results',
                            Icons.event_note,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: groupMatches.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Text(
                                        'No fixtures scheduled for this group.',
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: groupMatches
                                        .map((match) => MatchCard(match: match))
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildGroupTeamsGrid(
    BuildContext context,
    List<GroupStandingModel> standings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
        ),
        itemCount: standings.length,
        itemBuilder: (context, index) {
          final standing = standings[index];
          final team = standing.team;

          return Card(
            elevation: isDark ? 2 : 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade100,
                width: 1,
              ),
            ),
            color: isDark ? const Color(0xFF131A22) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamDetailsScreen(teamName: team.name),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large circular country flag
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          TeamLogoHelper.getLogo(team.name),
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(
                                radius: 23,
                                child: Icon(Icons.flag, size: 24),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Team Name
                    Text(
                      team.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Quick Action Text
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
