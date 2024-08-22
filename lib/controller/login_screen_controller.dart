// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreenController with ChangeNotifier {
  bool isloading = false;
  Future<bool> onLogin(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      isloading = true;
      notifyListeners();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user?.uid != null) {
        isloading = false;
        notifyListeners();
        return true;
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     backgroundColor: Colors.green,
        //     content: Text("Registraion Success")));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user found for that email.')));
        isloading = false;
        notifyListeners();
        return false;
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('Wrong password provided for that user.')));
        return false;
        // print('The account already exists for that email.');
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      return false;
      print(e);
    }
    isloading = false;
    notifyListeners();
    return false;
  }
}
