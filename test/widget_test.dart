import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smartvenue/main.dart';
import 'package:smartvenue/providers/app_state.dart';

void main() {
  testWidgets('Smart Venue app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const SmartVenueApp(),
      ),
    );

    // Verify app renders heading title
    expect(find.text('SMART VENUE'), findsWidgets);
  });
}
