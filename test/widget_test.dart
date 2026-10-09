import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:juice_flow/main.dart';
import 'package:juice_flow/providers/app_state_provider.dart';
import 'package:juice_flow/providers/factory_data_provider.dart';

void main() {
  testWidgets('JuiceFlow App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>(create: (_) => AppStateProvider()),
          ChangeNotifierProvider<FactoryDataProvider>(create: (_) => FactoryDataProvider()),
        ],
        child: const JuiceFlowApp(),
      ),
    );

    // Initial pump
    await tester.pump();
    expect(find.byType(JuiceFlowApp), findsOneWidget);

    // Advance timer past splash screen
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byType(JuiceFlowApp), findsOneWidget);
  });
}
