import 'package:edge_detection/edge_detection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';
import 'dart:async';
import 'package:googleapis/sheets/v4.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
part 'google_service_state.dart';

class GoogleServiceCubit extends Cubit<GoogleserviceState> {
  GoogleServiceCubit() : super(GoogleserviceInitial());

  File? _nationalIdFront;
  File? _nationalIdBack;
  File? get nationalIdFront => _nationalIdFront;
  File? get nationalIdBack => _nationalIdBack;

  clearNationalIdImages() {
    _nationalIdFront = null;
    _nationalIdBack = null;
  }

  Future<void> getImage({required String side}) async {
    // check if we have permission to open camera or not
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      // ask for camera permission
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    // Generate filepath for saving
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = await EdgeDetection.detectEdge(
      imagePath,
      canUseGallery: true,
      androidScanTitle: 'Scanning', // use custom localizations for android
      androidCropTitle: 'Crop',
      androidCropBlackWhiteTitle: 'Black White',
      androidCropReset: 'Reset',
    );

    if (success) {
      side == 'front'
          ? _nationalIdFront = File(imagePath)
          : _nationalIdBack = File(imagePath);
      emit(GetImageSuccessState());
    }
  }

// Function to authenticate with the Google APIs
  Future<auth.AutoRefreshingAuthClient> authenticate() async {
    final credentials = auth.ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "blnk-386411",
      "private_key_id": "fa21b40c1ada75b97e6f4f94f093670009464f2b",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCqfQTMBclIrwg+\nwr1MBwFJFjTfGyKZYaj4DVud0yvElv7hgCzDOb7wdJf3RdSUBk5OvT1yLQHjeulb\nThGUVDX87lpV8v/RLW5cevYXtKRZKNPWdEM4Sdxh0jOYBNXjTVUCTo8855fQwJ7Q\nYGu26NCnLpXaVRX5VzszNmhO/ECuJdIJC6X1Z8GGYPBN9Dihb9whLTlQ2/uRaKNY\nEub5zIwTb+DVY5JmO7ElDYE8TxsLrfAEDtPmcv2Pn9mVWpFxn/yz7NQBmvtjg+qG\n87XSGMAA5J5QgNzcKlEwVERDZPF5dSiP2SXkcvJ/iMVGZXjYwWmOy+3g//NU69HJ\nVsypnsVLAgMBAAECggEAM9CXOqKvkCWSLfDls0uVum7DVuNaWp9xySHWLFtXvAHg\nKQzZjePpAg+NeBuDBhH8jrW5DRBcuJRMg/FwKlKFrf+K+QBHe32BQx4j2QSPxoFA\nELd5Dox0LE7EW3lswA5qva6+ndYNL+a63b3QPuD3OThRVu/xI7y9Q01P2mGUDtj0\nYcJvEQ5w+i0ftDyOilERy78GcctuZM1priI1eHnG5r/+wEzAUxHiTSNFeq+4+I+p\ntCDQwdaeKOGGd6Y9i+GVwbea6sOllcSIyUG/j08vRp+rPQoUO7nqRnRgeNyAQwdo\n0d9XoJW8sETqFT1RcvN6VJP8RIRZlNl1KZoF73SRIQKBgQDh9eUbKFL6iZkSP5cK\nZTrtN47Fujqc1723QNxg7ljHWtfIIy7qbAN+xomK/j41+LDpVrSPT/lUejOMcSzi\nZx0lK2ewznQeCc0S3jPRNpkfw9WM10knVLmg5+0Ri4w4xAs/saCC8KfBbJmc17eq\nuYZ3yiMG1qacs3hrSv1T2NCB+QKBgQDBJz3fP/cCkIi19sNZfHMWYrTdOh5FJTi0\n+/Dkjf5ua9odRJQeMuWwxnKne052sQrt5lxJimBDegm6wn0mQtfAYbaPkanNrXyP\nqTsqYktikuCEfvwBO+Pf29dC/9xOS1uEPZyjDlsFz8v9CicgMiMzrRV4oRppC8fX\nqSjRTOESYwKBgBu84LP1vkHtFDJORg9Ln/EwycDx/HH2dd6CAsuPVqyaNTTnRMIY\nIlG0s3uxfBeKAMWUFDQngBbjrWJHHlhoigZfDqqAnXZ2g4sWZcv/5MomcxeH8f33\nA5aCAfMOa1cokazu9CI+wokW+MBtJqm5fo1D7grP3MINsfGR0gkx616ZAoGAB0qd\n8VGO14/xOT1JfpVOGug6/6b0AZQ4Iczo+RfLJQv5PeWa2dD+DsBPD7d97MkeKoDp\ntvT8UU/IEj7JTqpzTpXhuGW9TUBhVWMEEsOHKP92bkoE5V8HaSn5ZFQYUvRRThqt\nURJ3qS6A+tppQ7Pg1FCSYO1j+9cwAhomqlAGpxUCgYBVjycsDV3ZSkyrgYOPnTA3\n8HPJ64BpGLDwd18ekJPQvdoCYlDWErvZqcbDLIkcTDLL3ZmtsgqFfVfshJL/oBLT\nDhffwJRDpZ73xfYVuXRvEfifcSJPmhvsJ6HTr9D71jWXKUljHr1hPViRB2jk/g2U\ng516cmcMqEwHE5bwzaTSfw==\n-----END PRIVATE KEY-----\n",
      "client_email": "blnk-340@blnk-386411.iam.gserviceaccount.com",
      "client_id": "107038046154962303859",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/blnk-340%40blnk-386411.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    // define drive API and Sheets API
    var scopes = [
      drive.DriveApi.driveFileScope,
      sheets.SheetsApi.spreadsheetsScope
    ];

    return await auth.clientViaServiceAccount(credentials, scopes);
  }

// Function to create a new row in the Google Sheet
  Future<void> addRow(sheets.SheetsApi sheetsApi, String spreadsheetId,
      List<String> values) async {
    String range = "Sheet1!A2:C";
    ValueRange valueRange = sheets.ValueRange(range: range, values: [values]);

    await sheetsApi.spreadsheets.values.append(valueRange, spreadsheetId, range,
        insertDataOption: 'OVERWRITE', valueInputOption: "RAW");
  }

// Function to upload an image to Google Drive and return the image link
  Future<String?> uploadImage(
      drive.DriveApi driveApi, String folderId, File file) async {
    // Create a new folder
    await driveApi.files.create(
      drive.File()
        ..name = 'New Folder'
        ..mimeType = 'application/vnd.google-apps.folder',
    );

    // Upload the image file to the new folder
    final media =
        drive.Media(file.openRead(), file.lengthSync()); // read the image data

    final uploadedFile = await driveApi.files.create(
      drive.File()
        ..name = file.path
            .split('/')
            .last // Use the file name as the uploaded file name
        ..parents = [folderId] // Set the new folder as the parent folder
        ..mimeType =
            'image/jpeg', // Replace with the MIME type of your image file
      uploadMedia: media,
    );

    // Set the permissions of the uploaded file to "public"
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploadedFile.id!,
    );

    // Get the image link
    final fileUrl = 'https://drive.google.com/uc?id=${uploadedFile.id}';
    final response = await http.get(Uri.parse(fileUrl));
    final imageUrl = response.request!.url.toString();

    return imageUrl;
  }

  late String msg;
// Main function to submit the basic information and images
  Future<void> submitData(List<String> values, File image1, File image2) async {
    emit(SubmitDataLoadingState());

    try {
      var client = await authenticate();

      var driveApi = drive.DriveApi(client);

      var sheetsApi = sheets.SheetsApi(client);

      // Create a new folder in Google Drive to store the images
      var folder = drive.File();
      folder.name = "Images";
      folder.mimeType = "application/vnd.google-apps.folder";
      var folderResponse = await driveApi.files.create(folder);
      var folderId = folderResponse.id;

      // Upload the images to Google Drive and obtain their URLs
      var imageUrl1 = await uploadImage(driveApi, folderId!, image1);
      var imageUrl2 = await uploadImage(driveApi, folderId, image2);

      // Store the basic information in Google Sheets
      await addRow(sheetsApi, "1B8mNps1Qc-nEtBbc2Isrx45vCZi8CI37624pZKZQrSE",
          [...values, imageUrl1!, imageUrl2!]);
      emit(SubmitDataSuccessState());
      // Close the client to release resources
      client.close();
    } catch (error) {
      msg = error.toString();
      emit(SubmitDataErrorState());
    }
  }
}
