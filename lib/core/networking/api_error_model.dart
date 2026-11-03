/// The error shape every feature surfaces to its UI (doc_doc-style error model).
class ApiErrorModel {
  final String? message;
  const ApiErrorModel({this.message});

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      ApiErrorModel(message: json['message'] as String?);

  Map<String, dynamic> toJson() => {'message': message};
}
