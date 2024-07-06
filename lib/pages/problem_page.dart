import 'package:flutter/material.dart';
import 'package:serverapp/api/gemini_api.dart';

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> {
  String? _response;
  bool _loading = false;
  final TextEditingController _geminiInputController = TextEditingController();

  void _getResponse() async {
    setState(() {
      _loading = true;
      _response = null;
    });

    final response = await GeminiSource.getFromText(_geminiInputController.text);

    setState(() {
      _response = response;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _geminiResponseText(),
          const SizedBox(height: 24),
          _userInputTextField(),
          const SizedBox(height: 12),
          _getResponseButton(),
        ],
      ),
    );
  }

  Widget _geminiResponseText() {
    if (_loading) {
      return const Column(
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
            maxHeight: 300
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

  Widget _userInputTextField() {
    return TextField(
      controller: _geminiInputController,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: 'Enter your query',
        suffixIcon: IconButton(
          onPressed: _geminiInputController.clear,
          icon: const Icon(Icons.clear),
        )
      ),
    );
  }

  Widget _getResponseButton() {
    return TextButton(
      onPressed: _getResponse,
      child: const Text('Get response from Gemini'),
    );
  }
}

