import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension DeliveryAddressPresentation on DeliveryLocation {
  String? addressName(AppLocalizations l10n) => switch (addressLabel) {
    DeliveryAddressLabel.home => l10n.addressHome,
    DeliveryAddressLabel.work => l10n.addressWork,
    DeliveryAddressLabel.partner => l10n.addressPartner,
    DeliveryAddressLabel.other =>
      customLabel.trim().isEmpty ? l10n.addressOther : customLabel.trim(),
    null => null,
  };

  IconData get addressIcon => switch (addressLabel) {
    DeliveryAddressLabel.home => Icons.home_outlined,
    DeliveryAddressLabel.work => Icons.work_outline_rounded,
    DeliveryAddressLabel.partner => Icons.favorite_border_rounded,
    _ => Icons.location_on_outlined,
  };
}

class AddressDetailsFields extends StatefulWidget {
  const AddressDetailsFields({
    super.key,
    required this.value,
    required this.onChanged,
    this.keyPrefix = 'location',
    this.enabled = true,
  });
  final DeliveryLocation value;
  final ValueChanged<DeliveryLocation> onChanged;
  final String keyPrefix;
  final bool enabled;

  @override
  State<AddressDetailsFields> createState() => _AddressDetailsFieldsState();
}

class _AddressDetailsFieldsState extends State<AddressDetailsFields> {
  late final _house = TextEditingController(text: widget.value.houseNumber);
  late final _street = TextEditingController(text: widget.value.street);
  late final _note = TextEditingController(text: widget.value.note);
  late final _customLabel = TextEditingController(
    text: widget.value.customLabel,
  );

  @override
  void didUpdateWidget(AddressDetailsFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final field in [
      (_house, widget.value.houseNumber),
      (_street, widget.value.street),
      (_note, widget.value.note),
      (_customLabel, widget.value.customLabel),
    ]) {
      if (field.$1.text != field.$2) field.$1.text = field.$2;
    }
  }

  @override
  void dispose() {
    for (final controller in [_house, _street, _note, _customLabel]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _emit(String _) => widget.onChanged(
    widget.value.copyWith(
      houseNumber: _house.text,
      street: _street.text,
      note: _note.text,
      customLabel: _customLabel.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    InputDecoration decoration(String label, IconData icon, {String? hint}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          hintMaxLines: 2,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 21),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorMaxLines: 3,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 32, color: AppColors.border),
        Text(
          l10n.addressDetailsTitle,
          style: const TextStyle(
            fontSize: AppFontSize.price,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.addressDetailsHint,
          style: const TextStyle(
            fontSize: AppFontSize.caption,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.addressSaveAs,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final label in DeliveryAddressLabel.values)
              ChoiceChip(
                key: Key('${widget.keyPrefix}-label-${label.name}'),
                avatar: Icon(
                  widget.value.copyWith(addressLabel: label).addressIcon,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  widget.value
                      .copyWith(addressLabel: label, customLabel: '')
                      .addressName(l10n)!,
                ),
                selected: widget.value.addressLabel == label,
                selectedColor: AppColors.lightGreen,
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                showCheckmark: false,
                onSelected: widget.enabled
                    ? (selected) => widget.onChanged(
                        widget.value.copyWith(
                          addressLabel: label,
                          clearAddressLabel: !selected,
                        ),
                      )
                    : null,
              ),
          ],
        ),
        if (widget.value.addressLabel == DeliveryAddressLabel.other) ...[
          const SizedBox(height: 16),
          TextFormField(
            key: Key('${widget.keyPrefix}-custom-label'),
            controller: _customLabel,
            enabled: widget.enabled,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: decoration(
              l10n.addressCustomLabel,
              Icons.label_outline_rounded,
            ),
            onChanged: _emit,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.addressCustomLabelRequired
                : null,
          ),
        ],
        const SizedBox(height: 18),
        TextFormField(
          key: Key('${widget.keyPrefix}-house-number'),
          controller: _house,
          enabled: widget.enabled,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: decoration(
            l10n.addressHouseNumber,
            Icons.home_work_outlined,
          ),
          onChanged: _emit,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: Key('${widget.keyPrefix}-street'),
          controller: _street,
          enabled: widget.enabled,
          maxLength: 120,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.streetAddressLine1],
          decoration: decoration(l10n.addressStreet, Icons.signpost_outlined),
          onChanged: _emit,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: Key('${widget.keyPrefix}-note'),
          controller: _note,
          enabled: widget.enabled,
          maxLength: 300,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoration(
            l10n.addressNote,
            Icons.notes_rounded,
            hint: l10n.addressNoteHint,
          ),
          onChanged: _emit,
        ),
      ],
    );
  }
}
