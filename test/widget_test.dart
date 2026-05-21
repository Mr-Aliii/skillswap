import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_swap/widgets/common/app_logo.dart';

void main() {
  testWidgets('AppLogo renders SkillSwap branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: AppLogo())),
        ),
      ),
    );

    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
  });
}
