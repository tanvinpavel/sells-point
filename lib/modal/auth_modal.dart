class AuthModal {
  String? name;
  String? email;
  String? accessToken;
  String? userId;
  String? role;

  AuthModal({this.name, this.email, this.accessToken, this.userId, this.role});

  AuthModal.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    accessToken = json['accessToken'];
    userId = json['userId'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['accessToken'] = this.accessToken;
    data['userId'] = this.userId;
    data['role'] = this.role;
    return data;
  }
}