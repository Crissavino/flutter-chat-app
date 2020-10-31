// To parse this JSON data, do
//
//     final mensajeResponse = mensajeResponseFromJson(jsonString);

import 'dart:convert';

import 'package:chat_app/models/mensaje.dart';

MensajesResponse mensajeResponseFromJson(String str) =>
    MensajesResponse.fromJson(json.decode(str));

String mensajeResponseToJson(MensajesResponse data) =>
    json.encode(data.toJson());

class MensajesResponse {
  MensajesResponse({
    this.ok,
    this.mensajes,
  });

  bool ok;
  List<Mensaje> mensajes;

  factory MensajesResponse.fromJson(Map<String, dynamic> json) =>
      MensajesResponse(
        ok: json["ok"],
        mensajes: List<Mensaje>.from(
            json["mensajes"].map((x) => Mensaje.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "mensajes": List<dynamic>.from(mensajes.map((x) => x.toJson())),
      };
}
