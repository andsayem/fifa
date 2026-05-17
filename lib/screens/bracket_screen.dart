import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bracket_provider.dart';
import '../models/bracket_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/team_logo_helper.dart';

class BracketScreen extends StatelessWidget {
  const BracketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bracketProvider = Provider.of<BracketProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade400, size: 22),
            const SizedBox(width: 8),
            const Text('Road to Glory'),
          ],
        ),
      ),
      body: bracketProvider.isLoading || bracketProvider.bracket == null
          ? const Center(child: CircularProgressIndicator())
          : InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(120),
              minScale: 0.3,
              maxScale: 2.0,
              constrained: false,
              child: Stack(
                children: [
                  // Beautiful soccer field tactical backdrop watermark
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PitchBackdropPainter(isDark: isDark),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                    child: _buildFullBracket(context, bracketProvider.bracket!, isDark),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFullBracket(BuildContext context, BracketModel bracket, bool isDark) {
    final r32 = bracket.roundOf32;
    final r16 = bracket.roundOf16;
    final qf = bracket.quarterFinals;
    final sf = bracket.semiFinals;
    final tp = bracket.thirdPlace;
    final fin = bracket.final_;

    // Column spacing
    const colWidth = 180.0;
    const colGap = 32.0;
    const matchH = 92.0;

    final primaryColor = Theme.of(context).primaryColor;
    final connectorColor = isDark ? Colors.white24 : Colors.grey.shade300;

    // Y Centers for Left/Right Columns (card height is matchH = 92.0)
    final y_r32 = List.generate(4, (i) => (matchH + matchH) * i + matchH / 2);
    
    // Perfectly centered R16 calculations
    const topPad_r16 = matchH; // 92.0
    const spacing_r16 = matchH * 3; // 276.0
    final y_r16 = List.generate(2, (i) => topPad_r16 + (matchH + spacing_r16) * i + matchH / 2);

    // Perfectly centered QF calculations
    const topPad_qf = matchH * 3; // 276.0
    final y_qf = [topPad_qf + matchH / 2]; // 322.0

    // Perfectly centered SF calculations
    const topPad_sf = matchH * 3; // 276.0
    final y_sf = [topPad_sf + matchH / 2]; // 322.0

    // Perfectly centered Final calculations
    const topPad_final = matchH * 3; // 276.0
    final y_final = [topPad_final + matchH / 2]; // 322.0

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Round of 32 (Left Side) ──────────────────────────
          _buildRoundColumn(context, 'ROUND OF 32', [r32[0], r32[1], r32[2], r32[3]], colWidth, matchH, isDark, leftConnector: false),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: true,
            connections: [
              ForkConnection(topY: y_r32[0], bottomY: y_r32[1], childY: y_r16[0]),
              ForkConnection(topY: y_r32[2], bottomY: y_r32[3], childY: y_r16[1]),
            ],
          ),

          // ── Round of 16 (Left) ────────────────────────────────
          _buildRoundColumn(context, 'ROUND OF 16', [r16[0], r16[1]], colWidth, spacing_r16, isDark, topPad: topPad_r16),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: true,
            connections: [
              ForkConnection(topY: y_r16[0], bottomY: y_r16[1], childY: y_qf[0]),
            ],
          ),

          // ── Quarter Finals (Left) ─────────────────────────────
          _buildRoundColumn(context, 'QUARTER FINALS', [qf[0]], colWidth, matchH * 4 + 30, isDark, topPad: topPad_qf),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: true,
            connections: [],
            straightConnections: [
              StraightConnection(parentY: y_qf[0], childY: y_sf[0]),
            ],
          ),

          // ── Semi Finals ───────────────────────────────────────
          Column(
            children: [
              _buildRoundLabel(context, 'SEMI FINALS'),
              const SizedBox(height: topPad_sf),
              _buildMatchCard(context, sf[0], colWidth, isDark, accent: const Color(0xFFFFD700)),
              const SizedBox(height: 40),
              _buildThirdPlaceCard(context, tp, colWidth, isDark),
            ],
          ),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: true,
            connections: [],
            straightConnections: [
              StraightConnection(parentY: y_sf[0], childY: y_final[0]),
            ],
          ),

          // ── FINAL ─────────────────────────────────────────────
          // ── FINAL ─────────────────────────────────────────────
          Column(
            children: [
              _buildRoundLabel(context, 'FINAL 🏆'),
              const SizedBox(height: topPad_final - 76),
              _buildChampionshipTrophyBanner(context, fin, isDark),
              const SizedBox(height: 12),
              _buildMatchCard(context, fin, colWidth + 20, isDark, accent: Colors.amber, isHighlight: true),
            ],
          ),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: false,
            connections: [],
            straightConnections: [
              StraightConnection(parentY: y_sf[0], childY: y_final[0]),
            ],
          ),

          // ── Semi Finals (Right) ───────────────────────────────
          Column(
            children: [
              _buildRoundLabel(context, 'SEMI FINALS'),
              const SizedBox(height: topPad_sf),
              _buildMatchCard(context, sf[1], colWidth, isDark, accent: const Color(0xFFFFD700)),
            ],
          ),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: false,
            connections: [],
            straightConnections: [
              StraightConnection(parentY: y_qf[0], childY: y_sf[0]),
            ],
          ),

          // ── Quarter Finals (Right) ────────────────────────────
          _buildRoundColumn(context, 'QUARTER FINALS', [qf[1]], colWidth, matchH * 4 + 30, isDark, topPad: topPad_qf),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: false,
            connections: [
              ForkConnection(topY: y_r16[0], bottomY: y_r16[1], childY: y_qf[0]),
            ],
          ),

          // ── Round of 16 (Right) ───────────────────────────────
          _buildRoundColumn(context, 'ROUND OF 16', [r16[2], r16[3]], colWidth, spacing_r16, isDark, topPad: topPad_r16),
          _buildConnectorColumn(
            color: connectorColor,
            isLeftToRight: false,
            connections: [
              ForkConnection(topY: y_r32[0], bottomY: y_r32[1], childY: y_r16[0]),
              ForkConnection(topY: y_r32[2], bottomY: y_r32[3], childY: y_r16[1]),
            ],
          ),

          // ── Round of 32 (Right Side) ─────────────────────────
          _buildRoundColumn(context, 'ROUND OF 32', [r32[4], r32[5], r32[6], r32[7]], colWidth, matchH, isDark, leftConnector: false),
        ],
      ),
    );
  }

  Widget _buildRoundColumn(
    BuildContext context,
    String label,
    List<BracketMatchModel> matches,
    double cardWidth,
    double spacing,
    bool isDark, {
    double topPad = 0,
    bool leftConnector = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoundLabel(context, label),
        SizedBox(height: topPad),
        ...matches.map((match) => Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _buildMatchCard(context, match, cardWidth, isDark),
            )),
      ],
    );
  }

  Widget _buildRoundLabel(BuildContext context, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).primaryColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context,
    BracketMatchModel match,
    double width,
    bool isDark, {
    Color? accent,
    bool isHighlight = false,
  }) {
    final cardColor = isDark ? const Color(0xFF131A22) : Colors.white;
    final accentColor = accent ?? Theme.of(context).primaryColor;
    final settings = Provider.of<SettingsProvider>(context);

    // Check if match kickoff time has passed relative to system time
    final matchDateTime = settings.getRawUtcDateTime(match.date, match.time, null).toLocal();
    final isStarted = matchDateTime.isBefore(DateTime.now());

    final hasScore = match.homeScore != null && match.awayScore != null;
    final isHomeWinner = hasScore && match.homeScore! > match.awayScore!;
    final isAwayWinner = hasScore && match.awayScore! > match.homeScore!;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark ? const Color(0xFF1A1500) : const Color(0xFFFFFBE6))
            : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight
              ? Colors.amber.withOpacity(0.7)
              : accentColor.withOpacity(0.2),
          width: isHighlight ? 2.0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlight
                ? Colors.amber.withOpacity(0.2)
                : Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: isHighlight ? 16 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status bar showing SCHEDULED or STARTED
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isStarted ? Colors.grey.shade700 : accentColor.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Text(
              isStarted ? 'STARTED' : 'SCHEDULED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Home team row
          _buildTeamRow(
            context,
            match.home,
            match.homeScore,
            isDark,
            accentColor,
            isWinner: isHomeWinner,
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 12,
            endIndent: 12,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
          ),

          // Away team row
          _buildTeamRow(
            context,
            match.away,
            match.awayScore,
            isDark,
            accentColor,
            isWinner: isAwayWinner,
          ),

          // Date + venue chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 9, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${settings.getFormattedRawDate(match.date, match.time, null)} @ ${settings.getFormattedRawTime(match.date, match.time, null)}',
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    maxLines: 1,
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

  Widget _buildTeamRow(
    BuildContext context,
    String teamName,
    int? score,
    bool isDark,
    Color accentColor, {
    bool isWinner = false,
  }) {
    final isTBD = teamName.startsWith('W_') || teamName.startsWith('L_') || teamName.startsWith('W1') || teamName.startsWith('R2');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          // Mini flag / placeholder
          Container(
            width: 24,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                if (!isTBD)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: isTBD
                  ? Container(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
                      child: Icon(Icons.help_outline, size: 10, color: Colors.grey.shade400),
                    )
                  : Image.network(
                      TeamLogoHelper.getLogo(teamName),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: accentColor.withOpacity(0.15),
                            child: Icon(Icons.flag, size: 10, color: accentColor),
                          ),
                    ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              isTBD ? _formatTBDLabel(teamName) : teamName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
                color: isTBD
                    ? Colors.grey.shade500
                    : isWinner
                        ? accentColor
                        : (isDark ? Colors.white : Colors.black87),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (score != null) ...[
            const SizedBox(width: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isWinner
                    ? accentColor
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThirdPlaceCard(BuildContext context, BracketMatchModel match, double width, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '3RD PLACE PLAYOFF 🥉',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.orange,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildMatchCard(context, match, width, isDark, accent: Colors.orange),
      ],
    );
  }

  Widget _buildConnectorColumn({
    required Color color,
    required List<ForkConnection> connections,
    List<StraightConnection> straightConnections = const [],
    bool isLeftToRight = true,
    double width = 32.0,
  }) {
    return Column(
      children: [
        const SizedBox(height: 32),
        Expanded(
          child: SizedBox(
            width: width,
            child: CustomPaint(
              size: Size.infinite,
              painter: RoundConnectorPainter(
                color: color,
                connections: connections,
                straightConnections: straightConnections,
                isLeftToRight: isLeftToRight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChampionshipTrophyBanner(BuildContext context, BracketMatchModel finalMatch, bool isDark) {
    final hasWinner = finalMatch.homeScore != null && finalMatch.awayScore != null && finalMatch.homeScore != finalMatch.awayScore;
    final championName = hasWinner 
        ? (finalMatch.homeScore! > finalMatch.awayScore! ? finalMatch.home : finalMatch.away)
        : null;

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade700,
            Colors.amber.shade400,
            Colors.amber.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events, 
            size: 32, 
            color: Colors.white, 
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.35), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          const SizedBox(height: 4),
          Text(
            championName != null ? 'WORLD CHAMPION 🏆' : 'WORLD CUP TROPHY',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          if (championName != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(
                      TeamLogoHelper.getLogo(championName),
                      width: 16,
                      height: 12,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag, size: 9, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      championName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTBDLabel(String raw) {
    if (raw.startsWith('W_R32_')) return 'Winner M${raw.replaceAll('W_R32_', '')}';
    if (raw.startsWith('W_R16_')) return 'Winner R16 M${raw.replaceAll('W_R16_', '')}';
    if (raw.startsWith('W_QF_')) return 'Winner QF${raw.replaceAll('W_QF_', '')}';
    if (raw.startsWith('W_SF_')) return 'Winner SF${raw.replaceAll('W_SF_', '')}';
    if (raw.startsWith('L_SF_')) return 'Loser SF${raw.replaceAll('L_SF_', '')}';
    if (raw.startsWith('W1')) return 'Winner Group ${raw.substring(2)}';
    if (raw.startsWith('R2')) return 'Runner-up ${raw.substring(2)}';
    return 'TBD';
  }
}

// ── CONNECTION DATA MODEL CLASSES ────────────────────────────────────────

class ForkConnection {
  final double topY;
  final double bottomY;
  final double childY;

  ForkConnection({
    required this.topY,
    required this.bottomY,
    required this.childY,
  });
}

class StraightConnection {
  final double parentY;
  final double childY;

  StraightConnection({
    required this.parentY,
    required this.childY,
  });
}

// ── BRACKET CONNECTOR CUSTOM PAINTER ──────────────────────────────────────

class RoundConnectorPainter extends CustomPainter {
  final Color color;
  final List<ForkConnection> connections;
  final List<StraightConnection> straightConnections;
  final bool isLeftToRight;

  RoundConnectorPainter({
    required this.color,
    required this.connections,
    this.straightConnections = const [],
    this.isLeftToRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final path = Path();
    final midX = w * 0.5;

    // 1. Draw Fork (⊂ or ⊃) bracket lines with gorgeous smooth curves
    for (var conn in connections) {
      if (isLeftToRight) {
        // Curve from parent top card to child
        path.moveTo(0, conn.topY);
        path.cubicTo(midX, conn.topY, midX, conn.childY, w, conn.childY);
        
        // Curve from parent bottom card to child
        path.moveTo(0, conn.bottomY);
        path.cubicTo(midX, conn.bottomY, midX, conn.childY, w, conn.childY);
      } else {
        // Right to left smooth curves
        path.moveTo(w, conn.topY);
        path.cubicTo(midX, conn.topY, midX, conn.childY, 0, conn.childY);
        
        path.moveTo(w, conn.bottomY);
        path.cubicTo(midX, conn.bottomY, midX, conn.childY, 0, conn.childY);
      }
    }

    // 2. Draw Straight horizontal connector lines with smooth S-curves if Y differs
    for (var conn in straightConnections) {
      if (isLeftToRight) {
        path.moveTo(0, conn.parentY);
        path.cubicTo(midX, conn.parentY, midX, conn.childY, w, conn.childY);
      } else {
        path.moveTo(w, conn.parentY);
        path.cubicTo(midX, conn.parentY, midX, conn.childY, 0, conn.childY);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RoundConnectorPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.connections.length != connections.length ||
           oldDelegate.straightConnections.length != straightConnections.length ||
           oldDelegate.isLeftToRight != isLeftToRight;
  }
}

// ── SOCCER PITCH BACKDROP CUSTOM PAINTER ──────────────────────────────────

class PitchBackdropPainter extends CustomPainter {
  final bool isDark;

  PitchBackdropPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark 
          ? Colors.white.withOpacity(0.015) 
          : Colors.black.withOpacity(0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    // Draw outer boundary with padding
    final rect = Rect.fromLTWH(20, 20, w - 40, h - 40);
    canvas.drawRect(rect, paint);

    // Draw center line
    canvas.drawLine(Offset(w * 0.5, 20), Offset(w * 0.5, h - 20), paint);

    // Draw center circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 80, paint);
    
    // Center point
    final pointPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 4, pointPaint);

    // Draw penalty boxes
    // Left penalty box
    canvas.drawRect(Rect.fromLTWH(20, h * 0.5 - 120, 100, 240), paint);
    // Left goal area
    canvas.drawRect(Rect.fromLTWH(20, h * 0.5 - 50, 40, 100), paint);

    // Right penalty box
    canvas.drawRect(Rect.fromLTWH(w - 120, h * 0.5 - 120, 100, 240), paint);
    // Right goal area
    canvas.drawRect(Rect.fromLTWH(w - 60, h * 0.5 - 50, 40, 100), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


