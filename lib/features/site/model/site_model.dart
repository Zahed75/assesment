class SiteListModel {
  String? message;
  int? count;
  int? page;
  int? pageSize;
  int? numPages;
  String? next;
  Null? previous;
  List<Sites>? sites;

  SiteListModel({
    this.message,
    this.count,
    this.page,
    this.pageSize,
    this.numPages,
    this.next,
    this.previous,
    this.sites,
  });

  SiteListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    count = json['count'];
    page = json['page'];
    pageSize = json['page_size'];
    numPages = json['num_pages'];
    next = json['next'];
    previous = json['previous'];
    if (json['sites'] != null) {
      sites = <Sites>[];
      json['sites'].forEach((v) {
        sites!.add(new Sites.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['count'] = this.count;
    data['page'] = this.page;
    data['page_size'] = this.pageSize;
    data['num_pages'] = this.numPages;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.sites != null) {
      data['sites'] = this.sites!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sites {
  String? siteCode;
  String? name;
  String? address;

  Sites({this.siteCode, this.name, this.address});

  Sites.fromJson(Map<String, dynamic> json) {
    siteCode = json['site_code'];
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['site_code'] = this.siteCode;
    data['name'] = this.name;
    data['address'] = this.address;
    return data;
  }
}
