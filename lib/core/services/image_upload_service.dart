import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final _uuid = const Uuid();

  Future<String> uploadImageToImgBB(File imageFile) async {
    final imgbbApiKey = dotenv.env['IMGBB_API_KEY'];

    if (imgbbApiKey == null || imgbbApiKey.isEmpty) {
      throw Exception('IMGBB_API_KEY is not defined in .env');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');

    final response = await http.post(url, body: {
      'image': base64Image,
      'name': _uuid.v4(),
    });

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data']['url'];
    } else {
      throw Exception('ImgBB upload failed: ${data['error']['message']}');
    }
  }
}
