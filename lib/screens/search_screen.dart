import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/match_filter_provider.dart';
import '../providers/world_cup_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/match_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(worldCupProvider);
    final matches = ref.watch(filteredMatchesProvider);
    final teams = ref.watch(teamsProvider);
    final venues = ref.watch(venuesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search teams, stadiums, groups...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(matchFilterProvider.notifier).setSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (v) {
                setState(() {});
                ref.read(matchFilterProvider.notifier).setSearch(v);
              },
            ),
          ),
          if (_searchController.text.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teams',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: teams.take(20).map((t) {
                          return ListTile(
                            dense: true,
                            title: Text(t),
                            onTap: () {
                              _searchController.text = t;
                              ref
                                  .read(matchFilterProvider.notifier)
                                  .setSearch(t);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Venues',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: venues.map((v) {
                          return ListTile(
                            dense: true,
                            title: Text(v),
                            onTap: () {
                              _searchController.text = v;
                              ref
                                  .read(matchFilterProvider.notifier)
                                  .setSearch(v);
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_searchController.text.isNotEmpty)
            Expanded(
              child: state.state == DataLoadState.loaded
                  ? (matches.isEmpty
                      ? const EmptyWidget(message: 'No matches found')
                      : ListView.builder(
                          itemCount: matches.length,
                          itemBuilder: (_, i) => MatchCard(
                            match: matches[i],
                          ),
                        ))
                  : const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
