import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_faq_section_repository.dart';

class ModelFaqSectionDetailPageViewModel extends ChangeNotifier {
  final modelFaqSectionRepository = sl<ModelFaqSectionRepository>();

  bool isLoading = false;
  bool isSubmittingAnswer = false;
  bool isEditingFaq = false;
  bool isDeletingFaq = false;
  String? errorMessage;
  String? currentUserUuid;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  ModelFaqSectionResponseApiModel? faqDetail;

  static const int _repliesPerPage = 5;
  int _displayedRepliesCount = 5;

  List<ModelFaqSectionReplyDto> get allReplies => faqDetail?.replies ?? [];
  List<ModelFaqSectionReplyDto> get replies =>
      allReplies.take(_displayedRepliesCount).toList();
  bool get hasReplies => allReplies.isNotEmpty;
  bool get hasMoreReplies => _displayedRepliesCount < allReplies.length;
  int get totalRepliesCount => allReplies.length;
  int get displayedRepliesCount =>
      _displayedRepliesCount.clamp(0, allReplies.length);

  bool isOwner(String userUuid) => currentUserUuid == userUuid;

  void loadMoreReplies() {
    if (hasMoreReplies) {
      _displayedRepliesCount += _repliesPerPage;
      notifyListeners();
    }
  }

  void resetRepliesPagination() {
    _displayedRepliesCount = _repliesPerPage;
    notifyListeners();
  }

  Future<void> init(ModelFaqSectionResponseApiModel faq) async {
    faqDetail = faq;
    _displayedRepliesCount = _repliesPerPage;
    currentUserUuid = await TokenStorage.getCurrentUserUuid();
    notifyListeners();
  }

  Future<bool> submitAnswer(BuildContext context, String messageText) async {
    if (faqDetail == null) return false;

    errorMessage = null;
    isSubmittingAnswer = true;
    notifyListeners();

    try {
      final request = ModelFaqSectionCreateAnswerRequestApiModel(
        modelUuid: faqDetail!.model.uuid,
        parentMessageUuid: faqDetail!.uuid,
        messageText: messageText,
      );

      await modelFaqSectionRepository.createAnswer(request);

      final updatedFaq = await modelFaqSectionRepository.getByUuid(
        faqDetail!.uuid,
      );
      faqDetail = updatedFaq;
      isSubmittingAnswer = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer submitted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isSubmittingAnswer = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isSubmittingAnswer = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isSubmittingAnswer = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit answer: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> editFaq(
    BuildContext context,
    String faqUuid,
    String newMessageText,
  ) async {
    if (faqDetail == null) return false;

    errorMessage = null;
    isEditingFaq = true;
    notifyListeners();

    try {
      final request = ModelFaqSectionPatchRequestApiModel(
        modelFaqSectionUuid: faqUuid,
        modelUuid: faqDetail!.model.uuid,
        messageText: newMessageText,
      );

      await modelFaqSectionRepository.patch(request);

      final updatedFaq = await modelFaqSectionRepository.getByUuid(
        faqDetail!.uuid,
      );
      faqDetail = updatedFaq;
      isEditingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isEditingFaq = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isEditingFaq = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isEditingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> deleteFaq(BuildContext context, String faqUuid) async {
    if (faqDetail == null) return false;

    errorMessage = null;
    isDeletingFaq = true;
    notifyListeners();

    try {
      final request = ModelFaqSectionDeleteRequestApiModel(
        modelFaqSectionUuid: faqUuid,
      );

      await modelFaqSectionRepository.delete(request);
      isDeletingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isDeletingFaq = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isDeletingFaq = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isDeletingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> deleteAnswer(BuildContext context, String answerUuid) async {
    if (faqDetail == null) return false;

    errorMessage = null;
    isDeletingFaq = true;
    notifyListeners();

    try {
      final request = ModelFaqSectionDeleteRequestApiModel(
        modelFaqSectionUuid: answerUuid,
      );

      await modelFaqSectionRepository.delete(request);

      final updatedFaq = await modelFaqSectionRepository.getByUuid(
        faqDetail!.uuid,
      );
      faqDetail = updatedFaq;
      isDeletingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isDeletingFaq = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isDeletingFaq = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isDeletingFaq = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete answer: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}
