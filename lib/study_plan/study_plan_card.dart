import 'package:flutter/material.dart';
import 'package:study_plan_shared/study_plan_shared.dart';

import 'study_catalog.dart';

/// The home page's Study Plan card: prepare a plan, or edit and start the one
/// being built.
class StudyPlanCard extends StatelessWidget {
  const StudyPlanCard({
    super.key,
    required this.draft,
    required this.onPrepare,
    required this.onStart,
  });

  final StudyPlanDraft draft;
  final VoidCallback onPrepare;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: draft,
      builder: (BuildContext context, Widget? _) {
        final bool hasPlan = !draft.isEmpty;
        final int count = draft.items.length;
        return Container(
          key: const ValueKey<String>('study-plan-card'),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF0B5E8B), Color(0xFF1D9FC1)],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0B5E8B).withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.event_note_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Semantics(
                    header: true,
                    child: Text(
                      hasPlan ? 'Your Study Plan' : 'Study Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hasPlan
                    ? '$count ${count == 1 ? 'item' : 'items'} · ${draft.totalMinutes} min total'
                    : kStudyPlanSubtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton(
                    key: const ValueKey<String>('study-prepare'),
                    onPressed: onPrepare,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B5E8B),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    child: Text(hasPlan ? 'Edit plan' : 'Prepare Study Plan'),
                  ),
                  if (hasPlan)
                    FilledButton(
                      key: const ValueKey<String>('study-card-start'),
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B5E8B),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      child: const Text('Start'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
