import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/profile_switcher/profile_switcher_notifier.dart';
import 'package:truck_stop_erp_lite_front_end/features/profile_switcher/profile_switcher_styles.dart';

class ProfileSwitcher extends StatelessWidget {
  final ProfileNotifier notifier;
  final StyleTokens tokens;

  const ProfileSwitcher({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final styles = ProfileSwitcherStyles(tokens);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: styles.triggerBg,
        border: Border.all(color: styles.triggerBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        notifier.userEmail,
        style: styles.emailStyle,
      ),
    );
  }
}
