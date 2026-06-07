import 'package:fifa/common/admob_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../models/team_model.dart';
import '../models/match_model.dart';
import '../models/player_model.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/team_logo_helper.dart';
import '../services/fifa_history_service.dart';
import '../services/player_history_service.dart';
import '../widgets/player_photo_helper.dart';

class TeamDetailsScreen extends StatefulWidget {
  final String teamName;

  const TeamDetailsScreen({super.key, required this.teamName});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final matchProvider = Provider.of<MatchProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Find the TeamModel if it exists in provider to get group
    final TeamModel? teamInfo = teamProvider.teams.firstWhere(
      (t) =>
          t.name.toLowerCase().trim() == widget.teamName.toLowerCase().trim(),
      orElse: () =>
          TeamModel(id: 0, name: widget.teamName, logo: '', group: 'A'),
    );

    // Fetch players and fixtures
    final players = teamProvider.getPlayersForTeam(widget.teamName);
    final fixtures = matchProvider.matches
        .where(
          (match) =>
              match.homeTeam.toLowerCase().trim() ==
                  widget.teamName.toLowerCase().trim() ||
              match.awayTeam.toLowerCase().trim() ==
                  widget.teamName.toLowerCase().trim(),
        )
        .toList();

    final history = FifaHistoryService.getHistory(widget.teamName);

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 210.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? const Color(0xFF0F172A) : primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Top dark-gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark
                                ? const Color(0xFF020617)
                                : primaryColor.withBlue(100),
                            isDark
                                ? const Color(0xFF0F172A).withOpacity(0.8)
                                : primaryColor.withOpacity(0.9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Centered Big Flag and Country Name
                    SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                TeamLogoHelper.getLogo(widget.teamName),
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(
                                      radius: 38,
                                      child: Icon(Icons.flag, size: 36),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.teamName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'GROUP ${teamInfo?.group ?? "A"} • ${players.length} Squad Stars',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: isDark
                      ? Colors.grey
                      : Colors.grey.shade600,
                  indicatorColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  tabs: const [
                    Tab(
                      text: 'SQUAD',
                      icon: Icon(Icons.people_outline, size: 20),
                    ),
                    Tab(
                      text: 'FIXTURES',
                      icon: Icon(Icons.sports_soccer_outlined, size: 20),
                    ),
                    Tab(
                      text: 'HISTORY',
                      icon: Icon(Icons.emoji_events_outlined, size: 20),
                    ),
                  ],
                ),
                isDark,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSquadTab(players, isDark, primaryColor),
            _buildFixturesTab(fixtures, isDark),
            _buildHistoryTab(history, isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  // --- SQUAD ROSTER TAB ---
  Widget _buildSquadTab(
    List<PlayerModel> players,
    bool isDark,
    Color primaryColor,
  ) {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No squad data available',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    }

    // Group players by position
    final gks = players
        .where((p) => p.position.toLowerCase() == 'goalkeeper')
        .toList();
    final dfs = players
        .where((p) => p.position.toLowerCase() == 'defender')
        .toList();
    final mfs = players
        .where((p) => p.position.toLowerCase() == 'midfielder')
        .toList();
    final fws = players
        .where((p) => p.position.toLowerCase() == 'forward')
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        if (gks.isNotEmpty)
          _buildPositionSection('GOALKEEPERS', gks, Colors.purple, isDark),
        if (dfs.isNotEmpty)
          _buildPositionSection('DEFENDERS', dfs, Colors.green, isDark),
        if (mfs.isNotEmpty)
          _buildPositionSection('MIDFIELDERS', mfs, Colors.blue, isDark),
        if (fws.isNotEmpty)
          _buildPositionSection('FORWARDS', fws, Colors.amber, isDark),
      ],
    );
  }

  Widget _buildPositionSection(
    String title,
    List<PlayerModel> list,
    Color accentColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: list.length,
          itemBuilder: (context, index) {
            final player = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: isDark ? 2 : 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.shade100,
                  width: 1,
                ),
              ),
              color: isDark ? const Color(0xFF131A22) : Colors.white,
              child: ListTile(
                onTap: () {
                  _showPlayerBiography(context, player, accentColor);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      PlayerPhotoHelper.getPlayerPhoto(player.name),
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          CircleAvatar(
                            backgroundColor: accentColor.withOpacity(0.12),
                            child: Icon(
                              Icons.person,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                    ),
                  ),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '#${player.number} • ${player.position}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _getPositionShort(player.position),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showPlayerBiography(
    BuildContext context,
    PlayerModel player,
    Color accentColor,
  ) {
    final history = PlayerHistoryService.getPlayerHistory(
      player.name,
      player.teamName,
      player.position,
      player.number,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sliding handlebar
                Center(
                  child: Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Player Top profile banner
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Layered Player Photo Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          PlayerPhotoHelper.getPlayerPhoto(player.name),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              CircleAvatar(
                                backgroundColor: accentColor.withOpacity(0.12),
                                child: Icon(
                                  Icons.person,
                                  color: accentColor,
                                  size: 28,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${player.number}',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  TeamLogoHelper.getLogo(player.teamName),
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.flag,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                player.teamName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Position Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        player.position.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 20),

                // Club Info
                Row(
                  children: [
                    const Icon(
                      Icons.business_center,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CURRENT CLUB: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      history.club,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Player Biography
                Text(
                  'BIOGRAPHY & CAREER STATS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  history.bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),

                // Key achievements
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HONOURS & ACHIEVEMENTS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.amber.shade800,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        history.achievements,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade200
                              : Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPositionShort(String position) {
    switch (position.toLowerCase()) {
      case 'goalkeeper':
        return 'GK';
      case 'defender':
        return 'DF';
      case 'midfielder':
        return 'MF';
      case 'forward':
        return 'FW';
      default:
        return 'PL';
    }
  }

  // --- FIXTURES TAB ---
  Widget _buildFixturesTab(List<MatchModel> fixtures, bool isDark) {
    if (fixtures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No matches scheduled for this team',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        return MatchCard(match: fixtures[index]);
      },
    );
  }

  // --- FIFA HISTORY TAB ---
  Widget _buildHistoryTab(
    FifaHistoryModel? history,
    bool isDark,
    Color primaryColor,
  ) {
    if (history == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No tournament statistics available',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trophy Card banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: history.titlesCount > 0
                    ? [const Color(0xFFFBBF24), const Color(0xFFD97706)]
                    : [primaryColor.withOpacity(0.7), primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (history.titlesCount > 0 ? Colors.amber : primaryColor)
                      .withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.titlesCount > 0
                            ? 'WORLD CUP CHAMPIONS'
                            : 'COMPETING NATION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        history.titlesCount > 0
                            ? '${history.titlesCount} Title Achievements'
                            : 'Chasing Glory',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (history.titlesCount > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Years: ${history.titleYears.join(", ")}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: history.titlesCount > 0
                      ? Colors.white
                      : Colors.white.withOpacity(0.55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics rows
          _buildInfoRow(
            'BEST WORLD CUP FINISH',
            history.bestFinish,
            Icons.military_tech,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'TOURNAMENT APPEARANCES',
            history.appearanceCount,
            Icons.calendar_today,
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'LEGENDARY PLAYERS',
            history.legends,
            Icons.stars,
            isDark,
          ),
          const SizedBox(height: 24),

          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 24),

          // Did you know fact card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blueAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'DID YOU KNOW?',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  history.interestingFact,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Persistent Header Delegate to keep tabbar on scroll
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.isDark);

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
