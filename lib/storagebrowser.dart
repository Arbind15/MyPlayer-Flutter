import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';

class FileBrowser extends StatefulWidget {
  const FileBrowser({Key? key}) : super(key: key);

  @override
  _FileBrowserState createState() => _FileBrowserState();
}

class _FileBrowserState extends State<FileBrowser> {
  DrawDirs(dir) async {
    print("mn");
    print(dir);
    var tmp = [];
    var fm = FileManager(root: Directory(dir.rootDir)); //
    var folders = await fm.dirsTree(
      excludedPaths: ["/storage/emulated/0/Android"],
    );
    var files = await fm.filesTree(
      //set fm.dirsTree() for directory/folder tree list
      excludedPaths: [
        "/storage/emulated/0/Android"
      ], //optional, to filter files, remove to list all,
      extensions: ["mp3"],
      //remove this if your are grabbing folder list
    );
    // print(folders[0]);
    // print(files[0]);
    tmp = List.from(folders)..addAll(files);
    print(tmp);
    return tmp;
  }

  fileTaped(dir) {}
  folderTaped(dir) {
    // print("storage");
    Navigator.pushNamed(context, '/fileFolderBrowser',
        arguments: FileFolderBrowserArgs(dir));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cur_args =
        ModalRoute.of(context)!.settings.arguments as StorageBrowserArgs;

    // DrawDirs(cur_args.root);

    return Scaffold(
      body: FutureBuilder(
          future: DrawDirs(cur_args.root),
          builder: (context, AsyncSnapshot snapshot) {
            // print(snapshot.connectionState);
            if (snapshot.hasData) {
              // print(snapshot.connectionState);
              return ListView.builder(
                // padding: EdgeInsets.only(top: _topPadding + _appBarHeight),
                itemCount: snapshot.data.length.toInt(),
                itemBuilder: (_, i) => ListTile(
                    leading:
                        snapshot.data[i].runtimeType.toString() == '_Directory'
                            ? Icon(Icons.folder_rounded)
                            : Icon(Icons.music_note_rounded),
                    onTap: () => {
                          snapshot.data[i].runtimeType.toString() ==
                                  '_Directory'
                              ? folderTaped(snapshot.data[i])
                              : fileTaped(snapshot.data[i])
                        },
                    title:
                        Text(snapshot.data[i].path.toString().split('/').last)),
              );
              return Container();
            } else {
              return Container(
                child: Center(child: CircularProgressIndicator()),
              );
            }
          }),
    );
  }
}




