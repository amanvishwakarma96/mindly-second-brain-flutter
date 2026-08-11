import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindly/app/app_routes.dart';
import 'package:mindly/app/mindly_app.dart';
import 'package:mindly/app/platform/screen_family.dart';
import 'package:mindly/features/insights/application/insight_controller.dart';
import 'package:mindly/features/insights/application/tier3_insight_controller.dart';
import 'package:mindly/features/insights/domain/insight_models.dart';
import 'package:mindly/features/insights/domain/tier3_models.dart';
import 'package:mindly/features/memory/domain/memory_models.dart';
import 'package:mindly/features/text_capture/domain/text_capture_models.dart';

void main() {
  final cases = <ScreenFamily, (Key, Key)>{
    ScreenFamily.mobile: (
      const ValueKey<String>('screen-mobile-insights'),
      const ValueKey<String>('mobile-tier3-preview'),
    ),
    ScreenFamily.desktop: (
      const ValueKey<String>('screen-desktop-insights'),
      const ValueKey<String>('desktop-tier3-preview'),
    ),
    ScreenFamily.web: (
      const ValueKey<String>('screen-web-insights'),
      const ValueKey<String>('web-tier3-preview'),
    ),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key.name} Tier 3 requires explicit preview action', (
      tester,
    ) async {
      final tier3 = _FakeTier3InsightController();
      await tester.pumpWidget(
        MindlyApp(
          screenFamilyOverride: entry.key,
          insightControllerOverride: const _FakeInsightController(),
          tier3InsightControllerOverride: tier3,
        ),
      );
      Navigator.of(
        tester.element(find.byType(Scaffold).first),
      ).pushNamed(AppRoutes.insights);
      await tester.pumpAndSettle();

      expect(find.byKey(entry.value.$1), findsOneWidget);
      expect(find.byKey(entry.value.$2), findsOneWidget);
      expect(tier3.previewCalls, 0);
      expect(tier3.generateCalls, 0);

      await tester.tap(find.byKey(entry.value.$2));
      await tester.pumpAndSettle();
      expect(tier3.previewCalls, 1);
      expect(tier3.generateCalls, 0);
      expect(find.textContaining('Add or connect more memories'), findsWidgets);
    });
  }
}

class _FakeInsightController implements InsightController {
  const _FakeInsightController();

  @override
  Future<List<ProactiveInsight>> dismiss(String fingerprint) async => const [];

  @override
  Future<List<ProactiveInsight>> load() async => const [];

  @override
  Future<Set<InsightKind>> mutedKinds() async => const <InsightKind>{};

  @override
  Future<List<ProactiveInsight>> setMuted(InsightKind kind, bool muted) async =>
      const [];

  @override
  Future<MemoryDetail?> sourceDetail(InsightSourceReference source) async => null;
}

class _FakeTier3InsightController implements Tier3InsightController {
  int previewCalls = 0;
  int generateCalls = 0;

  @override
  Future<Tier3GenerationPreview> preview(
    ExtractionProviderProfile profile,
  ) async {
    previewCalls += 1;
    return Tier3GenerationPreview(
      status: Tier3PreviewStatus.insufficientEvidence,
      profile: profile,
      bundle: const Tier3EvidenceBundle(sources: [], totalCharacters: 0),
    );
  }

  @override
  Future<Tier3GenerationOutcome> generate(
    ExtractionProviderProfile profile,
  ) async {
    generateCalls += 1;
    final preview = await this.preview(profile);
    return Tier3GenerationOutcome(
      kind: Tier3GenerationOutcomeKind.insufficientEvidence,
      preview: preview,
    );
  }
}
