import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/report_dialog.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_mobile/ui/model_faq_section_detail_page/view_model/model_faq_section_detail_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';

class ModelFaqSectionDetailPageScreen extends StatefulWidget {
  final ModelFaqSectionResponseApiModel faq;

  const ModelFaqSectionDetailPageScreen({super.key, required this.faq});

  @override
  State<ModelFaqSectionDetailPageScreen> createState() =>
      _ModelFaqSectionDetailPageScreenState();
}

class _ModelFaqSectionDetailPageScreenState
    extends State<ModelFaqSectionDetailPageScreen> {
  late final ModelFaqSectionDetailPageViewModel _viewModel;
  final _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ModelFaqSectionDetailPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init(widget.faq);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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

  void _navigateToUserProfile(String userUuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserProfilePageViewModel()..init(userUuid),
          child: UserProfilePageScreen(userUuid: userUuid),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModelFaqSectionDetailPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(viewModel.faqDetail),
        ),
      ),
      body: viewModel.faqDetail == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuestionCard(viewModel, theme),
                        const SizedBox(height: 24),
                        _buildAnswersSection(viewModel, theme),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isModelPublic)
                  _buildAnswerInput(viewModel, theme),
              ],
            ),
    );
  }

  Widget _buildQuestionCard(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final faq = viewModel.faqDetail!;
    final isOwner = viewModel.isOwner(faq.user.uuid);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _navigateToUserProfile(faq.user.uuid),
                child: UserAvatar(
                  imageUrl:
                      "${ApiConstants.baseUrl}/users/get/${faq.user.uuid}/avatar",
                  radius: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToUserProfile(faq.user.uuid),
                      child: Text(
                        faq.user.nickName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(faq.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (viewModel.isModelPublic)
                _buildPopupMenu(
                  theme: theme,
                  isOwner: isOwner,
                  isAdminOrRoot: viewModel.isAdminOrRoot,
                  onEdit: () => _showEditDialog(
                    viewModel,
                    theme,
                    faq.uuid,
                    faq.messageText,
                    isQuestion: true,
                  ),
                  onDelete: () => _showDeleteDialog(
                    viewModel,
                    theme,
                    faq.uuid,
                    isQuestion: true,
                  ),
                  onReport: () => _showReportDialog(faq.uuid, faq.messageText),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            faq.messageText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersSection(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Answers (${viewModel.totalRepliesCount})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!viewModel.hasReplies)
          _buildNoAnswers(theme)
        else ...[
          ...viewModel.replies.map(
            (reply) => _buildAnswerCard(viewModel, reply, theme),
          ),
          if (viewModel.hasMoreReplies) _buildLoadMoreButton(viewModel, theme),
        ],
      ],
    );
  }

  Widget _buildLoadMoreButton(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    final remaining =
        viewModel.totalRepliesCount - viewModel.displayedRepliesCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: viewModel.loadMoreReplies,
          icon: const Icon(Icons.expand_more, size: 20),
          label: Text(
            'Load more ($remaining remaining)',
            style: theme.textTheme.bodyMedium,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.secondary,
            side: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildNoAnswers(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No answers yet',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to answer this question',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(
    ModelFaqSectionDetailPageViewModel viewModel,
    ModelFaqSectionReplyDto reply,
    ThemeData theme,
  ) {
    final isOwner = viewModel.isOwner(reply.user.uuid);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _navigateToUserProfile(reply.user.uuid),
                child: UserAvatar(
                  imageUrl:
                      "${ApiConstants.baseUrl}/users/get/${reply.user.uuid}/avatar",
                  radius: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _navigateToUserProfile(reply.user.uuid),
                            child: Text(
                              reply.user.nickName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(reply.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (viewModel.isModelPublic)
                          _buildPopupMenu(
                            theme: theme,
                            isOwner: isOwner,
                            isAdminOrRoot: viewModel.isAdminOrRoot,
                            onEdit: () => _showEditDialog(
                              viewModel,
                              theme,
                              reply.uuid,
                              reply.messageText,
                              isQuestion: false,
                            ),
                            onDelete: () => _showDeleteDialog(
                              viewModel,
                              theme,
                              reply.uuid,
                              isQuestion: false,
                            ),
                            onReport: () => _showReportDialog(
                              reply.uuid,
                              reply.messageText,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reply.messageText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu({
    required ThemeData theme,
    required bool isOwner,
    required bool isAdminOrRoot,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onReport,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'report':
            onReport();
            break;
        }
      },
      itemBuilder: (context) => [
        if (isOwner) ...[
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ] else if (isAdminOrRoot)
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          )
        else
          PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag, size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Text('Report'),
              ],
            ),
          ),
      ],
    );
  }

  void _showEditDialog(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
    String faqUuid,
    String currentText, {
    required bool isQuestion,
  }) {
    final editController = TextEditingController(text: currentText);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(isQuestion ? 'Edit Question' : 'Edit Answer'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  return TextFormField(
                    controller: editController,
                    maxLines: 4,
                    maxLength: 5000,
                    decoration: InputDecoration(
                      hintText: isQuestion
                          ? 'Edit your question...'
                          : 'Edit your answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      errorText: viewModel.editInputError,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your ${isQuestion ? 'question' : 'answer'}';
                      }
                      if (value.trim().length < 5) {
                        return '${isQuestion ? 'Question' : 'Answer'} must be at least 5 characters';
                      }
                      return null;
                    },
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return ElevatedButton(
                  onPressed: viewModel.isEditingFaq
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await viewModel.editFaq(
                              this.context,
                              faqUuid,
                              editController.text.trim(),
                            );
                            if (success && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: viewModel.isEditingFaq
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
    String faqUuid, {
    required bool isQuestion,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Text(isQuestion ? 'Delete Question' : 'Delete Answer'),
            ],
          ),
          content: Text(
            isQuestion
                ? 'Are you sure you want to delete this question? This will also delete all answers.'
                : 'Are you sure you want to delete this answer?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return ElevatedButton(
                  onPressed: viewModel.isDeletingFaq
                      ? null
                      : () async {
                          final parentContext = this.context;
                          bool success;
                          if (isQuestion) {
                            success = await viewModel.deleteFaq(
                              parentContext,
                              faqUuid,
                            );
                            if (success && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              if (parentContext.mounted) {
                                Navigator.of(parentContext).pop(null);
                              }
                            }
                          } else {
                            success = await viewModel.deleteAnswer(
                              parentContext,
                              faqUuid,
                            );
                            if (success && dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  child: viewModel.isDeletingFaq
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Delete'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnswerInput(
    ModelFaqSectionDetailPageViewModel viewModel,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _answerController,
                  maxLines: 3,
                  minLines: 1,
                  maxLength: 5000,
                  decoration: InputDecoration(
                    hintText: 'Write your answer...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    errorText: viewModel.answerInputError,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your answer';
                    }
                    if (value.trim().length < 5) {
                      return 'Answer must be at least 5 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: viewModel.isSubmittingAnswer
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await viewModel.submitAnswer(
                              context,
                              _answerController.text.trim(),
                            );
                            if (success) {
                              _answerController.clear();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: viewModel.isSubmittingAnswer
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(String uuid, String? description) async {
    final result = await ReportDialog.show(
      context: context,
      entityType: ReportedEntityTypeApiEnum.modelFaqQuestion,
      entityUuid: uuid,
      entityDescription: description,
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report submitted')));
    }
  }
}
