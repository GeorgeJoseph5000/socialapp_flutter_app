import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http/http.dart';

const baseurl = "https://wild-dungarees-bee.cyclic.app/api/";

Future<Response> postReq(String url, Object body) async {
  var response = await http.post(Uri.parse(baseurl + url),
      headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  return response;
}

Future<Response> deleteReq(String url, Object body) async {
  var response = await http.delete(Uri.parse(baseurl + url),
      headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  return response;
}

Future<Response> getReq(String url) async {
  var response = await http.get(Uri.parse(baseurl + url),
      headers: {"Content-Type": "application/json"});
  return response;
}

Future<Response> putReq(String url, Object body) async {
  var response = await http.put(Uri.parse(baseurl + url),
      headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  return response;
}
