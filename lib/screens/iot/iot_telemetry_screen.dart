import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class IotTelemetryScreen extends StatefulWidget {
  const IotTelemetryScreen({super.key});

  @override
  State<IotTelemetryScreen> createState() => _IotTelemetryScreenState();
}

class _IotTelemetryScreenState extends State<IotTelemetryScreen> {
  Timer? _telemetryTimer;
  bool _isAutoStreamActive = true;

  // Live IoT telemetry states
  double _htstPasteurizerTemp = 74.2; // Target: 72°C - 78°C
  double _coldStorageVatTemp = 3.6; // Target: 2°C - 4°C
  int _agitatorRpm = 420; // Target: 380 - 450 RPM
  double _flowRateLpm = 52.8; // Target: 45 - 60 L/min
  double _homogenizerPressureBar = 175.0; // Target: 160 - 200 bar
  final int _currentVatVolumeLiters = 4250; // Max 5000L

  final List<double> _tempHistory = [73.5, 73.8, 74.1, 74.0, 74.5, 74.2, 74.4];

  @override
  void initState() {
    super.initState();
    _startTelemetryStream();
  }

  void _startTelemetryStream() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isAutoStreamActive || !mounted) return;
      final rng = math.Random();
      setState(() {
        _htstPasteurizerTemp = (73.5 + rng.nextDouble() * 1.6);
        _coldStorageVatTemp = (3.2 + rng.nextDouble() * 0.9);
        _agitatorRpm = (410 + rng.nextInt(25));
        _flowRateLpm = (50.0 + rng.nextDouble() * 5.0);
        _homogenizerPressureBar = (170.0 + rng.nextDouble() * 12.0);

        _tempHistory.add(_htstPasteurizerTemp);
        if (_tempHistory.length > 10) _tempHistory.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Factory Telemetry'),
        actions: [
          IconButton(
            icon: Icon(
              _isAutoStreamActive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: _isAutoStreamActive ? AppColors.secondary : Colors.grey,
            ),
            tooltip: _isAutoStreamActive ? 'Live Stream Active' : 'Stream Paused',
            onPressed: () {
              setState(() {
                _isAutoStreamActive = !_isAutoStreamActive;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Smart Vat #01 Online',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Telemetry syncing via MQTT • Chilled Nectar Line',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Gauge Cards
          Row(
            children: [
              Expanded(
                child: _sensorCard(
                  title: 'HTST Pasteurizer',
                  subtitle: 'Target: 72–78°C',
                  value: '${_htstPasteurizerTemp.toStringAsFixed(1)}°C',
                  icon: Icons.whatshot_rounded,
                  color: const Color(0xFFEA580C),
                  status: 'Nominal',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _sensorCard(
                  title: 'Cold Storage Vat',
                  subtitle: 'Target: 2–4°C',
                  value: '${_coldStorageVatTemp.toStringAsFixed(1)}°C',
                  icon: Icons.ac_unit_rounded,
                  color: const Color(0xFF0284C7),
                  status: 'Chilled',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _sensorCard(
                  title: 'Agitator RPM',
                  subtitle: 'Vat Impeller Speed',
                  value: '$_agitatorRpm RPM',
                  icon: Icons.sync_rounded,
                  color: const Color(0xFF16A34A),
                  status: 'Running',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _sensorCard(
                  title: 'In-line Flow Rate',
                  subtitle: 'Bottle Filling Feed',
                  value: '${_flowRateLpm.toStringAsFixed(1)} L/m',
                  icon: Icons.waves_rounded,
                  color: const Color(0xFFD97706),
                  status: 'Optimal',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Vat Level Monitor Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Blending Tank Level (Vat-01)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_currentVatVolumeLiters / 5000 L (85%)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _currentVatVolumeLiters / 5000.0,
                    minHeight: 14,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _vatSpec(label: 'Product', value: 'Mango Nectar 14.5°Bx'),
                    _vatSpec(label: 'CIP Sanitized', value: 'Today, 06:30 AM'),
                    _vatSpec(label: 'Valve Status', value: 'OPEN (Auto)'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Homogenizer Pressure Gauge Card
          CustomCard(
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
                            color: Colors.purple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.speed_rounded, color: Colors.purple, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Two-Stage Homogenizer Pressure',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${_homogenizerPressureBar.toStringAsFixed(0)} Bar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Stage 1: 150 Bar (Globule reduction) • Stage 2: 30 Bar (Anti-coalescence)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sensorCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
    required String status,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _vatSpec({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
