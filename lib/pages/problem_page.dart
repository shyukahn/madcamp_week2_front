import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:page_transition/page_transition.dart';
import 'package:serverapp/pages/gemini_review_page.dart';
import 'package:http/http.dart' as http;

import '../models/gemini_response.dart';
import 'new_post_page.dart';

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage>{
  final imagePicker = ImagePicker();
  bool _isLoading = true;
  final _questionUrl = '${dotenv.env['baseUrl']}my_question/my_page/user_question/';
  List<GeminiResponse>? _pastQuestions;

  void _showGeminiReviewPage(ImageSource source) async {
    final image = await imagePicker.pickImage(source: source);
    if (image != null) {
      if (!context.mounted) throw StateError('Context not mounted');
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => GeminiReviewPage(imagePath: image.path))
      ).then((_) {
        setState(() {
          _isLoading = true;
        });
        _getPastQuestions();
      })
      ;
    }
  }

  @override
  void initState() {
    _getPastQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: _showPastQuestions(),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: _floatingActionButton(),
    );
  }

  void _getPastQuestions() async {
    final user = await UserApi.instance.me();
    final pastQuestionsResponse = await http.get(Uri.parse('$_questionUrl?kakao_id=${user.id}'));
    if (pastQuestionsResponse.statusCode == 200) {
      final List<Map<String, dynamic>> jsonList = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(pastQuestionsResponse.bodyBytes)));
      setState(() {
        _pastQuestions = jsonList.map(
                (Map<String, dynamic> jsonMap) {
              return GeminiResponse(
                content: jsonMap['content']! as String,
                answer: jsonMap['answer']! as String,
                solution: '',
              );
            }
        ).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _showPastQuestions() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_pastQuestions == null) {
      return const Center(
          child: Text('오류가 발생했습니다')
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(12.0),
        itemCount: _pastQuestions!.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              _showDetailDialog(_pastQuestions![index]);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                title: Text(
                  _pastQuestions![index].content,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _pastQuestions![index].answer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          );
        },
      );
    }
  }

  void _writeNewPostWithQuestion(GeminiResponse question) {
    Navigator.of(context).push(
      PageTransition(
        child: NewPostPage(question: question,),
        type: PageTransitionType.bottomToTop,
        duration: Duration(milliseconds: 150),
        reverseDuration: Duration(milliseconds: 150),
        curve: Curves.easeInOutBack,
        inheritTheme: true,
        ctx: context,
      )
    );
  }

  void _showDetailDialog(GeminiResponse question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('문제: ${question.content}'),
                Divider(),
                Text(question.answer),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.all(8.0),
          actions: <Widget>[
            TextButton(
              child: const Text('공유'),
              onPressed: () {
                Navigator.of(context).pop();
                _writeNewPostWithQuestion(question);
              },
            ),
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        heroTag: null,
      ),
      closeButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        shape: const CircleBorder(),
        heroTag: null,
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
        _showGeminiReviewPage(ImageSource.camera);
      },
      shape: const CircleBorder(),
      heroTag: null,
      child: const Icon(Icons.add_a_photo),
    );
  }

  Widget _fabGallery() {
    return FloatingActionButton(
      onPressed: () {
        _showGeminiReviewPage(ImageSource.gallery);
      },
      shape: const CircleBorder(),
      heroTag: null,
      child: const Icon(Icons.add_photo_alternate),
    );
  }
}
