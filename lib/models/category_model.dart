class CategoryModel {
  final String id;
  final String name;
  final String thumbnail;
  final String description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory']?.toString() ?? '',
      name: json['strCategory']?.toString() ?? '',
      thumbnail: json['strCategoryThumb']?.toString() ?? '',
      description: json['strCategoryDescription']?.toString() ?? '',
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? thumbnail,
    String? description,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
    );
  }
}
