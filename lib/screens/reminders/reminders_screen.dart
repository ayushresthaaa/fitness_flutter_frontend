import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reminders/reminders_provider.dart';
import '../../models/reminder/reminders_model.dart';
import '../../widgets/common.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().fetchReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppTopBar(
        title: 'Reminders',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kTextDark),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.reminders.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No reminders yet',
              subtitle: 'Tap + to add a reminder',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final reminder = provider.reminders[index];
                return _ReminderCard(reminder: reminder);
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _AddReminderSheet(),
    );
  }
}

// reminder card
class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;

  const _ReminderCard({required this.reminder});

  IconData _iconForType(String type) {
    switch (type) {
      case 'workout':
        return Icons.fitness_center;
      case 'water':
        return Icons.water_drop_outlined;
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.apple_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _subtitleForReminder(ReminderModel r) {
    if (r.type == 'water' && r.intervalHours != null) {
      return 'Every ${r.intervalHours} hour${r.intervalHours! > 1 ? 's' : ''}';
    }
    return '${r.formattedTime} · ${r.formattedDays}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReminderProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForType(reminder.type), color: kPrimary, size: 20),
          ),
          const SizedBox(width: 12),

          // title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reminder.type[0].toUpperCase()}${reminder.type.substring(1)} Reminder',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitleForReminder(reminder),
                  style: const TextStyle(fontSize: 12, color: kTextGrey),
                ),
              ],
            ),
          ),

          // toggle
          Switch(
            value: reminder.enabled,
            onChanged: (val) => provider.toggleReminder(reminder.id, val),
            activeColor: kPrimary,
          ),

          // delete
          GestureDetector(
            onTap: () => _confirmDelete(context, provider, reminder.id),
            child: const Icon(Icons.delete_outline, color: kTextGrey, size: 20),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ReminderProvider provider,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteReminder(id);
            },
            child: const Text('Delete', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
  }
}

//add reminder bottom sheet
class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _types = ['workout', 'water', 'breakfast', 'lunch', 'dinner', 'snack'];
  final _allDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  String _selectedType = 'workout';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  List<String> _selectedDays = [];
  int _intervalHours = 2;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReminderProvider>();
    final isWater = _selectedType == 'water';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          const Text(
            'Add Reminder',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 16),

          // type picker
          const SectionLabel('Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((type) {
              final selected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kPrimary : kWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? kPrimary : kTextHint),
                  ),
                  child: Text(
                    '${type[0].toUpperCase()}${type.substring(1)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? kWhite : kTextDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // time picker (not for water)
          if (!isWater) ...[
            const SectionLabel('Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kTextHint),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: kPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 14, color: kTextDark),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // days picker
            const SectionLabel('Days (empty = daily)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allDays.map((day) {
                final selected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    selected
                        ? _selectedDays.remove(day)
                        : _selectedDays.add(day);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? kPrimaryLight : kWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? kPrimary : kTextHint,
                      ),
                    ),
                    child: Text(
                      day.substring(0, 3).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? kPrimary : kTextGrey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // interval picker (water only)
          if (isWater) ...[
            const SectionLabel('Interval'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Every',
                  style: TextStyle(fontSize: 14, color: kTextDark),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _intervalHours,
                  underline: const SizedBox(),
                  items: [1, 2, 3, 4].map((h) {
                    return DropdownMenuItem(
                      value: h,
                      child: Text('$h hour${h > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _intervalHours = val!),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // save button
          PrimaryButton(
            text: 'Save Reminder',
            isLoading: provider.isLoading,
            onTap: () async {
              await provider.upsertReminder(
                type: _selectedType,
                hour: isWater ? 0 : _selectedTime.hour,
                minute: isWater ? 0 : _selectedTime.minute,
                days: _selectedDays,
                intervalHours: isWater ? _intervalHours : null,
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
