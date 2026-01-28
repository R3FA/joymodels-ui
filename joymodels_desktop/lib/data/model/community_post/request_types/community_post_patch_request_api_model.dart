import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/model/community_post/request_types/community_post_create_request_api_model.dart';

class CommunityPostPatchRequestApiModel {
  final String communityPostUuid;
  final String? title;
  final String? description;
  final String? postTypeUuid;
  final String? youtubeVideoLink;
  final List<CommunityPostPictureFile>? picturesToAdd;
  final List<String>? picturesToRemove;

  CommunityPostPatchRequestApiModel({
    required this.communityPostUuid,
    this.title,
    this.description,
    this.postTypeUuid,
    this.youtubeVideoLink,
    this.picturesToAdd,
    this.picturesToRemove,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['communityPostUuid'] = communityPostUuid;

    if (title != null) {
      request.fields['title'] = title!;
    }

    if (description != null) {
      request.fields['description'] = description!;
    }

    if (postTypeUuid != null) {
      request.fields['postTypeUuid'] = postTypeUuid!;
    }

    if (youtubeVideoLink != null) {
      request.fields['youtubeVideoLink'] = youtubeVideoLink!;
    }

    if (picturesToAdd != null) {
      for (final picture in picturesToAdd!) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'picturesToAdd',
            picture.bytes,
            filename: picture.name,
          ),
        );
      }
    }

    if (picturesToRemove != null) {
      for (int i = 0; i < picturesToRemove!.length; i++) {
        request.fields['picturesToRemove[$i]'] = picturesToRemove![i];
      }
    }

    return request;
  }
}
