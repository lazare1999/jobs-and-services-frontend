class PaidUsersModel {

  int? id;
  int? userId;
  String? firstName;
  String? lastName;
  double? rating;
  String? nickname;
  String? mainNickname;
  bool? isFav;

  PaidUsersModel({
    this.id, this.userId, this.firstName, this.lastName, this.rating,
    this.nickname, this.mainNickname, this.isFav
  });


  void updatePaidUsersModel(var body, int id) {
    if (body == null) {
      return;
    }

    this.id = id;
    if (body.userId != null) {
      userId = body.userId;
    }
    if (body.firstName != null) {
      firstName = body.firstName;
    }
    if (body.lastName != null) {
      lastName = body.lastName;
    }
    if (body.rating != null) {
      rating = body.rating;
    }
    if (body.nickname != null) {
      nickname = body.nickname;
    }
    if (body.mainNickname != null) {
      mainNickname = body.mainNickname;
    }
    if (body.isFav != null) {
      isFav = body.isFav;
    }
  }
}