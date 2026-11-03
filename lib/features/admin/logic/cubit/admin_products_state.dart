import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/api_error_model.dart';
import '../../data/repos/admin_products_source.dart';

part 'admin_products_state.freezed.dart';

/// States of [AdminProductsCubit]. Consume the union via the named variant
/// classes exported here (freezed-4 style used across the app: import THIS
/// file and pattern-match / `is`-check the public classes).
@freezed
class AdminProductsState with _$AdminProductsState {
  const factory AdminProductsState.initial() = _Initial;

  /// Catalog stream states (realtime, [AdminProductsCubit.loadProducts]).
  const factory AdminProductsState.productsLoading() = AdminProductsLoading;
  const factory AdminProductsState.productsSuccess(
    List<AdminProductEntry> entries,
  ) = AdminProductsSuccess;
  const factory AdminProductsState.productsError(ApiErrorModel apiErrorModel) =
      AdminProductsError;

  /// Create/update states.
  const factory AdminProductsState.submitLoading() = AdminProductSubmitLoading;
  const factory AdminProductsState.submitSuccess(String successMessage) =
      AdminProductSubmitSuccess;
  const factory AdminProductsState.submitError(ApiErrorModel apiErrorModel) =
      AdminProductSubmitError;

  /// Delete state (after the confirmation dialog).
  const factory AdminProductsState.deleteLoading() = AdminProductDeleteLoading;
  const factory AdminProductsState.deleteSuccess(String successMessage) =
      AdminProductDeleteSuccess;
  const factory AdminProductsState.deleteError(ApiErrorModel apiErrorModel) =
      AdminProductDeleteError;

  /// The admin role guard refused a write (PRD §1/§5: only `role == admin`
  /// may write products). Emitted instead of calling the repository.
  const factory AdminProductsState.writeUnauthorized(
    ApiErrorModel apiErrorModel,
  ) = AdminProductsWriteUnauthorized;
}
