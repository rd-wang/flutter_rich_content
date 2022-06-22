import 'dart:io';

enum HomeModuleType { video, audio, news, album, quiz ,scolling_banner,transformers,appPath}
enum RichContentType { audio, video, image, text}


class RichContent {
  int? _id;
  String? _type;
  Content? _content;
  int? _createdAt;
  RichContentType? _contentType;

  int? get id => _id;

  String? get type => _type;

  Content? get content => _content;

  int? get createdAt => _createdAt;

  RichContentType? get contentType => _contentType;

  RichContent({int? id, String? type, Content? content, int? createdAt,RichContentType? contentType}) {
    _id = id;
    _type = type;
    _content = content;
    _createdAt = createdAt;
    _contentType = contentType;
  }

  RichContent.fromJson(dynamic json) {
    _id = json['id'];
    _type = json['type'];
    _content = json['content'] != null ? Content.fromJson(json['content']) : null;
    _createdAt = json['createdAt'];

    if (_type == "audio") {
      _contentType = RichContentType.audio;
    } else if (_type == "video") {
      _contentType = RichContentType.video;
    } else if (_type == "image") {
      _contentType = RichContentType.image;
    } else if (_type == "text") {
      _contentType = RichContentType.text;
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['type'] = _type;
    if (_content != null) {
      map['content'] = _content!.toJson();
    }
    map['createdAt'] = _createdAt;
    return map;
  }
}

/// audio  video  quiz 的内容类    album 为ResourcesWarp  news为RichContent
class Content {
  String? _url;
  num? _duration;
  String? _text;
  String? _image;
  List<String>? _tags;
  int? _visitors;
  int? _createdAt;
  String? _name;

  String? get url => _url;

  num? get duration => _duration;

  String? get text => _text;

  String? get image => _image;

  List<String>? get tags => _tags;

  int? get visitors => _visitors;

  int? get createdAt => _createdAt;
  String? get name => _name;

  Content({String? url, int? duration, String? text, String? image, List<String>? tags, int? visitors, int? createdAt,String? name}) {
    _url = url;
    _duration = duration;
    _text = text;
    _image = image;
    _tags = tags;
    _visitors = visitors;
    _createdAt = createdAt;
    _name = name;
  }

  Content.fromJson(dynamic json) {
    _url = json['url'];
    _duration = json['duration'];
    _text = json['text'];
    _image = json['image'];
    _tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    _visitors = json['visitors'];
    _createdAt = json['createdAt'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['url'] = _url;
    map['duration'] = _duration;
    map['text'] = _text;
    map['image'] = _image;
    map['tags'] = _tags;
    map['visitors'] = _visitors;
    map['createdAt'] = _createdAt;
    map['name'] = _name;
    return map;
  }
}
