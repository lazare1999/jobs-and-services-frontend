import 'dart:convert';

import 'package:jobs_and_services/utils/lazo_utils.dart';

AuthenticationResponse authenticationResponseFromJson(String str) => AuthenticationResponse.fromJson(json.decode(str));

String authenticationResponseToJson(AuthenticationResponse data) => json.encode(data.toJson());

class AuthenticationResponse {
  AuthenticationResponse({
    this.jwt,
    this.expiresIn,
    this.expiresAt,
    this.refreshToken,
    this.refreshExpiresIn,
    this.refreshExpiresAt,
  });

  String? jwt;
  int? expiresIn;
  DateTime? expiresAt;
  String? refreshToken;
  int? refreshExpiresIn;
  DateTime? refreshExpiresAt;

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) => AuthenticationResponse(
    jwt: json["jwt"],
    expiresIn: json["expiresIn"],
    refreshToken: json["refreshToken"],
    refreshExpiresIn: json["refreshExpiresIn"],
  );

  Map<String, dynamic> toJson() => {
    "jwt": jwt,
    "expiresIn": expiresIn,
    "refreshToken": refreshToken,
    "refreshExpiresIn": refreshExpiresIn,
  };

  void update(String str) {
    var body = json.decode(str);

    if (body == null) {
      return;
    }
    if (body.containsKey("jwt")) {
      jwt = body["jwt"];
    }
    if (body.containsKey("refreshToken")) {
      refreshToken = body["refreshToken"];
    }
    if (body.containsKey("expiresIn")) {

      if (isInteger(body["expiresIn"])) {
        expiresIn = body["expiresIn"];
      } else {
        expiresIn = int.parse(body["expiresIn"]);
      }

      expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresIn!);
    }
    if (body.containsKey("refreshExpiresIn")) {

      if (isInteger(body["refreshExpiresIn"])) {
        refreshExpiresIn = body["refreshExpiresIn"];
      } else {
        refreshExpiresIn = int.parse(body["refreshExpiresIn"]);
      }

      refreshExpiresAt = DateTime.fromMillisecondsSinceEpoch(refreshExpiresIn!);
    }
  }

}