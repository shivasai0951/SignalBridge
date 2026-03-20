class ContactModel {

  int? id;
  String name;
  String uniqueId;
  String? image;

  ContactModel({
    this.id,
    required this.name,
    required this.uniqueId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "uniqueId": uniqueId,
      "image": image,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map["id"],
      name: map["name"],
      uniqueId: map["uniqueId"],
      image: map["image"],
    );
  }
}