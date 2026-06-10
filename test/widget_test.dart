import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheelride/main.dart';

void main() {
  testWidgets('signs in to the WheelRide home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WheelRideApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenue !'), findsOneWidget);

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Salut'), findsOneWidget);
    expect(find.text('Creer un ride'), findsOneWidget);
    expect(find.text('Rejoindre un ride'), findsOneWidget);
  });

  testWidgets('creates a ride and displays an invite QR code', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WheelRideApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Creer un ride'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ride-name')), findsOneWidget);

    await tester.tap(find.text('Creer le ride'));
    await tester.pumpAndSettle();

    expect(find.text('Ride cree !'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text('Partager le QR Code'), findsOneWidget);
    expect(find.text('Commencer le ride'), findsOneWidget);
  });
}
