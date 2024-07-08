import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/gemini_api.dart';
import '../models/gemini_response.dart';

class GeminiReviewPage extends StatefulWidget {
  const GeminiReviewPage({super.key, required this.imagePath});

  final String imagePath;

  @override
  State createState() => _GeminiReviewPageState();
}

class _GeminiReviewPageState extends State<GeminiReviewPage> {
  GeminiResponse? _response;
  bool _loading = true;
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

  void _addResponse() {
    Navigator.of(context).pop();
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
                  TextButton(onPressed: _addResponse, child: const Text('추가')),
                ],
              )
            ]
          )
        )
      )
          : const Center(child: Text('Search something!')),
    );
  }
}
