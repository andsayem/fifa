import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../presentation/widgets/purchase_popup.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.access_time,
                title: 'Time Zone',
                subtitle: 'Choose how match times are displayed',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Timezone Mode Selection Card
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildRadioListTile(
                      context: context,
                      title: 'My Timezone (${DateTime.now().timeZoneName})',
                      subtitle:
                          'Automatically convert match times to your device local time (${DateTime.now().timeZoneName}).',
                      value: TimezoneMode.device,
                      groupValue: settingsProvider.timezoneMode,
                      icon: Icons.phonelink_setup,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setTimezoneMode(val);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildRadioListTile(
                      context: context,
                      title: 'Stadium Time (Venue Local)',
                      subtitle:
                          'Show the scheduled time local to the stadium hosting the match in USA/Canada/Mexico.',
                      value: TimezoneMode.stadium,
                      groupValue: settingsProvider.timezoneMode,
                      icon: Icons.stadium_outlined,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setTimezoneMode(val);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildRadioListTile(
                      context: context,
                      title: 'UTC / GMT Time',
                      subtitle: 'Display times in Coordinated Universal Time.',
                      value: TimezoneMode.utc,
                      groupValue: settingsProvider.timezoneMode,
                      icon: Icons.public,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setTimezoneMode(val);
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildRadioListTile(
                      context: context,
                      title: 'Custom GMT Offset',
                      subtitle: 'Manually select a custom GMT timezone offset.',
                      value: TimezoneMode.custom,
                      groupValue: settingsProvider.timezoneMode,
                      icon: Icons.settings_ethernet,
                      onChanged: (val) {
                        if (val != null) settingsProvider.setTimezoneMode(val);
                      },
                    ),
                  ],
                ),
              ),

              // Custom Offset Selection (visible only when custom is chosen)
              if (settingsProvider.timezoneMode == TimezoneMode.custom) ...[
                const SizedBox(height: 12),
                Card(
                  elevation: isDark ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled, color: primaryColor),
                            const SizedBox(width: 12),
                            const Text(
                              'Select GMT Offset',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Offset:',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey
                                    : Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GMT ${settingsProvider.customOffsetHours >= 0 ? '+' : ''}${settingsProvider.customOffsetHours}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          min: -12,
                          max: 14,
                          divisions: 26,
                          activeColor: primaryColor,
                          label:
                              'GMT ${settingsProvider.customOffsetHours >= 0 ? '+' : ''}${settingsProvider.customOffsetHours}',
                          value: settingsProvider.customOffsetHours.toDouble(),
                          onChanged: (val) {
                            settingsProvider.setCustomOffset(val.round());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              _buildSectionHeader(
                context: context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage match reminder notifications',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (val) {
                        settingsProvider.setNotificationsEnabled(val);
                      },
                      title: const Text(
                        'Enable Match Reminders',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Receive notifications for upcoming matches',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: settingsProvider.notificationsEnabled
                              ? primaryColor.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          settingsProvider.notificationsEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: settingsProvider.notificationsEnabled
                              ? primaryColor
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 72),
                    SwitchListTile(
                      value: settingsProvider.remind30minBefore,
                      onChanged: settingsProvider.notificationsEnabled
                          ? (val) {
                              settingsProvider.setRemind30minBefore(val);
                            }
                          : null,
                      title: const Text(
                        'Remind me 30 minutes before kickoff',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Get alerted exactly 30 minutes before each match',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: settingsProvider.notificationsEnabled &&
                                  settingsProvider.remind30minBefore
                              ? primaryColor.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.timer_outlined,
                          color: settingsProvider.notificationsEnabled &&
                                  settingsProvider.remind30minBefore
                              ? primaryColor
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildSectionHeader(
                context: context,
                icon: Icons.workspace_premium,
                title: 'Support & Premium',
                subtitle: 'Remove ads and get help',
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Remove Ads Card
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await showPurchasePopup();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.block,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Remove Ads',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Subscribe to remove all ads and enjoy an ad-free experience.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isDark ? Colors.grey : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contact Support Card
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: 'andsayem@gmail.com'),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mail_outline,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact Support',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'andsayem@gmail.com',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: isDark ? Colors.grey : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Info Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: Colors.blueAccent, width: 3),
                  ),
                  color: isDark
                      ? Colors.blueAccent.withValues(alpha: 0.08)
                      : Colors.blue.withValues(alpha: 0.06),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Match Kickoffs & Countdown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Changing these options shifts the dates & times shown for all matches in the home page, schedule lists, details, and brackets. Your ticking countdown timers will stay 100% accurate as they calculate the time left in your absolute local timezone.',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.15),
                primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.3),
                primaryColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioListTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TimezoneMode value,
    required TimezoneMode groupValue,
    required IconData icon,
    required ValueChanged<TimezoneMode?> onChanged,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isSelected = value == groupValue;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha: 0.06)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      )
                    : const SizedBox(width: 10, height: 10),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isSelected ? primaryColor : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: isSelected
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
