// features/profile/presentation/cubit/profile_cubit.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit(this._profileService) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));
    final profile = await _profileService.getProfile();
    emit(
      state.copyWith(
        isLoading: false,
        imageUrl: profile?['avatar_url'],
        name: profile?['full_name'] ?? '',
        address: profile?['address'] ?? '',
        contact: profile?['contact_number'] ?? '',
        age: profile?['age']?.toString() ?? '',
      ),
    );
  }

  Future<void> uploadAvatar(File file) async {
    emit(state.copyWith(isLoading: true));
    await _profileService.uploadAvatar(file);
    await loadProfile();
  }

  Future<void> updateProfile({
    required String fullName,
    required String address,
    required String contact,
    required String age,
  }) async {
    emit(state.copyWith(isLoading: true));
    await _profileService.updateProfile(
      fullName: fullName,
      address: address,
      contactNumber: contact,
      age: int.tryParse(age),
    );
    emit(
      state.copyWith(isLoading: false, message: 'Profile updated successfully'),
    );
    await loadProfile();
  }
}
