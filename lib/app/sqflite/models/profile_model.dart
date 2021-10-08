import 'dart:convert';

import 'package:http/http.dart';

class ProfileModel {
  int? id;
  String? firstName;
  String? lastName;
  String? nickname;
  String? email;
  String? phoneNumber;
  String? rating;

  ProfileModel({this.id, this.firstName, this.lastName, this.nickname, this.email, this.phoneNumber, this.rating});

  Map<String, dynamic> toMap() {
    return {
      'id': id !=null ? id.toString() : "",
      'firstName': firstName ?? "",
      'lastName': lastName ?? "",
      'nickname': nickname ?? "",
      'email': email ?? "",
      'phoneNumber': phoneNumber ?? "",
      'rating': rating ?? "0",
    };
  }

  void updateProfile(Response response) {
    var body = json.decode(utf8.decode(response.bodyBytes));

    if (body == null) {
      return;
    }
    if (body.containsKey("userId")) {
      id = body["userId"] ?? 0;
    } else {
      id = 0;
    }
    if (body.containsKey("email")) {
      email = body["email"] ==null ? "" : body["email"].toString();
    } else {
      email = "";
    }
    if (body.containsKey("firstName")) {
      firstName = body["firstName"] ==null ? "" : body["firstName"].toString();
    } else {
      firstName = "";
    }
    if (body.containsKey("lastName")) {
      lastName = body["lastName"] ==null ? "" : body["lastName"].toString();
    } else {
      lastName = "";
    }
    if (body.containsKey("nickname")) {
      nickname = body["nickname"] ==null ? "" : body["nickname"].toString();
    } else {
      nickname = "";
    }
    if (body.containsKey("username")) {
      phoneNumber = body["username"] ==null ? "" : body["username"].toString();
    } else {
      phoneNumber = "";
    }
    if (body.containsKey("rating")) {
      rating = body["rating"] ==null ? "0" : body["rating"].toString();
    } else {
      rating = "0";
    }
  }
}