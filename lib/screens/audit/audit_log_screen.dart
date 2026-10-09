import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/factory_data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/stat_badge.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<FactoryDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('auditLog')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.auditLogs.length,
        itemBuilder: (context, index) {
          final log = provider.auditLogs[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history_toggle_off, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            log.action,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      StatBadge(label: log.module, color: Colors.blueGrey, fontSize: 9.5),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.details,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'By: ${log.userName} (${log.userRole})',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        Formatters.dateTime(log.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
