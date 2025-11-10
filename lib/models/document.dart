import 'dart:convert';

class Document {
  final String id;
  final String name;
  final String pdfUrl;
  final bool isTrain;
  final String cloudinaryId;
  final DateTime uploadedAt;

  Document({required this.id, required this.name, required this.pdfUrl, required this.cloudinaryId, required this.isTrain,required this.uploadedAt});

  factory Document.fromMap(Map<String, dynamic> json) {
    return Document(id: json["_id"],
      name: json["name"],
      pdfUrl: json["pdfUrl"],
      isTrain: json["isTrain"],
      cloudinaryId: json["cloudinaryId"],
      uploadedAt: DateTime.parse(json["uploadedAt"]),);

  }
  factory Document.fromJson(String json){
    return Document.fromMap(jsonDecode(json));
  }

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "name": this.name,
      "pdfUrl": this.pdfUrl,
      "isTrain": this.isTrain,
      "cloudinaryId": this.cloudinaryId,
      "uploadedAt": this.uploadedAt.toIso8601String(),
    };
  }
  String toJson(){
    return jsonEncode(toMap());
  }


}