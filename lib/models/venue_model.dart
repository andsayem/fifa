class VenueModel {
  final int id;
  final String name;
  final String city;
  final int capacity;

  VenueModel({
    required this.id,
    required this.name,
    required this.city,
    required this.capacity,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      capacity: json['capacity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'capacity': capacity,
    };
  }
}
