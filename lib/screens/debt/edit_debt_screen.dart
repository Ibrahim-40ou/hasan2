import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/debt_controller.dart';
import 'package:hasan2/models/debt_model.dart';
import 'package:hasan2/models/installment_model.dart';
import 'package:hasan2/utils/date_picker.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:iconsax/iconsax.dart';

class EditDebtScreen extends StatefulWidget {
  late Debt debt;

  EditDebtScreen({super.key, required this.debt});

  @override
  State<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends State<EditDebtScreen> {
  final DebtController debtController = Get.find();

  late TextEditingController personNameController;
  late TextEditingController totalAmountController;
  late TextEditingController noteController;
  late TextEditingController phoneNumberController;
  late DateTime startDate;
  late List<Installment> installments;

  @override
  void initState() {
    super.initState();
    personNameController = TextEditingController(text: widget.debt.personName);
    totalAmountController = TextEditingController(text: formatPrice(widget.debt.totalAmount));
    noteController = TextEditingController(text: widget.debt.note);
    phoneNumberController = TextEditingController(text: widget.debt.phoneNumber);
    startDate = widget.debt.startDate;
    installments = List.from(widget.debt.installments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<DebtController>(
      builder: (debtController) {
        widget.debt = debtController.debts.firstWhere((item) => item.id == widget.debt.id);
        return Scaffold(
          appBar: CustomAppBar(title: "تعديل الدين", isBackButtonVisible: true),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: ListView(
                children: [
                  _buildHeaderCard(theme),
                  SizedBox(height: 2.h),
                  GetBuilder<DebtController>(
                    builder: (controller) {
                      return Column(
                        children: [
                          CustomButton(
                            onTap: () {
                                final updatedDebt = Debt(
                                  id: widget.debt.id,
                                  personName: personNameController.text,
                                  totalAmount: double.parse(totalAmountController.text.replaceAll(",", '')),
                                  startDate: startDate,
                                  installments: installments,
                                  isFinished: widget.debt.isFinished,
                                  endDate: widget.debt.endDate,
                                  note: noteController.text,
                                  phoneNumber: phoneNumberController.text,
                                );
                                controller.updateDebt(updatedDebt);

                            },
                            title: "حفظ التعديلات",
                            loading: controller.isEditDebtLoading,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(height: 1.h),

                          CustomButton(
                            onTap: () {
                              if (widget.debt.isFinished) {
                                controller.resumeDebt(widget.debt.id!);
                              } else {
                                controller.finishDebt(widget.debt.id!);
                              }
                            },
                            title: widget.debt.isFinished ? "استئناف الدين" : "إنهاء الدين",
                            loading: controller.isFinishDebtLoading,
                            color: widget.debt.isFinished ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).cardColor, width: 2),
      ),
      child: Column(
        children: [
          _buildField(label: "اسم الشخص", controller: personNameController, validator: (val) => val!.isEmpty ? "الرجاء إدخال الاسم" : null),
          SizedBox(height: 2.h),
          _buildField(
            label: "المبلغ الكلي",
            controller: totalAmountController,
            keyboardType: TextInputType.number,
            validator: (val) => val!.isEmpty ? "الرجاء إدخال المبلغ" : null,
          ),
          SizedBox(height: 2.h),
          _buildField(
            label: "رقم الهاتف",
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            validator: (val) => val!.isEmpty ? "الرجاء إدخال رقم الهاتف" : null,
          ),
          SizedBox(height: 2.h),
          _buildField(
            label: "ملاحظة",
            controller: noteController,
            maxLines: 3,
            validator: (val) => val!.isEmpty ? "الرجاء إدخال الملاحظة" : null,
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () async {
              final picked = await selectDate(context);
              if (picked != null) {
                setState(() => startDate = picked);
              }
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
                      CustomText(text: "تاريخ البداية", fontSize: 4.5, color: theme.colorScheme.secondary),
                      CustomText(
                        text: startDate.toLocal().toString().split(' ')[0],
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
          if (widget.debt.isFinished && widget.debt.endDate != null) ...[
            SizedBox(height: 2.h),
            Container(
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
                      CustomText(text: "تاريخ الانتهاء", fontSize: 4.5, color: theme.colorScheme.secondary),
                      CustomText(
                        text: widget.debt.endDate!.toLocal().toString().split(' ')[0],
                        fontSize: 5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return CustomField(
      controller: controller, 
      labelText: label, 
      keyboardType: keyboardType, 
      validator: validator,
      maxLines: maxLines,
    );
  }
}
