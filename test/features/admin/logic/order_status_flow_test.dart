import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/features/admin/logic/order_status_flow.dart';
import 'package:flutter_test/flutter_test.dart';

/// Business-rule tests for the admin order lifecycle (PRD §5):
/// 1. strict one-step advance pending → confirmed → preparing → shipped →
///    delivered (no jumps, no backwards, no updates of final orders);
/// 2. cancellation only before confirmed (while pending).
void main() {
  group('OrderStatusFlow.next — sequential advance only', () {
    test('advances exactly one step through the whole lifecycle', () {
      expect(OrderStatusFlow.next(OrderStatus.pending), OrderStatus.confirmed);
      expect(
        OrderStatusFlow.next(OrderStatus.confirmed),
        OrderStatus.preparing,
      );
      expect(OrderStatusFlow.next(OrderStatus.preparing), OrderStatus.shipped);
      expect(OrderStatusFlow.next(OrderStatus.shipped), OrderStatus.delivered);
    });

    test('returns null for the final status (delivered) — no update', () {
      expect(OrderStatusFlow.next(OrderStatus.delivered), isNull);
    });

    test('returns null for cancelled — a terminal side exit, not a step', () {
      expect(OrderStatusFlow.next(OrderStatus.cancelled), isNull);
    });
  });

  group('OrderStatusFlow.canCancel — only before confirmed', () {
    test('pending orders can be cancelled', () {
      expect(OrderStatusFlow.canCancel(OrderStatus.pending), isTrue);
    });

    test('confirmed/preparing/shipped orders cannot be cancelled', () {
      expect(OrderStatusFlow.canCancel(OrderStatus.confirmed), isFalse);
      expect(OrderStatusFlow.canCancel(OrderStatus.preparing), isFalse);
      expect(OrderStatusFlow.canCancel(OrderStatus.shipped), isFalse);
    });

    test('terminal orders cannot be cancelled', () {
      expect(OrderStatusFlow.canCancel(OrderStatus.delivered), isFalse);
      expect(OrderStatusFlow.canCancel(OrderStatus.cancelled), isFalse);
    });
  });

  group('OrderStatusFlow.canAdvance', () {
    test('is true for every non-final status on the progression', () {
      for (final status in OrderStatusFlow.progression) {
        if (status == OrderStatus.delivered) {
          expect(OrderStatusFlow.canAdvance(status), isFalse);
        } else {
          expect(OrderStatusFlow.canAdvance(status), isTrue);
        }
      }
    });
  });
}



