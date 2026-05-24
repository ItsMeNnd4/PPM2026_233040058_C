import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tugas_p4/main.dart';

void main() {
  testWidgets('can edit an existing note and update the list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Belajar Flutter'), findsOneWidget);

    await tester.tap(find.text('Belajar Flutter'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Catatan'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('Edit Catatan'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Belajar Flutter Lanjutan',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Mempelajari form edit, validasi, dan pembaruan data.',
    );

    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Catatan'), findsOneWidget);
    expect(find.text('Belajar Flutter Lanjutan'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Belajar Flutter Lanjutan'), findsOneWidget);
    expect(find.text('Belajar Flutter'), findsNothing);
  });
}
