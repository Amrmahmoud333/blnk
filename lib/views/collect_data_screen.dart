import 'dart:io';
import 'package:blnk/logic/cubit/google_service_cubit.dart';
import 'package:blnk/views/widgets/custom_text_form_field.dart';
import 'package:blnk/views/widgets/uploading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollectDataScreen extends StatefulWidget {
  const CollectDataScreen({super.key});

  @override
  CollectDataScreenState createState() => CollectDataScreenState();
}

class CollectDataScreenState extends State<CollectDataScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _firstName;
  late String _lastName;
  late String _address;
  late String _area = 'Area 1';
  late String _landline;
  late String _mobile;

  // we can replace areas with real data
  final List<String> _areas = [
    'Area 1',
    'Area 2',
    'Area 3',
    'Area 4',
    'Area 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
      ),
      body: BlocListener<GoogleServiceCubit, GoogleserviceState>(
        listener: (context, state) {
          if (state is SubmitDataSuccessState) {
            // remove the uploaded images from this screen
            context.read<GoogleServiceCubit>().clearNationalIdImages();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data submitted successfully'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            );
          }
          if (state is SubmitDataErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'There is problem in data uploading, please try again'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: BlocBuilder<GoogleServiceCubit, GoogleserviceState>(
                builder: (context, state) {
                  return state is SubmitDataLoadingState
                      ? const UploadingWidget(
                          text: 'Uploading data, please wait a while...')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextFormField(
                              labelText: 'First Name',
                              validateText: 'Please enter your first name',
                              onSaved: (value) {
                                _firstName = value!;
                              },
                            ),
                            CustomTextFormField(
                              labelText: 'Last Name',
                              validateText: 'Please enter your last name',
                              onSaved: (value) {
                                _lastName = value!;
                              },
                            ),
                            CustomTextFormField(
                              labelText: 'Address',
                              validateText: 'Please enter your address',
                              onSaved: (value) {
                                _address = value!;
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButtonFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Area',
                                    border: OutlineInputBorder()),
                                value: _area,
                                items: _areas.map((area) {
                                  return DropdownMenuItem(
                                    value: area,
                                    child: Text(area),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an area';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _area = value!;
                                  });
                                },
                              ),
                            ),
                            CustomTextFormField(
                              labelText: 'Landline Number',
                              inputType: TextInputType.phone,
                              validateText: 'Please enter your landline number',
                              onSaved: (value) {
                                _landline = value!;
                              },
                              validator: (landline) {
                                if (landline!.isEmpty ||
                                    !RegExp(r'^\d{6,}$').hasMatch(landline)) {
                                  return 'Please enter landline number';
                                }
                                return null;
                              },
                            ),
                            CustomTextFormField(
                              labelText: 'Mobile Number',
                              inputType: TextInputType.phone,
                              validateText: 'Please enter your mobile number',
                              validator: (mobileNumber) {
                                if (mobileNumber!.isEmpty ||
                                    !RegExp(r'^0\d{10}$')
                                        .hasMatch(mobileNumber)) {
                                  return 'Please enter mobile number';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _mobile = value!;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<GoogleServiceCubit>()
                                      .getImage(side: 'front');
                                },
                                child:
                                    const Text('Scan national ID front side'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<GoogleServiceCubit, GoogleserviceState>(
                              builder: (context, state) {
                                final googleService =
                                    context.read<GoogleServiceCubit>();
                                return googleService.nationalIdFront != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          child: Image.file(
                                            googleService.nationalIdFront!,
                                            height: 200,
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<GoogleServiceCubit>()
                                      .getImage(side: 'back');
                                },
                                child: const Text('Scan national ID back side'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<GoogleServiceCubit, GoogleserviceState>(
                              builder: (context, state) {
                                final googleService =
                                    context.read<GoogleServiceCubit>();
                                return googleService.nationalIdBack != null
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.file(
                                            googleService.nationalIdBack!,
                                            height: 200,
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final googleService =
                                      context.read<GoogleServiceCubit>();
                                  if (googleService.nationalIdFront != null &&
                                      googleService.nationalIdBack != null) {
                                    _showDialog(context: context);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Please enter national ID Images!'),
                                      duration: Duration(seconds: 2),
                                    ));
                                  }
                                }
                              },
                              child: const Text('Submit'),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure to save this data?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('First Name: $_firstName'),
                Text('Last Name: $_lastName'),
                Text('Address: $_address'),
                Text('Area: $_area'),
                Text('Landline: $_landline'),
                Text('Mobile: $_mobile'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Yes'),
              onPressed: () {
                final googleService = context.read<GoogleServiceCubit>();
                googleService.submitData([
                  _firstName,
                  _lastName,
                  _address,
                  _area,
                  _landline,
                  _mobile
                ], File(googleService.nationalIdFront!.path),
                    File(googleService.nationalIdBack!.path));
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
