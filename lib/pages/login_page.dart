import 'package:chat_app/helpers/mostrar_alerta.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widget/boton_azul.dart';
import 'package:chat_app/widget/custom_input.dart';
import 'package:chat_app/widget/labels.dart';
import 'package:chat_app/widget/logo.dart';
import 'package:chat_app/widget/terms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(
                  title: 'Messenger',
                ),
                _Form(),
                Labels(
                  text1: 'No tienes cuenta?',
                  text2: 'Crea una ahora!',
                  route: 'register',
                ),
                Terms(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  __FormState createState() => __FormState();
}

class __FormState extends State<_Form> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      margin: EdgeInsets.only(
        top: 40.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 50.0,
      ),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.mail_outline,
            placeHolder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailController,
          ),
          CustomInput(
            icon: Icons.lock_outline,
            placeHolder: 'Password',
            textController: passController,
            isPassword: true,
          ),
          BotonAzul(
            btnLabel: 'Ingrese',
            onPressed: authService.autenticando
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    final loginOk = await authService.login(
                        emailController.text.trim(),
                        passController.text.trim());

                    if (loginOk) {
                      socketService.connect();

                      Navigator.pushReplacementNamed(context, 'usuarios');
                    } else {
                      // mostrar alerta
                      mostrarAlerta(context, 'Login incorrecto',
                          'Revise su credenciales');
                    }
                  },
          ),
        ],
      ),
    );
  }
}
