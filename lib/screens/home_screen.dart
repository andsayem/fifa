import 'package:fifa/common/admob_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/match_card.dart';
import '../models/match_model.dart';
import '../models/venue_model.dart';
import '../widgets/match_countdown_widget.dart';
import '../providers/settings_provider.dart';
import '../presentation/controllers/purchase_controller.dart';
import 'settings_screen.dart';
import 'team_details_screen.dart';
import 'venue_details_screen.dart';
import 'venues_screen.dart';
import '../presentation/widgets/purchase_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    super.dispose();
    _bannerAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final teamProvider = Provider.of<TeamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF10B981)
                  : Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'World Cup Match Shedule',
              style: TextStyle(letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          _buildDataSourceBadge(matchProvider),
          if (matchProvider.errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Retry loading matches',
              onPressed: () => matchProvider.loadMatches(),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      //https://livealltv.com/
      body: matchProvider.isLoading || teamProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await matchProvider.loadMatches();
                await teamProvider.loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error banner
                    if (matchProvider.errorMessage != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 16,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                matchProvider.errorMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => matchProvider.loadMatches(),
                              child: Icon(
                                Icons.refresh,
                                size: 18,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Dynamic Next Match Countdown Card
                    _buildNextMatchCountdownCard(
                      context,
                      matchProvider.upcomingMatches,
                      matchProvider.matches,
                    ),

                    // Subscribe / Remove Ads Banner
                    Obx(() {
                      if (_purchaseController.adsRemoved.value) {
                        return const SizedBox.shrink();
                      }
                      return _buildSubscribeBanner(context);
                    }),

                    Obx(() {
                      if (_purchaseController.adsRemoved.value ||
                          !_isBannerAdLoaded ||
                          _bannerAd == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Container(
                          width: double.infinity,
                          height: _bannerAd!.size.height.toDouble(),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      );
                    }),

                    // Section 2: Today Highlight Matches
                    _buildSectionTitle(
                      context,
                      "Today's Highlights",
                      Icons.event_note,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: matchProvider.todayMatches.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('No matches scheduled for today.'),
                              ),
                            )
                          : Column(
                              children: matchProvider.todayMatches
                                  .map((match) => MatchCard(match: match))
                                  .toList(),
                            ),
                    ),

                    // Section 3: Upcoming Matches Preview
                    _buildSectionTitle(
                      context,
                      'Upcoming Key Clashes',
                      Icons.upcoming,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: matchProvider.upcomingMatches.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('No upcoming matches.'),
                              ),
                            )
                          : Column(
                              children: matchProvider.upcomingMatches
                                  .take(3)
                                  .map((match) => MatchCard(match: match))
                                  .toList(),
                            ),
                    ),

                    // Section 4: Host Stadiums/Venues
                    _buildSectionTitleWithAction(
                      context,
                      'Host Stadiums Preview',
                      Icons.stadium,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VenuesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildStadiumsRow(context, teamProvider.venues),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLiveTvLink,
        icon: const Icon(Icons.live_tv),
        label: const Text('Live TV'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDataSourceBadge(MatchProvider provider) {
    if (provider.isLoading) return const SizedBox.shrink();
    final (
      String label,
      Color color,
      IconData icon,
    ) = switch (provider.dataSource) {
      'github' => ('Live', Colors.green.shade600, Icons.cloud_done),
      'cache' => ('Cached', Colors.orange.shade600, Icons.cloud_off),
      _ => ('Offline', Colors.grey.shade600, Icons.storage),
    };
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: 'Data from: ${provider.dataSource.toUpperCase()}',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
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

  Widget _buildSectionTitleWithAction(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onActionTap,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStadiumsRow(BuildContext context, List<VenueModel> venues) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          return Card(
            margin: const EdgeInsets.only(right: 12, bottom: 4),
            elevation: isDark ? 2 : 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueDetailsScreen(venue: venue),
                  ),
                );
              },
              child: Container(
                width: 175,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stadium_outlined,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            venue.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      venue.city,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(venue.capacity / 1000).toStringAsFixed(0)}k capacity',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  Widget _buildSubscribeBanner(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => showPurchasePopup(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.block, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remove Ads',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Subscribe for an ad-free experience',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'SUBSCRIBE',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLiveTvLink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.live_tv, color: Theme.of(ctx).primaryColor),
            const SizedBox(width: 8),
            const Text('Watch Live TV'),
          ],
        ),
        content: const Text(
          'Watch a quick ad to unlock Live TV access.\nThank you for your support!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Watch Ad'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    AdmobHelper.showInterstitialAd(
      onAdDismissed: () {
        _launchLiveTvUrl();
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opening Live TV...')));
    }
  }

  Future<void> _launchLiveTvUrl() async {
    final uri = Uri.parse('https://livealltv.com/');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Live TV link.')),
        );
      }
    }
  }
}

Widget _buildNextMatchCountdownCard(
  BuildContext context,
  List<MatchModel> upcoming,
  List<MatchModel> allMatches,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final settings = Provider.of<SettingsProvider>(context, listen: false);

  MatchModel? nextMatch;
  bool isFinished = false;

  if (upcoming.isNotEmpty) {
    // Sort and pick closest upcoming match
    final sortedList = List<MatchModel>.from(upcoming);
    sortedList.sort((a, b) {
      final dtA = DateTime.parse("${a.date}T${a.time}:00");
      final dtB = DateTime.parse("${b.date}T${b.time}:00");
      return dtA.compareTo(dtB);
    });
    nextMatch = sortedList.first;

    // If the match is already in progress (time passed), treat as finished
    try {
      final dt = DateTime.parse("${nextMatch.date}T${nextMatch.time}:00");
      if (dt.isBefore(DateTime.now()) && nextMatch.homeScore != null) {
        isFinished = true;
      }
    } catch (_) {}
  }

  // No upcoming matches — show most recent finished match
  if (nextMatch == null) {
    final finished = allMatches
        .where((m) => m.homeScore != null)
        .toList();
    if (finished.isEmpty) return const SizedBox.shrink();
    finished.sort((a, b) {
      final dtA = DateTime.parse("${b.date}T${b.time}:00");
      final dtB = DateTime.parse("${a.date}T${a.time}:00");
      return dtA.compareTo(dtB);
    });
    nextMatch = finished.first;
    isFinished = true;
  }

  final match = nextMatch;
  final matchDateTime = settings.getMatchUtcDateTime(match).toLocal();

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF131A22) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade200,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Title row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFinished ? Icons.emoji_events : Icons.timer_outlined,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isFinished ? 'LAST MATCH RESULT' : 'NEXT MATCH COUNTDOWN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isDark ? Colors.grey : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Score or Countdown
        if (isFinished && match.homeScore != null)
          Text(
            '${match.homeScore} - ${match.awayScore}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
              letterSpacing: 2,
            ),
          )
        else
          MatchCountdownWidget(
            targetDateTime: matchDateTime,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
            ),
            finishedWidget: const Text(
              'MATCH STARTED!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

        const SizedBox(height: 14),
        const Divider(height: 1),
        const SizedBox(height: 14),

        // Teams row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeamDetailsScreen(teamName: match.homeTeam),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Text(
                    match.homeTeam,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isFinished && match.homeScore != null
                      ? 'FT'
                      : 'VS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeamDetailsScreen(teamName: match.awayTeam),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Text(
                    match.awayTeam,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${settings.getFormattedDate(nextMatch)} @ ${settings.getFormattedTime(nextMatch)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.stadium_outlined,
                size: 12,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  match.stadium,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
