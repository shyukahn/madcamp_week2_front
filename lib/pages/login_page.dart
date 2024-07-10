import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:serverapp/pages/HomePage.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _userUrl = Uri.parse('${dotenv.env['baseUrl']}users/save_user/');

  void _signInWithKakao(BuildContext context) async {
    bool isUserLoggedIn = false;
    try {
      bool isInstalled = await isKakaoTalkInstalled();

      OAuthToken token = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk() // if installed execute KakaoTalk
          : await UserApi.instance.loginWithKakaoAccount(); // else Kakao web

      final user = await UserApi.instance.me();
      isUserLoggedIn = true;
      final response = await http.post(_userUrl,
        body: {
          'kakao_id' : user.id.toString(),
          'nickname' : user.kakaoAccount!.profile!.nickname,
          'profile_image' : user.kakaoAccount!.profile!.profileImageUrl.toString(),
          'thumbnail_image' : user.kakaoAccount!.profile!.thumbnailImageUrl.toString()
        }
      );
      // 200 -> update OK, 201 -> Created
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!context.mounted) {
          throw StateError('Widget not mounted');
        }
        Fluttertoast.showToast(msg: '카카오톡으로 로그인했습니다');
        _gotoHomepage(context);
      } else {
        throw const HttpException('Bad response: 인터넷 연결을 확인해주세요');
      }
    } catch (error) {
      // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
      // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
      if(isUserLoggedIn) {
        await UserApi.instance.logout();
      }
      if (error is PlatformException && error.code == 'CANCELED') {
        Fluttertoast.showToast(msg: '로그인이 취소되었습니다');
      } else {
        Fluttertoast.showToast(msg: error.toString());
      }
    }
  }

  void _gotoHomepage(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Homepage(title: 'LingoHub'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 24.0, 0.0),
                child: Image.asset('assets/images/icon.png'),
              ),
              _kakaoLoginButton(
                  'kakao_login_medium_wide.png',
                      () => _signInWithKakao(context)
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _kakaoLoginButton(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset('assets/images/$path'),
    );
  }
}