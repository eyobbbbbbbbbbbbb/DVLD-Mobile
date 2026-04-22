import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dvld_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const DVLDApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
