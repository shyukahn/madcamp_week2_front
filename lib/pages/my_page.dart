import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userResponse = await UserApi.instance.me();
      setState(()  {
        _user = userResponse;
      });
    } catch (e) {
      // Handle exceptions (e.g., display an error message)
      print('Error fetching user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: _isLoading
            ? const CircularProgressIndicator()
            : _user != null
            ? Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                _user!.kakaoAccount!.profile!.profileImageUrl!,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _user!.kakaoAccount!.profile!.nickname ?? 'Unknown',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        )
            : const Text('Failed to load user profile'),
      ),
    );
  }
}