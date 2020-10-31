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

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(
                  title: 'Registro',
                ),
                _Form(),
                Labels(
                  text1: 'Ya tienes cuenta?',
                  text2: 'Ingresa ahora!',
                  route: 'login',
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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 50.0,
      ),
      child: Column(
        children: [
          CustomInput(
            icon: Icons.perm_identity,
            placeHolder: 'Nombre',
            keyboardType: TextInputType.text,
            textController: nameController,
          ),
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
                    final registerOk = await authService.register(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passController.text.trim(),
                    );

                    if (registerOk == true) {
                      socketService.connect();
                      Navigator.pushReplacementNamed(context, 'usuarios');
                    } else {
                      // mostrar alerta
                      mostrarAlerta(context, 'Registro incorrecto',
                          'Sus credenciales no son validas');
                    }
                  },
          ),
        ],
      ),
    );
  }
}
