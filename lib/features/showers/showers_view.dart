import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/showers/showers_notifier.dart';
import 'package:self_improvement_app/features/showers/showers_styles.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';

class ShowersView extends StatelessWidget {
  final ShowersNotifier notifier;
  final StyleTokens tokens;

  const ShowersView({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final styles = ShowersStyles(tokens);

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Shower Units', style: styles.titleStyle),
                  const SizedBox(height: 4),
                  Container(height: 4, width: 100, color: tokens.accent),
                ],
              ),
              const SizedBox(height: 24),

              if (notifier.loading)
                Center(child: CircularProgressIndicator(color: tokens.accent))
              else if (notifier.error != null)
                OfflineErrorWidget(
                  tokens: tokens,
                  error: notifier.error!,
                  onRetry: notifier.fetchShowers,
                )
              else
                _buildShowersGrid(context, styles),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShowersGrid(BuildContext context, ShowersStyles styles) {
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

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
          ),
          itemCount: notifier.showers.length,
          itemBuilder: (context, index) {
            final shower = notifier.showers[index];
            return _buildShowerCard(context, shower, styles);
          },
        );
      },
    );
  }

  Widget _buildShowerCard(BuildContext context, ShowerUnit shower, ShowersStyles styles) {
    final badgeColor = styles.getStatusColor(shower.occupied, shower.cleaning);

    String statusText = 'Available';
    if (shower.cleaning) {
      statusText = 'Cleaning';
    } else if (shower.occupied) {
      statusText = 'Occupied';
    }

    String subText = 'Ready';
    if (shower.cleaning) {
      subText = 'Maintenance';
    } else if (shower.occupied) {
      subText = shower.customerName;
    }

    final formattedSince = shower.occupiedSince != null
        ? DateTime.tryParse(shower.occupiedSince!) != null
            ? DateTime.parse(shower.occupiedSince!).toLocal().toString().substring(11, 16)
            : shower.occupiedSince!
        : 'N/A';

    final formattedUntil = shower.reservedUntil != null
        ? DateTime.tryParse(shower.reservedUntil!) != null
            ? DateTime.parse(shower.reservedUntil!).toLocal().toString().substring(11, 16)
            : shower.reservedUntil!
        : 'N/A';

    return InkWell(
      onTap: () => _showShowerDetailsDialog(context, shower, styles),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: tokens.cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            // Shower Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unit ${shower.showerNumber}', style: styles.unitNumberStyle),
                Expanded(
                  child: Text(
                    subText,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: shower.occupied || shower.cleaning ? tokens.textHeader : tokens.textMain.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),

            // Time & cost info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Occupied Since', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text(formattedSince, style: styles.valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reserved Until', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text(formattedUntil, style: styles.valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Cost', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text('\$${shower.totalCost.toStringAsFixed(2)}', style: styles.valueStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShowerDetailsDialog(BuildContext context, ShowerUnit shower, ShowersStyles styles) {
    final badgeColor = styles.getStatusColor(shower.occupied, shower.cleaning);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String statusText = 'Available';
        if (shower.cleaning) {
          statusText = 'Cleaning';
        } else if (shower.occupied) {
          statusText = 'Occupied';
        }

        final formattedSince = shower.occupiedSince != null
            ? DateTime.tryParse(shower.occupiedSince!) != null
                ? DateTime.parse(shower.occupiedSince!).toLocal().toString().substring(0, 16)
                : shower.occupiedSince!
            : 'N/A';

        final formattedUntil = shower.reservedUntil != null
            ? DateTime.tryParse(shower.reservedUntil!) != null
                ? DateTime.parse(shower.reservedUntil!).toLocal().toString().substring(0, 16)
                : shower.reservedUntil!
            : 'N/A';

        final formattedCleaning = shower.cleaningUntil != null
            ? DateTime.tryParse(shower.cleaningUntil!) != null
                ? DateTime.parse(shower.cleaningUntil!).toLocal().toString().substring(0, 16)
                : shower.cleaningUntil!
            : 'N/A';

        return AlertDialog(
          title: Text('Shower Details: ${shower.showerNumber}', style: styles.unitNumberStyle.copyWith(fontSize: 20)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Status & Occupant'),
                  _buildDetailRowWidget(
                    'Current Status',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                  ),
                  _buildDetailRow('Customer', shower.occupied ? shower.customerName : 'N/A'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Schedule & Billing'),
                  _buildDetailRow('Occupied Since', formattedSince),
                  _buildDetailRow('Reserved Until', formattedUntil),
                  _buildDetailRow('Cleaning Until', formattedCleaning),
                  _buildDetailRow('Total Cost', '\$${shower.totalCost.toStringAsFixed(2)}'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Notes'),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      shower.message.isNotEmpty ? shower.message : 'No additional information.',
                      style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: tokens.accent)),
            )
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: tokens.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: tokens.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain.withOpacity(0.6))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, fontWeight: FontWeight.w600, color: tokens.textHeader),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWidget(String label, Widget widgetValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain.withOpacity(0.6))),
          widgetValue,
        ],
      ),
    );
  }
}
