import 'dart:developer';
import 'dart:io';

import 'package:chat_with_ai/localStore/boxes.dart';
import 'package:chat_with_ai/localStore/setting.dart';
import 'package:chat_with_ai/providers/theme_provider.dart';
import 'package:chat_with_ai/widget/build_display_image.dart';
import 'package:chat_with_ai/widget/setting_tiles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userName = 'cloud';
  String userImage = '';
  final ImagePicker _picker = ImagePicker();
  void pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        maxHeight: 800,
        maxWidth: 800,
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          file = File(pickedImage.path);
        });
      }
    } catch (e) {
      log('error: $e');
    }
  }

  void getUserDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBox = Boxes.getUser();
      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        setState(() {
          userImage = user!.name;
          userImage = user.response;
        });
      }
    });
  }

  @override
  void initState() {
    getUserDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.check))],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 21),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: BuildDisplayImage(
                  file: file,
                  userImage: userImage,
                  onPressed: () {
                    pickImage();
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 40.0,
              ),
              ValueListenableBuilder<Box<Settings>>(
                  valueListenable: Boxes.getSetting().listenable(),
                  builder: (context, box, child) {
                    if (box.isEmpty) {
                      // return const CircularProgressIndicator();
                      return Column(
                        children: [
                          // SwitchListTile(
                          //     title: Text('Enable AI voice'),
                          //     value: false,
                          //     onChanged: (value) {}),
                          SettingTiles(
                            icon: Icons.mic,
                            title: 'Enable AI voice',
                            onChanged: (bool value) {
                              final settingProvider =
                                  context.read<SettingsProvider>();
                              settingProvider.toggleShouldSpeak(value: value);
                            },
                            value: false,
                          ),
                          // SwitchListTile(
                          //     title: Text('Theme Mode'),
                          //     value: false,
                          //     onChanged: (value) {}),
                          SettingTiles(
                            icon: Icons.light_mode,
                            title: 'Theme Mode',
                            onChanged: (bool value) {
                              final settingProvider =
                                  context.read<SettingsProvider>();
                              settingProvider.toggleDarkMode(value: value);
                            },
                            value: false,
                          ),
                        ],
                      );
                    } else {
                      final setting = box.getAt(0);
                      return Column(
                        children: [
                          SettingTiles(
                            icon: Icons.mic,
                            title: 'Enable AI voice',
                            onChanged: (bool value) {
                              setting.shouldSpeak = value;
                              setting.save();
                            },
                            value: setting!.shouldSpeak,
                          ),
                          SettingTiles(
                            icon: setting.darkTheme
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            title: 'Theme Mode',
                            onChanged: (bool value) {
                              // final settingProvider =
                              //     context.read<SettingsProvider>();
                              // settingProvider.toggleDarkMode(value: value);
                              setting.darkTheme = value;
                              setting.save();
                            },
                            value: setting.darkTheme,
                          ),
                          // SwitchListTile(
                          //     value: setting!.darkTheme,
                          //     onChanged: (value) {
                          // setting.darkTheme = value;
                          // setting.save();
                          //     })
                        ],
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
