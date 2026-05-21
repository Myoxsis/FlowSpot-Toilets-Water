import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowspot_toilets_water/src/app.dart';

void main() {
  testWidgets('FlowSpot app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const FlowSpotApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('FlowSpot'), findsOneWidget);
  });
}
