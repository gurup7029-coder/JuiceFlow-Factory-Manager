import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class ShiftAttendanceScreen extends StatefulWidget {
  const ShiftAttendanceScreen({super.key});

  @override
  State<ShiftAttendanceScreen> createState() => _ShiftAttendanceScreenState();
}

class _ShiftAttendanceScreenState extends State<ShiftAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedShift = 'Morning (06:00 - 14:00)';
  String _searchQuery = '';

  final List<String> _shifts = [
    'Morning (06:00 - 14:00)',
    'General Day (09:00 - 17:00)',
    'Evening (14:00 - 22:00)',
    'Night CIP Clean (22:00 - 06:00)',
  ];

  final List<Map<String, dynamic>> _workers = [
    {
      'id': 'EMP-01',
      'name': 'Murugan K.',
      'code': 'JF-PROD-01',
      'role': 'Pasteurizer Lead Operator',
      'station': 'HTST Pasteurizer Unit',
      'clockIn': '06:02 AM',
      'clockOut': null,
      'status': 'present', // present, late, absent, on_break
      'batch': 'B-2026-M402 (Mango Nectar)',
      'phone': '+91 98421 11201',
    },
    {
      'id': 'EMP-02',
      'name': 'Priya Selvam',
      'code': 'JF-QC-04',
      'role': 'QA & Brix Chemist',
      'station': 'Quality Lab',
      'clockIn': '06:15 AM',
      'clockOut': null,
      'status': 'late',
      'batch': 'B-2026-M402 (Mango Nectar)',
      'phone': '+91 98421 22302',
    },
    {
      'id': 'EMP-03',
      'name': 'Karthik Raja',
      'code': 'JF-LINE-02',
      'role': 'Bottling Line Technician',
      'station': 'Automated Capping Line A',
      'clockIn': '05:55 AM',
      'clockOut': null,
      'status': 'present',
      'batch': 'B-2026-M402 (Mango Nectar)',
      'phone': '+91 98421 33403',
    },
    {
      'id': 'EMP-04',
      'name': 'Anitha Sundaram',
      'code': 'JF-PREP-09',
      'role': 'Fruit Sorter & Washer',
      'station': 'Fruit Intake Conveyor',
      'clockIn': null,
      'clockOut': null,
      'status': 'absent',
      'batch': 'Unassigned',
      'phone': '+91 98421 44504',
    },
    {
      'id': 'EMP-05',
      'name': 'Saravanan M.',
      'code': 'JF-COLD-03',
      'role': 'Cold Storage Stacker',
      'station': 'Chamber 1 (-4°C)',
      'clockIn': '06:00 AM',
      'clockOut': null,
      'status': 'present',
      'batch': 'Finished Goods Dock',
      'phone': '+91 98421 55605',
    },
    {
      'id': 'EMP-06',
      'name': 'Dinesh Kumar',
      'code': 'JF-LINE-07',
      'role': 'Carton Packaging Specialist',
      'station': 'Shrink-Wrap Station',
      'clockIn': '06:05 AM',
      'clockOut': null,
      'status': 'present',
      'batch': 'B-2026-M402 (Mango Nectar)',
      'phone': '+91 98421 66706',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _workers.where((w) {
      final name = (w['name'] as String).toLowerCase();
      final code = (w['code'] as String).toLowerCase();
      final station = (w['station'] as String).toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || code.contains(q) || station.contains(q);
    }).toList();

    final presentCount = _workers.where((w) => w['status'] == 'present' || w['status'] == 'late').length;
    final absentCount = _workers.where((w) => w['status'] == 'absent').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift & Worker Attendance'),
        actions: [
          IconButton(
            tooltip: 'Roster Report',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift Attendance Report exported successfully')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Shift and Date Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131826) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedShift,
                          items: _shifts.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedShift = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Quick KPI Counters
                Row(
                  children: [
                    _buildKpiChip('Scheduled', '${_workers.length}', Colors.blue),
                    const SizedBox(width: 8),
                    _buildKpiChip('Present', '$presentCount', Colors.green),
                    const SizedBox(width: 8),
                    _buildKpiChip('Absent', '$absentCount', Colors.red),
                    const SizedBox(width: 8),
                    _buildKpiChip('Active Batches', '1 Active', Colors.orange),
                  ],
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search worker, code or station...',
                prefixIcon: const Icon(Icons.search_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Workers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final w = filtered[index];
                return _buildWorkerCard(context, w, isDark);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerModal,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Worker to Shift'),
      ),
    );
  }

  Widget _buildKpiChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Map<String, dynamic> w, bool isDark) {
    final isPresent = w['status'] == 'present';
    final isLate = w['status'] == 'late';
    final isAbsent = w['status'] == 'absent';

    Color statusColor = Colors.grey;
    String statusText = 'Absent';
    if (isPresent) {
      statusColor = Colors.green;
      statusText = 'On Duty (${w['clockIn']})';
    } else if (isLate) {
      statusColor = Colors.amber;
      statusText = 'Late In (${w['clockIn']})';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Text(
                    (w['name'] as String).substring(0, 1),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            w['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${w['code']} • ${w['role']}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.precision_manufacturing_rounded, size: 14, color: AppColors.neonOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Station: ${w['station']}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  'Batch: ${w['batch']}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: Icon(
                      isAbsent ? Icons.login_rounded : Icons.logout_rounded,
                      size: 14,
                      color: isAbsent ? Colors.green : Colors.redAccent,
                    ),
                    label: Text(
                      isAbsent ? 'Clock In' : 'Clock Out',
                      style: TextStyle(
                        fontSize: 11,
                        color: isAbsent ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (isAbsent) {
                          w['status'] = 'present';
                          w['clockIn'] = DateFormat('hh:mm a').format(DateTime.now());
                        } else {
                          w['status'] = 'absent';
                          w['clockOut'] = DateFormat('hh:mm a').format(DateTime.now());
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                    label: const Text('Reassign Station', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showReassignStationModal(w),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReassignStationModal(Map<String, dynamic> worker) {
    final stations = [
      'Fruit Intake & Sorting',
      'HTST Pasteurizer Unit',
      'Homogenizer & Mixing Tank',
      'Automated Capping Line A',
      'Cold Storage Chamber (-4°C)',
      'Quality Lab Sampling',
      'CIP Sanitation Loop',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reassign Station for ${worker['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...stations.map((s) {
                return ListTile(
                  dense: true,
                  title: Text(s),
                  trailing: worker['station'] == s ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() => worker['station'] = s);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddWorkerModal() {
    final nameController = TextEditingController();
    final roleController = TextEditingController(text: 'Operator');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Worker to Roster', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Worker Full Name')),
              const SizedBox(height: 10),
              TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role / Designation')),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    setState(() {
                      _workers.add({
                        'id': 'EMP-${_workers.length + 1}',
                        'name': nameController.text.trim(),
                        'code': 'JF-TEMP-0${_workers.length + 1}',
                        'role': roleController.text.trim(),
                        'station': 'Fruit Intake & Sorting',
                        'clockIn': DateFormat('hh:mm a').format(DateTime.now()),
                        'clockOut': null,
                        'status': 'present',
                        'batch': 'Unassigned',
                        'phone': '+91 98421 99999',
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add & Clock In'),
              ),
            ],
          ),
        );
      },
    );
  }
}
