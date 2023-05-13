part of 'google_service_cubit.dart';

abstract class GoogleserviceState {}

class GoogleserviceInitial extends GoogleserviceState {}

class SubmitDataLoadingState extends GoogleserviceState {}

class SubmitDataSuccessState extends GoogleserviceState {}

class SubmitDataErrorState extends GoogleserviceState {}

class GetImageSuccessState extends GoogleserviceState {}
