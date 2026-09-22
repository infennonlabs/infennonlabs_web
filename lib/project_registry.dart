import 'package:flutter/material.dart';

class ProjectEntry {
  const ProjectEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.icon,
    this.gradeRangeLabel,
    this.ageOrder,
    this.isPlaceholder = false,
  });

  final String id;
  final String title;
  final String description;
  final String slug;
  final IconData icon;
  final String? gradeRangeLabel;
  final int? ageOrder;
  final bool isPlaceholder;
}

const List<ProjectEntry> kProjectRegistry = <ProjectEntry>[
  ProjectEntry(
    id: 'alpha_kids',
    title: 'Alpha Kids',
    description: 'Emphasis on the alphabet and associated words and sounds',
    slug: 'alpha-kids',
    icon: Icons.abc,
    gradeRangeLabel: 'Early-PreK',
    ageOrder: 0,
  ),
  ProjectEntry(
    id: 'does_it_solve',
    title: 'Does It Solve',
    description: 'Simple math logical thinking',
    slug: 'does-it-solve',
    icon: Icons.extension_outlined,
    gradeRangeLabel: 'K-1st',
    ageOrder: 20,
  ),
  ProjectEntry(
    id: 'mahjong',
    title: 'Tile Match Learning',
    description: 'Fun pattern recognition learning',
    slug: 'tile-match',
    icon: Icons.grid_view_rounded,
    gradeRangeLabel: 'PreK-5th',
    ageOrder: 14,
  ),
  ProjectEntry(
    id: 'make_it',
    title: 'Make It',
    description: 'Critical thinking and spelling through recipe creations',
    slug: 'make-it',
    icon: Icons.build_circle_outlined,
    gradeRangeLabel: 'PreK-2nd',
    ageOrder: 11,
  ),
  ProjectEntry(
    id: 'math_adventures_kids',
    title: 'Math Adventures Kids',
    description:
        'Build strong math skills through patterns and problem solving',
    slug: 'math-adventure',
    icon: Icons.calculate_outlined,
    gradeRangeLabel: 'K-1st',
    ageOrder: 12,
  ),
  ProjectEntry(
    id: 'memory_match',
    title: 'Memory Match',
    description: 'Card-flip memory games designed for recognition and recall.',
    slug: 'memory-match',
    icon: Icons.style_outlined,
    gradeRangeLabel: 'PreK-2nd',
    ageOrder: 13,
  ),
  ProjectEntry(
    id: 'reading_writing_kids',
    title: 'Reading Writing Kids',
    description: 'Read and write with confidence',
    slug: 'reading-writing',
    icon: Icons.menu_book_outlined,
    gradeRangeLabel: 'K-3rd',
    ageOrder: 21,
  ),
  ProjectEntry(
    id: 'sight_word_search',
    title: 'Sight Word Search',
    description: 'Word search and spelling practice',
    slug: 'sight-word',
    icon: Icons.search_outlined,
    gradeRangeLabel: 'K-5th',
    ageOrder: 22,
  ),
  ProjectEntry(
    id: 'chem_kids',
    title: 'Chem Kids',
    description: 'Chemistry exploration and periodic table learning',
    slug: 'chemistry',
    icon: Icons.science_outlined,
    gradeRangeLabel: '5th',
    ageOrder: 999,
  ),
  ProjectEntry(
    id: 'countin_kids',
    title: 'Countin Kids',
    description: 'Learn counting through playful number activities',
    slug: 'counting',
    icon: Icons.numbers_outlined,
    gradeRangeLabel: 'PreK-K',
    ageOrder: 9,
  ),
  ProjectEntry(
    id: 'speak_repeat',
    title: 'Speak Repeat',
    description: 'Pronoun and speech practice through listen-and-repeat play',
    slug: 'speak-repeat',
    icon: Icons.record_voice_over_outlined,
    gradeRangeLabel: 'PreK-3rd',
    ageOrder: 10,
  ),
  ProjectEntry(
    id: 'math_solitaire_kids',
    title: 'Math Solitaire Kids',
    description: 'Math practice blended with card-style puzzle play.',
    slug: 'math-solitaire-kids',
    icon: Icons.filter_9_plus_outlined,
    gradeRangeLabel: '2nd-5th',
    ageOrder: 24,
    isPlaceholder: true,
  ),
];
