import 'dart:convert';

List<CategoryListModel> categoryListModelFromJson(String str) =>
    List<CategoryListModel>.from(
        json.decode(str).map((x) => CategoryListModel.fromJson(x)));

String categoryListModelToJson(List<CategoryListModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryListModel {
  String id;
  String name;
  String code;

  CategoryListModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CategoryListModel.fromJson(Map<String, dynamic> json) =>
      CategoryListModel(
        id: json["Id"],
        name: json["Name"],
        code: json["Code"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Code": code,
      };
}
