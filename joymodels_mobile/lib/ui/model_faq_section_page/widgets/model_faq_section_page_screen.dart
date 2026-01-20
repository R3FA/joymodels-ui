import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/model_faq_section_detail_page/view_model/model_faq_section_detail_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_faq_section_detail_page/widgets/model_faq_section_detail_page_screen.dart';
import 'package:joymodels_mobile/ui/model_faq_section_page/view_model/model_faq_section_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelFaqSectionPageScreen extends StatefulWidget {
  final String modelUuid;
  final String? modelName;

  const ModelFaqSectionPageScreen({
    super.key,
    required this.modelUuid,
    this.modelName,
  });

  @override
  State<ModelFaqSectionPageScreen> createState() =>
      _ModelFaqSectionPageScreenState();
}

class _ModelFaqSectionPageScreenState extends State<ModelFaqSectionPageScreen> {
  late final ModelFaqSectionPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelFaqSectionPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.modelUuid, modelName: widget.modelName);
    });
  }

  void _handleSessionExpired() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePageScreen()),
      (route) => false,
    );
  }

  void _handleForbidden() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
      (route) => false,
    );
  }

  Future<void> _openFAQDetail(ModelFaqSectionResponseApiModel faq) async {
    final result = await Navigator.push<ModelFaqSectionResponseApiModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ModelFaqSectionDetailPageViewModel(),
          child: ModelFaqSectionDetailPageScreen(faq: faq),
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      _viewModel.updateFaqInList(result);
    } else {
      _viewModel.removeFaqFromList(faq.uuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelFaqSectionPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.modelName != null ? 'FAQ - ${viewModel.modelName}' : 'FAQ',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(viewModel, theme),
    );
  }

  Widget _buildBody(ModelFaqSectionPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading && viewModel.faqList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.loadFAQ(),
      );
    }

    if (viewModel.faqList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No FAQ yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to ask a question about this model',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: viewModel.faqList.length,
            itemBuilder: (context, index) {
              return _buildFAQCard(viewModel.faqList[index], theme);
            },
          ),
        ),
        PaginationControls(
          currentPage: viewModel.currentPage,
          totalPages: viewModel.totalPages,
          hasPreviousPage: viewModel.hasPreviousPage,
          hasNextPage: viewModel.hasNextPage,
          onPreviousPage: viewModel.onPreviousPage,
          onNextPage: viewModel.onNextPage,
          isLoading: viewModel.isLoading,
        ),
      ],
    );
  }

  Widget _buildFAQCard(ModelFaqSectionResponseApiModel faq, ThemeData theme) {
    final replyCount = faq.replies?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openFAQDetail(faq),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl:
                        "${ApiConstants.baseUrl}/users/get/${faq.user.uuid}/avatar",
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq.user.nickName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(faq.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          faq.messageText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$replyCount ${replyCount == 1 ? 'answer' : 'answers'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
