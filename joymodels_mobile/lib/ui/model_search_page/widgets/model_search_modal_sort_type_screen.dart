import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/ui/model_search_page/view_model/model_search_page_view_model.dart';
import 'package:provider/provider.dart';

class ModelSearchModalSortTypeScreen extends StatefulWidget {
  final List<CategoryResponseApiModel> categories;

  const ModelSearchModalSortTypeScreen({super.key, required this.categories});

  @override
  State<ModelSearchModalSortTypeScreen> createState() =>
      _ModelSearchModalSortTypeScreenState();
}

const String _kAllCategory = '__all__';

class _ModelSearchModalSortTypeScreenState
    extends State<ModelSearchModalSortTypeScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelSearchPageViewModel>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sort & Filter Models", style: theme.textTheme.titleMedium),
            const SizedBox(height: 18),
            Text("Category", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            DropdownMenu<String>(
              initialSelection:
                  viewModel.selectedFilterCategory ?? _kAllCategory,
              expandedInsets: EdgeInsets.zero,
              menuHeight: 200,
              requestFocusOnTap: false,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              onSelected: (cat) {
                setState(() {
                  viewModel.selectedFilterCategory = cat == _kAllCategory
                      ? null
                      : cat;
                });
              },
              dropdownMenuEntries: [
                const DropdownMenuEntry<String>(
                  value: _kAllCategory,
                  label: 'All',
                ),
                ...widget.categories.map(
                  (cat) => DropdownMenuEntry<String>(
                    value: cat.categoryName,
                    label: cat.categoryName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text("Sort by", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            RadioGroup<ModelSortType>(
              groupValue: viewModel.selectedFilterSort,
              onChanged: (sort) {
                setState(() {
                  if (viewModel.selectedFilterSort == sort) {
                    viewModel.selectedFilterSort = null;
                  } else {
                    viewModel.selectedFilterSort = sort;
                  }
                });
              },
              child: Column(
                children: ModelSortType.values
                    .map(
                      (type) => RadioListTile<ModelSortType>(
                        value: type,
                        title: Text(
                          viewModel.labelForSortType(type),
                          style: theme.textTheme.bodyMedium,
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: theme.colorScheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: FilledButton(
                onPressed: () {
                  viewModel.onFilterSubmit();
                  Navigator.of(context).pop();
                },
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
