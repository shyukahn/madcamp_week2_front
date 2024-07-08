import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serverapp/api/gemini_api.dart';

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  String? _response;
  bool _loading = false;
  final imagePicker = ImagePicker();

  void _getResponse(ImageSource source) async {
    setState(() {
      _loading = true;
      _response = null;
    });

    final image = await imagePicker.pickImage(source: source);
    if (image == null) {
      setState(() {
        _loading = false;
      });
    }

    final response = await GeminiSource.getFromImageAndText(
      File(image!.path),
      '이 문제를 보고 문제를 한국어로 번역해주고, 문제의 답을 준 다음 풀이도 써줘. 답변은 JSON형식으로 해주고, 번역문은 content 키에, 답은 answer 키에, 풀이는 solution 키에 넣어줘.'
    );

    setState(() {
      _response = response;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        body: Center(
          child: _geminiResponseText(),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: _floatingActionButton(),
      )
    );
  }

  Widget _geminiResponseText() {
    if (_loading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Gemini 답변 받아오는 중...')
        ],
      );
    } else if (_response != null) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        constraints: const BoxConstraints(
            maxHeight: 500
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Text(_response!),
        ),
      );
    } else {
      return const Center(
          child: Text('Search something!')
      );
    }
  }

  Widget _floatingActionButton() {
    return ExpandableFab(
      distance: 75,
      duration: const Duration(milliseconds: 200),
      type: ExpandableFabType.up,
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
        angle: 0.7854,
      ),
      closeButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        shape: const CircleBorder(),
      ),
      children: [
        _fabGallery(),
        _fabCamera(),
      ],
    );
  }

  Widget _fabCamera() {
    return FloatingActionButton(
      onPressed: () {
        _getResponse(ImageSource.camera);
      },
      shape: const CircleBorder(),
      child: const Icon(Icons.add_a_photo),
    );
  }

  Widget _fabGallery() {
    return FloatingActionButton(
      onPressed: () {
        _getResponse(ImageSource.gallery);
      },
      shape: const CircleBorder(),
      child: const Icon(Icons.add_photo_alternate),
    );
  }
}

