import 'package:fifa/common/admob_helper.dart';
import 'package:fifa/presentation/controllers/purchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../models/venue_model.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';
import '../widgets/stadium_helper.dart';

class VenueDetailsScreen extends StatefulWidget {
  final VenueModel venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
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
    final matchProvider = Provider.of<MatchProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // Fetch matches scheduled at this stadium
    final venueKey = widget.venue.name.toLowerCase().trim();
    final groundName = StadiumHelper.getGroundName(widget.venue.name).toLowerCase().trim();
    final fixtures = matchProvider.matches.where((match) {
      final matchStadium = match.stadium.toLowerCase().trim();
      return matchStadium == groundName || matchStadium == venueKey;
    }).toList();

    // Fetch stadium description and images
    final profile = StadiumHelper.getProfile(widget.venue.name);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Parallax Stadium Image Header
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    profile.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF0F172A) : primaryColor,
                      child: Center(
                        child: Icon(
                          Icons.stadium_outlined,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  // Dark shadow gradient on bottom for readable text
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'OFFICIAL WORLD CUP STADIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.venue.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Details List
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Capacity & Location Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'CITY & LOCATION',
                            widget.venue.city,
                            Icons.location_on,
                            Colors.redAccent,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'SEATING CAPACITY',
                            '${_formatCapacity(widget.venue.capacity)} Spectators',
                            Icons.people,
                            Colors.blueAccent,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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

                    const SizedBox(height: 24),

                    // Section 1: History & Profile
                    Text(
                      'STADIUM HISTORY & PROFILE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      profile.description,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Stadium Trivia Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.15),
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
                                'TOURNAMENT TRIVIA & HIGHLIGHTS',
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
                            profile.facts,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(height: 1, thickness: 0.8),
                    const SizedBox(height: 28),

                    // Section 3: Scheduled Matches title
                    Row(
                      children: [
                        Icon(Icons.event, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SCHEDULED MATCHES AT THIS STADIUM',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Matches list
                    fixtures.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'No fixtures currently scheduled at this venue.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: fixtures
                                .map((match) => MatchCard(match: match))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCapacity(int capacity) {
    final capStr = capacity.toString();
    if (capStr.length > 3) {
      return '${capStr.substring(0, capStr.length - 3)},${capStr.substring(capStr.length - 3)}';
    }
    return capStr;
  }
}
