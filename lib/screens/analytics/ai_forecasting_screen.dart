import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class AiForecastingScreen extends StatefulWidget {
  const AiForecastingScreen({super.key});

  @override
  State<AiForecastingScreen> createState() => _AiForecastingScreenState();
}

class _AiForecastingScreenState extends State<AiForecastingScreen> {
  double _summerHeatIndexMultiplier = 1.25; // 1.0x to 1.6x

  final List<Map<String, dynamic>> _forecastItems = [
    {
      'flavor': 'Alphonso Mango Nectar',
      'currentSales': 4800,
      'projectedBottles': 6250,
      'confidence': 94,
      'rawFruitNeeded': '3.2 Tons Ripe Mango',
      'urgency': 'HIGH DEMAND',
      'color': Color(0xFFD97706),
    },
    {
      'flavor': 'Nagpur Orange Fresh',
      'currentSales': 3200,
      'projectedBottles': 4100,
      'confidence': 91,
      'rawFruitNeeded': '2.1 Tons Citrus Orange',
      'urgency': 'NORMAL',
      'color': Color(0xFFEA580C),
    },
    {
      'flavor': 'Shimla Apple Crisp',
      'currentSales': 2400,
      'projectedBottles': 2750,
      'confidence': 88,
      'rawFruitNeeded': '1.4 Tons Apple',
      'urgency': 'STEADY',
      'color': Color(0xFFDC2626),
    },
    {
      'flavor': 'Queen Pineapple Zing',
      'currentSales': 1900,
      'projectedBottles': 2400,
      'confidence': 86,
      'rawFruitNeeded': '1.2 Tons Pineapple',
      'urgency': 'NORMAL',
      'color': Color(0xFFEAB308),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Demand & Seasonality Engine'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI Engine Overview Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Predictive Demand Model',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        '92.4% Accuracy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Historical 365-day factory sales correlated with regional weather telemetry (36°C ambient heat) & retail stock-out velocity.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seasonality Heat Wave Simulator Slider
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seasonality & Ambient Temperature Index',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(_summerHeatIndexMultiplier * 100).round()}% Surge',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Slider(
                  value: _summerHeatIndexMultiplier,
                  min: 1.0,
                  max: 1.6,
                  divisions: 6,
                  activeColor: const Color(0xFF6366F1),
                  inactiveColor: Colors.grey.withOpacity(0.2),
                  onChanged: (val) {
                    setState(() {
                      _summerHeatIndexMultiplier = val;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Standard (28°C)',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    Text('Peak Heat Wave (41°C)',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Demand Projection Bar Chart
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next 4 Weeks Projected Volume (Bottles)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Blue: Baseline Sales • Violet: AI Projected with Weather Impact',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (context) {
                    double maxSales = 4000.0;
                    for (final item in _forecastItems) {
                      final p = (item['currentSales'] as num).toDouble() * _summerHeatIndexMultiplier;
                      if (p > maxSales) maxSales = p;
                    }
                    final chartMaxY = (maxSales * 1.25).clamp(6000.0, 50000.0);

                    return SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: chartMaxY,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1E293B),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final fruit = _forecastItems[group.x]['name'] as String;
                                final isProjected = rodIndex == 1;
                                return BarTooltipItem(
                                  '$fruit\n',
                                  const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: '${isProjected ? "Projected" : "Base"}: ${rod.toY.toInt()} L',
                                      style: TextStyle(
                                        color: isProjected ? const Color(0xFF818CF8) : Colors.lightBlueAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (val, _) {
                                  switch (val.toInt()) {
                                    case 0:
                                      return const Text('Mango', style: TextStyle(fontSize: 10));
                                    case 1:
                                      return const Text('Orange', style: TextStyle(fontSize: 10));
                                    case 2:
                                      return const Text('Apple', style: TextStyle(fontSize: 10));
                                    case 3:
                                      return const Text('Pineapple', style: TextStyle(fontSize: 10));
                                    default:
                                      return const Text('');
                                  }
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                getTitlesWidget: (v, _) =>
                                    Text('${(v / 1000).toInt()}k', style: const TextStyle(fontSize: 9)),
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_forecastItems.length, (idx) {
                        final item = _forecastItems[idx];
                        final base = (item['currentSales'] as num).toDouble();
                        final projected = base * _summerHeatIndexMultiplier;
                        return BarChartGroupData(
                          x: idx,
                          barRods: [
                            BarChartRodData(
                              toY: base,
                              color: Colors.blue.shade300,
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            BarChartRodData(
                              toY: projected,
                              color: const Color(0xFF6366F1),
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Recommended Fruit Procurement Actions
          const Text(
            'Raw Fruit Procurement Recommendations',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._forecastItems.map((item) {
            final projected =
                ((item['projectedBottles'] as num) * _summerHeatIndexMultiplier).round();
            final isUrgent = item['urgency'] == 'HIGH DEMAND';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUrgent
                      ? Colors.amber.shade700.withOpacity(0.6)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_florist_rounded,
                        color: item['color'] as Color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['flavor'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isUrgent ? Colors.amber.shade800 : Colors.green.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['urgency'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plan: $projected bottles (${item['rawFruitNeeded']})',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
