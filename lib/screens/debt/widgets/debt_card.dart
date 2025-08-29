import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hasan2/models/debt_model.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/widgets/text_widget.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DebtCard({super.key, required this.debt, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final bool isFinished = debt.isFinished;
    final Color statusColor = isFinished ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary;
    final String statusText = isFinished ? 'منتهي' : 'جاري';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: CustomText(
                    text: debt.personName,
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(color: statusColor.withAlpha((0.15 * 255).toInt()), borderRadius: BorderRadius.circular(10)),
                  child: CustomText(text: statusText, fontSize: 5, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: CustomText(
                    text: formatPriceWithCurrency(debt.totalAmount),
                    fontSize: 5,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    Icon(Iconsax.calendar_1, color: Colors.grey[600], size: 16),
                    SizedBox(width: 2.w),
                    CustomText(
                      text: DateFormat('MMMM d, yyyy').format(debt.startDate.toLocal()),
                      fontSize: 5,
                      color: Theme.of(context).dividerColor,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
