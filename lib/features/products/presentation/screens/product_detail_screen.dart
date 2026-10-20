import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_error.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const CustomScrollView(
          slivers: [
            SliverAppBar(expandedHeight: 0, pinned: true),
            SliverFillRemaining(child: DetailHeaderSkeleton()),
          ],
        ),
        error: (err, _) {
          if (err is NotFoundError) {
            return Scaffold(
              appBar: AppBar(),
              body: AppErrorWidget(error: err, onRetry: () => ref.invalidate(productDetailProvider(widget.productId))),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
            ),
          );
        },
        data: (product) => _buildDetail(context, product),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 0,
          pinned: true,
          title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),

        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image carousel
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 320,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: product.images.length,
                      onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: product.images[i],
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.broken_image_outlined, size: 64, color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  // Page indicator
                  if (product.images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentImageIndex ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _currentImageIndex
                                  ? colorScheme.primary
                                  : colorScheme.onSurface.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Brand
                    Row(
                      children: [
                        Chip(
                          label: Text(product.category),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (product.brand != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            product.brand!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      product.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final full = i < product.rating.floor();
                          final half = !full && i < product.rating;
                          return Icon(
                            full
                                ? Icons.star_rounded
                                : half
                                    ? Icons.star_half_rounded
                                    : Icons.star_outline_rounded,
                            color: Colors.amber.shade600,
                            size: 22,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${product.rating.toStringAsFixed(1)} · ${product.reviews.length} reviews',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.finalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (product.discountPercentage >= 1) ...[
                          const SizedBox(width: 12),
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock status
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: product.inStock ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.inStock
                              ? '${product.stock} in stock'
                              : 'Out of stock',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: product.inStock ? Colors.green.shade700 : colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (product.availabilityStatus != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '· ${product.availabilityStatus}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),

                    // Extra info
                    if (product.shippingInformation != null) ...[
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.local_shipping_outlined,
                        label: product.shippingInformation!,
                      ),
                    ],
                    if (product.warrantyInformation != null)
                      _InfoRow(
                        icon: Icons.verified_outlined,
                        label: product.warrantyInformation!,
                      ),
                    if (product.returnPolicy != null)
                      _InfoRow(
                        icon: Icons.assignment_return_outlined,
                        label: product.returnPolicy!,
                      ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Quantity selector
                    Row(
                      children: [
                        Text(
                          'Quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _QuantitySelector(
                          quantity: _quantity,
                          max: product.stock,
                          onChanged: product.inStock
                              ? (q) => setState(() => _quantity = q)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add to cart button
                    _AddToCartButton(
                      product: product,
                      quantity: _quantity,
                      enabled: product.inStock,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Reviews
                    if (product.reviews.isNotEmpty) ...[
                      Text(
                        'Customer Reviews',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...product.reviews.map((r) => _ReviewCard(review: r)),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int max;
  final void Function(int)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          onPressed: onChanged == null || quantity <= 1
              ? null
              : () => onChanged!(quantity - 1),
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton.outlined(
          onPressed: onChanged == null || quantity >= max
              ? null
              : () => onChanged!(quantity + 1),
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  const _AddToCartButton({
    required this.product,
    required this.quantity,
    required this.enabled,
  });

  final Product product;
  final int quantity;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: enabled
          ? () {
              ref.read(cartNotifierProvider.notifier).addItem(product, quantity: quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} added to cart'),
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.add_shopping_cart_rounded),
      label: Text(enabled ? 'Add to Cart' : 'Out of Stock'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    review.reviewerName.isNotEmpty
                        ? review.reviewerName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating.floor()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber.shade600,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.comment, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
