import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:notes_crud_app/main.dart';
import 'package:notes_crud_app/screens/home_page.dart';

void main() {
  testWidgets('App starts and displays HomePage', (WidgetTester tester) async {
    // Build aplikasi kita dan trigger sebuah frame.
    // MyApp() sekarang tidak lagi memerlukan parameter.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa HomePage ditampilkan.
    expect(find.byType(HomePage), findsOneWidget);

    // Verifikasi bahwa judul aplikasi 'College Notes' ada di AppBar.
    expect(find.text('College Notes'), findsOneWidget);

    // Verifikasi bahwa FloatingActionButton dengan ikon 'add' ada.
    expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
  });
}