class UpsertDTO {
  List<String> members;
  List<String> admins;

  UpsertDTO({this.members = const [], this.admins = const []});

  factory UpsertDTO.fromJson(Map<String, dynamic> json) {
    return UpsertDTO(
      admins: json['admins'].cast<String>() ?? [],
      members: json['members'].cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['members'] = members;
    data['admins'] = admins;
    return data;
  }
}
