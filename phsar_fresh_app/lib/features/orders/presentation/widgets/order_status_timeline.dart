import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/models/order_content.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTimeline({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    const stages = [
      OrderStatus.confirmed,
      OrderStatus.packed,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];
    final current = stages.indexOf(status);
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned(
            top: 18,
            left: constraints.maxWidth / 8,
            right: constraints.maxWidth / 8,
            child: Container(
              height: 2,
              color: AppColors.divider,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: current < 0 ? 0 : current / 3,
                child: Container(color: AppColors.primary),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < stages.length; index++)
                Expanded(
                  child: Semantics(
                    selected: current == index,
                    label: index < current
                        ? context.l10n.ordersStepComplete(
                            stages[index].label(context.l10n),
                          )
                        : null,
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color:
                                index == current &&
                                    status != OrderStatus.delivered
                                ? AppColors.lightOrange
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  index < current ||
                                      status == OrderStatus.delivered
                                  ? AppColors.loginButton
                                  : index == current
                                  ? AppColors.mango
                                  : AppColors.divider,
                            ),
                            child: Icon(
                              index < current || status == OrderStatus.delivered
                                  ? Icons.check_rounded
                                  : switch (stages[index]) {
                                      OrderStatus.confirmed =>
                                        Icons.receipt_long_outlined,
                                      OrderStatus.packed =>
                                        Icons.inventory_2_outlined,
                                      OrderStatus.onTheWay =>
                                        Icons.delivery_dining_rounded,
                                      _ => Icons.home_outlined,
                                    },
                              color: index <= current
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            stages[index].label(context.l10n),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppFontSize.badge,
                              height: 1.4,
                              color: index == current
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                              fontWeight: index == current
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
