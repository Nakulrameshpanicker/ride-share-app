import 'dart:convert';


UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String userId;
  String phoneNumber;
  String token;

  UserModel(
      {required this.userId, required this.phoneNumber, required this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      phoneNumber: json["phoneNumber"],
      userId: json["userId"],
      token: json["token"]);

  Map<String, dynamic> toJson() =>
      {"userId": userId, "phoneNumber": phoneNumber, "token": token};
}

class AddressModel {
  String? address = "";
  String? landMark = "";
  String? pinCode = "";
  String? userId = "";
  String? street = "";

  String? id = "";

  String? fullName = "";

  String? phoneNumber = "";
  String? city = "";
  String? state = "";
  String? country = "";
  double? latitude = 0.0;
  double? longitude = 0.0;

  bool isLoading = false;

  AddressModel(
      {this.address,
        this.landMark,
        this.street,
        this.pinCode,
        this.userId,
        this.phoneNumber,
        this.id,
        this.fullName,
        this.city,
        this.state,
        this.country,
        this.longitude,
        this.latitude});

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
      address: json["address"],
      landMark: json["landMark"],
      street: json["street"],
      pinCode: json["pinCode"],
      userId: json["userId"],
      phoneNumber: json["phoneNumber"],
      fullName: json["fullName"],
      city: json["city"],
      state: json["state"],
      id: json["id"],
      country: json["country"],
  latitude: json["latitude"],
  longitude: json["longitude"]);

  Map<String, dynamic> toJson() => {
    "address": address,
    "landMark": landMark,
    "pinCode": pinCode,
    "userId": userId,
    "id": id,
    "street": street,
    "fullName": fullName,
    "phoneNumber": phoneNumber,
    "city": city,
    "state": state,
    "country": country,
    "latitude": latitude,
    "longitude": longitude
  };
}
