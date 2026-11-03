import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/features/checkout/ui/screens/order_success_screen.dart';

Future<void> pumpScreen(WidgetTester tester, {String orderId = ''}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, _) => MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('stub:${settings.name}'))),
        ),
        home: OrderSuccessScreen(orderId: orderId),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('shows the success copy and the order ID when one was passed', (
    tester,
  ) async {
    await pumpScreen(tester, orderId: 'order-42');

    expect(find.text('Order Success'), findsOneWidget);
    expect(find.text('Order placed successfully!'), findsOneWidget);
    expect(
      find.text('Order #order-42 — pay cash when your order arrives.'),
      findsOneWidget,
    );
  });

  testWidgets('falls back to generic copy when no order ID was passed', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Order placed successfully!'), findsOneWidget);
    expect(find.text('Pay cash when your order arrives.'), findsOneWidget);
  });
}



