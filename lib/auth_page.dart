import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book_publishing_app/home_page.dart';
import 'package:flutter_book_publishing_app/snackbar_util.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AuthPage extends HookWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: '');
    final emailController = useTextEditingController(text: '');
    final passwordController = useTextEditingController(text: '');
    final passwordVisibility = useState<bool>(true);
    final isSubmitting = useState<bool>(false);

    final isMounted = useIsMounted();

    void signIn() async {
      if (emailController.text.length < 2 &&
          passwordController.text.length < 2) {
        return;
      }
      isSubmitting.value = true;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        isSubmitting.value = false;
        snackBar(context, 'Authentication', 'You just signed in',
            contentType: ContentType.success);
      } catch (e) {
        isSubmitting.value = false;
        if (isMounted()) {
          snackBar(context, 'Error', e.toString(),
              contentType: ContentType.failure);
        }
      }
    }

    void register() async {
      if (nameController.text.length < 2 &&
          emailController.text.length < 2 &&
          passwordController.text.length < 2) {
        return;
      }
      isSubmitting.value = true;
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        final usersCollection = FirebaseFirestore.instance.collection('users');
        await usersCollection.doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'username': nameController.text,
        });
        isSubmitting.value = false;
        snackBar(context, 'Authentication', 'You just signed in',
            contentType: ContentType.success);
      } catch (e) {
        isSubmitting.value = false;
        if (!isMounted()) {
          snackBar(context, 'Error', e.toString(),
              contentType: ContentType.failure);
        }
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hey, You',
                  textScaleFactor: 3,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Welcome to Flutter Book Publishing App.',
                  textScaleFactor: 1.5,
                  style: TextStyle(),
                ),
                const Text(
                  "We've been expecting you",
                  textScaleFactor: 1.5,
                  style: TextStyle(),
                ),
                const SizedBox(height: 30),
                const Text(
                  "N.b ❗: only enter you'r name if you want to sign up",
                  style: TextStyle(
                    color: Color.fromARGB(255, 217, 2, 255),
                  ),
                ),
                AuthTextInput(
                  controller: nameController,
                  enabled: !isSubmitting.value,
                  helperText: 'Name',
                ),
                const SizedBox(height: 10),
                AuthTextInput(
                  enabled: !isSubmitting.value,
                  controller: emailController,
                  helperText: 'Email',
                ),
                const SizedBox(height: 10),
                AuthTextInput(
                  enabled: !isSubmitting.value,
                  controller: passwordController,
                  helperText: 'Password',
                  onVisibilityPressed: () =>
                      passwordVisibility.value = !passwordVisibility.value,
                  visibility: passwordVisibility.value,
                ),
                const SizedBox(height: 60),
                if (isSubmitting.value == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: AuthButton(
                            inputData: 'Register',
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            onPressed: register,
                          ),
                        ),
                        Expanded(
                          child: AuthButton(
                            inputData: 'Sign in',
                            backgroundColor: Colors.grey[200],
                            textColor: Colors.black87,
                            onPressed: signIn,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    required this.inputData,
  });

  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final String inputData;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          fixedSize: const Size(30, 60),
          backgroundColor: backgroundColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)))),
      onPressed: onPressed,
      child: Text(inputData, style: TextStyle(color: textColor)),
    );
  }
}

class AuthTextInput extends StatelessWidget {
  const AuthTextInput({
    super.key,
    this.onChanged,
    this.controller,
    this.helperText,
    this.hintText,
    this.visibility = false,
    this.onVisibilityPressed,
    this.enabled = true,
  });
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  final String? helperText;
  final String? hintText;
  final bool visibility;
  final void Function()? onVisibilityPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 10,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )),
                helperText: helperText,
                hintText: hintText,
                enabled: enabled),
            onChanged: onChanged,
            controller: controller,
            obscureText: visibility,
          ),
        ),
        if (helperText == 'Password')
          Center(
              child: IconButton(
            style: const ButtonStyle(
              alignment: Alignment.center,
            ),
            onPressed: onVisibilityPressed,
            icon: Icon(visibility ? Icons.visibility_off : Icons.visibility),
          ))
      ],
    );
  }
}
