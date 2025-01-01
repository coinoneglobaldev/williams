// To parse this JSON data, do
//
//     final itemListModel = itemListModelFromJson(jsonString);

import 'dart:convert';

List<ItemListModel> itemListModelFromJson(String str) => List<ItemListModel>.from(json.decode(str).map((x) => ItemListModel.fromJson(x)));

String itemListModelToJson(List<ItemListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemListModel {
  String id;
  String name;
  String code;
  ItemGroup itemGroup;
  String bulkRate;
  String splitRate;

  ItemListModel({
    required this.id,
    required this.name,
    required this.code,
    required this.itemGroup,
    required this.bulkRate,
    required this.splitRate,
  });

  factory ItemListModel.fromJson(Map<String, dynamic> json) => ItemListModel(
    id: json["Id"],
    name: json["Name"],
    code: json["Code"],
    itemGroup: itemGroupValues.map[json["ItemGroup"]]!,
    bulkRate: json["BulkRate"],
    splitRate: json["SplitRate"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "Code": code,
    "ItemGroup": itemGroupValues.reverse[itemGroup],
    "BulkRate": bulkRate,
    "SplitRate": splitRate,
  };
}

enum ItemGroup {
  CHARCUTERIE,
  DAIRY,
  DRY_STORAGE,
  FROZEN,
  FRUITS,
  HERBS,
  JUICES,
  MEAT,
  MUSHROOMS,
  PREP_GOODS,
  SALADS,
  VEGETABLES,
  WINE
}

final itemGroupValues = EnumValues({
  "CHARCUTERIE": ItemGroup.CHARCUTERIE,
  "DAIRY": ItemGroup.DAIRY,
  "DRY STORAGE": ItemGroup.DRY_STORAGE,
  "FROZEN": ItemGroup.FROZEN,
  "FRUITS": ItemGroup.FRUITS,
  "HERBS": ItemGroup.HERBS,
  "JUICES": ItemGroup.JUICES,
  "MEAT": ItemGroup.MEAT,
  "MUSHROOMS": ItemGroup.MUSHROOMS,
  "PREP GOODS": ItemGroup.PREP_GOODS,
  "SALADS": ItemGroup.SALADS,
  "VEGETABLES": ItemGroup.VEGETABLES,
  "WINE": ItemGroup.WINE
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
