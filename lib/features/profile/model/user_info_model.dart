class GetUserInfoModel {
  int? code;
  String? message;
  Data? data;

  GetUserInfoModel({this.code, this.message, this.data});

  GetUserInfoModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  User? user;

  Data({this.user});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? staffId;
  String? designation;
  String? name;
  String? phoneNumber;
  bool? isVerified;
  String? access;
  Site? site;
  String? grantedAt;

  User({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.staffId,
    this.designation,
    this.name,
    this.phoneNumber,
    this.isVerified,
    this.access,
    this.site,
    this.grantedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    staffId = json['staff_id'];
    designation = json['designation'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    isVerified = json['is_verified'];
    access = json['access'];
    site = json['site'] != null ? new Site.fromJson(json['site']) : null;
    grantedAt = json['granted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['staff_id'] = this.staffId;
    data['designation'] = this.designation;
    data['name'] = this.name;
    data['phone_number'] = this.phoneNumber;
    data['is_verified'] = this.isVerified;
    data['access'] = this.access;
    if (this.site != null) {
      data['site'] = this.site!.toJson();
    }
    data['granted_at'] = this.grantedAt;
    return data;
  }
}

class Site {
  int? id;
  String? siteCode;
  String? name;
  Null? address;
  Null? district;
  Null? postCode;
  Platform? platform;
  String? source;

  Site({
    this.id,
    this.siteCode,
    this.name,
    this.address,
    this.district,
    this.postCode,
    this.platform,
    this.source,
  });

  Site.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    siteCode = json['site_code'];
    name = json['name'];
    address = json['address'];
    district = json['district'];
    postCode = json['post_code'];
    platform = json['platform'] != null
        ? new Platform.fromJson(json['platform'])
        : null;
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['site_code'] = this.siteCode;
    data['name'] = this.name;
    data['address'] = this.address;
    data['district'] = this.district;
    data['post_code'] = this.postCode;
    if (this.platform != null) {
      data['platform'] = this.platform!.toJson();
    }
    data['source'] = this.source;
    return data;
  }
}

class Platform {
  int? id;
  String? name;
  Null? description;

  Platform({this.id, this.name, this.description});

  Platform.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}
