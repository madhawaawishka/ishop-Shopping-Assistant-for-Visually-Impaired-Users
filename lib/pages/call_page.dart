import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:spm_project/constant/constant.dart';

final userId = Random().nextInt(9999);

class CallPage extends StatelessWidget {
  final String CallID;

  // Removed unnecessary `callID` parameter
  const CallPage({super.key, required this.CallID});

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: AppInfo.appId,
      appSign: AppInfo.appSign,
      userID: userId.toString(),
      userName: 'UserName $userId',
      callID: CallID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
