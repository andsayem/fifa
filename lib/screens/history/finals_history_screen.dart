import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/tournament_model.dart';
import '../../widgets/team_logo_helper.dart';
import 'history_details_screen.dart';

class FinalsHistoryScreen extends StatelessWidget {
  const FinalsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);
    final finals = provider.finalsList;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, color: Colors.blue.shade300, size: 22),
            const SizedBox(width: 8),
            const Text('World Cup Finals'),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: finals.length,
        itemBuilder: (context, index) {
          final t = finals[index];
          return _buildFinalCard(context, t, index);
        },
      ),
    );
  }

  Widget _buildFinalCard(BuildContext context, TournamentModel t, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HistoryDetailsScreen(tournament: t)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${t.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    t.final_.stadium,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            TeamLogoHelper.getLogo(t.winner),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const CircleAvatar(radius: 18, child: Icon(Icons.flag, size: 18)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.winner,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.hasPenalties
                                ? Colors.orange.withValues(alpha: 0.12)
                                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            t.final_.scoreDisplay,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: t.hasPenalties
                                  ? Colors.orange
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        if (t.hasPenalties)
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Text(
                              'Penalties',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network(
                            TeamLogoHelper.getLogo(t.runnerUp),
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const CircleAvatar(radius: 18, child: Icon(Icons.flag, size: 18)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.runnerUp,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
}
