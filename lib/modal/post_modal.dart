class PostModal {
  String? sId;
  String? creator;
  String? image;
  String? publicId;
  int? price;
  String? post;
  String? status;
  bool? private;
  UserDetails? userDetails;

  PostModal(
      {this.sId,
      this.creator,
      this.image,
      this.publicId,
      this.price,
      this.post,
      this.status,
      this.private,
      this.userDetails});

  PostModal.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    creator = json['creator'];
    image = json['image'];
    publicId = json['publicId'];
    price = json['price'];
    post = json['post'];
    status = json['status'];
    private = json['private'];
    userDetails = json['userDetails'] != null
        ? new UserDetails.fromJson(json['userDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['creator'] = this.creator;
    data['image'] = this.image;
    data['publicId'] = this.publicId;
    data['price'] = this.price;
    data['post'] = this.post;
    data['status'] = this.status;
    data['private'] = this.private;
    if (this.userDetails != null) {
      data['userDetails'] = this.userDetails!.toJson();
    }
    return data;
  }
}

class UserDetails {
  String? sId;
  String? firstName;
  String? lastName;
  String? email;
  String? birthDate;

  UserDetails(
      {this.sId, this.firstName, this.lastName, this.email, this.birthDate});

  UserDetails.fromJson(Map<String, dynamic> json) {
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
