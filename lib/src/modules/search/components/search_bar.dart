import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18next/i18next.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../../components/atoms/blur_background.dart';
import '../../../hooks/floating_search_bar_controller.dart';
import '../../navigation/navigation.provider.dart';
import '../search.provider.dart';
import 'search_results_list.dart';

/// Search bar widget
class SearchBar extends HookWidget {
  /// Constructor
  const SearchBar({
    Key key,
    // @required this.onFocusChanged,
    // @required this.showSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryProvider = useProvider(searchQueryProvider);
    final currentRoute = useProvider(navigationProvider);
    final results = useProvider(searchResultsProvider);
    final isLoading = useState(false);
    final controller = useFloatingSearchBarController();
    final showSearch = useState(false);

    useValueChanged(currentRoute, (_, __) {
      showSearch.value = currentRoute == NavigationRoutes.searchScreen;
    });

    useValueChanged(showSearch.value, (_, __) {
      if (showSearch.value) {
        controller.open();
      } else {
        controller.clear();
        controller.close();
      }
    });

    // ignore: avoid_positional_boolean_parameters
    void onFocusChanged(bool focus) {
      if (!focus) {
        context.read(navigationProvider.notifier).goBack();
      }
    }

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: showSearch.value
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox(height: 0),
      secondChild: Container(
        constraints: BoxConstraints(
          maxHeight: showSearch.value ? MediaQuery.of(context).size.height : 0,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              child: const BlurBackground(
                strength: 15,
              ),
            ),
            FloatingSearchBar(
              hint: I18Next.of(context).t('modules:search.components.search'),
              controller: controller,
              progress: isLoading.value,
              shadowColor: Colors.transparent,
              transitionDuration: const Duration(milliseconds: 300),
              transitionCurve: Curves.easeInOut,
              margins: const EdgeInsets.fromLTRB(0, 10, 0, 0),

              physics: const BouncingScrollPhysics(),
              debounceDelay: const Duration(milliseconds: 200),
              width: MediaQuery.of(context).size.width / 1.5,
              backdropColor: Colors.black.withOpacity(0.5),
              onFocusChanged: onFocusChanged,
              // transition: CircularFloatingSearchBarTransition(),
              scrollPadding: const EdgeInsets.all(0),
              onQueryChanged: (query) async {
                if (query.isNotEmpty) {
                  isLoading.value = true;
                }
                queryProvider.state = query ?? '';
                await Future.delayed(const Duration(milliseconds: 250));
                isLoading.value = false;
              },
              actions: [
                FloatingSearchBarAction.searchToClear(
                  showIfClosed: false,
                ),
              ],
              builder: (context, transition) {
                if (results.isEmpty && queryProvider.state.isEmpty) {
                  return const SizedBox(height: 0);
                }
                if (results.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(I18Next.of(context)
                        .t('modules:search.components.noResults')),
                  );
                }

                return SearchResultsList(results);
              },
            ),
          ],
        ),
      ),
    );
  }
}
