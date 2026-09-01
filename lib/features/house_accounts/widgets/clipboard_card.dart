import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_notifier.dart';
import 'package:self_improvement_app/features/house_accounts/house_accounts_styles.dart';

class ClipboardCard extends StatelessWidget {
  final HouseAccount account;
  final StyleTokens tokens;
  final HouseAccountsStyles styles;
  final VoidCallback onTap;

  const ClipboardCard({
    super.key,
    required this.account,
    required this.tokens,
    required this.styles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = tokens.brightness == Brightness.dark;

    // Board Background: Wooden/card-stock coloring
    final Color boardColor = isDark
        ? const Color(0xFF3A2F28) // Deep dark walnut/mahogany board
        : const Color(0xFFD2BCA6); // Warm kraft board

    final Color boardBorderColor = isDark
        ? const Color(0xFF29211C)
        : const Color(0xFFB09880);

    // Paper Background: Soft vintage cream
    final Color paperColor = isDark
        ? const Color(0xFFFBF8F0) // Keep paper readable and high contrast
        : const Color(0xFFFFFDF5);

    // Standing status details
    final Color standingColor = styles.getStandingColor(account.accountStanding);
    final String stampText = _getStampText(account.accountStanding);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: boardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: boardBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor.withOpacity(isDark ? 0.5 : 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Paper Sheet
            Positioned.fill(
              top: 24, // Inset paper below the metal clip
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: paperColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Manifest Header / ID row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANIFEST #${account.houseAccountId.substring(0, math.min(8, account.houseAccountId.length)).toUpperCase()}',
                          style: TextStyle(
                            fontFamily: tokens.monoFont,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5C5446),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '-' * 40,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontFamily: tokens.monoFont,
                            fontSize: 9,
                            color: Colors.grey[400],
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),

                    // Bill To (Company Name)
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BILL TO:',
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 9,
                                color: const Color(0xFF8B8070),
                              ),
                            ),
                            Text(
                              account.companyName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C251C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Metrics (Amount Due & Credit Limit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BAL DUE:',
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 9,
                                color: const Color(0xFF8B8070),
                              ),
                            ),
                            Text(
                              '\$${account.amountDue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C251C),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIMIT:',
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 9,
                                color: const Color(0xFF8B8070),
                              ),
                            ),
                            Text(
                              '\$${account.creditLimit.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: tokens.monoFont,
                                fontSize: 11,
                                color: const Color(0xFF5C5446),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Rubber Status Stamp (Diagonal overlay on the middle right)
            Positioned(
              right: 20,
              top: 60,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: standingColor.withOpacity(0.55),
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stampText,
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: standingColor.withOpacity(0.55),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Metal Clip (Top center)
            Positioned(
              top: -6,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 54,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[400]!,
                        Colors.grey[300]!,
                        Colors.grey[500]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF424242),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStampText(String standing) {
    switch (standing.toUpperCase()) {
      case 'GOOD':
        return '✔ APPROVED';
      case 'WARNING':
      case 'PAST_DUE':
        return '⚠ PAST DUE';
      case 'DELINQUENT':
      case 'OVER_DUE':
        return '✘ CREDIT HOLD';
      default:
        return standing.toUpperCase();
    }
  }
}
