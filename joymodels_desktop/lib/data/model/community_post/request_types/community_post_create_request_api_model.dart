import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CommunityPostCreateRequestApiModel {
  final String title;
  final String description;
  final String postTypeUuid;
  final String? youtubeVideoLink;
  final List<CommunityPostPictureFile>? pictures;

  CommunityPostCreateRequestApiModel({
    required this.title,
    required this.description,
    required this.postTypeUuid,
    this.youtubeVideoLink,
    this.pictures,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['postTypeUuid'] = postTypeUuid;

    if (youtubeVideoLink != null) {
      request.fields['youtubeVideoLink'] = youtubeVideoLink!;
    }

    if (pictures != null) {
      for (final picture in pictures!) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'pictures',
            picture.bytes,
            filename: picture.name,
          ),
        );
      }
    }

    return request;
  }
}

class CommunityPostPictureFile {
  final Uint8List bytes;
  final String name;

  CommunityPostPictureFile({required this.bytes, required this.name});
}
