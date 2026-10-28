import 'package:phsar_fresh_app/features/cart/data/voucher_repository.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

/// The customer-facing reason a code was refused.
String voucherProblemText(
  AppLocalizations l10n,
  VoucherCheck check,
  String Function(int cents) price,
) => switch (check.problem) {
  VoucherProblem.expired => l10n.cartVoucherExpired,
  VoucherProblem.notStarted => l10n.cartVoucherNotStarted,
  VoucherProblem.minSubtotal => l10n.cartVoucherMinOrder(
    price(check.minSubtotalInCents ?? 0),
  ),
  VoucherProblem.loginRequired => l10n.cartVoucherLoginRequired,
  VoucherProblem.notNewCustomer => l10n.cartVoucherNotNewCustomer,
  VoucherProblem.alreadyUsed => l10n.cartVoucherAlreadyUsed,
  VoucherProblem.network => l10n.cartVoucherCheckFailed,
  _ => l10n.cartInvalidVoucher,
};
