import 'package:cloudreve/component/RenameNickDialog.dart';
import 'package:cloudreve/entity/LoginResult.dart';
import 'package:cloudreve/entity/MFile.dart';
import 'package:cloudreve/utils/Service.dart';
import 'package:cloudreve/entity/SettingData.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Setting extends StatelessWidget {
  final UserData userData;
  final void Function(bool) refresh;
  Setting({Key? key, required this.userData, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              "个人资料",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            constraints:
                BoxConstraints(minWidth: double.infinity, minHeight: 30),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: FutureBuilder(
                    future: avatar(userData.id),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ClipOval(
                          child: Image.memory(
                            snapshot.data!.data,
                            fit: BoxFit.cover,
                            width: 32,
                            height: 32,
                          ),
                        );
                      } else {
                        return SizedBox(
                          child: CircularProgressIndicator(),
                          height: 15.0,
                          width: 15.0,
                        );
                      }
                    },
                  ),
                  title: Text("头像"),
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (buildContext) {
                        return AlertDialog(
                          title: Text("修改头像"),
                          contentPadding:
                              const EdgeInsets.fromLTRB(0, 20.0, 0, 24.0),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.crop_original,
                                  color: Colors.blue,
                                ),
                                title: Text("从文件上传"),
                                onTap: () async {
                                  var result =
                                      await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    FormData formData = new FormData();
                                    formData.files.add(
                                      new MapEntry(
                                        "avatar",
                                        await MultipartFile.fromFile(
                                          result.files.first.path.toString(),
                                        ),
                                      ),
                                    );
                                    Response response =
                                        await setFileAsAvatar(formData);
                                    if (response.data['msg'] == '') {
                                      Navigator.pop(buildContext);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("上传成功"),
                                        ),
                                      );
                                      refresh(true);
                                    } else {
                                      Navigator.pop(buildContext);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(response.data['msg']),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.fingerprint,
                                  color: Colors.yellow,
                                ),
                                title: Text("使用 Gravatar 头像 "),
                                onTap: () async {
                                  Response response = await setAvatar();
                                  if (response.data['msg'] == '') {
                                    Navigator.pop(buildContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("设置成功"),
                                      ),
                                    );
                                    refresh(true);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                Divider(
                  height: 0,
                ),
                ListTile(
                  leading: Icon(Icons.contacts_rounded),
                  title: Text("UID"),
                  trailing: FutureBuilder(
                    future: setting(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Response> snapshot) {
                      if (snapshot.hasData) {
                        SettingData settingData =
                            SettingData.fromJson(snapshot.data!.data["data"]);
                        return Text(settingData.uid.toString());
                      } else {
                        return Text("Loading");
                      }
                    },
                  ),
                ),
                Divider(
                  height: 0,
                ),
                ListTile(
                  leading: Icon(Icons.account_box),
                  title: Text('昵称'),
                  trailing: Text(userData.nickname),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return RenameNickDialog(
                            nick: userData.nickname, refresh: refresh);
                      },
                    );
                  },
                ),
                Divider(
                  height: 0,
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("Email"),
                  trailing: Text(userData.userName),
                ),
                Divider(
                  height: 0,
                ),
                ListTile(
                  leading: Icon(Icons.group),
                  title: Text('用户组'),
                  trailing: Text(userData.group!.name),
                ),
                Divider(
                  height: 0,
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("注册时间"),
                  trailing: Text(getFormatDate(userData.createdAt)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
