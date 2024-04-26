class UserModal {
  String? sId;
  String? firstName;
  String? lastName;
  String? email;
  String? birthDate;

  UserModal(
      {this.sId, this.firstName, this.lastName, this.email, this.birthDate});

  UserModal.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    birthDate = json['birthDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['birthDate'] = this.birthDate;
    return data;
  }
}
