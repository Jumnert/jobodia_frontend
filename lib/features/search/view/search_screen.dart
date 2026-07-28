import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/search/controller/search_controller.dart';
import 'package:jobodia_frontend/features/search/view/widgets/search_results_list.dart';

/// Full-screen job search page.
///
/// Shows a back button and search field at the top. Below it, either a list
/// of recent searches (tap to re-run) when the query is empty, or the
/// matching job results as the user types.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textController;
  late final HomeController _homeController;
  late final JobSearchController _searchHistory;

  @override
  void initState() {
    super.initState();
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    _searchHistory = Get.isRegistered<JobSearchController>()
        ? Get.find<JobSearchController>()
        : Get.put(JobSearchController());
    _textController = TextEditingController(
      text: _homeController.searchQuery.value,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _searchHistory.addSearch(q);
    _homeController.updateSearchQuery(q);
  }

  void _selectRecent(String query) {
    _textController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _submit(query);
  }

  Widget _clearIcon(
    BuildContext context,
    FTextFieldStyle style,
    VoidCallback clear,
  ) {
    return FTextField.defaultClearIconBuilder(context, style, () {
      clear();
      _homeController.clearSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.embedded ? 20 : 12,
                8,
                20,
                12,
              ),
              child: Row(
                children: [
                  if (!widget.embedded) ...[
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      onPress: () => Get.back<void>(),
                      child: const Icon(FLucideIcons.arrowLeft),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: FTextField(
                      control: FTextFieldControl.managed(
                        controller: _textController,
                        onChange: (_) => setState(() {}),
                      ),
                      hint: 'Search jobs, companies...',
                      autofocus: !widget.embedded,
                      textInputAction: TextInputAction.search,
                      onSubmit: _submit,
                      prefixBuilder: (context, style, variants) =>
                          FTextField.prefixIconBuilder(
                            context,
                            style,
                            variants,
                            const Icon(FLucideIcons.search),
                          ),
                      clearable: (value) => value.text.isNotEmpty,
                      clearIconBuilder: _clearIcon,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final query = _homeController.searchQuery.value;
                final jobs = _homeController.filteredJobs;

                if (query.isEmpty) {
                  return _RecentSearches(
                    searchHistory: _searchHistory,
                    onSelect: _selectRecent,
                  );
                }

                return SearchResultsList(
                  jobs: jobs,
                  query: query,
                  homeController: _homeController,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.searchHistory, required this.onSelect});

  final JobSearchController searchHistory;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final recents = searchHistory.recentSearches;
      if (recents.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Search for jobs by title, company, or keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textTertiary, fontSize: 14),
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Row(
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: searchHistory.clearAll,
                child: Text(
                  'Clear all',
                  style: TextStyle(color: palette.textTertiary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...recents.map(
            (query) => _RecentSearchRow(
              query: query,
              onTap: () => onSelect(query),
              onRemove: () => searchHistory.removeSearch(query),
            ),
          ),
        ],
      );
    });
  }
}

class _RecentSearchRow extends StatelessWidget {
  const _RecentSearchRow({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                query,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(FLucideIcons.arrowUpRight, size: 18, color: palette.iconMuted),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  FLucideIcons.x,
                  size: 16,
                  color: palette.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
