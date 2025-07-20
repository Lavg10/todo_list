// features/profile/presentation/cubit/profile_state.dart

import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final String? imageUrl;
  final String name;
  final String address;
  final String contact;
  final String age;
  final String? message;

  const ProfileState({
    this.isLoading = false,
    this.imageUrl,
    this.name = '',
    this.address = '',
    this.contact = '',
    this.age = '',
    this.message,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? imageUrl,
    String? name,
    String? address,
    String? contact,
    String? age,
    String? message,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      age: age ?? this.age,
      message: message,
    );
  }

  @override
  List<Object?> get props => [isLoading, imageUrl, name, address, contact, age, message];
}
