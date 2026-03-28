import 'package:flutter/material.dart';
import '../main.dart';
import '../models/history_data.dart';

class HistoryCard extends StatelessWidget {
  final HistoryData history;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.history,
    this.onTap,
  });

  IconData _getAnimalIcon() {
    final type = history.animalType.toLowerCase();
    if (type.contains('snake')) return Icons.pest_control;
    if (type.contains('bird') || type.contains('eagle')) return Icons.flutter_dash;
    return Icons.pets;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: history.isDangerous
                ? AppTheme.alertRed.withValues(alpha: 0.4)
                : AppTheme.white.withValues(alpha: 0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Animal icon / image ──
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: history.isDangerous
                      ? AppTheme.alertRed.withValues(alpha: 0.15)
                      : AppTheme.forestGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: history.imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    history.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      _getAnimalIcon(),
                      color: history.isDangerous
                          ? AppTheme.alertRed
                          : AppTheme.forestGreen,
                      size: 28,
                    ),
                  ),
                )
                    : Icon(
                  _getAnimalIcon(),
                  color: history.isDangerous
                      ? AppTheme.alertRed
                      : AppTheme.forestGreen,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              // ── Details ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal name + danger badge
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            history.animalType[0].toUpperCase() +
                                history.animalType.substring(1),
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (history.isDangerous)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.alertRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DANGER',
                              style: TextStyle(
                                color: AppTheme.alertRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13,
                            color: AppTheme.white.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            history.location,
                            style: TextStyle(
                              color: AppTheme.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Category + Confidence
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.forestGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            history.animalCategory.toUpperCase(),
                            style: TextStyle(
                              color:
                              AppTheme.forestGreen.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.analytics_outlined,
                            size: 13,
                            color: AppTheme.white.withValues(alpha: 0.5)),
                        const SizedBox(width: 3),
                        Text(
                          history.confidencePercent,
                          style: TextStyle(
                            color: AppTheme.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Timestamp + arrow ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    history.formattedTime,
                    style: TextStyle(
                      color: AppTheme.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.map_outlined,
                    color: AppTheme.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}