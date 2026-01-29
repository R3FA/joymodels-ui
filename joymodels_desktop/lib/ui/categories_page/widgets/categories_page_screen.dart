import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_desktop/ui/categories_page/view_model/categories_page_view_model.dart';
import 'package:joymodels_desktop/ui/core/ui/pagination_controls.dart';
import 'package:provider/provider.dart';

class CategoriesPageScreen extends StatefulWidget {
  final VoidCallback? onSessionExpired;
  final VoidCallback? onForbidden;
  final VoidCallback? onNetworkError;

  const CategoriesPageScreen({
    super.key,
    this.onSessionExpired,
    this.onForbidden,
    this.onNetworkError,
  });

  @override
  State<CategoriesPageScreen> createState() => _CategoriesPageScreenState();
}

class _CategoriesPageScreenState extends State<CategoriesPageScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<CategoriesPageViewModel>();

    _searchController = TextEditingController(text: viewModel.searchQuery);

    viewModel.onSessionExpired = widget.onSessionExpired;
    viewModel.onForbidden = widget.onForbidden;
    viewModel.onNetworkError = widget.onNetworkError;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CategoriesPageViewModel>();
    final theme = Theme.of(context);
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        viewModel.clearErrorMessage();
      });
    }

    return Column(
      children: [
        _buildSearchBar(viewModel, theme),
        Expanded(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.items.isEmpty
              ? Center(
                  child: Text(
                    'No categories found.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : _buildDataTable(viewModel.items, viewModel, theme),
        ),
        if (viewModel.paginationData != null)
          PaginationControls(
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            totalRecords: viewModel.totalRecords,
            hasPreviousPage: viewModel.hasPreviousPage,
            hasNextPage: viewModel.hasNextPage,
            isLoading: viewModel.isLoadingPage,
            onPreviousPage: () => viewModel.onPreviousPage(),
            onNextPage: () => viewModel.onNextPage(),
          ),
      ],
    );
  }

  Widget _buildSearchBar(CategoriesPageViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                errorText: viewModel.searchError,
              ),
              onChanged: (value) {
                viewModel.setSearchQuery(value);
                _debounce?.cancel();
                if (viewModel.searchError == null) {
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    viewModel.searchCategories();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => _showCreateDialog(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<CategoryResponseApiModel> categories,
    CategoriesPageViewModel viewModel,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nameMinWidth = constraints.maxWidth - 200;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 16,
                columns: [
                  DataColumn(
                    label: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: nameMinWidth),
                      child: const Text('Name'),
                    ),
                  ),
                  const DataColumn(label: Center(child: Text('Actions'))),
                  const DataColumn(label: Text('')),
                ],
                rows: categories
                    .map(
                      (cat) => _buildCategoryRow(
                        cat,
                        viewModel,
                        theme,
                        nameMinWidth,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildCategoryRow(
    CategoryResponseApiModel category,
    CategoriesPageViewModel viewModel,
    ThemeData theme,
    double nameMinWidth,
  ) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: nameMinWidth),
            child: Text(category.categoryName),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _showEditDialog(context, viewModel, category),
          ),
        ),
        DataCell(
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'Delete',
            onPressed: () => _showDeleteDialog(
              context,
              viewModel,
              category.uuid,
              category.categoryName,
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext ctx, CategoriesPageViewModel viewModel) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: ctx,
      builder: (context) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Category'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSaving = true);
                          await viewModel.createCategory(
                            nameController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext ctx,
    CategoriesPageViewModel viewModel,
    CategoryResponseApiModel category,
  ) {
    final nameController = TextEditingController(text: category.categoryName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: ctx,
      builder: (context) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Category'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSaving = true);
                          await viewModel.updateCategory(
                            category.uuid,
                            nameController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext ctx,
    CategoriesPageViewModel viewModel,
    String uuid,
    String categoryName,
  ) {
    showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteCategory(uuid);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
