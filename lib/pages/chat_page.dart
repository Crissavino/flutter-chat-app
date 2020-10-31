import 'dart:io';

import 'package:chat_app/models/mensaje.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widget/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _estaEscribiendo = false;
  ChatService chatService;
  SocketService socketService;
  AuthService authService;

  List<ChatMessage> _messages = [];

  @override
  void initState() {
    // TODO: implement initState
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('mensaje-personal', _escucharMensaje);

    _cargarHistorial(this.chatService.usuarioPara.uuid);
  }

  void _cargarHistorial(String uuid) async {
    List<Mensaje> chat = await this.chatService.getChat(uuid);
    final history = chat.map(
      (m) => ChatMessage(
        texto: m.mensaje,
        uuid: m.de,
        animationController: AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: 0,
          ),
        )..forward(),
      ),
    );

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      texto: payload['mensaje'],
      uuid: payload['de'],
      animationController: AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 400,
        ),
      ),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioPara = this.chatService.usuarioPara;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                usuarioPara.nombre.substring(0, 2),
                style: TextStyle(fontSize: 12.0),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14.0,
            ),
            SizedBox(
              height: 3.0,
            ),
            Text(
              usuarioPara.nombre,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, int index) {
                  return _messages[index];
                },
              ),
            ),
            Divider(
              height: 1.0,
            ),
            Container(
              color: Colors.white,
              child: _inputChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String texto) {
                  setState(() {
                    if (texto.trim().length > 0) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enviar mensaje',
                ),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 4.0,
              ),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Enviar'),
                      onPressed: _estaEscribiendo
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.0,
                      ),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.send,
                          ),
                          onPressed: _estaEscribiendo
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String texto) {
    if (texto.length == 0) {
      return;
    }
    final newMessage = ChatMessage(
      uuid: this.authService.usuario.uuid,
      texto: texto,
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );
    _messages.insert(0, newMessage);
    // desp de insertar el mensaje disparo la animacion
    newMessage.animationController.forward();

    _focusNode.requestFocus();
    _textController.clear();

    setState(() {
      _estaEscribiendo = false;
    });

    this.socketService.socket.emit('mensaje-personal', {
      'de': this.authService.usuario.uuid,
      'para': this.chatService.usuarioPara.uuid,
      'mensaje': texto
    });
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }
    _textController.dispose();
    this.socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
