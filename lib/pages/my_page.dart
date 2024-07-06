import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:serverapp/pages/login_page.dart';

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

  Future<dynamic> _showLogoutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('로그아웃 하시겠습니까?'),
        actionsPadding: const EdgeInsets.all(4),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showDeleteAccountDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('회원 탈퇴 하시겠습니까?\n계정정보가 모두 삭제됩니다.'),
        actionsPadding: const EdgeInsets.all(4),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('확인')),
        ],
      ),
    );
  }

  void _signOut() async {
    _returnToLoginPage();
    await UserApi.instance.logout();
  }

  void _deleteAccount() async {
    _returnToLoginPage();
    await UserApi.instance.unlink();
  }

  void _returnToLoginPage() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: _isLoading ? Alignment.center : Alignment.topCenter,
        child: _isLoading
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8,),
            Text('프로필 정보 불러오는 중...'),
          ],
        )
            : _user != null
            ? Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage(
                _user!.kakaoAccount!.profile!.profileImageUrl!,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _user!.kakaoAccount!.profile!.nickname ?? 'Unknown',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _kakaoLogoutButton(),
                const SizedBox(width: 10),
                _kakaoDeleteButton()
              ],
            ),
          ],
        )
            : const Text('Failed to load user profile'),
      ),
    );
  }

  Widget _kakaoLogoutButton() {
    return TextButton(
      onPressed: () {
        _showLogoutDialog(context);
      },
      style: const ButtonStyle(),
      child: const Text('로그아웃'),
    );
  }

  Widget _kakaoDeleteButton() {
    return TextButton(
      onPressed: () {
        _showDeleteAccountDialog(context);
      },
      style: const ButtonStyle(),
      child: const Text('회원 탈퇴'),
    );
  }
}