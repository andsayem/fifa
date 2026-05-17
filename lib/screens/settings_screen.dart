import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  'TIMEZONE SETTINGS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.grey : Colors.grey.shade700,
                  ),
                ),
              ),

              // Timezone Mode Selection Card
              Card(
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildRadioListTile(
                      context: context,
                      title: 'My Timezone (Device Time)',
                      subtitle: 'Automatically convert match times to your device local country time.',
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
                      subtitle: 'Show the scheduled time local to the stadium hosting the match in USA/Canada/Mexico.',
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
                const SizedBox(height: 16),
                Card(
                  elevation: isDark ? 4 : 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled, color: primaryColor),
                            const SizedBox(width: 12),
                            const Text(
                              'Select GMT Offset',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Offset:',
                              style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
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
                          label: 'GMT ${settingsProvider.customOffsetHours >= 0 ? '+' : ''}${settingsProvider.customOffsetHours}',
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

              const SizedBox(height: 24),
              Card(
                color: primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blueAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Kickoffs & Countdown',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Changing these options shifts the dates & times shown for all matches in the home page, schedule lists, details, and brackets. Your ticking countdown timers will stay 100% accurate as they calculate the time left in your absolute local timezone.',
                              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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

    return RadioListTile<TimezoneMode>(
      activeColor: primaryColor,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Row(
        children: [
          Icon(icon, size: 22, color: isSelected ? primaryColor : Colors.grey),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 34.0, top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, height: 1.2),
        ),
      ),
    );
  }
}
