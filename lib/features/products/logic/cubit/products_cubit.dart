import 'dart:async';

// `flutter_bloc` re-exports `package:bloc/bloc.dart` (Cubit lives there), so
// the direct `bloc` import (not a declared dependency) is avoided.
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_error_handler.dart';
import '../../data/datasources/product_catalog_data_source.dart';
import '../../data/models/product_doc.dart';
import 'products_state.dart';

/// Catalog cubit (PRD §2): shows all products, browses by category and
/// searches by name — category and name filters compose (both are applied
/// client-side over one live subscription, so the screen updates in realtime
/// while filtered).
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._catalogDataSource)
    : super(const ProductsState.initial()) {
    _subscribe();
  }

  final ProductCatalogDataSource _catalogDataSource;
  StreamSubscription<List<ProductDoc>>? _subscription;

  /// Latest unfiltered snapshot; filters are re-applied on top of it.
  List<ProductDoc> _catalog = const [];
  String? _selectedCategory;
  String _searchQuery = '';

  void _subscribe({bool emitLoading = false}) {
    _subscription?.cancel();
    if (emitLoading) {
      emit(const ProductsState.productsLoading());
    }
    _subscription = _catalogDataSource.streamCatalog().listen(
      (docs) {
        _catalog = docs;
        _emitFiltered();
      },
      onError: (Object error) {
        emit(ProductsState.productsError(ApiErrorHandler.handle(error)));
      },
    );
  }

  /// Browse by category (PRD §2). `null` clears the filter (show all).
  void selectCategory(String? category) {
    _selectedCategory = (category == null || category.isEmpty) ? null : category;
    _emitFiltered();
  }

  /// Search by name (case-insensitive), composed with the active category
  /// filter (PRD §2: "Search for products by name and filter by category").
  void search(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  /// Re-subscribe to the catalog stream (retry after an error state). The
  /// loading state is re-emitted here because a listener is guaranteed to be
  /// subscribed (the screen asked for the retry).
  void refresh() => _subscribe(emitLoading: true);

  void _emitFiltered() {
    final categories =
        _catalog
            .map((doc) => doc.product.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final needle = _searchQuery.trim().toLowerCase();
    final filtered =
        _catalog.where((doc) {
          final matchesCategory =
              _selectedCategory == null ||
              doc.product.category == _selectedCategory;
          final matchesQuery =
              needle.isEmpty ||
              doc.product.name.toLowerCase().contains(needle);
          return matchesCategory && matchesQuery;
        }).toList();

    if (filtered.isEmpty) {
      emit(
        ProductsState.productsEmpty(
          categories: categories,
          selectedCategory: _selectedCategory,
          searchQuery: _searchQuery,
        ),
      );
    } else {
      emit(
        ProductsState.productsLoaded(
          products: filtered,
          categories: categories,
          selectedCategory: _selectedCategory,
          searchQuery: _searchQuery,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
