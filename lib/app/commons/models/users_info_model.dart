class UsersInfoModel {
  UsersInfoModel({
    this.userId,
    this.firstName,
    this.lastName,
    this.rating,
    this.nickname,
    this.mainNickname,
    this.isFav,
    this.isPaid,
  });

  factory UsersInfoModel.fromJson(Map<String, dynamic> json) =>
      UsersInfoModel(
        userId: json['userId'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        rating: json['rating'],
        nickname: json['nickname'],
        mainNickname: json['mainNickname'],
        isFav: json['isFav'],
        isPaid: json['isPaid'],
      );

  final int? userId;
  final String? firstName;
  final String? lastName;
  final double? rating;
  final String? nickname;
  final String? mainNickname;
  final bool? isFav;
  final bool? isPaid;

}