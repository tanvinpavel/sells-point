class AuthModal {
  String? name;
  String? email;
  String? accessToken;
  String? userId;

  AuthModal({this.name, this.email, this.accessToken, this.userId});

  AuthModal.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    accessToken = json['accessToken'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['accessToken'] = this.accessToken;
    data['userId'] = this.userId;
    return data;
  }
}
