import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;

import '../api/gemini_api.dart';
import '../models/gemini_response.dart';

class GeminiReviewPage extends StatefulWidget {
  const GeminiReviewPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State createState() => _GeminiReviewPageState();
}

class _GeminiReviewPageState extends State<GeminiReviewPage> {
  final _questionUrl = '${dotenv.env['baseUrl']}my_question/my_page/user_question/';
  GeminiResponse? _response;
  bool _loading = true;
  bool _isAddingResponse = true;
  final imagePicker = ImagePicker();

  void _getResponse() async {
    final responseRaw = await GeminiSource.getFromImageAndText(
        File(widget.imagePath),
        '이 문제를 보고 문제를 한국어로 번역해주고, 문제의 답을 준 다음 풀이도 써줘. 답변은 JSON형식으로 해주고, 번역문은 content 키에, 답은 answer 키에, 풀이는 solution 키에 넣어줘.'
    );
    // trim '''json and ''' at start and end
    final responseString = responseRaw.substring(7, responseRaw.length - 3).trim();
    final response = GeminiResponse.fromString(responseString);

    setState(() {
      _loading = false;
      _response = response;
    });
  }

  void _showAddResponseDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return _addResponseDialog(context, setState);
              }
          );
        }
    );
  }

  void _addResponse() async {
    final user = await UserApi.instance.me();
    final addResponse = await http.post(
        Uri.parse(_questionUrl),
        body: {
          "kakao_id" : user.id.toString(),
          "content" : _response!.content,
          "answer" : '답: ${_response!.answer}\n해설: ${_response!.solution}',
        }
    );
    if (addResponse.statusCode == 201) {
      Fluttertoast.showToast(msg: 'Gemini 답변이 저장되었습니다');
    } else {
      Fluttertoast.showToast(msg: '오류가 발생했습니다');
    }
    setState(() {
      _isAddingResponse = false;
      Navigator.of(context).pop();
      _showAddResponseDialog();
    });
  }

  @override
  void initState() {
    super.initState();
    _getResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Review'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Gemini 답변 받아오는 중...')
          ],
        ),
      )
          : _response != null
          ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      constraints: const BoxConstraints(maxHeight: 500),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('문제 번역: ${_response!.content}'),
                            Text('답: ${_response!.answer}'),
                            Text('해설: ${_response!.solution}'),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('취소')
                        ),
                        TextButton(
                            onPressed: () {
                              _addResponse();
                              _showAddResponseDialog();
                            },
                            child: const Text('추가')
                        ),
                      ],
                    )
                  ]
              )
          )
      )
          : const Center(child: Text('Search something!')),
    );
  }

  Widget _addResponseDialog(BuildContext context, StateSetter setState) {
    if (_isAddingResponse) {
      return AlertDialog(
        shape: RoundedRectangleBorder(),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 8.0,),
            Text('Gemini 답변 저장 중...'),
          ],
        ),
      );
    } else {
      return AlertDialog(
        shape: RoundedRectangleBorder(),
        content: Text('답변이 저장되었습니다.'),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('확인')
          )
        ],
      );
    }
  }
}
