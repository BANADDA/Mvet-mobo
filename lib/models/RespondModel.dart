import 'dart:convert';

import 'package:get/get.dart';
import 'package:marcci/auth/BoardingWelcomeScreen.dart';

import '../utils/Utils.dart';

class RespondModel {
  dynamic raw;
  int code = 0;
  String message =
      "Failed to connect to internet. Check your connection and try again";
  dynamic data;

  RespondModel(this.raw) {
    if (this.raw == null) {
      return;
    }
    Map<String, dynamic> resp = {};
    if (raw.runtimeType.toString() != '_Map<String, dynamic>') {
      try {
        resp = jsonDecode(raw);
      } catch (e) {
        resp = {'code': 0, 'message': raw.toString(), 'data': null};
      }
    } else {
      resp = raw;
    }

    if (resp['message'] == 'Unauthenticated') {
      Utils.toast("You are not logged in.");
      Utils.logout();
      Get.off(BoardingWelcomeScreen());
      return;
    }

    if (resp['code'] != null) {
      this.code = Utils.int_parse(resp['code'].toString());
      this.message = resp['message'].toString();
      this.data = resp['data'];
    } else if (resp['message'] != null) {
      this.code = Utils.int_parse(resp['code'].toString());
      this.message = resp['message'].toString();
      this.data = resp['data'];
    }
  }
}
