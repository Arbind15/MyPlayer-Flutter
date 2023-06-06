import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'dart:io';
import 'package:filesystem_picker/filesystem_picker.dart';

class FileFolderBrowser extends StatefulWidget {
  const FileFolderBrowser({Key? key}) : super(key: key);

  @override
  _FileFolderBrowser createState() => _FileFolderBrowser();
}

class _FileFolderBrowser extends State<FileFolderBrowser> {
  DrawDirs(cur_args) async {
    // print("dooo");
    // print(cur_args.dir);
    var tmp = [];
    var folders = await FileManager.listDirectories(cur_args.dir);
    var files=await FileManager.listFiles(cur_args.dir.path,extensions: ['mp3']);
    tmp = List.from(folders)..addAll(files);
    // print(tmp);
    return tmp;
  }

  fileTaped(files,indx,length) {
      Navigator.pushNamed(context, '/currentwin',
          arguments: CurrentPlayArgs(files, indx, length));
  }

  folderTaped(dir) {
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
    ModalRoute.of(context)!.settings.arguments as FileFolderBrowserArgs;

    // DrawDirs(cur_args.root);

    return Scaffold(
      body: FutureBuilder(
          future: DrawDirs(cur_args),
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
                          : fileTaped(snapshot.data,i,snapshot.data.length.toInt())
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


