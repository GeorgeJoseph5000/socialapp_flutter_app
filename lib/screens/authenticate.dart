import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/ui/ui_shortcuts.dart';
import '../provider/user_provider.dart';

class Authenticate extends HookWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    var usernameController = TextEditingController();

    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    var segmentedControlGroupValue = useState(0);
    var loginRegister = useState(true);
    const Map<int, Widget> myTabs = <int, Widget>{
      0: Text("Login"),
      1: Text("Register")
    };

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SocialApp",
              style: TextStyle(fontSize: 50),
            ),
            const SizedBox(
              height: 30,
            ),
            CupertinoSlidingSegmentedControl(
                groupValue: segmentedControlGroupValue.value,
                children: myTabs,
                onValueChanged: (i) {
                  segmentedControlGroupValue.value = i! as int;
                  segmentedControlGroupValue.value == 0
                      ? loginRegister.value = true
                      : loginRegister.value = false;
                }),
            loginRegister.value
                ? Text("")
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            StyledButton(loginRegister.value ? "Login" : "Register", () {
              loginRegister.value
                  ? _login(emailController.text, passwordController.text,
                      context, userProvider)
                  : _register(usernameController.text, emailController.text,
                      passwordController.text, context, userProvider);
            })
          ],
        ),
      ),
    );
  }
}

_register(String username, String email, String password, BuildContext context,
    UserProvider userProvider) async {
  if (password == "" || email == "" || username == "") {
    showSnackBar(context, "Fill all fields");
  } else {
    String emailText = email.trimLeft().trimRight();
    String passwordText = password.trimLeft().trimRight();
    String usernameText = username.trimLeft().trimRight();
    if (!EmailValidator.validate(emailText)) {
      showSnackBar(context, "Enter a valid email");
    } else {
      Response response =
          await userProvider.register(usernameText, emailText, passwordText);
      if (response.statusCode == 500) {
        showSnackBar(context, "Error while connecting");
      }
    }
  }
}

_login(String email, String password, BuildContext context,
    UserProvider userProvider) async {
  if (password == "" || email == "") {
    showSnackBar(context, "Fill all fields");
  } else {
    String emailText = email.trimLeft().trimRight();
    String passwordText = password.trimLeft().trimRight();
    if (!EmailValidator.validate(emailText)) {
      showSnackBar(context, "Enter a valid email");
    } else {
      Response response = await userProvider.login(emailText, passwordText);
      if (response.statusCode == 400) {
        showSnackBar(context, "Invalid Credentials");
      } else if (response.statusCode == 500) {
        showSnackBar(context, "Error while connecting");
      }
    }
  }
}
