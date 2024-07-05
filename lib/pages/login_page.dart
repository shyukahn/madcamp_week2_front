import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:serverapp/pages/HomePage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login(BuildContext context) {
    // TODO: validate input with login server
    if (_usernameController.text == 'admin' && _passwordController.text == 'admin') {
      _gotoHomepage(context);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password'))
      );
    }
  }

  void signInWithKakao(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk() // if installed execute KakaoTalk
          : await UserApi.instance.loginWithKakaoAccount(); // else Kakao web

      print('카카오톡으로 로그인 성공');

      // 로그인 성공 후 사용자 정보 요청
      User user = await UserApi.instance.me();
      print('회원번호: ${user.id}\n');
      print('닉네임: ${user.kakaoAccount?.profile?.nickname}\n');

      _gotoHomepage(context);

    } catch (error) {
      print('카카오톡으로 로그인 실패 $error');
      // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
      // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
      if (error is PlatformException && error.code == 'CANCELED') {
        return;
      }
    }
  }

  void _gotoHomepage(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Homepage(title: 'Homepage Title'))
    );
  }

  void signOut() async {
    await UserApi.instance.unlink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _usernameTextField(),
            _passwordTextField(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Login'),
            ),
            _kakaoLoginButton(
                'kakao_login_medium_wide',
                () => signInWithKakao(context)
            ),
            _kakaoLogoutButton()
          ],
        ),
      ),
    );
  }

  Widget _usernameTextField() {
    return TextField(
      controller: _usernameController,
      decoration: const InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(
            color: Colors.grey,
          )
      ),
      textAlignVertical: TextAlignVertical.bottom,
    );
  }

  Widget _passwordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
      ),
      textAlignVertical: TextAlignVertical.bottom,
    );
  }

  Widget _kakaoLoginButton(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset('assets/images/$path.png'),
    );
  }

  Widget _kakaoLogoutButton() {
    return ElevatedButton(
      onPressed: signOut,
      style: ButtonStyle(),
      child: const Text('로그아웃'),
    );
  }
}