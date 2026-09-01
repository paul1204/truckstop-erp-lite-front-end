import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_styles.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';
import 'package:self_improvement_app/features/house_accounts/widgets/add_house_account_dialog.dart';
import 'package:self_improvement_app/features/house_accounts/widgets/clipboard_card.dart';
import 'package:self_improvement_app/features/house_accounts/widgets/mail_organizer_widget.dart';

class HouseAccountsViewV2 extends StatefulWidget {
  final HouseAccountsNotifier notifier;
  final StyleTokens tokens;

  const HouseAccountsViewV2({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<HouseAccountsViewV2> createState() => _HouseAccountsViewV2State();
}

class _HouseAccountsViewV2State extends State<HouseAccountsViewV2> {
  bool _showOrganizer = true;

  @override
  Widget build(BuildContext context) {
    final styles = HouseAccountsStyles(widget.tokens);

    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title & Actions row
              LayoutBuilder(
                builder: (context, headerConstraints) {
                  final bool isNarrow = headerConstraints.maxWidth < 750;
                  final Widget titleWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('House Accounts V2', style: styles.titleStyle),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 100, color: widget.tokens.accent),
                    ],
                  );

                  final Widget actionButtons = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View Toggle Switch
                      ToggleButtons(
                        isSelected: [_showOrganizer, !_showOrganizer],
                        onPressed: (index) {
                          setState(() {
                            _showOrganizer = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        borderWidth: 1.5,
                        borderColor: widget.tokens.border,
                        selectedBorderColor: widget.tokens.accent,
                        selectedColor: Colors.white,
                        fillColor: widget.tokens.accent,
                        color: widget.tokens.textMain,
                        constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                        children: const [
                          Text('Organizer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('List Grid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Add Account Button
                      ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AddHouseAccountDialog(
                              notifier: widget.notifier,
                              tokens: widget.tokens,
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.tokens.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: 16),
                        actionButtons,
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleWidget,
                        actionButtons,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              if (widget.notifier.loading)
                Center(child: CircularProgressIndicator(color: widget.tokens.accent))
              else if (widget.notifier.error != null)
                OfflineErrorWidget(
                  tokens: widget.tokens,
                  error: widget.notifier.error!,
                  onRetry: widget.notifier.fetchAccounts,
                )
              else
                _showOrganizer
                    ? MailOrganizerWidget(
                        accounts: widget.notifier.accounts,
                        tokens: widget.tokens,
                        styles: styles,
                        onCardTap: (account) => _showAccountDetailsDialog(context, account, styles),
                      )
                    : _buildAccountsGrid(context, styles),
            ],
          ),
        );
      },
    );
  }

  // --- Alternate Grid List View ---
  Widget _buildAccountsGrid(BuildContext context, HouseAccountsStyles styles) {
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
            childAspectRatio: 1.4,
          ),
          itemCount: widget.notifier.accounts.length,
          itemBuilder: (context, index) {
            final account = widget.notifier.accounts[index];
            return ClipboardCard(
              account: account,
              tokens: widget.tokens,
              styles: styles,
              onTap: () => _showAccountDetailsDialog(context, account, styles),
            );
          },
        );
      },
    );
  }

  void _showAccountDetailsDialog(BuildContext context, HouseAccount account, HouseAccountsStyles styles) {
    final standingColor = styles.getStandingColor(account.accountStanding);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(account.companyName, style: styles.companyNameStyle.copyWith(fontSize: 20)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account Summary'),
                  _buildDetailRow('Account ID', account.houseAccountId),
                  _buildDetailRowWidget(
                    'Standing',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: standingColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        account.accountStanding,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: standingColor),
                      ),
                    ),
                  ),
                  _buildDetailRow('Amount Due', '\$${account.amountDue.toStringAsFixed(2)}'),
                  _buildDetailRow('Gallons Due', '${account.gallonsDue.toStringAsFixed(0)} gal'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Contact Information'),
                  _buildDetailRow('Phone', account.phoneNumber),
                  _buildDetailRow('Address', account.address),

                  const SizedBox(height: 16),
                  _buildSectionHeader('History'),
                  _buildDetailRow('Account Age', '${account.accountAge} months'),
                  _buildDetailRow('Good Standing Duration', '${account.goodStandingDuration} months'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: widget.tokens.accent)),
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
          fontFamily: widget.tokens.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: widget.tokens.accent,
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
          Text(label, style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, color: widget.tokens.textMain.withOpacity(0.6))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, fontWeight: FontWeight.w600, color: widget.tokens.textHeader),
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
          Text(label, style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, color: widget.tokens.textMain.withOpacity(0.6))),
          widgetValue,
        ],
      ),
    );
  }
}
