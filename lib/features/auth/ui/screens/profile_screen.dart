import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../data/models/user_model.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../widgets/profile_bloc_listener.dart';

/// Shows and updates the signed-in user's name/phone/address (PRD §1) and
/// hosts the logout action. loadProfile prefills the form from the
/// Firestore user doc; logout relies on AuthGate to swap the tree.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // read (not watch) is safe in initState: one-shot lookup, no subscribe.
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyles.font24BlackBold,
                ),
                verticalSpace(8),
                Text(
                  'Manage your name, phone and shipping address.',
                  style: TextStyles.font14GrayRegular,
                ),
                verticalSpace(36),
                BlocBuilder<ProfileCubit, ProfileState<UserModel>>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      // Until the profile doc lands (or if the load failed —
                      // surfaced as a dialog by ProfileBlocListener), keep a
                      // centered spinner.
                      initial: () => _buildLoadingView(),
                      profileLoading: () => _buildLoadingView(),
                      profileError: (apiErrorModel) => _buildLoadingView(),
                      orElse: () => _buildProfileForm(context, state),
                    );
                  },
                ),
                const ProfileBlocListener(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    // Fixed height: SingleChildScrollView hands its child unbounded height.
    return SizedBox(
      height: 400.h,
      width: double.infinity,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileForm(
    BuildContext context,
    ProfileState<UserModel> state,
  ) {
    return Form(
      key: context.read<ProfileCubit>().formKey,
      child: Column(
        children: [
          AppTextFormField(
            controller: context.read<ProfileCubit>().nameController,
            hintText: 'Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          verticalSpace(18),
          AppTextFormField(
            controller: context.read<ProfileCubit>().phoneController,
            hintText: 'Phone',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          verticalSpace(18),
          AppTextFormField(
            controller: context.read<ProfileCubit>().addressController,
            hintText: 'Address',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          verticalSpace(24),
          AppButton(
            text: 'Save Changes',
            isLoading: state is ProfileUpdateLoading,
            onPressed: () {
              validateThenDoUpdate(context);
            },
          ),
          verticalSpace(16),
          AppButton(
            text: 'Logout',
            backgroundColor: ColorsManager.red,
            onPressed: () {
              context.read<ProfileCubit>().logout();
            },
          ),
        ],
      ),
    );
  }

  void validateThenDoUpdate(BuildContext context) {
    if (context.read<ProfileCubit>().formKey.currentState!.validate()) {
      context.read<ProfileCubit>().updateProfile();
    }
  }
}
