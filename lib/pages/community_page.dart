import 'package:flutter/cupertino.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Page 1',
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
    );
  }
}