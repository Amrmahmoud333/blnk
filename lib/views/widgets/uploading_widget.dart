import 'package:blnk/theme/styling.dart';
import 'package:flutter/material.dart';

class UploadingWidget extends StatelessWidget {
  const UploadingWidget({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: AppTheme.lightTextTheme.bodyText1,
            ),
            const SizedBox(height: 100),
            CircularProgressIndicator(
              color: Colors.blue[900],
            ),
          ],
        ),
      ),
    );
  }
}
