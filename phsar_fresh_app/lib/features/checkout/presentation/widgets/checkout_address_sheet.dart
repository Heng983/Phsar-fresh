import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/location/domain/model/delivery_location.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/address_details_fields.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/market_location_sheet.dart';

class CheckoutAddressSheet extends ConsumerStatefulWidget {
  const CheckoutAddressSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => const CheckoutAddressSheet(),
  );

  @override
  ConsumerState<CheckoutAddressSheet> createState() =>
      _CheckoutAddressSheetState();
}

class _CheckoutAddressSheetState extends ConsumerState<CheckoutAddressSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late DeliveryLocation _location;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final preferences = ref.read(checkoutProvider);
    _name = TextEditingController(text: preferences.recipient);
    _phone = TextEditingController(
      text: preferences.phone.replaceFirst('+855', '0'),
    );
    _address = TextEditingController(text: ref.read(marketLocationProvider));
    _location = ref.read(deliveryLocationProvider);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final invalid = _form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalid.first.context,
        duration: const Duration(milliseconds: 200),
        alignment: .2,
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(deliveryLocationProvider.notifier)
          .select(_location.withLabel(_address.text.trim()));
      if (!mounted) return;
      ref
          .read(checkoutProvider.notifier)
          .updateRecipient(
            name: _name.text,
            phone: AuthValidators.normalizePhoneNumber(_localPhone),
          );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = context.l10n.locationSaveError;
          _saving = false;
        });
      }
    }
  }

  Future<void> _chooseOnMap() async {
    final location = await MarketLocationSheet.show(
      context,
      _location.withLabel(_address.text),
    );
    if (!mounted || location == null) return;
    setState(() {
      _location = location;
      _address.text = location.label;
    });
  }

  String get _localPhone => _phone.text
      .replaceAll(RegExp(r'[\s-]'), '')
      .replaceFirst(RegExp(r'^\+855'), '0');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorMaxLines: 3,
    );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.checkoutEditAddress,
                style: const TextStyle(
                  fontSize: AppFontSize.headline,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('checkout-recipient-input'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                maxLength: 80,
                decoration: decoration(l10n.checkoutRecipientName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.checkoutNameRequired
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('checkout-phone-input'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                maxLength: 20,
                decoration: decoration(l10n.authPhoneNumber),
                validator: (value) =>
                    AuthValidators.isValidPhoneNumber(_localPhone)
                    ? null
                    : l10n.authInvalidPhone,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('checkout-choose-map'),
                onPressed: _saving ? null : _chooseOnMap,
                icon: const Icon(Icons.map_outlined),
                label: Text(l10n.locationChooseOnMap),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('checkout-address-input'),
                controller: _address,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 3,
                maxLength: 200,
                onChanged: (value) => setState(() {
                  _location = _location.copyWith(
                    label: value,
                    clearCoordinates: true,
                  );
                }),
                decoration: decoration(l10n.checkoutStreetAddress),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.checkoutAddressRequired
                    : null,
              ),
              AddressDetailsFields(
                keyPrefix: 'checkout',
                value: _location,
                enabled: !_saving,
                onChanged: (location) => setState(() => _location = location),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              FilledButton(
                key: const Key('checkout-save-address'),
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.loginButton,
                ),
                child: Text(l10n.marketSaveLocation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
