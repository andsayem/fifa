import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../providers/favorite_provider.dart';
import '../screens/match_details_screen.dart';
import 'team_logo_helper.dart';
import 'match_countdown_widget.dart';
import '../providers/settings_provider.dart';
import '../screens/team_details_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favProvider = Provider.of<FavoriteProvider>(context);
    final isFav = favProvider.isFavorite(match.id);
    final settings = Provider.of<SettingsProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailsScreen(match: match),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Status badge and Favorite toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(context),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.grey,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      favProvider.toggleFavorite(match.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams Row: Logo | Team Name | Score/VS | Team Name | Logo
              Row(
                children: [
                  // Home Team
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailsScreen(teamName: match.homeTeam),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          children: [
                            ClipOval(
                              child: Image.network(
                                TeamLogoHelper.getLogo(match.homeTeam),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(radius: 24, child: Icon(Icons.flag)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              match.homeTeam,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Middle Score/VS Column
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _buildScoreOrTime(context),
                  ),

                  // Away Team
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailsScreen(teamName: match.awayTeam),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          children: [
                            ClipOval(
                              child: Image.network(
                                TeamLogoHelper.getLogo(match.awayTeam),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(radius: 24, child: Icon(Icons.flag)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              match.awayTeam,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.8),

              // Bottom Row: Date & Time and Stadium Name
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.grey : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${settings.getFormattedDate(match)} @ ${settings.getFormattedTime(match)}',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600),
                  ),
                  const Spacer(),
                  Icon(Icons.stadium_outlined, size: 14, color: isDark ? Colors.grey : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.stadium,
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color textColor;
    String label;

    final matchDateTime = DateTime.parse("${match.date}T${match.time}:00");
    final isStarted = matchDateTime.isBefore(DateTime.now());

    if (isStarted) {
      bgColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
      textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
      label = 'FINISHED';
    } else {
      bgColor = Theme.of(context).primaryColor.withOpacity(0.12);
      textColor = isDark ? Theme.of(context).primaryColor : Theme.of(context).primaryColor;
      label = 'UPCOMING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildScoreOrTime(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final matchDateTime = settings.getMatchUtcDateTime(match).toLocal();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
          ),
          child: Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        MatchCountdownWidget(
          targetDateTime: matchDateTime,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          finishedWidget: const Text(
            'STARTED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
