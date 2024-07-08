import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serverapp/pages/gemini_review_page.dart';

class ProblemPage extends StatefulWidget {
  const ProblemPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProblemPageState();
}

class _ProblemPageState extends State<ProblemPage> with AutomaticKeepAliveClientMixin<ProblemPage> {
  final imagePicker = ImagePicker();

  void _showGeminiReviewPage(ImageSource source) async {
    final image = await imagePicker.pickImage(source: source);
    if (image != null) {
      if (!context.mounted) throw StateError('Context not mounted');
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => GeminiReviewPage(imagePath: image.path))
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: const Center(
        child: Text('Search Something!'),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: _floatingActionButton(),
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

