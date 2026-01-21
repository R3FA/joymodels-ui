import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/response_types/community_post_question_section_response_api_model.dart';
import 'package:joymodels_mobile/data/services/community_post_question_section_service.dart';

class CommunityPostQuestionSectionRepository {
  final CommunityPostQuestionSectionService _service;
  final AuthService _authService;

  CommunityPostQuestionSectionRepository(this._service, this._authService);

  Future<CommunityPostQuestionSectionResponseApiModel> getByUuid(
    String communityPostQuestionSectionUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(communityPostQuestionSectionUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostQuestionSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch community post question section: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostQuestionSectionResponseApiModel> create(
    CommunityPostQuestionSectionCreateRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.create(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostQuestionSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create community post question section: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostQuestionSectionResponseApiModel> createAnswer(
    CommunityPostQuestionSectionCreateAnswerRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.createAnswer(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostQuestionSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create answer: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostQuestionSectionResponseApiModel> patch(
    CommunityPostQuestionSectionPatchRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.patch(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostQuestionSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update community post question section: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String communityPostQuestionSectionUuid) async {
    final response = await _authService.request(
      () => _service.delete(communityPostQuestionSectionUuid),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete community post question section: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
