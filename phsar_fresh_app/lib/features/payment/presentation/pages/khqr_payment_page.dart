import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/features/payment/data/payment_repository.dart';
import 'package:phsar_fresh_app/features/payment/domain/khqr_payment.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows an order's ABA KHQR, opens ABA Mobile, and waits for PayWay to
/// confirm the payment. Pops with `true` once paid.
class KhqrPaymentPage extends ConsumerStatefulWidget {
  const KhqrPaymentPage({
    super.key,
    required this.orderId,
    required this.orderCode,
    this.payment,
    this.error,
  });

  final String orderId;

  /// "PF-3F9A2C"
  final String orderCode;

  /// The KHQR created with the order, if creating it worked.
  final KhqrPayment? payment;

  /// Why it didn't.
  final String? error;

  static Future<bool?> open(
    BuildContext context, {
    required String orderId,
    required String orderCode,
    KhqrPayment? payment,
    String? error,
  }) => Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => KhqrPaymentPage(
        orderId: orderId,
        orderCode: orderCode,
        payment: payment,
        error: error,
      ),
    ),
  );

  @override
  ConsumerState<KhqrPaymentPage> createState() => _KhqrPaymentPageState();
}

class _KhqrPaymentPageState extends ConsumerState<KhqrPaymentPage>
    with WidgetsBindingObserver {
  static const _khqrRed = Color(0xFFE1232E);
  static const _pollEvery = Duration(seconds: 4);

  KhqrPayment? _payment;
  String? _error;
  bool _busy = false;
  bool _abaMissing = false;
  Timer? _poll;
  Timer? _tick;

  PaymentRepository? get _repo {
    final client = ref.read(apiClientProvider);
    return client == null ? null : PaymentRepository(client);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _payment = widget.payment;
    _error = widget.error;
    if (_payment == null && _error == null) _error = '';
    _startTimers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  /// Coming back from ABA Mobile: check straight away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  void _startTimers() {
    _poll?.cancel();
    _tick?.cancel();
    _poll = Timer.periodic(_pollEvery, (_) => _check());
    // Redraws the countdown.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _check() async {
    final payment = _payment;
    final repo = _repo;
    if (payment == null || repo == null || _busy) return;
    if (payment.status != KhqrPaymentStatus.pending) return;
    try {
      final next = await repo.status(widget.orderId);
      if (!mounted) return;
      setState(() => _payment = next);
      if (next.status != KhqrPaymentStatus.pending) {
        _poll?.cancel();
        _tick?.cancel();
      }
      _closeIfPaid();
    } on PaymentException {
      // Network blip: keep polling.
    }
  }

  bool _closing = false;

  /// Paid: show the tick for a moment, then return to checkout, which shows
  /// the same "Order placed!" sheet as cash on delivery.
  void _closeIfPaid() {
    if (_closing || !(_payment?.isPaid ?? false)) return;
    _closing = true;
    _poll?.cancel();
    _tick?.cancel();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  Future<void> _renew() async {
    final repo = _repo;
    if (repo == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _abaMissing = false;
    });
    try {
      final next = await repo.renew(widget.orderId);
      if (!mounted) return;
      setState(() {
        _payment = next;
        _busy = false;
      });
      _startTimers();
    } on PaymentException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message ?? '';
      });
    }
  }

  Future<void> _simulatePay() async {
    final repo = _repo;
    if (repo == null || _busy) return;
    setState(() => _busy = true);
    try {
      final next = await repo.testPay(widget.orderId);
      if (!mounted) return;
      setState(() {
        _payment = next;
        _busy = false;
      });
      _closeIfPaid();
    } on PaymentException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    }
  }

  Future<void> _openAba(String deeplink) async {
    final opened = await launchUrl(
      Uri.parse(deeplink),
      mode: LaunchMode.externalApplication,
    ).catchError((Object _) => false);
    if (!opened && mounted) setState(() => _abaMissing = true);
  }

  Future<bool> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.khqrLeaveTitle),
        content: Text(l10n.khqrLeaveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.khqrLeave),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.khqrStay),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final payment = _payment;
    final paid = payment?.isPaid ?? false;
    return PopScope(
      // Always answers whether it was paid, even on a system back.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (paid) return navigator.pop(true);
        if (await _confirmLeave()) navigator.pop(false);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.khqrTitle)),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: paid
                      ? _PaidView(
                          key: const ValueKey('khqr-paid'),
                          orderCode: widget.orderCode,
                          onDone: () => Navigator.of(context).pop(true),
                        )
                      : _body(context, payment),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, KhqrPayment? payment) {
    final l10n = context.l10n;
    final now = DateTime.now();
    if (payment == null) {
      return _Problem(
        key: const ValueKey('khqr-error'),
        message: [
          l10n.khqrError,
          if (_error != null && _error!.isNotEmpty) _error!,
        ].join('\n'),
        action: l10n.khqrTryAgain,
        busy: _busy,
        onAction: _renew,
      );
    }
    final open = payment.isOpenAt(now);
    final remaining = payment.expiresAt.difference(now);
    final mm = remaining.inMinutes.clamp(0, 999).toString().padLeft(2, '0');
    final ss = (remaining.inSeconds % 60)
        .clamp(0, 59)
        .toString()
        .padLeft(2, '0');
    final amount = '\$${(payment.amountInCents / 100).toStringAsFixed(2)}';
    return Column(
      key: ValueKey('khqr-${payment.tranId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KHQR card: red header, merchant, amount, dashed line, QR.
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A15281D),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 52,
                color: _khqrRed,
                alignment: Alignment.center,
                child: const Text(
                  'KHQR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppFontSize.title,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phsar Fresh',
                      style: TextStyle(
                        fontSize: AppFontSize.bodySmall,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          amount,
                          key: const Key('khqr-amount'),
                          style: const TextStyle(
                            fontSize: AppFontSize.display,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          payment.currency,
                          style: const TextStyle(
                            fontSize: AppFontSize.footnote,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.khqrOrder(widget.orderCode),
                      style: const TextStyle(
                        fontSize: AppFontSize.caption,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _DashedLine(),
              ),
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  margin: const EdgeInsets.fromLTRB(32, 6, 32, 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (payment.qrString != null) ...[
                          QrImageView(
                            key: const Key('khqr-code'),
                            data: payment.qrString!,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            // The highest level keeps the code readable under
                            // the currency badge.
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            semanticsLabel: l10n.khqrScanHint,
                          ),
                          FractionallySizedBox(
                            widthFactor: .2,
                            heightFactor: .2,
                            child: _CurrencyBadge(payment.currency),
                          ),
                        ],
                        if (!open)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white.withValues(alpha: .92),
                              child: Center(
                                child: Text(
                                  payment.status == KhqrPaymentStatus.failed
                                      ? l10n.khqrFailed
                                      : l10n.khqrExpired,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: AppFontSize.body,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 14, 32, 22),
                child: Text(
                  l10n.khqrScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (open) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '${l10n.khqrWaiting}  ·  ${l10n.khqrExpiresIn('$mm:$ss')}',
                  key: const Key('khqr-waiting'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppFontSize.footnote,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (payment.testMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.khqrTestModeNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.orange,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('khqr-simulate-pay'),
              onPressed: _busy ? null : _simulatePay,
              icon: const Icon(Icons.science_outlined, size: 20),
              label: Text(context.l10n.khqrSimulatePay),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppColors.orange,
                side: const BorderSide(color: AppColors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (payment.deeplink != null)
            FilledButton.icon(
              key: const Key('khqr-open-aba'),
              onPressed: () => _openAba(payment.deeplink!),
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              label: Text(l10n.khqrOpenAba),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF005D7E),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          if (_abaMissing)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.khqrAbaMissing,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.orange,
                ),
              ),
            ),
        ] else
          FilledButton(
            key: const Key('khqr-new'),
            onPressed: _busy ? null : _renew,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: _busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.khqrNewQr),
          ),
      ],
    );
  }
}

class _PaidView extends StatelessWidget {
  const _PaidView({super.key, required this.orderCode, required this.onDone});

  final String orderCode;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      child: Column(
        children: [
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.lightGreen,
            child: Icon(
              Icons.check_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.khqrPaidTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppFontSize.headline,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.khqrPaidBody(orderCode),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppFontSize.bodySmall,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('khqr-done'),
            onPressed: onDone,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(l10n.khqrDone),
          ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({
    super.key,
    required this.message,
    required this.action,
    required this.busy,
    required this.onAction,
  });

  final String message;
  final String action;
  final bool busy;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      children: [
        const Icon(
          Icons.qr_code_2_rounded,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: AppFontSize.bodySmall, height: 1.5),
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('khqr-retry'),
          onPressed: busy ? null : onAction,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(action),
        ),
      ],
    ),
  );
}

/// The black currency coin KHQR puts in the middle of the code.
class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge(this.currency);

  final String currency;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        child: Text(
          currency == 'KHR' ? '៛' : r'$',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    ),
  );
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = (constraints.maxWidth / 10).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < count; i++)
            const SizedBox(
              width: 5,
              height: 1.5,
              child: ColoredBox(color: AppColors.divider),
            ),
        ],
      );
    },
  );
}
