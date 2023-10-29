import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_publishing_app/auth_page.dart';
import 'package:flutter_book_publishing_app/home_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SplashPage extends HookWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = useStream(FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser);
    // final controller = useAnimationController(
    //   duration: const Duration(milliseconds: 500),
    // );

    // useEffect(() {
    //   controller.repeat();
    //   return null;
    // }, const []);

    // final rotation = useAnimation(
    //   CurvedAnimation(
    //     parent: controller,
    //     curve: Curves.linear,
    //   ),
    // );
    return Scaffold(
      body: user.data != null ? const HomePage() : const AuthPage(),
    );
  }
}



// Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               'Routing to page...\nPlease wait.🚶',
//               style: TextStyle(
//                 fontFamily: 'Calligraffitti',
//                 fontSize: 48.0,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.purple,
//                 wordSpacing: 20.0,
//               ),
//             ),
//             const SizedBox(height: 50),
//             AnimatedBuilder(
//               animation: controller,
//               builder: (context, child) {
//                 return Transform.rotate(
//                   angle: rotation * 6.28319, // 360 degrees in radians
//                   child: Container(
//                     width: 100.0,
//                     height: 4.0,
//                     color: Colors.purple,
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),