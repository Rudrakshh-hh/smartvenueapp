import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/venue.dart';
import '../providers/app_state.dart';
import '../services/booking_api_service.dart';
import '../theme/app_theme.dart';

/// Bottom sheet shown when the user taps BOOK NOW.
/// Collects date, start/end time and purpose, saves the booking through the
/// API, and closes with `true` when it succeeded.
///
///   final booked = await showModalBottomSheet<bool>(
///     context: context,
///     isScrollControlled: true,
///     backgroundColor: Colors.transparent,
///     builder: (_) => BookVenueSheet(venue: venue),
///   );
class BookVenueSheet extends StatefulWidget {
  const BookVenueSheet({super.key, required this.venue});

  final Venue venue;

  @override
  State<BookVenueSheet> createState() => _BookVenueSheetState();
}

class _BookVenueSheetState extends State<BookVenueSheet> {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final TextEditingController _purposeController = TextEditingController();
  late DateTime _date;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
    final startHour = (now.hour + 1).clamp(8, 20).toInt();
    _start = TimeOfDay(hour: startHour, minute: 0);
    _end = TimeOfDay(hour: startHour + 1, minute: 0);
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        // Keep the end time after the start time.
        if (_minutes(_end) <= _minutes(_start)) {
          _end = TimeOfDay(
            hour: picked.hour < 23 ? picked.hour + 1 : 23,
            minute: picked.hour < 23 ? picked.minute : 59,
          );
        }
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    final purpose = _purposeController.text.trim();
    if (purpose.isEmpty) {
      setState(() => _error = 'Please enter a purpose (e.g. Extra class)');
      return;
    }
    if (_minutes(_end) <= _minutes(_start)) {
      setState(() => _error = 'End time must be after the start time');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await BookingApiService.createBooking(
        venue: widget.venue,
        date: _date,
        start: _start,
        end: _end,
        purpose: purpose,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on BookingException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<AppState>(context).isDarkMode;
    final accent = AppTheme.emerald(isDark);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted(isDark).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'BOOK VENUE',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.venue.name} (${widget.venue.code})',
                style: TextStyle(
                  color: AppTheme.textPrimary(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              _pickerTile(
                isDark: isDark,
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: '${_date.day} ${_months[_date.month - 1]} ${_date.year}',
                onTap: _saving ? null : _pickDate,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _pickerTile(
                      isDark: isDark,
                      icon: Icons.access_time_rounded,
                      label: 'Start',
                      value: _start.format(context),
                      onTap: _saving ? null : () => _pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _pickerTile(
                      isDark: isDark,
                      icon: Icons.access_time_filled_rounded,
                      label: 'End',
                      value: _end.format(context),
                      onTap: _saving ? null : () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _purposeController,
                enabled: !_saving,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: AppTheme.textPrimary(isDark)),
                decoration: InputDecoration(
                  labelText: 'Purpose (e.g. Extra class, Meeting)',
                  labelStyle: TextStyle(color: AppTheme.textMuted(isDark)),
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accent.withValues(alpha: 0.15)),
                  ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CONFIRM BOOKING',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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

  Widget _pickerTile({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
  }) {
    final accent = AppTheme.emerald(isDark);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppTheme.textMuted(isDark), fontSize: 11),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
