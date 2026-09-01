import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/inventory/inventory_notifier.dart';
import 'package:self_improvement_app/features/inventory/inventory_styles.dart';
import 'package:self_improvement_app/features/inventory/widgets/gauge_circular.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';

// 1px transparent PNG bytes for smooth image fade-in placeholder
final Uint8List kTransparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82
]);

class InventoryView extends StatelessWidget {
  final InventoryNotifier notifier;
  final StyleTokens tokens;

  const InventoryView({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final styles = InventoryStyles(tokens);

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        if (notifier.loading) {
          return Center(child: CircularProgressIndicator(color: tokens.accent));
        }

        if (notifier.error != null) {
          return OfflineErrorWidget(
            tokens: tokens,
            error: notifier.error!,
            onRetry: notifier.fetchInventory,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1100) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 500) {
              crossAxisCount = 2;
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Inventory Management', style: styles.titleStyle),
                                const SizedBox(height: 4),
                                Text(
                                  'Track and manage your product stock levels',
                                  style: styles.subtitleStyle,
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 24,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Category: ', style: styles.categoryLabelStyle),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: notifier.category,
                                      dropdownColor: tokens.cardBg,
                                      underline: Container(height: 2, color: tokens.accent),
                                      style: TextStyle(
                                        fontFamily: tokens.sansFont,
                                        color: tokens.textHeader,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'packagedFood',
                                          child: Text('Packaged Food'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'bottledBeverages',
                                          child: Text('Bottled Beverage'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          notifier.setCategory(val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Animation: ', style: styles.categoryLabelStyle),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: notifier.animationType,
                                      dropdownColor: tokens.cardBg,
                                      underline: Container(height: 2, color: tokens.accent),
                                      style: TextStyle(
                                        fontFamily: tokens.sansFont,
                                        color: tokens.textHeader,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Fade', child: Text('Fade In')),
                                        DropdownMenuItem(value: 'Scale', child: Text('Scale In')),
                                        DropdownMenuItem(value: 'Slide', child: Text('Slide Up')),
                                        DropdownMenuItem(value: 'Flip', child: Text('3D Flip')),
                                        DropdownMenuItem(value: 'Bounce', child: Text('Elastic Bounce')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          notifier.setAnimationType(val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = notifier.products[index];
                        return ProductCard(
                          key: ValueKey(product.skuCode),
                          product: product,
                          styles: styles,
                          tokens: tokens,
                          animationType: notifier.animationType,
                          onTap: () => _showProductDetailsDialog(context, product),
                        );
                      },
                      childCount: notifier.products.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Details dialog pop-up with product specifications and recent orders list
  void _showProductDetailsDialog(BuildContext context, Product product) {
    int initialIndex = notifier.products.indexOf(product);
    if (initialIndex == -1) initialIndex = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _InventoryDetailsDialog(
          products: notifier.products,
          initialIndex: initialIndex,
          tokens: tokens,
        );
      },
    );
  }
}

class _InventoryDetailsDialog extends StatefulWidget {
  final List<Product> products;
  final int initialIndex;
  final StyleTokens tokens;

  const _InventoryDetailsDialog({
    required this.products,
    required this.initialIndex,
    required this.tokens,
  });

  @override
  State<_InventoryDetailsDialog> createState() => _InventoryDetailsDialogState();
}

class _InventoryDetailsDialogState extends State<_InventoryDetailsDialog> {
  late int currentIndex;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatProfit(double profit) {
    final isNegative = profit < 0;
    final absVal = profit.abs().toStringAsFixed(2);
    return isNegative ? '-\$$absVal' : '\$$absVal';
  }

  String formatMargin(double profit, double retailPrice) {
    if (retailPrice <= 0) return '0.00%';
    final margin = (profit / retailPrice) * 100;
    return '${margin.toStringAsFixed(2)}%';
  }

  Widget buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: widget.tokens.sansFont,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: widget.tokens.textHeader,
        ),
      ),
    );
  }

  Widget buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: widget.tokens.sansFont,
          fontSize: 14,
          color: widget.tokens.textMain,
        ),
      ),
    );
  }

  void _showImagePopup(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final tokens = widget.tokens;

        return Dialog(
          backgroundColor: tokens.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
            child: Stack(
              children: [
                // Centered Product Image with reduced padding to maximize size
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: ResizeImage(
                        AssetImage('assets/Photos/inventory-photos/${product.skuCode}.png'),
                        width: 1000,
                      ),
                      fit: BoxFit.contain,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: tokens.textMain.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                color: tokens.textMain.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Styled Close Button overlayed on top right with translucent circle backdrop
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.cardBg.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: tokens.textHeader,
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = widget.products[currentIndex];
    final deliveries = currentProduct.deliveries;
    final tokens = widget.tokens;

    return Dialog(
      backgroundColor: tokens.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        width: 800,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row (Product Name and Close Button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      currentProduct.name,
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tokens.textHeader,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: tokens.textMain,
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subheader Row (Product name repeated, and Navigation Arrows)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentProduct.name,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 16,
                      color: tokens.textMain,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: tokens.textHeader,
                        disabledColor: tokens.textMain.withOpacity(0.3),
                        onPressed: currentIndex > 0
                            ? () {
                                setState(() {
                                  currentIndex--;
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        color: tokens.textHeader,
                        disabledColor: tokens.textMain.withOpacity(0.3),
                        onPressed: currentIndex < widget.products.length - 1
                            ? () {
                                setState(() {
                                  currentIndex++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Delivery Dates Section Header
              Text(
                'Delivery Dates',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tokens.textHeader,
                ),
              ),
              const SizedBox(height: 16),

              // Grid Table Container with fixed height for scrolling grid behavior
              SizedBox(
                height: 270,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 736,
                    child: Column(
                      children: [
                        // Fixed Table Header
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.6), // Delivery Date
                            1: FlexColumnWidth(1.4), // Quantity Ordered
                            2: FlexColumnWidth(1.5), // Cost Per Unit
                            3: FlexColumnWidth(1.4), // Retail Price
                            4: FlexColumnWidth(1.2), // Profit
                            5: FlexColumnWidth(1.2), // Margin
                          },
                          children: [
                            TableRow(
                              children: [
                                buildHeaderCell('Delivery Date'),
                                buildHeaderCell('Quantity Ordered'),
                                buildHeaderCell('Cost Per Unit'),
                                buildHeaderCell('Retail Price'),
                                buildHeaderCell('Profit'),
                                buildHeaderCell('Margin'),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: tokens.border.withOpacity(0.15),
                          height: 1,
                          thickness: 1,
                        ),
                        // Scrollable Table Body
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1.6), // Delivery Date
                                  1: FlexColumnWidth(1.4), // Quantity Ordered
                                  2: FlexColumnWidth(1.5), // Cost Per Unit
                                  3: FlexColumnWidth(1.4), // Retail Price
                                  4: FlexColumnWidth(1.2), // Profit
                                  5: FlexColumnWidth(1.2), // Margin
                                },
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    color: tokens.border.withOpacity(0.15),
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: tokens.border.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                children: deliveries.isEmpty
                                    ? [
                                        TableRow(
                                          children: [
                                            buildDataCell('No delivery records'),
                                            buildDataCell(''),
                                            buildDataCell(''),
                                            buildDataCell(''),
                                            buildDataCell(''),
                                            buildDataCell(''),
                                          ],
                                        )
                                      ]
                                    : deliveries.map((d) {
                                        final profit = d.retailPrice - d.costPerUnit;
                                        return TableRow(
                                          children: [
                                            buildDataCell(d.deliveryDate),
                                            buildDataCell(d.qtyOrdered.toString()),
                                            buildDataCell('\$${d.costPerUnit.toStringAsFixed(2)}'),
                                            buildDataCell('\$${d.retailPrice.toStringAsFixed(2)}'),
                                            buildDataCell(formatProfit(profit)),
                                            buildDataCell(formatMargin(profit, d.retailPrice)),
                                          ],
                                        );
                                      }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Records text
              Text(
                'Total Records: ${deliveries.length}',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 12,
                  color: tokens.textMain.withOpacity(0.6),
                ),
              ),
              const Spacer(),

              // Center Display Image button
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    _showImagePopup(context, currentProduct);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: tokens.border),
                    backgroundColor: tokens.brightness == Brightness.light
                        ? Colors.white
                        : tokens.border.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    'Display Image',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontWeight: FontWeight.w600,
                      color: tokens.textHeader,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final InventoryStyles styles;
  final StyleTokens tokens;
  final String animationType;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.styles,
    required this.tokens,
    required this.animationType,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.skuCode != widget.product.skuCode ||
        oldWidget.animationType != widget.animationType) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _applyAnimation(Widget child) {
    switch (widget.animationType) {
      case 'Scale':
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      case 'Slide':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case 'Flip':
        return AnimatedBuilder(
          animation: _controller,
          child: child,
          builder: (context, child) {
            final angle = (1.0 - _controller.value) * 3.1415926535 / 2.0;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(angle),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      case 'Bounce':
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
          ),
          child: child,
        );
      case 'Fade':
      default:
        return FadeTransition(
          opacity: _controller,
          child: child,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final product = widget.product;
    final styles = widget.styles;
    final tokens = widget.tokens;
    final double stockLevel = (product.qty / product.maxCapacity).clamp(0.0, 1.0);

    return _applyAnimation(
      InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: tokens.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image Container with smooth FadeInImage
            Expanded(
              child: Container(
                color: tokens.border.withOpacity(0.1),
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: ResizeImage(
                    AssetImage('assets/Photos/inventory-photos/${product.skuCode}.png'),
                    width: 600,
                  ),
                  fit: BoxFit.contain,
                  imageErrorBuilder: (context, error, stackTrace) {
                    // Styled Fallback when Image is missing
                    return Container(
                      color: tokens.border.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: tokens.textMain.withOpacity(0.3), size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'No Image',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              color: tokens.textMain.withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Text details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: styles.productNameStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SKU:', style: styles.detailLabelStyle),
                      Text(product.skuCode, style: styles.detailValueStyle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Qty:', style: styles.detailLabelStyle),
                      Text('${product.qty}', style: styles.detailValueStyle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cost/Price:', style: styles.detailLabelStyle),
                      Text(
                        '\$${product.costOfGoods.toStringAsFixed(2)} | \$${product.retailPrice.toStringAsFixed(2)}',
                        style: styles.detailValueStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Circular Stock Level Gauge
                  Center(
                    child: Column(
                      children: [
                        SemiCircularGauge(percentage: stockLevel, tokens: tokens),
                        Text(
                          'Stock: ${(stockLevel * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: tokens.sansFont,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tokens.textMain.withOpacity(0.6),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

