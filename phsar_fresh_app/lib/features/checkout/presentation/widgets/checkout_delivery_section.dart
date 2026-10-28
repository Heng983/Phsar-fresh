import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_choice_card.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_section_heading.dart';

class CheckoutDeliverySection extends ConsumerStatefulWidget {
  const CheckoutDeliverySection({super.key});

  @override
  ConsumerState<CheckoutDeliverySection> createState() =>
      _CheckoutDeliverySectionState();
}

class _CheckoutDeliverySectionState
    extends ConsumerState<CheckoutDeliverySection> {
  /// The day whose times are on show, once the customer picks one.
  DateTime? _day;

  /// Restored when switching back from express.
  DeliverySlot? _lastScheduled;

  void _select(DeliverySlot slot) {
    if (!slot.isExpress) _lastScheduled = slot;
    ref.read(checkoutProvider.notifier).selectDelivery(slot);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final now = DateTime.now();
    final selected = DeliverySchedule.resolve(
      ref.watch(checkoutProvider.select((value) => value.delivery)),
      now,
    );
    final selectedStart = selected.start;
    final days = DeliverySchedule.days(now);
    final shownDay =
        _day ??
        (selectedStart == null ? null : DateUtils.dateOnly(selectedStart));
    final day = days.firstWhere(
      (value) => value == shownDay,
      orElse: () => days.first,
    );
    final expressOpen = DeliverySchedule.expressOpen(now);

    String time(DateTime value) => DateFormat.Hm(locale).format(value);
    String dayName(DateTime value) {
      if (DateUtils.isSameDay(value, now)) return l10n.checkoutToday;
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      if (DateUtils.isSameDay(value, tomorrow)) return l10n.checkoutTomorrow;
      return DateFormat.EEEE(locale).format(value);
    }

    Widget leading(IconData icon, bool active) => CircleAvatar(
      radius: 19,
      backgroundColor: active
          ? const Color(0xFF319751)
          : const Color(0xFFD8E3CE),
      child: Icon(
        icon,
        size: 22,
        color: active ? Colors.white : AppColors.textSecondary,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutSectionHeading(
          icon: Icons.schedule_rounded,
          tint: AppTints.sky,
          title: l10n.checkoutDeliveryWindow,
          badge: l10n.checkoutFreshlyPrepared,
        ),
        if (expressOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CheckoutChoiceCard(
              key: const ValueKey('checkout-delivery-express'),
              selected: selected.isExpress,
              filled: true,
              leading: leading(Icons.bolt_rounded, selected.isExpress),
              title: l10n.checkoutExpress,
              subtitle: l10n.checkoutExpressArrives(
                time(now.add(DeliverySchedule.expressTime)),
              ),
              badge: l10n.checkoutFastest,
              onTap: () => _select(const DeliverySlot.express()),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CheckoutChoiceCard(
            key: const ValueKey('checkout-delivery-schedule'),
            selected: !selected.isExpress,
            filled: true,
            leading: leading(Icons.calendar_month_rounded, !selected.isExpress),
            title: selectedStart == null
                ? l10n.checkoutSchedule
                : l10n.checkoutScheduledSlot(
                    dayName(selectedStart),
                    time(selectedStart),
                    time(selected.end!),
                  ),
            subtitle: l10n.checkoutScheduleDescription,
            detail: _SlotPicker(
              days: days,
              day: day,
              slots: DeliverySchedule.slotsOn(day, now),
              selected: selectedStart,
              dayName: dayName,
              dayDate: (value) => DateFormat.MMMd(locale).format(value),
              time: time,
              onDay: (value) => setState(() => _day = value),
              onSlot: (start) => _select(DeliverySlot(start)),
            ),
            onTap: () {
              if (!selected.isExpress) return;
              _select(
                DeliverySchedule.resolve(
                  _lastScheduled ??
                      DeliverySlot(DeliverySchedule.slotsOn(day, now).first),
                  now,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Day tabs and a two-column grid of time windows, drawn on the filled card.
class _SlotPicker extends StatelessWidget {
  final List<DateTime> days;
  final DateTime day;
  final List<DateTime> slots;
  final DateTime? selected;
  final String Function(DateTime) dayName;
  final String Function(DateTime) dayDate;
  final String Function(DateTime) time;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<DateTime> onSlot;

  const _SlotPicker({
    required this.days,
    required this.day,
    required this.slots,
    required this.selected,
    required this.dayName,
    required this.dayDate,
    required this.time,
    required this.onDay,
    required this.onSlot,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD6F1DA),
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        label(l10n.checkoutChooseDay),
        Row(
          children: [
            for (final (index, value) in days.indexed) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  key: ValueKey('checkout-delivery-day-$index'),
                  selected: value == day,
                  onTap: () => onDay(value),
                  child: Column(
                    children: [
                      Text(
                        dayName(value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppFontSize.caption,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dayDate(value),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: AppFontSize.badge),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        label(l10n.checkoutChooseTime),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final width = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final start in slots)
                  SizedBox(
                    width: width,
                    child: _Pill(
                      key: ValueKey('checkout-delivery-slot-${start.hour}'),
                      selected: start == selected,
                      onTap: () => onSlot(start),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${time(start)} – '
                          '${time(start.add(DeliverySchedule.slotLength))}',
                          style: const TextStyle(
                            fontSize: AppFontSize.footnote,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _Pill({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.sm);
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: .12),
          borderRadius: radius,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: selected ? AppColors.loginButton : Colors.white,
                      height: 1.35,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
