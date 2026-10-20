import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import '../../domain/entities/product.dart';

class CatalogueScreen extends ConsumerStatefulWidget {
  const CatalogueScreen({super.key});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(catalogueNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final layoutWidth = MediaQuery.sizeOf(context).width;
    final isMedium = layoutWidth >= 600 && layoutWidth < 840;
    final isExpanded = layoutWidth >= 840;

    final navDestinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.storefront_outlined),
        selectedIcon: Icon(Icons.storefront_rounded),
        label: 'Shop',
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: cartCount > 0,
          label: Text('$cartCount'),
          child: const Icon(Icons.shopping_cart_rounded),
        ),
        label: 'Cart',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    final Widget body = _CatalogueBody(
      scrollController: _scrollController,
      searchController: _searchController,
    );

    if (isExpanded) {
      return Scaffold(
        body: Row(
          children: [
            NavigationDrawer(
              selectedIndex: _currentNavIndex,
              onDestinationSelected: _onNavTap,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ShopSphere',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ...navDestinations.map(
                  (d) => NavigationDrawerDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
                ),
              ],
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    if (isMedium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentNavIndex,
              onDestinationSelected: _onNavTap,
              labelType: NavigationRailLabelType.all,
              leading: Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(
                    Icons.shopping_bag_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              destinations: navDestinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onNavTap,
        destinations: navDestinations,
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 1:
        context.push(kCartPath);
      case 2:
        context.push(kProfilePath);
      default:
        break;
    }
    // Reset to 0 after navigating away so returning shows Shop tab active
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _currentNavIndex = 0);
    });
  }
}

class _CatalogueBody extends ConsumerWidget {
  const _CatalogueBody({
    required this.scrollController,
    required this.searchController,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogueNotifierProvider);
    final notifier = ref.read(catalogueNotifierProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);
    final layoutWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = layoutWidth < 600
        ? 2
        : layoutWidth < 840
        ? 3
        : 4;

    return RefreshIndicator(
      onRefresh: () => notifier.load(refresh: true),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // App bar + search
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('ShopSphere'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _showSortSheet(context, ref),
                tooltip: 'Sort',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  controller: searchController,
                  hintText: 'Search products…',
                  leading: const Icon(Icons.search_rounded),
                  trailing: searchController.text.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              searchController.clear();
                              notifier.setSearch('');
                            },
                          ),
                        ]
                      : null,
                  onChanged: (q) {
                    notifier.setSearch(q);
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ),
          ),

          // Category filter
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (cats) => _CategoryBar(
                categories: cats,
                selected: state.filter.categorySlug,
                onSelected: notifier.setCategory,
              ),
              loading: () => const SizedBox(height: 48),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Active sort/filter chips
          if (state.filter.sort != ProductSort.none ||
              state.filter.categorySlug != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (state.filter.sort != ProductSort.none)
                      Chip(
                        label: Text(state.filter.sort.label),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => notifier.setSort(ProductSort.none),
                      ),
                  ],
                ),
              ),
            ),

          // Product count
          if (!state.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '${state.total} products',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // Grid
          if (state.isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const ProductCardSkeleton(),
                  childCount: 8,
                ),
              ),
            )
          else if (state.error != null)
            SliverFillRemaining(
              child: AppErrorWidget(
                error: state.error!,
                onRetry: () => notifier.load(refresh: true),
              ),
            )
          else if (state.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'No products found',
                subtitle: 'Try a different search or category',
                actionLabel: 'Clear filters',
                onAction: () {
                  searchController.clear();
                  notifier.setCategory(null);
                  notifier.setSearch('');
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = state.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.push(
                      kProductDetailPath.replaceAll(':id', '${product.id}'),
                    ),
                  );
                }, childCount: state.products.length),
              ),
            ),

          // Load more indicator
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(catalogueNotifierProvider.notifier);
    final current = ref.read(catalogueNotifierProvider).filter.sort;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...ProductSort.values.map(
                (sort) => ListTile(
                  leading: Radio<ProductSort>(
                    value: sort,
                    groupValue: current,
                    onChanged: (s) {
                      if (s != null) {
                        notifier.setSort(s);
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(sort.label),
                  onTap: () {
                    notifier.setSort(sort);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selected;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final slug = cat.slug;
          final name = cat.name;
          return FilterChip(
            label: Text(name),
            selected: selected == slug,
            onSelected: (_) => onSelected(selected == slug ? null : slug),
          );
        },
      ),
    );
  }
}
