import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/profile_switcher/profile_switcher_notifier.dart';
import 'package:self_improvement_app/features/profile_switcher/profile_switcher_styles.dart';

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

    return PopupMenuButton<AppProfile>(
      onSelected: (AppProfile profile) {
        notifier.setProfile(profile);
      },
      offset: const Offset(0, 48),
      tooltip: 'Switch User Profile',
      color: tokens.cardBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: tokens.border),
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 4,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppProfile>>[
        PopupMenuItem<AppProfile>(
          value: AppProfile.profileA,
          child: Text(
            'Profile A',
            style: notifier.activeProfile == AppProfile.profileA
                ? styles.dropdownActiveItemStyle
                : styles.dropdownItemStyle,
          ),
        ),
        PopupMenuItem<AppProfile>(
          value: AppProfile.profileB,
          child: Text(
            'Profile B (Redwood)',
            style: notifier.activeProfile == AppProfile.profileB
                ? styles.dropdownActiveItemStyle
                : styles.dropdownItemStyle,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: styles.triggerBg,
          border: Border.all(color: styles.triggerBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notifier.userEmail,
              style: styles.emailStyle,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: tokens.textMain,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
