// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistrationScreenController with ChangeNotifier {
  bool isloading = false;
  Future<bool> register(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      isloading = true;
      notifyListeners();
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("The password provided is too weak")));
        isloading = false;
        notifyListeners();
        return false;
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("The account already exists for that email")));
        return false;
        // print('The account already exists for that email.');
      }
    } catch (e) {
      isloading = false;
      notifyListeners();
      return false;
    }
    isloading = false;
    notifyListeners();
    return false;
  }
}
