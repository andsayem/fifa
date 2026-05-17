import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../models/venue_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/team_logo_helper.dart';
import '../widgets/match_countdown_widget.dart';
import '../providers/settings_provider.dart';
import 'team_details_screen.dart';
import 'venue_details_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  final MatchModel match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final teamProvider = Provider.of<TeamProvider>(context);
    final isFav = favProvider.isFavorite(match.id);

    // Look up stadium capacity details from venues in TeamProvider
    VenueModel? venueDetails;
    try {
      venueDetails = teamProvider.venues.firstWhere(
        (v) => v.name.toLowerCase() == match.stadium.toLowerCase(),
      );
    } catch (_) {
      // Fallback
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
            onPressed: () {
              favProvider.toggleFavorite(match.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Scoreboard header
            _buildScoreboardHeader(context),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Info Details Card
                  _buildMatchInfoCard(context),
                  const SizedBox(height: 20),

                  // Stadium Details Profile
                  _buildStadiumCard(context, venueDetails),
                  const SizedBox(height: 24),

                  // Favorites Action button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFav ? Colors.red.withOpacity(0.12) : Theme.of(context).primaryColor,
                        foregroundColor: isFav ? Colors.red : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isFav ? const BorderSide(color: Colors.red, width: 1.0) : BorderSide.none,
                        ),
                      ),
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      label: Text(
                        isFav ? 'Remove from Favorites' : 'Add to Favorites',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        favProvider.toggleFavorite(match.id);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboardHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F2B1D), const Color(0xFF090D10)]
              : [const Color(0xFF0D6E3E), const Color(0xFF10B981)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Status badge
          _buildDetailStatusBadge(context),
          const SizedBox(height: 24),

          // Core scoreboard
          Row(
            children: [
              // Home Team
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailsScreen(teamName: match.homeTeam),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              TeamLogoHelper.getLogo(match.homeTeam),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const CircleAvatar(radius: 40, child: Icon(Icons.flag, size: 36)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          match.homeTeam,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Score or Versus divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDetailsScoreCenter(context),
              ),

              // Away Team
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailsScreen(teamName: match.awayTeam),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              TeamLogoHelper.getLogo(match.awayTeam),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const CircleAvatar(radius: 40, child: Icon(Icons.flag, size: 36)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          match.awayTeam,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatusBadge(BuildContext context) {
    Color textColor;
    Color bgColor;
    String text;

    final matchDateTime = DateTime.parse("${match.date}T${match.time}:00");
    final isStarted = matchDateTime.isBefore(DateTime.now());

    if (isStarted) {
      textColor = Colors.white;
      bgColor = Colors.white24;
      text = 'FINISHED';
    } else {
      textColor = const Color(0xFF10B981);
      bgColor = Colors.white;
      text = 'UPCOMING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDetailsScoreCenter(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final matchDateTime = settings.getMatchUtcDateTime(match).toLocal();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        MatchCountdownWidget(
          targetDateTime: matchDateTime,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          finishedWidget: const Text(
            'STARTED',
            style: TextStyle(
              fontSize: 13,
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfoCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Card(
      elevation: isDark ? 2 : 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Match Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 28),
            _buildInfoRow(context, Icons.calendar_today_outlined, 'Date', settings.getFormattedDate(match)),
            const SizedBox(height: 14),
            _buildInfoRow(context, Icons.access_time, 'Kickoff Time', settings.getFormattedTime(match)),
            const SizedBox(height: 14),
            _buildInfoRow(context, Icons.stadium_outlined, 'Stadium', match.stadium),
            const SizedBox(height: 14),
            _buildInfoRow(context, Icons.tag, 'Match Status', match.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStadiumCard(BuildContext context, VenueModel? venueDetails) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 2 : 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: venueDetails == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VenueDetailsScreen(venue: venueDetails),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stadium, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Venue Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              match.stadium,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  venueDetails?.city ?? 'Host City',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEATING CAPACITY',
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venueDetails != null
                          ? venueDetails.capacity.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')
                          : 'TBD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stadium_outlined, size: 32, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
     ),
    );
  }
}
