import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/ui/model_search_page/view_model/model_search_page_view_model.dart';
import 'package:provider/provider.dart';

class ModelSearchModalSortTypeScreen extends StatefulWidget {
  final List<CategoryResponseApiModel> categories;
  final CategoryResponseApiModel? selectedCategory;

  const ModelSearchModalSortTypeScreen({
    super.key,
    required this.categories,
    this.selectedCategory,
  });

  @override
  State<ModelSearchModalSortTypeScreen> createState() =>
      _ModelSearchModalSortTypeScreenState();
}

class _ModelSearchModalSortTypeScreenState
    extends State<ModelSearchModalSortTypeScreen> {
  late final ModelSearchPageViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelSearchPageViewModel>();
    _viewModel.selectedFilterCategory = widget.selectedCategory?.categoryName;
  }

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
            DropdownButtonFormField<String>(
              initialValue: widget.selectedCategory?.categoryName,
              hint: const Text("Choose category"),
              isExpanded: true,
              decoration: InputDecoration(
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
              items: [
                const DropdownMenuItem<String>(value: null, child: Text("All")),
                ...widget.categories.map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat.categoryName,
                    child: Text(cat.categoryName),
                  ),
                ),
              ],
              onChanged: (cat) {
                setState(() {
                  viewModel.selectedFilterCategory = cat;
                });
              },
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
                onPressed: viewModel.onFilterSubmit,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
