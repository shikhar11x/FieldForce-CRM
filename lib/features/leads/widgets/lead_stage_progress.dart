import 'package:flutter/material.dart';

import '../../../core/extensions/lead_style_extensions.dart';
import '../../../data/models/lead_models.dart';

/// Five-segment bar for the open stages. Won and Lost fill it completely
/// in their own color.
class LeadStageProgress extends StatelessWidget {
  const LeadStageProgress({super.key, required this.stage});

  final LeadStage stage;

  @override
  Widget build(BuildContext context) {
    final open = LeadStage.values.where((s) => s.isOpen).toList();
    final reached = stage.isOpen ? stage.index + 1 : open.length;
    final color = stage.color;

    return Row(
      children: [
        for (final (i, _) in open.indexed)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == open.length - 1 ? 0 : 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: ColoredBox(
                    color: i < reached ? color : color.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}