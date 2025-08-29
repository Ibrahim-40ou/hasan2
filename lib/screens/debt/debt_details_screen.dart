import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/debt_controller.dart';
import 'package:hasan2/models/debt_model.dart';
import 'package:hasan2/models/installment_model.dart';
import 'package:hasan2/screens/debt/edit_debt_screen.dart';
import 'package:hasan2/utils/date_picker.dart';
import 'package:hasan2/utils/dialog.dart';
import 'package:hasan2/utils/error.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class DebtDetailsScreen extends StatefulWidget {
  late Debt debt;

  DebtDetailsScreen({super.key, required this.debt});

  @override
  State<DebtDetailsScreen> createState() => _DebtDetailsScreenState();
}

class _DebtDetailsScreenState extends State<DebtDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<DebtController>();

    return GetBuilder<DebtController>(
      builder: (debtController) {
        widget.debt = debtController.debts.firstWhere((item) => item.id == widget.debt.id);
        return Scaffold(
          appBar: CustomAppBar(title: widget.debt.personName, isBackButtonVisible: true),
          floatingActionButton: widget.debt.phoneNumber.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _sendWhatsAppMessage(),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: Icon(Icons.message, color: Theme.of(context).colorScheme.onSurface),
                )
              : null,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debt Summary
                Container(
                  margin: EdgeInsets.only(bottom: 3.h),
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary.withAlpha(40), theme.colorScheme.primary.withAlpha(10)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Iconsax.money, color: Colors.white, size: 6.w),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(text: 'إجمالي المبلغ', fontSize: 4.5, color: Colors.grey[600]),
                                CustomText(
                                  text: '${formatPrice(widget.debt.totalAmount)} / ${formatPrice(_calculateTotalPaidAmount())} د.ع',
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Iconsax.calendar_1, color: Colors.grey[600], size: 5.w),
                          SizedBox(width: 3.w),
                          CustomText(
                            text: 'تاريخ البداية: ${widget.debt.startDate.toLocal().toString().split(' ')[0]}',
                            fontSize: 4.5,
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      if (widget.debt.isFinished && widget.debt.endDate != null) ...[
                        Row(
                          children: [
                            Icon(Iconsax.calendar_1, color: Colors.grey[600], size: 5.w),
                            SizedBox(width: 3.w),
                            CustomText(
                              text: 'تاريخ الانتهاء: ${widget.debt.endDate!.toLocal().toString().split(' ')[0]}',
                              fontSize: 4.5,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: "تعديل الدين",
                              onTap: () => Get.to(() => EditDebtScreen(debt: widget.debt)),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: GetBuilder<DebtController>(
                              builder: (ctrl) => CustomButton(
                                title: widget.debt.isFinished ? "استئناف الدين" : "إنهاء الدين",
                                onTap: () {
                                  showConfirmationDialog(
                                    buildContext: context,
                                    content: widget.debt.isFinished
                                        ? 'هل أنت متأكد من استئناف هذا الدين؟'
                                        : 'هل أنت متأكد من إنهاء هذا الدين؟',
                                    confirm: () async {
                                      if (widget.debt.isFinished) {
                                        await ctrl.resumeDebt(widget.debt.id!);
                                      } else {
                                        await ctrl.finishDebt(widget.debt.id!);
                                      }
                                      setState(() {
                                        widget.debt;
                                      });
                                    },
                                    reject: () {},
                                  );
                                },
                                // loading: ctrl.isFinishDebtLoading,
                                color: widget.debt.isFinished ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Note and Phone Number Section
                if (widget.debt.note.isNotEmpty || widget.debt.phoneNumber.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.debt.note.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Iconsax.note_1, color: theme.colorScheme.secondary, size: 5.w),
                              ),
                              SizedBox(width: 3.w),
                              CustomText(text: 'ملاحظة', fontSize: 5.5, fontWeight: FontWeight.w600, color: theme.colorScheme.secondary),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          CustomText(text: widget.debt.note, fontSize: 4.5, color: Colors.grey[700]),
                          SizedBox(height: 2.h),
                        ],
                        if (widget.debt.phoneNumber.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Iconsax.call, color: theme.colorScheme.tertiary, size: 5.w),
                              ),
                              SizedBox(width: 3.w),
                              CustomText(text: 'رقم الهاتف', fontSize: 5.5, fontWeight: FontWeight.w600, color: theme.colorScheme.tertiary),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          CustomText(text: widget.debt.phoneNumber, fontSize: 4.5, color: Colors.grey[700]),
                        ],
                      ],
                    ),
                  ),
                ],

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Iconsax.note_25, color: theme.colorScheme.primary, size: 5.w),
                        ),
                        SizedBox(width: 3.w),
                        CustomText(text: 'الأقساط', fontSize: 6.5, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Iconsax.add_circle, color: theme.colorScheme.primary, size: 6.w),
                      onPressed: () => _addEditInstallmentBottomSheet(context, widget.debt.id!),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),

                // Installments or Empty State
                if (widget.debt.installments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(25), shape: BoxShape.circle),
                          child: Icon(Iconsax.note_favorite, color: theme.colorScheme.primary, size: 8.w),
                        ),
                        SizedBox(height: 2.h),
                        CustomText(text: 'لا توجد أقساط بعد', fontSize: 5.5, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                        SizedBox(height: 1.h),
                        CustomText(
                          text: 'اضغط على زر الإضافة لتسجيل أول قسط',
                          fontSize: 4.5,
                          color: Colors.grey[500],
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),
                        SizedBox(
                          width: 60.w,
                          child: CustomButton(
                            title: "إضافة قسط جديد",
                            onTap: () => _addEditInstallmentBottomSheet(context, widget.debt.id!),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...widget.debt.installments.asMap().entries.map((entry) {
                    final i = entry.key;
                    final installment = entry.value;

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'المبلغ: ${formatPrice(installment.amount)} د.ع',
                                  fontSize: 5.5,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: [
                                    Icon(Iconsax.calendar_1, size: 4.w, color: Colors.grey[600]),
                                    SizedBox(width: 2.w),
                                    CustomText(
                                      text: 'بتاريخ: ${installment.dueDate.toLocal().toString().split(' ')[0]}',
                                      fontSize: 4.5,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Iconsax.edit, color: theme.colorScheme.primary),
                                onPressed: () => _addEditInstallmentBottomSheet(context, widget.debt.id!, i, installment),
                              ),
                              IconButton(
                                icon: Icon(Iconsax.trash, color: theme.colorScheme.error),
                                onPressed: () async {
                                  showConfirmationDialog(
                                    buildContext: context,
                                    content: 'هل أنت متأكد من حذف هذا القسط؟',
                                    confirm: () async {
                                      await controller.deleteInstallment(widget.debt.id!, i);
                                    },
                                    reject: () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addEditInstallmentBottomSheet(BuildContext context, String debtId, [int? index, Installment? installment]) {
    final theme = Theme.of(context);
    final key = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController(text: installment?.amount.toString() ?? '');
    DateTime dueDate = installment?.dueDate ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Form(
                key: key,
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    color: theme.colorScheme.surface,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: installment == null ? "إضافة قسط" : "تعديل القسط", fontSize: 6, fontWeight: FontWeight.w700),
                      SizedBox(height: 3.h),

                      CustomField(
                        controller: amountController,
                        labelText: "المبلغ",
                        keyboardType: TextInputType.number,
                        validator: (val) => val!.isEmpty ? "يرجى إدخال المبلغ" : null,
                      ),
                      SizedBox(height: 2.h),

                      GestureDetector(
                        onTap: () async {
                          final picked = await selectDate(context);
                          if (picked != null) dueDate = picked;
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(color: theme.primaryColor.withAlpha(50), borderRadius: BorderRadius.circular(10)),
                                child: Icon(Iconsax.calendar_1, color: theme.colorScheme.primary, size: 6.w),
                              ),
                              SizedBox(width: 2.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(text: "تاريخ القسط", fontSize: 4.5, color: theme.colorScheme.secondary),
                                  CustomText(
                                    text: dueDate.toLocal().toString().split(' ')[0],
                                    fontSize: 5,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      GetBuilder<DebtController>(
                        builder: (ctrl) => CustomButton(
                          title: installment == null ? "إضافة" : "تحديث",
                          onTap: () async {
                            if (key.currentState!.validate()) {
                              final newItem = Installment(amount: double.parse(amountController.text), dueDate: dueDate);

                              if (installment == null) {
                                await ctrl.addInstallment(debtId, newItem);
                              } else {
                                await ctrl.updateInstallment(debtId, index!, newItem);
                              }
                              Get.back();
                            }
                          },
                          loading: installment == null ? ctrl.isAddInstallmentLoading : ctrl.isEditInstallmentLoading,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateTotalPaidAmount() {
    return widget.debt.installments.fold(0.0, (sum, installment) => sum + installment.amount);
  }

  void _sendWhatsAppMessage() async {
    final remainingAmount = widget.debt.totalAmount - _calculateTotalPaidAmount();

    final message =
        '''
مرحباً ${widget.debt.personName}،

تذكير بالدين:
- المبلغ الأصلي: ${formatPrice(widget.debt.totalAmount)} د.ع
- المبلغ المتبقي: ${formatPrice(remainingAmount)} د.ع
- الملاحظة: ${widget.debt.note}

شكراً لك
''';

    // Clean and format phone number
    String phoneNumber = widget.debt.phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove country code if it starts with 00 or +
    if (phoneNumber.startsWith('00')) {
      phoneNumber = phoneNumber.substring(2);
    }
    
    // Add country code for Iraq if not present
    if (!phoneNumber.startsWith('964')) {
      phoneNumber = '964$phoneNumber';
    }
    
    // Remove leading zero if present after country code
    if (phoneNumber.startsWith('9640')) {
      phoneNumber = phoneNumber.replaceFirst('9640', '964');
    }

    final whatsappUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Try alternative approach
        final alternativeUrl = 'https://wa.me/send?phone=+$phoneNumber&text=${Uri.encodeComponent(message)}';
        final alternativeUri = Uri.parse(alternativeUrl);
        if (await canLaunchUrl(alternativeUri)) {
          await launchUrl(alternativeUri, mode: LaunchMode.externalApplication);
        } else {
          showError('لا يمكن فتح تطبيق واتساب');
        }
      }
    } catch (e) {
      print('WhatsApp launch error: $e');
      showError('حدث خطأ أثناء فتح واتساب');
    }
  }
}
