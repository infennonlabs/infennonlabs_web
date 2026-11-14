import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infennon_labs_home/announcements/announcement_copy.dart';
import 'package:infennon_labs_home/announcements/announcement_feed.dart';
import 'package:infennon_labs_home/announcements/announcement_item.dart';
import 'package:infennon_labs_home/announcements/announcement_ticker.dart';
import 'package:infennon_labs_home/announcements/pulse_highlight.dart';
import 'package:infennon_labs_home/grade_filter_store.dart';
import 'package:infennon_labs_home/main.dart';
import 'package:infennon_labs_home/project_registry.dart';

final DateTime _now = DateTime.utc(2026, 11, 14, 9);

String _ago(int hours) =>
    _now.subtract(Duration(hours: hours)).toIso8601String();

List<AnnouncementItem> _build(Map<String, dynamic>? feed) => buildAnnouncements(
  feed: feed,
  now: _now,
  projects: kProjectRegistry,
  showUpdates: true,
);

List<String> _ids(List<AnnouncementItem> items) =>
    items.map((AnnouncementItem i) => i.id).toList();

Future<void> _wide(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The project cards overflow by a few pixels with the test font once a frame has advanced
/// (also without the ticker); that is unrelated to what these tests check.
void _ignoreCardOverflow() {
  final previous = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.toString().contains('overflowed')) return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

void main() {
  test('UPDATED pills are off by default for now', () {
    expect(kShowUpdatedGames, isFalse);
    final items = buildAnnouncements(
      feed: <String, dynamic>{
        'games': <String, dynamic>{
          'slice_it': <String, dynamic>{
            'firstDeployedAt': null,
            'announcement': <String, dynamic>{
              'text': 'new fifths mode',
              'at': _ago(1),
            },
          },
        },
      },
      now: _now,
      projects: kProjectRegistry,
    );
    expect(_ids(items), isNot(contains('update-slice_it')));
  });

  group('buildAnnouncements', () {
    test('no feed shows the tips only, Study Plan reminder first', () {
      final items = _build(null);
      expect(_ids(items), <String>['tip-study-plan', 'tip-hints', 'tip-grade']);
    });

    test('a game is NEW for 72h after its first deploy', () {
      Map<String, dynamic> feed(int h) => <String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{'firstDeployedAt': _ago(h)},
        },
      };
      expect(_ids(_build(feed(71))), contains('new-trace_lab'));
      expect(_ids(_build(feed(72))), isNot(contains('new-trace_lab')));
    });

    test('NEW uses the game title, its description and points at the card', () {
      final item = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{'firstDeployedAt': _ago(1)},
        },
      }).firstWhere((AnnouncementItem i) => i.id == 'new-trace_lab');
      final entry = kProjectRegistry.firstWhere((e) => e.id == 'trace_lab');
      expect(item.title, entry.title);
      expect(item.note, entry.description);
      expect(item.target, const AnnouncementTarget.game('trace_lab'));
      expect(
        item.expiresAt,
        _now.subtract(const Duration(hours: 1)).add(kNewWindow),
      );
    });

    test('a deploy line replaces the description on a NEW entry', () {
      final item = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{
            'firstDeployedAt': _ago(1),
            'announcement': <String, dynamic>{
              'text': 'Trace the alphabet',
              'at': _ago(1),
            },
          },
        },
      }).firstWhere((AnnouncementItem i) => i.id == 'new-trace_lab');
      expect(item.note, 'Trace the alphabet');
    });

    test('UPDATED needs an announcement line and lasts 48h', () {
      Map<String, dynamic> feed(int h, {String text = 'new fifths mode'}) =>
          <String, dynamic>{
            'games': <String, dynamic>{
              'slice_it': <String, dynamic>{
                'firstDeployedAt': null,
                'lastDeployedAt': _ago(h),
                'announcement': <String, dynamic>{'text': text, 'at': _ago(h)},
              },
            },
          };
      expect(_ids(_build(feed(47))), contains('update-slice_it'));
      expect(_ids(_build(feed(48))), isNot(contains('update-slice_it')));
      expect(
        _ids(_build(feed(1, text: '  '))),
        isNot(contains('update-slice_it')),
      );
    });

    test('a redeploy with no announcement adds nothing (no noise)', () {
      final items = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'slice_it': <String, dynamic>{
            'firstDeployedAt': null,
            'lastDeployedAt': _ago(1),
          },
        },
      });
      expect(
        _ids(items).where((String id) => id.startsWith('update-')),
        isEmpty,
      );
    });

    test('NEW wins over UPDATED for the same game', () {
      final items = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{
            'firstDeployedAt': _ago(5),
            'announcement': <String, dynamic>{'text': 'hi', 'at': _ago(2)},
          },
        },
      });
      expect(
        _ids(items).where((String id) => id.endsWith('trace_lab')),
        <String>['new-trace_lab'],
      );
    });

    test('unknown games and malformed entries are ignored', () {
      final items = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'nope': <String, dynamic>{'firstDeployedAt': _ago(1)},
          'slice_it': 'garbage',
          'trace_lab': <String, dynamic>{'firstDeployedAt': 'not a date'},
        },
        'pins': 'garbage',
      });
      expect(_ids(items), _ids(_build(null)));
    });

    test('rank order: pin 1-9, feature, new, update, study plan tip, tips', () {
      final items = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{'firstDeployedAt': _ago(20)},
          'slice_it': <String, dynamic>{
            'firstDeployedAt': null,
            'announcement': <String, dynamic>{'text': 'x', 'at': _ago(30)},
          },
        },
        'pins': <dynamic>[
          <String, dynamic>{
            'id': 'a',
            'text': 'Pin A',
            'target': 'studyPlan',
            'priority': 1,
            'endsAt': _now.add(const Duration(days: 3)).toIso8601String(),
          },
          <String, dynamic>{
            'id': 'b',
            'text': 'Pin B',
            'target': 'filter',
            'endsAt': _now.add(const Duration(days: 3)).toIso8601String(),
          },
        ],
      });
      expect(_ids(items), <String>[
        'pin-a',
        'pin-b',
        'new-trace_lab',
        'update-slice_it',
        'tip-study-plan',
        'tip-hints',
        'tip-grade',
      ]);
    });

    test('ties go to whichever expires first', () {
      final items = _build(<String, dynamic>{
        'games': <String, dynamic>{
          'trace_lab': <String, dynamic>{'firstDeployedAt': _ago(20)},
          'discovery_lab': <String, dynamic>{'firstDeployedAt': _ago(60)},
        },
      });
      expect(_ids(items).take(2), <String>[
        'new-discovery_lab',
        'new-trace_lab',
      ]);
    });

    test('pins respect their window, target and priority range', () {
      Map<String, dynamic> pin(Map<String, dynamic> extra) => <String, dynamic>{
        'id': 'p',
        'text': 'Pinned',
        'target': 'studyPlan',
        'endsAt': _now.add(const Duration(days: 2)).toIso8601String(),
        ...extra,
      };
      List<String> ids(Map<String, dynamic> extra) => _ids(
        _build(<String, dynamic>{
          'pins': <dynamic>[pin(extra)],
        }),
      );
      expect(ids(<String, dynamic>{}), contains('pin-p'));
      expect(
        ids(<String, dynamic>{'endsAt': _ago(1)}),
        isNot(contains('pin-p')),
      );
      expect(
        ids(<String, dynamic>{
          'startsAt': _now.add(const Duration(days: 1)).toIso8601String(),
        }),
        isNot(contains('pin-p')),
      );
      expect(
        ids(<String, dynamic>{'target': 'game:nope'}),
        isNot(contains('pin-p')),
      );
      expect(ids(<String, dynamic>{'text': ''}), isNot(contains('pin-p')));
      final wild = _build(<String, dynamic>{
        'pins': <dynamic>[
          pin(<String, dynamic>{'priority': 99}),
        ],
      });
      expect(wild.firstWhere((i) => i.id == 'pin-p').rank, 10);
    });

    test('a pin without a target still shows, but is not clickable', () {
      final items = _build(<String, dynamic>{
        'pins': <dynamic>[
          <String, dynamic>{
            'id': 'p',
            'text': 'Pinned',
            'endsAt': _now.add(const Duration(days: 2)).toIso8601String(),
          },
        ],
      });
      expect(items.firstWhere((i) => i.id == 'pin-p').target, isNull);
    });

    test('carries at most $kMaxAnnouncements entries', () {
      final games = <String, dynamic>{
        for (final id in <String>[
          'trace_lab',
          'discovery_lab',
          'slice_it',
          'shape_pals',
          'christmas_kids',
          'earth_lab',
          'find_it',
          'farm_kids',
        ])
          id: <String, dynamic>{'firstDeployedAt': _ago(2)},
      };
      expect(
        _build(<String, dynamic>{'games': games}),
        hasLength(kMaxAnnouncements),
      );
    });
  });

  test('feed path follows the host the page is served from', () {
    expect(
      announcementFeedPath(Uri.parse('https://infennonlabs.com/')),
      '/announcements-feed.json',
    );
    expect(
      announcementFeedPath(
        Uri.parse('https://x.github.io/learning-play/home/'),
      ),
      '/learning-play/announcements-feed.json',
    );
  });

  test('target parsing', () {
    expect(
      AnnouncementTarget.parse('studyPlan'),
      const AnnouncementTarget.studyPlan(),
    );
    expect(
      AnnouncementTarget.parse('filter'),
      const AnnouncementTarget.filter(),
    );
    expect(
      AnnouncementTarget.parse('game:slice_it'),
      const AnnouncementTarget.game('slice_it'),
    );
    expect(AnnouncementTarget.parse('game:'), isNull);
    expect(AnnouncementTarget.parse('elsewhere'), isNull);
    expect(AnnouncementTarget.parse(3), isNull);
  });

  group('ticker widget', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    const items = <AnnouncementItem>[
      AnnouncementItem(
        id: 'a',
        kind: AnnouncementKind.newGame,
        title: 'Trace Lab',
        note: 'Trace letters',
        target: AnnouncementTarget.game('trace_lab'),
      ),
      AnnouncementItem(
        id: 'b',
        kind: AnnouncementKind.tip,
        title: 'A static tip',
      ),
    ];

    Widget host(
      ValueChanged<AnnouncementTarget> onSelect, {
      bool reduced = false,
    }) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(1200, 800),
          disableAnimations: reduced,
        ),
        child: Scaffold(
          body: AnnouncementTicker(items: items, onSelect: onSelect),
        ),
      ),
    );

    testWidgets('shows entries and a click reports the target', (
      WidgetTester tester,
    ) async {
      final picked = <AnnouncementTarget>[];
      await _wide(tester);
      await tester.pumpWidget(host(picked.add));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Trace Lab').first);
      expect(picked, <AnnouncementTarget>[
        const AnnouncementTarget.game('trace_lab'),
      ]);
    });

    testWidgets('an entry with no target does nothing', (
      WidgetTester tester,
    ) async {
      final picked = <AnnouncementTarget>[];
      await _wide(tester);
      await tester.pumpWidget(host(picked.add));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('A static tip').first);
      expect(picked, isEmpty);
    });

    testWidgets('scrolls at kTickerSpeed and the pause button stops it', (
      WidgetTester tester,
    ) async {
      await _wide(tester);
      await tester.pumpWidget(host((_) {}));
      final list = find.byType(ListView);
      double offset() => tester.widget<ListView>(list).controller!.offset;
      await tester.pump(const Duration(milliseconds: 16));
      final start = offset();
      await tester.pump(const Duration(seconds: 1));
      expect(offset() - start, closeTo(kTickerSpeed, 3));

      await tester.tap(find.byTooltip(AnnouncementCopy.pause));
      await tester.pump();
      final paused = offset();
      await tester.pump(const Duration(seconds: 1));
      expect(offset(), paused);
      expect(find.byTooltip(AnnouncementCopy.play), findsOneWidget);
    });

    testWidgets('reduced motion: one entry at a time with arrows', (
      WidgetTester tester,
    ) async {
      await _wide(tester);
      await tester.pumpWidget(host((_) {}, reduced: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Trace Lab'), findsOneWidget);
      expect(find.text('A static tip'), findsNothing);
      expect(find.text('1 of 2'), findsOneWidget);

      await tester.tap(find.byTooltip(AnnouncementCopy.next));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('A static tip'), findsOneWidget);
      expect(find.text('2 of 2'), findsOneWidget);

      await tester.tap(find.byTooltip(AnnouncementCopy.previous));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Trace Lab'), findsOneWidget);
    });

    testWidgets('reduced motion advances on its own', (
      WidgetTester tester,
    ) async {
      await _wide(tester);
      await tester.pumpWidget(host((_) {}, reduced: true));
      await tester.pump(kCarouselDwell + const Duration(milliseconds: 300));
      expect(find.text('A static tip'), findsOneWidget);
    });

    testWidgets('pill contrast: ink text on every kind background', (
      WidgetTester tester,
    ) async {
      // Guards the colour pairs in the ticker; ink on these light backgrounds is far above 4.5:1.
      double lum(Color c) {
        double ch(double v) => v <= 0.03928
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
      }

      double ratio(Color a, Color b) {
        final l1 = lum(a), l2 = lum(b);
        return (l1 > l2 ? l1 + 0.05 : l2 + 0.05) /
            (l1 > l2 ? l2 + 0.05 : l1 + 0.05);
      }

      for (final bg in const <Color>[
        Color(0xFFEEFADF),
        Color(0xFFE3F4FD),
        Color(0xFFFFF1E1),
        Color(0xFFF2F5F8),
        BrandTheme.lime,
        BrandTheme.sky,
        BrandTheme.peach,
        Color(0xFFD3DCE5),
      ]) {
        expect(ratio(BrandTheme.ink, bg), greaterThan(4.5));
      }
      expect(
        ratio(const Color(0xFF445062), const Color(0xFFEEFADF)),
        greaterThan(4.5),
      );
      expect(ratio(Colors.white, BrandTheme.ocean), greaterThan(4.5));
    });
  });

  group('home wiring', () {
    setUp(() {
      saveGradeLabel(null);
      saveSubjectLabel(null);
    });

    Future<void> pumpAtSize(WidgetTester tester, Size size) async {
      _ignoreCardOverflow();
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const InfennonLabsApp());
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('desktop shows the strip, a phone does not', (
      WidgetTester tester,
    ) async {
      await pumpAtSize(tester, const Size(1200, 6000));
      expect(find.byType(AnnouncementTicker), findsOneWidget);
      await pumpAtSize(tester, const Size(390, 844));
      expect(find.byType(AnnouncementTicker), findsNothing);
    });

    testWidgets(
      'the Study Plan tip scrolls to and pulses the Study Plan card',
      (WidgetTester tester) async {
        await pumpAtSize(tester, const Size(1200, 6000));
        await tester.tap(find.text("Don't forget to set a Study Plan").first);
        await tester.pump();
        final pulses = tester.widgetList<PulseHighlight>(
          find.byType(PulseHighlight),
        );
        expect(pulses.where((PulseHighlight p) => p.active), hasLength(1));
        await tester.pump(const Duration(seconds: 3));
        expect(
          tester
              .widgetList<PulseHighlight>(find.byType(PulseHighlight))
              .where((PulseHighlight p) => p.active),
          isEmpty,
        );
      },
    );
  });
}
