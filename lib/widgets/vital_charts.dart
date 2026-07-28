import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

class AdherenceBarChart extends StatelessWidget {
  final Map<String, double> data;
  final double height;

  const AdherenceBarChart({
    super.key,
    required this.data,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${entries[groupIndex].key}\n${rod.toY.toStringAsFixed(0)}%',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == 50 || value == 100) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox();
                  }
                  final label = entries[index].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label.length > 3 ? label.substring(0, 3) : label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderLight,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final color = _barColor(e.value);
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: color,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _barColor(double value) {
    if (value >= 80) return AppColors.accent;
    if (value >= 50) return AppColors.warning;
    return AppColors.danger;
  }
}

class AdherencePieChart extends StatelessWidget {
  final double value;
  final double size;

  const AdherencePieChart({
    super.key,
    required this.value,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = 100 - value;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.28,
              sections: [
                PieChartSectionData(
                  value: value,
                  color: _pieColor(value),
                  radius: size * 0.32,
                  showTitle: false,
                ),
                if (remaining > 0)
                  PieChartSectionData(
                    value: remaining,
                    color: AppColors.bgCard,
                    radius: size * 0.32,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${value.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w700,
                  color: _pieColor(value),
                ),
              ),
              Text(
                'Adherencia',
                style: TextStyle(
                  fontSize: size * 0.08,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _pieColor(double value) {
    if (value >= 80) return AppColors.accent;
    if (value >= 50) return AppColors.warning;
    return AppColors.danger;
  }
}

class AdherenceTrendLine extends StatelessWidget {
  final List<double> data;
  final double height;

  const AdherenceTrendLine({
    super.key,
    required this.data,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderLight,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == 50 || value == 100) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                  final dayIndex = (DateTime.now().weekday - 1 - (data.length - 1 - index)) % 7;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[dayIndex.abs()],
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(0)}%',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
