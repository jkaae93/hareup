import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';

import '../../../../l10n/l10n.dart';

class ObservationChartPoint {
  const ObservationChartPoint({required this.time, required this.values});
  final DateTime time;
  final List<double> values;
}

/// Bars represent individual observations in chronological order, not daily totals.
class ObservationChart extends StatelessWidget {
  const ObservationChart({
    super.key,
    required this.title,
    required this.labels,
    required this.points,
    this.maximum,
    required this.unit,
  });
  final String title;
  final List<String> labels;
  final List<ObservationChartPoint> points;
  final double? maximum;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = [HareupColors.primary700, HareupColors.secondary700];
    final maxValue =
        maximum ??
        math.max(1.0, points.expand((p) => p.values).fold<double>(0, math.max));
    return HareupFormSection(
      title: title,
      description: context.l10n.recordsChartDescription,
      children: [
        Wrap(
          spacing: HareupSpacing.medium,
          children: [
            for (var i = 0; i < labels.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: colors[i]),
                  const SizedBox(width: HareupSpacing.extraSmall),
                  Text(labels[i]),
                ],
              ),
          ],
        ),
        const SizedBox(height: HareupSpacing.medium),
        Text(
          context.l10n.recordsChartMaximumText(
            context.l10n.recordsValueWithUnit(
              maxValue.toStringAsFixed(
                maxValue == maxValue.roundToDouble() ? 0 : 1,
              ),
              unit,
            ),
          ),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final point in points)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HareupSpacing.small,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < point.values.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      context.l10n.recordsValueWithUnit(
                                        point.values[i].toStringAsFixed(
                                          point.values[i] ==
                                                  point.values[i]
                                                      .roundToDouble()
                                              ? 0
                                              : 1,
                                        ),
                                        unit,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                    const SizedBox(
                                      height: HareupSpacing.extraSmall,
                                    ),
                                    Container(
                                      width: 22,
                                      height: math.max(
                                        2,
                                        115 *
                                            (point.values[i] / maxValue).clamp(
                                              0,
                                              1,
                                            ),
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors[i],
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(
                                                HareupSpacing.extraSmall,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: HareupSpacing.extraSmall),
                      Text(
                        '${point.time.month}/${point.time.day}\n${point.time.hour.toString().padLeft(2, '0')}:${point.time.minute.toString().padLeft(2, '0')}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
