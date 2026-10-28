import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';

class CheckoutNotifier extends Notifier<CheckoutPreferences> {
  @override
  CheckoutPreferences build() {
    // The account's name and phone stand in as the recipient until the
    // customer types someone else.
    ref.listen(authSessionProvider, (previous, next) {
      final before = previous?.value?.user;
      final after = next.value?.user;
      if (before?.id == after?.id) return;
      String follow(String current, String old, String fresh) =>
          current.isEmpty || current == old ? fresh : current;
      state = state.copyWith(
        recipient: follow(state.recipient, _name(before), _name(after)),
        phone: follow(state.phone, _phone(before), _phone(after)),
      );
    });
    final user = ref.read(authSessionProvider).value?.user;
    return CheckoutPreferences(recipient: _name(user), phone: _phone(user));
  }

  static String _name(AuthUser? user) => user?.displayName.trim() ?? '';

  static String _phone(AuthUser? user) {
    final phone = user?.phone?.trim() ?? '';
    if (phone.isEmpty || phone.startsWith('+')) return phone;
    return AuthValidators.normalizePhoneNumber(phone);
  }

  void selectDelivery(DeliverySlot slot) =>
      state = state.copyWith(delivery: slot);

  void selectPayment(CheckoutPayment payment) =>
      state = state.copyWith(payment: payment);

  void updateInstructions(String instructions) =>
      state = state.copyWith(instructions: instructions);

  void updateRecipient({required String name, required String phone}) =>
      state = state.copyWith(recipient: name.trim(), phone: phone.trim());
}

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutPreferences>(
      CheckoutNotifier.new,
    );
