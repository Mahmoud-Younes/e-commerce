import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/routing/routes.dart';
import 'package:e_commerce_app/features/products/data/models/product_doc.dart';
import 'package:e_commerce_app/features/products/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {void Function(RouteSettings)? onRoute}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    child: MaterialApp(
      onGenerateRoute: (settings) {
        onRoute?.call(settings);
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Pushed screen')),
        );
      },
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 200,
            height: 280,
            child: child,
          ),
        ),
      ),
    ),
  );
}

ProductDoc productDoc({
  String id = 'p1',
  String name = 'Running Shoes',
  double price = 99.5,
  String imageUrl = '',
}) =>
    ProductDoc(
      id: id,
      product: ProductModel(
        name: name,
        price: price,
        category: 'Fashion',
        stock: 5,
        imageUrl: imageUrl,
      ),
    );

void main() {
  testWidgets('ProductCard renders image placeholder, name and price',
      (tester) async {
    await tester.pumpWidget(
      _wrap(ProductCard(productDoc: productDoc(imageUrl: ''))),
    );
    await tester.pump();

    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('99.50 EGP'), findsOneWidget);
    // Empty image URL falls back to the placeholder icon.
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    // Favorite heart overlay exists (PRD §2 add-to-favorites entry).
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('ProductCard shows the network image when a URL is given',
      (tester) async {
    await tester.pumpWidget(
      _wrap(ProductCard(productDoc: productDoc(imageUrl: 'https://x/y.png'))),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('tapping the card pushes the details route with the product id '
      'as argument', (tester) async {
    RouteSettings? pushed;
    await tester.pumpWidget(
      _wrap(
        ProductCard(productDoc: productDoc(id: 'p1')),
        onRoute: (settings) => pushed = settings,
      ),
    );
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(pushed, isNotNull);
    expect(pushed!.name, Routes.productDetailsScreen);
    expect(pushed!.arguments, 'p1');
  });

  testWidgets('tapping the heart while signed out shows a sign-in snackbar '
      'and does not navigate', (tester) async {
    // No Firebase app initialized and nobody signed in — currentUserId()
    // resolves to null and the button must degrade gracefully.
    await tester.pumpWidget(
      _wrap(ProductCard(productDoc: productDoc(id: 'p1'))),
    );
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(
      find.text('Please sign in to manage favorites.'),
      findsOneWidget,
    );
  });
}



