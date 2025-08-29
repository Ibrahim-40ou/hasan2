import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/theme/colors.dart';
import 'package:hasan2/utils/widgets/button.dart';
import 'package:hasan2/utils/widgets/text_widget.dart';
import 'package:hasan2/utils/date_picker.dart';
import 'package:hasan2/utils/helpers/price_formatter.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/statistics_controller.dart';
import '../../utils/widgets/app_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticsController _statisticsController;

  @override
  void initState() {
    super.initState();
    _statisticsController = Get.find<StatisticsController>();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _statisticsController.setTimePeriod(TimePeriod.values[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _statisticsController.fetchTransactions();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "إحصائيات المبيعات", isBackButtonVisible: false),
      body: GetBuilder<StatisticsController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: controller.fetchTransactions,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildHeaderSection(controller),
                  SizedBox(height: 2.h),
                  _buildStatisticsCards(controller),
                  SizedBox(height: 2.h),
                  _buildTimePeriodNavigation(),
                  SizedBox(height: 2.h),
                  _buildContentSection(controller),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentSection(StatisticsController controller) {
    if (controller.isTransactionsLoading) return _buildSkeletonLoading();
    if (controller.isTransactionsError) return _buildErrorState(controller);
    if (controller.transactions.isEmpty) return _buildEmptyState();
    return _buildChartsSection(controller);
  }

  Widget _buildHeaderSection(StatisticsController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: "لوحة الإحصائيات", fontSize: 6, fontWeight: FontWeight.bold, color: Colors.white),
                  SizedBox(height: 0.5.h),
                  CustomText(text: "تتبع أداء مبيعاتك وأرباحك", fontSize: 4, color: Colors.white.withAlpha(230)),
                ],
              ),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(10)),
                child: Icon(Iconsax.chart_square, color: Colors.white, size: 6.w),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(child: _buildQuickStat("إجمالي المبيعات", "${controller.getFormattedSales()} ", Iconsax.money_recive)),
              SizedBox(width: 3.w),
              Expanded(child: _buildQuickStat("صافي الربح", "${controller.getFormattedProfit()} ", Iconsax.chart_success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(51), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 4.w),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomText(text: title, fontSize: 3.5, color: Colors.white.withAlpha(230), textAlign: TextAlign.start),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          CustomText(text: value, fontSize: 4.5, fontWeight: FontWeight.bold, color: Colors.white, textAlign: TextAlign.start),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(StatisticsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "إحصائيات مفصلة", fontSize: 5.5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                iconData: Iconsax.receipt_item,
                title: "عدد المعاملات",
                value: controller.getFormattedTransactions(),
                subtitle: "معاملة",
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildInfoCard(
                iconData: Iconsax.trend_up,
                title: "متوسط قيمة الطلب",
                value: controller.getFormattedAverageOrderValue(),
                subtitle: "د.",
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData iconData,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: color.withAlpha(51), width: 1.5),
        boxShadow: [BoxShadow(color: color.withAlpha(26), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                child: Icon(iconData, size: 5.w, color: color),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomText(text: title, fontSize: 4, fontWeight: FontWeight.w600, textAlign: TextAlign.start, maxLines: 2),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(text: value, fontSize: 6, fontWeight: FontWeight.bold, color: color, textAlign: TextAlign.start),
              SizedBox(width: 1.w),
              CustomText(text: subtitle, fontSize: 3.5, color: Theme.of(context).colorScheme.secondary, textAlign: TextAlign.start),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodNavigation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "الفترة الزمنية", fontSize: 5.5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
        SizedBox(height: 2.h),
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(26), width: 1),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)]),
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withAlpha(51), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 3.5.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 3.5.sp, fontWeight: FontWeight.w500),
            labelPadding: EdgeInsets.symmetric(horizontal: 1.w),
            dividerHeight: 0,
            tabs: TimePeriod.values.asMap().entries.map((entry) {
              final index = entry.key;
              final period = entry.value;
              final isSelected = _tabController.index == index;

              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTimePeriodIcon(period),
                      size: 3.5.w,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(width: 1.w),
                    Flexible(
                      child: CustomText(
                        text: _statisticsController.getTimePeriodName(period),
                        fontSize: 3.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 2.h),
        _buildCustomDatePicker(),
      ],
    );
  }

  Widget _buildCustomDatePicker() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor.withAlpha(51), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.calendar_tick,
                  size: 4.w,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomText(
                  text: "اختيار فترة مخصصة",
                  fontSize: 4.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectCustomDateRange(context),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          size: 4.w,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 2.w),
                        CustomText(
                          text: "اختيار التاريخ",
                          fontSize: 3.5,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              if (_statisticsController.isCustomDateSelected)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _statisticsController.clearCustomDateSelection(),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error.withAlpha(51),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.close_circle,
                            size: 4.w,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(width: 2.w),
                          CustomText(
                            text: "إلغاء",
                            fontSize: 3.5,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_statisticsController.isCustomDateSelected && 
              _statisticsController.customStartDate != null && 
              _statisticsController.customEndDate != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withAlpha(26),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 4.w,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: CustomText(
                      text: "الفترة المحددة: من ${_formatDate(_statisticsController.customStartDate!)} إلى ${_formatDate(_statisticsController.customEndDate!)}",
                      fontSize: 3.5,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _selectCustomDateRange(BuildContext context) async {
    final DateTime? startDate = await selectDate(context);
    if (startDate != null) {
      final DateTime? endDate = await selectDate(context);
      if (endDate != null) {
        if (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
          _statisticsController.setCustomDateRange(startDate, endDate);
        } else {
          // Show error if start date is after end date
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: "يجب أن يكون تاريخ البداية قبل تاريخ النهاية",
                color: Colors.white,
                fontSize: 4,
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  IconData _getTimePeriodIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.daily:
        return Iconsax.calendar_1;
      case TimePeriod.weekly:
        return Iconsax.calendar_2;
      case TimePeriod.monthly:
        return Iconsax.calendar;
      case TimePeriod.yearly:
        return Iconsax.calendar_tick;
    }
  }

  Widget _buildSkeletonLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "الرسوم البيانية", fontSize: 5.5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
        SizedBox(height: 2.h),
        _buildChartSkeleton(),
        SizedBox(height: 2.h),
        _buildChartSkeleton(),
        SizedBox(height: 2.h),
        _buildPerformanceOverviewSkeleton(),
      ],
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(26), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                width: 30.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 25.h,
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverviewSkeleton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(26), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 2.5.h,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withAlpha(51), borderRadius: BorderRadius.circular(4)),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Container(
                  height: 15.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(StatisticsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: "الرسوم البيانية", fontSize: 5.5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
        SizedBox(height: 1.h),
        // Add axis information
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor.withAlpha(51), width: 1),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, size: 4.w, color: Theme.of(context).primaryColor),
              SizedBox(width: 2.w),
              Expanded(
                child: CustomText(
                  text: controller.getChartAxisInfo(),
                  fontSize: 3.5,
                  color: Theme.of(context).primaryColor,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        _buildChart(
          title: "مخطط المبيعات",
          subtitle: "تتبع حجم المبيعات عبر الفترة المحددة",
          data: controller.salesVolumeData,
          labels: controller.chartLabels,
          color: Theme.of(context).primaryColor,
          icon: Iconsax.money_recive,
          yAxisLabel: "المبيعات",
        ),
        SizedBox(height: 3.h),
        _buildChart(
          title: "مخطط الأرباح",
          subtitle: "تتبع صافي الأرباح عبر الفترة المحددة",
          data: controller.profitData,
          labels: controller.chartLabels,
          color: AppColors.success,
          icon: Iconsax.chart_success,
          yAxisLabel: "الأرباح",
        ),
        SizedBox(height: 3.h),
        _buildPerformanceOverview(controller),
      ],
    );
  }

  Widget _buildChart({
    required String title,
    required String subtitle,
    required List<FlSpot> data,
    required List<String> labels,
    required Color color,
    required IconData icon,
    required String yAxisLabel,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: color.withAlpha(51), width: 1.5),
        boxShadow: [BoxShadow(color: color.withAlpha(26), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 5.w, color: color),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: title, fontSize: 5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
                    SizedBox(height: 0.5.h),
                    CustomText(text: subtitle, fontSize: 3.5, color: Theme.of(context).colorScheme.secondary, textAlign: TextAlign.start),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Y-axis label
          Row(
            children: [
              Icon(Iconsax.arrow_up_2, size: 3.w, color: Theme.of(context).colorScheme.secondary),
              SizedBox(width: 1.w),
              CustomText(text: yAxisLabel, fontSize: 3, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 30.h,
            child: data.isEmpty
                ? _buildNoDataMessage("لا توجد بيانات للعرض")
                : data.length > 50
                ? _buildNoDataMessage("بيانات كثيرة جداً للعرض")
                : _buildLineChart(data, labels, color),
          ),
          SizedBox(height: 1.h),
          // X-axis label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.arrow_right_3, size: 3.w, color: Theme.of(context).colorScheme.secondary),
              SizedBox(width: 1.w),
              CustomText(text: _getXAxisLabel(), fontSize: 3, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500),
            ],
          ),
        ],
      ),
    );
  }

  String _getXAxisLabel() {
    switch (_statisticsController.selectedTimePeriod) {
      case TimePeriod.daily:
        return "الأيام";
      case TimePeriod.weekly:
        return "الأسابيع";
      case TimePeriod.monthly:
        return "الأشهر";
      case TimePeriod.yearly:
        return "السنوات";
    }
  }

  Widget _buildLineChart(List<FlSpot> data, List<String> labels, Color color) {
    try {
      final safeData = data.where((spot) => spot.x.isFinite && spot.y.isFinite && spot.x >= 0 && spot.y >= 0).toList();

      if (safeData.isEmpty) {
        return _buildNoDataMessage("لا توجد بيانات صالحة");
      }

      final maxY = safeData.map((spot) => spot.y).reduce(math.max);
      final minY = safeData.map((spot) => spot.y).reduce(math.min);
      final safeMaxY = maxY.isFinite && maxY > 0 ? maxY * 1.1 : 100.0;
      final safeMinY = minY.isFinite && minY >= 0 ? math.max(0, minY * 0.9) : 0.0;

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: safeData.length > 1 ? 1 : null,
            horizontalInterval: (safeMaxY - safeMinY) / 4,
            getDrawingVerticalLine: (value) {
              return FlLine(color: Theme.of(context).colorScheme.secondary.withAlpha(13), strokeWidth: 1, dashArray: [3, 3]);
            },
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Theme.of(context).colorScheme.secondary.withAlpha(26), strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (safeMaxY - safeMinY) / 4,
                getTitlesWidget: (value, meta) {
                  if (value >= 1000) {
                    return CustomText(
                      text: '${(value / 1000).toStringAsFixed(1)}k',
                      fontSize: 2.5,
                      color: Theme.of(context).colorScheme.secondary,
                    );
                  }
                  return CustomText(text: value.toInt().toString(), fontSize: 2.5, color: Theme.of(context).colorScheme.secondary);
                },
                reservedSize: 12.w,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: math.max(1, (safeData.length / 5).ceil().toDouble()),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: CustomText(
                        text: labels[index],
                        fontSize: 2.5,
                        color: Theme.of(context).colorScheme.secondary,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 5.h,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(51), width: 1.5),
              left: BorderSide(color: Theme.of(context).colorScheme.secondary.withAlpha(51), width: 1.5),
            ),
          ),
          minX: 0,
          maxX: math.max(0, (safeData.length - 1).toDouble()),
          minY: safeMinY.toDouble(),
          maxY: safeMaxY,
          lineBarsData: [
            LineChartBarData(
              spots: safeData,
              isCurved: true,
              curveSmoothness: 0.35,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2, strokeColor: Colors.white);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withAlpha(77), color.withAlpha(13)],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: EdgeInsets.all(2.w),
              // tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  final label = index < labels.length ? labels[index] : '';
                  return LineTooltipItem(
                    '$label\n${formatPrice(barSpot.y)} ',
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 3.sp, fontFamily: 'Cairo'),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      );
    } catch (e) {
      dev.log('Error building chart: $e');
      return _buildNoDataMessage("خطأ في عرض الرسم البياني");
    }
  }

  Widget _buildNoDataMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.chart_21, size: 8.w, color: Theme.of(context).colorScheme.secondary.withAlpha(128)),
          SizedBox(height: 2.h),
          CustomText(text: message, fontSize: 4, color: Theme.of(context).colorScheme.secondary.withAlpha(179)),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(StatisticsController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(26), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.chart_square, size: 5.w, color: Theme.of(context).primaryColor),
              SizedBox(width: 2.w),
              CustomText(text: "نظرة عامة على الأداء", fontSize: 5, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(child: _buildPerformanceMetric("معدل النمو", "+12.5%", Iconsax.trend_up, AppColors.success)),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildPerformanceMetric(
                  "هامش الربح",
                  "${controller.totalSales > 0 ? ((controller.totalProfit / controller.totalSales) * 100).toStringAsFixed(1) : '0.0'}%",
                  Iconsax.percentage_circle,
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 6.w, color: color),
          SizedBox(height: 1.h),
          CustomText(text: value, fontSize: 5, fontWeight: FontWeight.bold, color: color),
          SizedBox(height: 0.5.h),
          CustomText(text: title, fontSize: 3.5, color: Theme.of(context).colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _buildErrorState(StatisticsController controller) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppColors.error.withAlpha(51), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(color: AppColors.error.withAlpha(26), borderRadius: BorderRadius.circular(50)),
            child: Icon(Iconsax.warning_2, size: 12.w, color: AppColors.error),
          ),
          SizedBox(height: 3.h),
          CustomText(text: "حدث خطأ في تحميل الإحصائيات", fontSize: 5.5, fontWeight: FontWeight.bold),
          SizedBox(height: 1.h),
          CustomText(
            text: "تعذر علينا مواجهة مشكلة في تحميل بيانات الإحصائيات",
            fontSize: 4,
            color: Theme.of(context).colorScheme.secondary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          CustomButton(
            title: "محاولة مرة أخرى",
            onTap: controller.fetchTransactions,
            width: 60,
            color: AppColors.error,
            verticalPadding: 1.5,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.info_circle, size: 4.w, color: Theme.of(context).colorScheme.secondary),
              SizedBox(width: 1.w),
              CustomText(text: "تأكد من اتصالك بالإنترنت", fontSize: 3.5, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withAlpha(26), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(26), borderRadius: BorderRadius.circular(50)),
              child: Icon(Iconsax.chart_21, size: 15.w, color: Theme.of(context).primaryColor),
            ),
            SizedBox(height: 4.h),
            CustomText(text: "لا توجد معاملات بعد", fontSize: 6, fontWeight: FontWeight.bold),
            SizedBox(height: 2.h),
            CustomText(
              text: "ابدأ ببيع المنتجات لرؤية إحصائيات مفصلة",
              fontSize: 4.5,
              color: Theme.of(context).colorScheme.secondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            CustomText(
              text: "ورسوم بيانية تفاعلية لأدائك",
              fontSize: 4,
              color: Theme.of(context).colorScheme.secondary.withAlpha(204),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).primaryColor.withAlpha(51), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.info_circle, size: 4.w, color: Theme.of(context).primaryColor),
                  SizedBox(width: 2.w),
                  CustomText(
                    text: "ستظهر الإحصائيات بعد أول عملية بيع",
                    fontSize: 3.5,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
