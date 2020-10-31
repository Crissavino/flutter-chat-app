import 'package:chat_app/models/usuario.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/services/usuarios_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final usuarioService = UsuariosService();

  List<Usuario> usuarios = [];

  @override
  void initState() {
    // TODO: implement initState
    this._cargarUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    final Usuario usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario.nombre,
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.exit_to_app,
            color: Colors.black87,
          ),
          onPressed: () {
            socketService.disconnect();
            Navigator.pushReplacementNamed(context, 'login');
            AuthService.deleteToken();
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[400])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        child: _listViewUsuarios(),
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: Colors.blue[400],
          ),
          waterDropColor: Colors.blue[400],
        ),
        onRefresh: _cargarUsuarios,
      ),
    );
  }

  ListView _listViewUsuarios() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemCount: usuarios.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemBuilder: (_, int index) {
        return _usuarioListTile(usuarios[index]);
      },
    );
  }

  ListTile _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          usuario.nombre.substring(0, 2),
        ),
      ),
      trailing: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: usuario.online ? Colors.green[300] : Colors.red,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);
        chatService.usuarioPara = usuario;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  _cargarUsuarios() async {
    this.usuarios = await usuarioService.getUsuarios();
    setState(() {});

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
