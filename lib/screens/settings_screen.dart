import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Dynamic Island Toggle
                    _SettingsTile(
                      icon: Icons.dynamic_form,
                      iconColor: AppTheme.primary,
                      title: 'Dynamic Island',
                      subtitle: 'Show floating controls over other apps',
                      trailing: Switch(
                        value: provider.overlayEnabled,
                        onChanged: (value) => provider.toggleOverlay(value),
                        activeTrackColor: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rescan Library
                    _SettingsTile(
                      icon: Icons.refresh,
                      iconColor: Colors.orange,
                      title: 'Rescan Music Library',
                      subtitle: '${provider.allSongs.length} songs found',
                      onTap: () async {
                        await provider.rescanLibrary();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Found ${provider.allSongs.length} songs'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // About
                    _SettingsTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.blue,
                      title: 'About Vibeland',
                      subtitle: 'Version 1.0.0',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Vibeland',
                          applicationVersion: '1.0.0',
                          applicationIcon: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                          ),
                          children: [
                            const Text('A premium local music player with Dynamic Island for Android.'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Stats section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0x08FFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Library Stats',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _StatRow('Total Songs', '${provider.allSongs.length}'),
                          _StatRow('Favorites', '${provider.favorites.length}'),
                          _StatRow('Folders', '${provider.folders.length}'),
                          _StatRow('Recently Played', '${provider.recentlyPlayed.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
