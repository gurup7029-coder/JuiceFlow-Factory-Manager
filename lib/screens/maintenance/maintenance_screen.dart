import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final List<Map<String, dynamic>> _logs = [
    {
      'id': 'CIP-1042',
      'equipment': 'Pasteurizer Line #01 CIP Sanitation',
      'type': 'Sanitation',
      'frequency': 'Every 12 Hours',
      'lastCompleted': 'Today, 06:00 AM',
      'supervisor': 'R. Sundaram (QC)',
      'status': 'Compliant',
      'details': 'Caustic wash 1.5% @ 75°C (20m) followed by peracetic acid rinse.',
      'color': Colors.green,
    },
    {
      'id': 'MNT-089',
      'equipment': 'Bottle Capper Induction Sealer',
      'type': 'Calibration',
      'frequency': 'Daily Audit',
      'lastCompleted': 'Yesterday, 05:30 PM',
      'supervisor': 'M. Karthik (Maint)',
      'status': 'Compliant',
      'details': 'Head torque verified at 2.4 Nm. Zero bottle leakage in 100 test cycle.',
      'color': Colors.green,
    },
    {
      'id': 'MNT-084',
      'equipment': 'High-Pressure Homogenizer',
      'type': 'Preventative',
      'frequency': 'Weekly',
      'lastCompleted': '3 days ago',
      'supervisor': 'K. Velu (Tech)',
      'status': 'Due Soon',
      'details': 'Piston packing ring lubrication & tungsten carbide seat inspection.',
      'color': Colors.amber,
    },
    {
      'id': 'CIP-1039',
      'equipment': 'Vat #03 Blending Impeller',
      'type': 'Deep Clean',
      'frequency': 'Bi-weekly',
      'lastCompleted': '5 days ago',
      'supervisor': 'S. Meena (QC)',
      'status': 'Compliant',
      'details': 'Manual swab test ATP < 10 RLU. Ready for fresh pineapple blend.',
      'color': Colors.green,
    },
  ];

  void _showAddLogDialog() {
    final equipController = TextEditingController();
    final detailsController = TextEditingController();
    String selectedType = 'Sanitation';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Record Maintenance / CIP Log'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: equipController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment / Line Name',
                    hintText: 'e.g. Pasteurizer Vat #02',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Task Type'),
                  items: const [
                    DropdownMenuItem(value: 'Sanitation', child: Text('CIP Sanitation')),
                    DropdownMenuItem(value: 'Calibration', child: Text('Instrument Calibration')),
                    DropdownMenuItem(value: 'Preventative', child: Text('Preventative Service')),
                    DropdownMenuItem(value: 'Emergency', child: Text('Breakdown Repair')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observations & Chemical Parameters',
                    hintText: 'Concentration, temperature, torque reading...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (equipController.text.trim().isEmpty) return;
                setState(() {
                  _logs.insert(0, {
                    'id': 'MNT-${100 + _logs.length}',
                    'equipment': equipController.text.trim(),
                    'type': selectedType,
                    'frequency': 'Logged Task',
                    'lastCompleted': 'Just now',
                    'supervisor': 'Active Supervisor',
                    'status': 'Compliant',
                    'details': detailsController.text.trim().isEmpty
                        ? 'Inspection completed successfully.'
                        : detailsController.text.trim(),
                    'color': Colors.green,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maintenance log recorded successfully!')),
                );
              },
              child: const Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory CIP & Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Add Log',
            onPressed: _showAddLogDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Compliance Badge Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FSSAI & HACCP Sanitation Compliant',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All thermal pasteurization lines & capping heads verified within legal tolerance.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('Equipment Logs & Verification Audit',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ..._logs.map((log) {
            final isDue = log['status'] == 'Due Soon';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (isDue ? Colors.amber : Colors.green).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDue ? Icons.warning_rounded : Icons.check_circle_rounded,
                                color: isDue ? Colors.amber.shade800 : Colors.green.shade800,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              log['id'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isDue ? Colors.amber.shade800 : Colors.green.shade800)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            log['status'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDue ? Colors.amber.shade900 : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      log['equipment'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log['details'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('By: ${log['supervisor']}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        Text('Done: ${log['lastCompleted']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_maintenance',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddLogDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
