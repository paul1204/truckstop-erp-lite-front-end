import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_styles.dart';

class MailOrganizerWidget extends StatefulWidget {
  final List<HouseAccount> accounts;
  final StyleTokens tokens;
  final HouseAccountsStyles styles;
  final ValueChanged<HouseAccount> onCardTap;

  const MailOrganizerWidget({
    super.key,
    required this.accounts,
    required this.tokens,
    required this.styles,
    required this.onCardTap,
  });

  @override
  State<MailOrganizerWidget> createState() => _MailOrganizerWidgetState();
}

class _MailOrganizerWidgetState extends State<MailOrganizerWidget> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.accounts.isEmpty) {
      return Center(
        child: Text(
          'No house accounts.',
          style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
        ),
      );
    }

    final bool isDark = widget.tokens.brightness == Brightness.dark;

    // Cabinet Wood colors
    final Color woodCabinetColor = isDark
        ? const Color(0xFF2D1E17) // Dark rich walnut wood
        : const Color(0xFF5D4037); // Warm mahogany wood

    final Color woodBorderColor = isDark
        ? const Color(0xFF1E140F)
        : const Color(0xFF3E2723);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute columns dynamically: 4 cols on desktop, 3 on tablets
        int crossAxisCount = 4;
        if (constraints.maxWidth < 650) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
        }

        return Container(
          decoration: BoxDecoration(
            color: woodCabinetColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: woodBorderColor, width: 8), // Thick wood outer casing
            boxShadow: [
              BoxShadow(
                color: widget.tokens.shadowColor.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            itemCount: widget.accounts.length,
            itemBuilder: (context, index) {
              final account = widget.accounts[index];
              return _buildCubbySlot(index, account, isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildCubbySlot(int index, HouseAccount account, bool isDark) {
    final bool isHovered = _hoveredIndex == index;

    // Inside shadow recess colors
    final Color slotBg = isDark
        ? const Color(0xFF1A120E) // Deep hollow recess
        : const Color(0xFF2C1D18);

    final Color woodDividerColor = isDark
        ? const Color(0xFF3E2A20)
        : const Color(0xFF7B5E57);

    // Document paper colors
    final Color paperBg = isDark
        ? const Color(0xFFF9F7F1)
        : const Color(0xFFFFFDF7);

    final Color paperBorder = isDark
        ? const Color(0xFFE5DECE)
        : const Color(0xFFEFE6D2);

    final Color standingColor = widget.styles.getStandingColor(account.accountStanding);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onCardTap(account),
        child: Container(
          decoration: BoxDecoration(
            color: slotBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: woodDividerColor, width: 3), // Internal wooden slots dividers
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 4,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Folded Invoice Document Paper
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                top: isHovered ? -16 : 14,
                left: isHovered ? 6 : 12,
                right: isHovered ? 6 : 12,
                bottom: isHovered ? 4 : 8,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: isHovered ? 1.05 : 1.0,
                  curve: Curves.easeOutCubic,
                  child: Container(
                    decoration: BoxDecoration(
                      color: paperBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                      border: Border.all(color: paperBorder, width: 1),
                      boxShadow: [
                        if (isHovered)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 8),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        // Small stamp seal top right
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Transform.rotate(
                            angle: -math.pi / 12,
                            child: Opacity(
                              opacity: isHovered ? 0.85 : 0.45,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: standingColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  _getStampText(account.accountStanding).toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: widget.tokens.monoFont,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: standingColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Folded letter layout
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MANIFEST #${account.houseAccountId.substring(0, 6).toUpperCase()}',
                              style: TextStyle(
                                fontFamily: widget.tokens.monoFont,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'BAL DUE',
                              style: TextStyle(
                                fontFamily: widget.tokens.sansFont,
                                fontSize: 8,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '\$${account.amountDue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: widget.tokens.monoFont,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D1505),
                              ),
                            ),
                            if (isHovered) ...[
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LIMIT: \$${account.creditLimit.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontFamily: widget.tokens.monoFont,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    '${account.accountAge}M AGE',
                                    style: TextStyle(
                                      fontFamily: widget.tokens.monoFont,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Brass Placard mounted below the slot opening
              Positioned(
                left: 10,
                right: 10,
                bottom: -7,
                height: 16,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE5C060),
                        Color(0xFFC59F3E),
                        Color(0xFFE5C060),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: const Color(0xFF8C6B1B), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    account.companyName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1005),
                      shadows: [
                        Shadow(color: Colors.white24, blurRadius: 1, offset: Offset(0.5, 0.5)),
                      ],
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

  String _getStampText(String standing) {
    switch (standing.toUpperCase()) {
      case 'GOOD':
        return 'APPROVED';
      case 'DELINQUENT':
        return 'PAST DUE';
      case 'SUSPENDED':
        return 'HOLD';
      default:
        return standing;
    }
  }
}
