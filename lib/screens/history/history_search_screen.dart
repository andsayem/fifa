import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/tournament_model.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/team_logo_helper.dart';
import 'history_details_screen.dart';

class HistorySearchScreen extends StatefulWidget {
  const HistorySearchScreen({super.key});

  @override
  State<HistorySearchScreen> createState() => _HistorySearchScreenState();
}

class _HistorySearchScreenState extends State<HistorySearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedChampion;
  String? _selectedHost;
  int? _selectedDecade;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by year, champion, host, player...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _showFilters ? Icons.filter_list_off : Icons.filter_list,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _showFilters = !_showFilters);
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF131A22) : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.2,
                  ),
                ),
              ),
              onChanged: (val) {
                provider.setSearchQuery(val);
                setState(() {});
              },
            ),
          ),
          if (_showFilters) _buildFilterSection(context, provider, isDark),
          Expanded(
            child: provider.tournaments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No tournaments found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.tournaments.length,
                    itemBuilder: (context, index) {
                      final t = provider.tournaments[index];
                      return _buildResultCard(context, t);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, HistoryProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFilterChip(
                context,
                'Champion',
                _selectedChampion,
                provider.allChampions,
                (val) {
                  setState(() => _selectedChampion = val);
                  provider.setChampionFilter(val);
                },
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Host',
                _selectedHost,
                provider.allHosts,
                (val) {
                  setState(() => _selectedHost = val);
                  provider.setHostFilter(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(
                context,
                'Decade',
                _selectedDecade?.toString(),
                provider.allDecades.map((d) => '${d}s').toList(),
                (val) {
                  final decade = val != null ? int.parse(val.replaceAll('s', '')) : null;
                  setState(() => _selectedDecade = decade);
                  provider.setDecadeFilter(decade);
                },
              ),
              const SizedBox(width: 8),
              if (_selectedChampion != null || _selectedHost != null || _selectedDecade != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedChampion = null;
                      _selectedHost = null;
                      _selectedDecade = null;
                    });
                    provider.clearFilters();
                    if (_searchController.text.isNotEmpty) {
                      provider.setSearchQuery(_searchController.text);
                    }
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String? currentValue,
    List<String> options,
    ValueChanged<String?> onSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: () => _showFilterDialog(context, label, options, onSelected),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: currentValue != null
                ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                : isDark
                    ? const Color(0xFF131A22)
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: currentValue != null
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  currentValue ?? label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: currentValue != null
                        ? Theme.of(context).primaryColor
                        : isDark
                            ? Colors.grey
                            : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: currentValue != null
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    String title,
    List<String> options,
    ValueChanged<String?> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    return ListTile(
                      title: const Text('All'),
                      leading: const Icon(Icons.clear),
                      onTap: () {
                        onSelected(null);
                        Navigator.pop(ctx);
                      },
                    );
                  }
                  return ListTile(
                    title: Text(options[index - 1]),
                    onTap: () {
                      onSelected(options[index - 1]);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, TournamentModel t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${t.year}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            if (!t.isTBD)
              ClipOval(
                child: Image.network(
                  TeamLogoHelper.getLogo(t.winner),
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      CircleAvatar(radius: 9, child: Text(t.winner[0], style: const TextStyle(fontSize: 9))),
                ),
              ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.isTBD ? 'TBD' : t.winner,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${t.hostDisplay} • ${t.teams} teams',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HistoryDetailsScreen(tournament: t)),
          );
        },
      ),
    );
  }
}
