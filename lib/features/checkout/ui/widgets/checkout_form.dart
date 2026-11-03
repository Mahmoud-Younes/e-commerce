import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_text_form_field.dart';
import '../../logic/cubit/checkout_cubit.dart';

/// Delivery address + phone form (PRD §4: "enter or select a delivery
/// address and phone number"). Prefilled from the profile through
/// [CheckoutArgs]; stays editable here.
class CheckoutForm extends StatelessWidget {
  const CheckoutForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    return Form(
      key: cubit.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextFormField(
            controller: cubit.addressController,
            hintText: 'Delivery address',
            maxLines: 2,
            validator: (value) =>
                (value == null || value.trim().isEmpty) == true
                ? 'Please enter a delivery address'
                : null,
          ),
          const SizedBox(height: 12),
          AppTextFormField(
            controller: cubit.phoneController,
            hintText: 'Phone number',
            keyboardType: TextInputType.phone,
            validator: (value) =>
                (value == null || value.trim().isEmpty) == true
                ? 'Please enter a phone number'
                : null,
          ),
        ],
      ),
    );
  }
}
