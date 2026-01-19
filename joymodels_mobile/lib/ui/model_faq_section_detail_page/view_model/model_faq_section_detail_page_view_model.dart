import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_faq_section_repository.dart';

class ModelFaqSectionDetailPageViewModel extends ChangeNotifier {
  final modelFaqSectionRepository = sl<ModelFaqSectionRepository>();

  bool isLoading = false;
  bool isSubmittingAnswer = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;

  ModelFaqSectionResponseApiModel? faqDetail;

  List<ModelFaqSectionReplyDto> get replies => faqDetail?.replies ?? [];
  bool get hasReplies => replies.isNotEmpty;

  Future<void> init(ModelFaqSectionResponseApiModel faq) async {
    faqDetail = faq;
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

      // Reload the parent FAQ to get updated replies
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

  @override
  void dispose() {
    onSessionExpired = null;
    super.dispose();
  }
}
