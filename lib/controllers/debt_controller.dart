import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hasan2/models/debt_model.dart';
import 'package:hasan2/utils/helpers/firebase_consumer.dart';

import '../../utils/error.dart';
import '../models/installment_model.dart';

class DebtController extends GetxController {
  final FirebaseConsumer _firebaseConsumer = FirebaseConsumer();

  @override
  void onInit() async {
    super.onInit();
    await fetchDebts();
  }

  List<Debt> debts = [];
  bool isDebtsFetchingError = false;
  bool isDebtsFetchingLoading = false;
  bool isAddDebtLoading = false;
  bool isEditDebtLoading = false;
  bool isFinishDebtLoading = false;
  bool isAddInstallmentLoading = false;
  bool isEditInstallmentLoading = false;
  bool isDeleteInstallmentLoading = false;
  bool isLoadingMoreDebts = false;
  bool isDeleteDebtLoading = false;

  Future<void> addDebt(Debt debt) async {
    try {
      isAddDebtLoading = true;
      update();

      final result = await _firebaseConsumer.addDocument(collectionPath: "debts", data: debt.toJson());

      if (result.isSuccess && result.data != null) {
        final docID = result.data!;
        await _firebaseConsumer.updateDocument(path: "debts/$docID", data: {"id": docID});
        debts.add(
          Debt(
            id: docID,
            personName: debt.personName,
            totalAmount: debt.totalAmount,
            startDate: debt.startDate,
            installments: debt.installments,
            note: debt.note,
            phoneNumber: debt.phoneNumber,
          ),
        );
        showSnackBar("تم اضافة الدين بنجاح");
        Get.back();
      } else {
        log("=== Error while adding debt: ${result.error!}");
        showError("حث خطأ اثناء اضافة الدين");
      }
    } on Exception catch (e) {
      showError("حث خطأ غير متوقع اثناء اضافة الدين");
      log("=== Exception while adding debt: $e");
    } finally {
      isAddDebtLoading = false;
      update();
    }
  }

  Future<void> fetchDebts({bool getNextPage = false, bool resetPagination = false}) async {
    if (getNextPage && !_firebaseConsumer.hasMoreData("debts")) return;

    if (!getNextPage || resetPagination) {
      isDebtsFetchingLoading = true;
    }

    isDebtsFetchingError = false;
    update();

    try {
      final result = await _firebaseConsumer.getCollection(
        path: "debts",
        limit: 20,
        getNextPage: getNextPage,
        resetPagination: resetPagination,
      );

      if (result.isSuccess && result.data != null) {
        final fetchedDebts = result.data!.map((data) => Debt.fromJson(data, data['id'])).toList();

        if (getNextPage && !resetPagination) {
          debts.addAll(fetchedDebts);
        } else {
          debts = fetchedDebts;
        }

        isDebtsFetchingError = false;
      } else {
        if (!getNextPage) {
          debts.clear();
        }
        log("=== Error fetching debts: ${result.error}");
        showError("حدث خطأ أثناء تحميل الديون");
        isDebtsFetchingError = true;
      }
    } on Exception catch (e) {
      log("=== Exception while fetching debts: $e");
      if (!getNextPage) {
        debts.clear();
      }
      showError("حدث خطأ غير متوقع اثناء تحميل الديون");
      isDebtsFetchingError = true;
    } finally {
      isDebtsFetchingLoading = false;
      update();
    }
  }

  Future<void> loadMoreDebts() async {
    if (isLoadingMoreDebts || !_firebaseConsumer.hasMoreData("debts")) return;

    isLoadingMoreDebts = true;
    update();

    try {
      await fetchDebts(getNextPage: true);
    } finally {
      isLoadingMoreDebts = false;
      update();
    }
  }

  Future<void> updateDebt(Debt debt) async {
    try {
      isEditDebtLoading = true;
      update();
      final updateResult = await _firebaseConsumer.updateDocument(path: "debts/${debt.id}", data: debt.toJson());

      if (updateResult.isSuccess) {
        final index = debts.indexWhere((d) => d.id == debt.id);
        if (index != -1) {
          debts[index] = debt;
        }
        showSnackBar("تم تعديل الدين بنجاح");
        Get.back();
      } else {
        showError("حث خطأ اثناء تعديل الدين");
      }
    } catch (e) {
      log("=== Exception while editing debt: $e");
      showError("حدث خطأ غير متوقع أثناء تعديل الدين");
    } finally {
      isEditDebtLoading = false;
      update();
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      isDeleteDebtLoading = true;
      update();

      final result = await _firebaseConsumer.deleteDocument(path: "debts/$debtId");

      if (result.isSuccess) {
        final index = debts.indexWhere((debt) => debt.id == debtId);
        if (index != -1) {
          debts.removeAt(index);
        }
        showSnackBar("تم حذف الدين بنجاح");
        Get.back();
      } else {
        log("=== Error while deleting debt: ${result.error!}");
        showError("حدث خطأ اثناء حذف الدين");
      }
    } on Exception catch (e) {
      showError("حدث خطأ غير متوقع اثناء حذف الدين");
      log("=== Exception while deleting debt: $e");
    } finally {
      isDeleteDebtLoading = false;
      update();
    }
  }

  Future<void> finishDebt(String debtId) async {
    try {
      isFinishDebtLoading = true;
      update();
      final endDate = DateTime.now();
      final result = await _firebaseConsumer.updateDocument(
        path: "debts/$debtId",
        data: {"isFinished": true, "endDate": Timestamp.fromDate(endDate)},
      );

      if (result.isSuccess) {
        final index = debts.indexWhere((d) => d.id == debtId);
        if (index != -1) {
          // Create a new Debt object with isFinished set to true
          final finishedDebt = Debt(
            id: debts[index].id,
            personName: debts[index].personName,
            totalAmount: debts[index].totalAmount,
            startDate: debts[index].startDate,
            installments: debts[index].installments,
            isFinished: true,
            endDate: endDate,
            note: debts[index].note,
            phoneNumber: debts[index].phoneNumber,
          );
          debts[index] = finishedDebt; // Replace the old debt with the new one
        }
        showSnackBar("تم إنهاء الدين بنجاح");
      } else {
        showError("حث خطأ اثناء إنهاء الدين");
      }
    } catch (e) {
      log("=== Exception while finishing debt: $e");
      showError("حدث خطأ غير متوقع أثناء إنهاء الدين");
    } finally {
      isFinishDebtLoading = false;
      update();
    }
  }

  Future<void> resumeDebt(String debtId) async {
    try {
      isFinishDebtLoading = true;
      update();

      final result = await _firebaseConsumer.updateDocument(path: "debts/$debtId", data: {"isFinished": false, "endDate": null});

      if (result.isSuccess) {
        final index = debts.indexWhere((d) => d.id == debtId);
        if (index != -1) {
          final resumedDebt = Debt(
            id: debts[index].id,
            personName: debts[index].personName,
            totalAmount: debts[index].totalAmount,
            startDate: debts[index].startDate,
            installments: debts[index].installments,
            isFinished: false,
            endDate: null,
            note: debts[index].note,
            phoneNumber: debts[index].phoneNumber,
          );
          debts[index] = resumedDebt;
        }
        showSnackBar("تم استئناف الدين بنجاح");
      } else {
        showError("حدث خطأ اثناء استئناف الدين");
      }
    } catch (e) {
      log("=== Exception while resuming debt: $e");
      showError("حدث خطأ غير متوقع أثناء استئناف الدين");
    } finally {
      isFinishDebtLoading = false;
      update();
    }
  }

  Future<void> addInstallment(String debtId, Installment installment) async {
    try {
      isAddInstallmentLoading = true;
      update();

      final debtIndex = debts.indexWhere((debt) => debt.id == debtId);
      if (debtIndex == -1) {
        showError("الدين غير موجود");
        return;
      }

      final updatedInstallments = List<Installment>.from(debts[debtIndex].installments)..add(installment);

      final result = await _firebaseConsumer.updateDocument(
        path: "debts/$debtId",
        data: {"installments": updatedInstallments.map((e) => e.toJson()).toList()},
      );

      if (result.isSuccess) {
        debts[debtIndex] = debts[debtIndex].copyWith(installments: updatedInstallments);
        showSnackBar("تم اضافة القسط بنجاح");
      } else {
        log("=== Error while adding installment: ${result.error!}");
        showError("حدث خطأ اثناء اضافة القسط");
      }
    } on Exception catch (e) {
      showError("حدث خطأ غير متوقع اثناء اضافة القسط");
      log("=== Exception while adding installment: $e");
    } finally {
      isAddInstallmentLoading = false;
      update();
    }
  }

  Future<void> updateInstallment(String debtId, int installmentIndex, Installment updatedInstallment) async {
    try {
      isEditInstallmentLoading = true;
      update();

      final debtIndex = debts.indexWhere((debt) => debt.id == debtId);
      if (debtIndex == -1) {
        showError("الدين غير موجود");
        return;
      }

      final currentInstallments = List<Installment>.from(debts[debtIndex].installments);
      if (installmentIndex < 0 || installmentIndex >= currentInstallments.length) {
        showError("القسط غير موجود");
        return;
      }

      currentInstallments[installmentIndex] = updatedInstallment;

      final result = await _firebaseConsumer.updateDocument(
        path: "debts/$debtId",
        data: {"installments": currentInstallments.map((e) => e.toJson()).toList()},
      );

      if (result.isSuccess) {
        debts[debtIndex] = debts[debtIndex].copyWith(installments: currentInstallments);
        showSnackBar("تم تعديل القسط بنجاح");
      } else {
        log("=== Error while updating installment: ${result.error!}");
        showError("حدث خطأ اثناء تعديل القسط");
      }
    } on Exception catch (e) {
      showError("حدث خطأ غير متوقع اثناء تعديل القسط");
      log("=== Exception while updating installment: $e");
    } finally {
      isEditInstallmentLoading = false;
      update();
    }
  }

  Future<void> deleteInstallment(String debtId, int installmentIndex) async {
    try {
      isDeleteInstallmentLoading = true;
      update();

      final debtIndex = debts.indexWhere((debt) => debt.id == debtId);
      if (debtIndex == -1) {
        showError("الدين غير موجود");
        return;
      }

      final currentInstallments = List<Installment>.from(debts[debtIndex].installments);
      if (installmentIndex < 0 || installmentIndex >= currentInstallments.length) {
        showError("القسط غير موجود");
        return;
      }

      currentInstallments.removeAt(installmentIndex);

      final result = await _firebaseConsumer.updateDocument(
        path: "debts/$debtId",
        data: {"installments": currentInstallments.map((e) => e.toJson()).toList()},
      );

      if (result.isSuccess) {
        debts[debtIndex] = debts[debtIndex].copyWith(installments: currentInstallments);
        showSnackBar("تم حذف القسط بنجاح");
      } else {
        log("=== Error while deleting installment: ${result.error!}");
        showError("حدث خطأ اثناء حذف القسط");
      }
    } on Exception catch (e) {
      showError("حدث خطأ غير متوقع اثناء حذف القسط");
      log("=== Exception while deleting installment: $e");
    } finally {
      isDeleteInstallmentLoading = false;
      update();
    }
  }
}
