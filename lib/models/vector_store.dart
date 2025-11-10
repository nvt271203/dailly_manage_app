import 'dart:convert';

class VectorStore {
  final String id;
  final String total_chunks_added;
  final String errors;

  VectorStore({required this.id, required this.total_chunks_added, required this.errors});

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "total_chunks_added": this.total_chunks_added,
      "errors": this.errors,
    };
  }
  String toJson(){
    return json.encode(toMap());
  }

  factory VectorStore.fromMap(Map<String, dynamic> json) {
    return VectorStore(id: json["id"],
      total_chunks_added: json["total_chunks_added"],
      errors: json["errors"],);
  }
  factory VectorStore.fromJson(String json){
    return VectorStore.fromMap(jsonDecode(json));
  }



}