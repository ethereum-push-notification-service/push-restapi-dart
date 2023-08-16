
class LivepeerStreamDetails {
  String? streamKey;
  String? playbackId;

  LivepeerStreamDetails({this.streamKey, this.playbackId});

  LivepeerStreamDetails.fromJson(Map<String, dynamic> json) {
    streamKey = json['streamKey'];
    playbackId = json['playbackId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['streamKey'] = streamKey;
    data['playbackId'] = playbackId;
    return data;
  }
}

class LivepeerParticipant {
  String? id;
  String? joinUrl;
  String? token;

  LivepeerParticipant({this.id, this.joinUrl, this.token});

  LivepeerParticipant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    joinUrl = json['joinUrl'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['joinUrl'] = joinUrl;
    data['token'] = token;
    return data;
  }
}
