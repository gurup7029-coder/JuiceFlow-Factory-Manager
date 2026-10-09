import 'package:flutter/material.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class FleetDispatchScreen extends StatefulWidget {
  const FleetDispatchScreen({super.key});

  @override
  State<FleetDispatchScreen> createState() => _FleetDispatchScreenState();
}

class _FleetDispatchScreenState extends State<FleetDispatchScreen> {
  int _selectedTabIndex = 0; // 0: Trips & Dispatches, 1: Fleet Vehicles

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'VEH-01',
      'name': 'Reefer Van 01 (Chilled)',
      'plate': 'TN 45 AX 2091',
      'driver': 'Venkatesh R.',
      'driverPhone': '+91 98421 88011',
      'temp': 3.8,
      'capacityCrates': 250,
      'loadedCrates': 210,
      'status': 'in_transit', // in_transit, at_dock, idle, maintenance
      'batteryOrFuel': 'Fuel: 74%',
      'color': AppTheme.neonCyan,
    },
    {
      'id': 'VEH-02',
      'name': 'Heavy Insulated Truck 02',
      'plate': 'TN 45 BY 7812',
      'driver': 'Ganesan S.',
      'driverPhone': '+91 98421 88022',
      'temp': 4.1,
      'capacityCrates': 450,
      'loadedCrates': 380,
      'status': 'at_dock',
      'batteryOrFuel': 'Fuel: 88%',
      'color': AppTheme.neonOrange,
    },
    {
      'id': 'VEH-03',
      'name': 'Electric City Runner 03',
      'plate': 'TN 45 CZ 4402',
      'driver': 'Manikandan P.',
      'driverPhone': '+91 98421 88033',
      'temp': 4.4,
      'capacityCrates': 120,
      'loadedCrates': 110,
      'status': 'in_transit',
      'batteryOrFuel': 'EV Battery: 81%',
      'color': AppTheme.neonLime,
    },
  ];

  final List<Map<String, dynamic>> _trips = [
    {
      'id': 'TRIP-101',
      'route': 'Route Alpha - RS Puram & Peelamedu',
      'vehicle': 'TN 45 AX 2091',
      'driver': 'Venkatesh R.',
      'crates': 210,
      'stops': 8,
      'completedStops': 5,
      'status': 'in_transit', // scheduled, loading, in_transit, delivered
      'eta': '35 mins',
      'coldChainStatus': 'Optimal (3.8°C)',
    },
    {
      'id': 'TRIP-102',
      'route': 'Route Beta - Gandhipuram Juice Lounges',
      'vehicle': 'TN 45 BY 7812',
      'driver': 'Ganesan S.',
      'crates': 380,
      'stops': 6,
      'completedStops': 1,
      'status': 'loading',
      'eta': 'Departs in 15m',
      'coldChainStatus': 'Pre-chilled (4.1°C)',
    },
    {
      'id': 'TRIP-103',
      'route': 'Route Gamma - Airport Road Luxury Hotels',
      'vehicle': 'TN 45 CZ 4402',
      'driver': 'Manikandan P.',
      'crates': 110,
      'stops': 4,
      'completedStops': 4,
      'status': 'delivered',
      'eta': 'Completed at 01:20 PM',
      'coldChainStatus': 'Verified (4.4°C)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet & Delivery Dispatch'),
        actions: [
          IconButton(
            tooltip: 'Live Cold-Chain GPS',
            icon: const Icon(Icons.satellite_alt_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All 3 Reefer units reporting active GPS & Cold-Chain IoT telematics')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Segment Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabItem(0, 'Active Dispatches (${_trips.length})', Icons.local_shipping_rounded),
                  _buildTabItem(1, 'Refrigerated Fleet (${_vehicles.length})', Icons.ac_unit_rounded),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildTripsList(context, isDark)
                : _buildVehiclesList(context, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTripModal,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('Schedule Dispatch'),
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripsList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _trips.length,
      itemBuilder: (context, index) {
        final t = _trips[index];
        final isInTransit = t['status'] == 'in_transit';
        final isDelivered = t['status'] == 'delivered';

        Color statusColor = Colors.orange;
        String statusLabel = 'Loading at Dock';
        if (isInTransit) {
          statusColor = AppTheme.neonCyan;
          statusLabel = 'In Transit';
        } else if (isDelivered) {
          statusColor = AppTheme.neonLime;
          statusLabel = 'All Delivered';
        }

        final progress = (t['completedStops'] as int) / (t['stops'] as int);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t['id'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t['route'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),

                // Vehicle, Driver, Crates chips
                Row(
                  children: [
                    _buildMiniBadge(Icons.airport_shuttle_rounded, t['vehicle'] as String),
                    const SizedBox(width: 8),
                    _buildMiniBadge(Icons.person_pin_rounded, t['driver'] as String),
                    const SizedBox(width: 8),
                    _buildMiniBadge(Icons.inventory_2_rounded, '${t['crates']} crates'),
                  ],
                ),
                const SizedBox(height: 12),

                // Stops progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Drop-offs: ${t['completedStops']}/${t['stops']} Completed',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'ETA: ${t['eta']}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),

                // Cold chain & actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.ac_unit_rounded, size: 14, color: AppTheme.neonCyan),
                        const SizedBox(width: 4),
                        Text(
                          t['coldChainStatus'] as String,
                          style: const TextStyle(fontSize: 11, color: AppTheme.neonCyan, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Share Manifest via WhatsApp',
                          icon: const Icon(Icons.share_rounded, size: 18),
                          onPressed: () {
                            WhatsAppDispatchService.shareFleetManifest(
                              vehiclePlate: t['vehicle'] as String,
                              driverName: t['driver'] as String,
                              routeName: t['route'] as String,
                              totalCrates: t['crates'] as int,
                              totalStops: t['stops'] as int,
                            );
                          },
                        ),
                        if (!isDelivered)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              setState(() {
                                final cur = t['completedStops'] as int;
                                final total = t['stops'] as int;
                                if (cur < total) {
                                  t['completedStops'] = cur + 1;
                                  if (t['completedStops'] == total) {
                                    t['status'] = 'delivered';
                                  }
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Stop delivery confirmed with Digital POD for ${t['route']}')),
                              );
                            },
                            child: const Text('Confirm Drop-off', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehiclesList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final v = _vehicles[index];
        final temp = (v['temp'] as num).toDouble();
        final loaded = v['loadedCrates'] as int;
        final cap = v['capacityCrates'] as int;
        final capRatio = loaded / cap;
        final vColor = v['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
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
                            color: vColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.local_shipping_rounded, color: vColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(v['plate'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    // Cold temp indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.ac_unit_rounded, size: 14, color: Colors.cyanAccent),
                          const SizedBox(width: 4),
                          Text(
                            '${temp.toStringAsFixed(1)}°C',
                            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Crate Capacity: $loaded / $cap Crates', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text('${(capRatio * 100).toInt()}% Full', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: capRatio,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(vColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Driver: ${v['driver']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(v['batteryOrFuel'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showNewTripModal() {
    final routeCtrl = TextEditingController(text: 'Route Delta - Saravanampatti IT Corridor');
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
              const Text('Schedule Delivery Trip Run', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: routeCtrl, decoration: const InputDecoration(labelText: 'Delivery Route Name')),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  setState(() {
                    _trips.add({
                      'id': 'TRIP-${100 + _trips.length + 1}',
                      'route': routeCtrl.text.trim(),
                      'vehicle': 'TN 45 AX 2091',
                      'driver': 'Venkatesh R.',
                      'crates': 140,
                      'stops': 5,
                      'completedStops': 0,
                      'status': 'scheduled',
                      'eta': 'Scheduled for 04:00 PM',
                      'coldChainStatus': 'Standby (3.8°C)',
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Schedule Dispatch'),
              ),
            ],
          ),
        );
      },
    );
  }
}
