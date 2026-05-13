import 'package:cloud_firestore/cloud_firestore.dart';

class PosterModel {
  final String id;
  String imageUrl;
  final bool active;

  PosterModel({
    required this.id,
    required this.imageUrl,
    required this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': imageUrl,
      'Active': active,
    };
  }

  factory PosterModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PosterModel(
      id: snapshot.id,
      imageUrl: data['ImageUrl'] ?? '',
      active: data['Active'] ?? true,
    );
  }
}

