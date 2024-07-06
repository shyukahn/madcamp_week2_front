import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:serverapp/pages/HomePage.dart';
import 'package:serverapp/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/config/.env");
  KakaoSdk.init(nativeAppKey: dotenv.env['kakaoAppkey']);

  bool isLoggedIn = await checkKakaoLoginStatus();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> checkKakaoLoginStatus() async {
  try {
    final tokenInfo = await UserApi.instance.accessTokenInfo();
    return tokenInfo.id! > 0;
  } catch(error) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const Homepage(title: "Homepage Title") : LoginPage(),
    );
  }
}