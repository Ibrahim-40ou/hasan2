import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/debt_controller.dart';
import 'package:hasan2/models/debt_model.dart';
import 'package:hasan2/models/installment_model.dart';
import 'package:hasan2/screens/debt/debt_details_screen.dart';
import 'package:hasan2/screens/debt/widgets/debt_card.dart';
import 'package:hasan2/utils/date_picker.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/widgets/app_bar.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/list_view.dart';
import 'package:hasan2/utils/widgets/message_widget.dart';
import 'package:hasan2/utils/widgets/shimmer.dart';
import 'package:hasan2/utils/widgets/text_form_field.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/dialog.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final DebtController controller = Get.find<DebtController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "الديون"),
      body: GetBuilder<DebtController>(
        builder: (debtController) {
          return RefreshIndicator(
            onRefresh: () => debtController.fetchDebts(),
            child: CustomListView(
              isPaginating: debtController.isLoadingMoreDebts,
              onEndReached: debtController.loadMoreDebts,
              isLoading: debtController.isDebtsFetchingLoading,
              hasError: debtController.isDebtsFetchingError,
              items: debtController.debts,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              listShimmerLoader: (context, index) => CustomShimmerContainer(height: 12.h, width: 100.w, borderRadius: 10, margin: 1.h),
              itemBuilder: (context, index) {
                final debt = debtController.debts[index];
                return DebtCard(
                  debt: debt,
                  onTap: () => Get.to(() => DebtDetailsScreen(debt: debt)),
                  onLongPress: () {
                    _deleteDebt(context, debt.id!);
                  },
                );
              },
              emptyWidget: const CustomMessageWidget(
                title: "لا توجد ديون",
                subTitle: "قم بإضافة ديون جديدة للبدء",
                iconData: Iconsax.empty_wallet,
              ),
              errorWidget: const CustomMessageWidget(
                title: "خطأ في تحميل البيانات",
                subTitle: "تحقق من الاتصال بالإنترنت ثم حاول مرة أخرى",
                iconData: Iconsax.warning_2,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDebtBottomSheet(context),
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _addDebtBottomSheet(BuildContext context) {
    final DebtController debtController = Get.find();
    final TextEditingController personNameController = TextEditingController();
    final TextEditingController totalAmountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();
    DateTime startDate = DateTime.now();
    List<Installment> installments = [];
    final key = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Form(
                    key: key,
                    child: Container(
                      width: 100.w,
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(text: "اضافة دين", fontSize: 6, fontWeight: FontWeight.w700),
                          SizedBox(height: 1.h),
                          CustomField(
                            controller: personNameController,
                            labelText: "اسم الشخص",
                            validator: (value) => value!.isEmpty ? "الرجاء ادخال الاسم" : null,
                          ),
                          SizedBox(height: 1.h),
                          CustomField(
                            controller: totalAmountController,
                            labelText: "المبلغ الكلي",
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? "الرجاء ادخال المبلغ" : null,
                          ),
                          SizedBox(height: 1.h),
                          CustomField(
                            controller: phoneNumberController,
                            labelText: "رقم الهاتف",
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty ? "الرجاء ادخال رقم الهاتف" : null,
                          ),
                          SizedBox(height: 1.h),
                          CustomField(
                            controller: noteController,
                            labelText: "ملاحظة",
                            maxLines: 3,
                            validator: (value) => value!.isEmpty ? "الرجاء ادخال الملاحظة" : null,
                          ),
                          SizedBox(height: 1.5.h),
                          GestureDetector(
                            onTap: () async {
                              final pickedDate = await selectDate(context);
                              if (pickedDate != null && pickedDate != startDate) {
                                setState(() {
                                  startDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withAlpha(50),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Iconsax.calendar_1, color: Theme.of(context).colorScheme.primary, size: 6.w),
                                  ),
                                  SizedBox(width: 2.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: "تاريخ القسط", fontSize: 4.5, color: Theme.of(context).colorScheme.secondary),
                                      CustomText(
                                        text: startDate.toLocal().toString().split(' ')[0],
                                        fontSize: 5,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 1.5.h),
                          GetBuilder<DebtController>(
                            builder: (controller) {
                              return CustomButton(
                                onTap: () {
                                  if (key.currentState!.validate()) {
                                    final newDebt = Debt(
                                      personName: personNameController.text,
                                      totalAmount: double.parse(totalAmountController.text),
                                      startDate: startDate,
                                      installments: installments,
                                      note: noteController.text,
                                      phoneNumber: phoneNumberController.text,
                                    );
                                    debtController.addDebt(newDebt);
                                  }
                                },
                                title: "اضافة",
                                loading: controller.isAddDebtLoading,
                              );
                            },
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
      },
    );
  }

  void _deleteDebt(BuildContext context, String debtID) {
    showConfirmationDialog(
      buildContext: context,
      content: 'هل أنت متأكد من حذف الدين؟',
      confirm: () async {
        await controller.deleteDebt(debtID);
      },
      reject: () {},
    );
  }
}
