// To parse this JSON data, do
//
//     final renewTokenResponse = renewTokenResponseFromJson(jsonString);

import 'dart:convert';

import 'package:chat_app/models/usuario.dart';

RenewTokenResponse renewTokenResponseFromJson(String str) =>
    RenewTokenResponse.fromJson(json.decode(str));

String renewTokenResponseToJson(RenewTokenResponse data) =>
    json.encode(data.toJson());

class RenewTokenResponse {
  RenewTokenResponse({
    this.ok,
    this.usuario,
    this.token,
  });

  bool ok;
  Usuario usuario;
  String token;

  factory RenewTokenResponse.fromJson(Map<String, dynamic> json) =>
      RenewTokenResponse(
        ok: json["ok"],
        usuario: Usuario.fromJson(json["usuario"]),
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "usuario": usuario.toJson(),
        "token": token,
      };
}
