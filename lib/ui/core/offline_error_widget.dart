import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class OfflineErrorWidget extends StatelessWidget {
  final StyleTokens tokens;
  final String error;
  final VoidCallback onRetry;

  const OfflineErrorWidget({
    super.key,
    required this.tokens,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = tokens.brightness == Brightness.dark;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: tokens.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.accentSecondary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with soft alert background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.accentSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: tokens.accentSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Backend Offline',
              style: TextStyle(
                fontFamily: tokens.sansFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: tokens.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              'The frontend application could not establish a connection to the Truckstop ERP Lite Spring Boot service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: tokens.sansFont,
                fontSize: 14,
                color: tokens.textMain.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Expected server details block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C1A) : const Color(0xFFF0EEE9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF3D3B39) : const Color(0xFFE2E0D9),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Service:',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'http://localhost:9000',
                    style: TextStyle(
                      fontFamily: tokens.monoFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: tokens.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Technical details ExpansionTile
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: tokens.textMain.withOpacity(0.5),
                collapsedIconColor: tokens.textMain.withOpacity(0.5),
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Technical Details',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 12,
                    color: tokens.textMain.withOpacity(0.6),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        error,
                        style: TextStyle(
                          fontFamily: tokens.monoFont,
                          fontSize: 11,
                          color: tokens.accentSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Action Retry Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.accent,
                  foregroundColor: tokens.headerText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
