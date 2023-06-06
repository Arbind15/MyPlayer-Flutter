import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'current_play.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'storagebrowser.dart';
import 'filefolderbrowser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

void main() => runApp(MaterialApp(
      title: "MyPlayer",
      debugShowCheckedModeBanner: false,
      home: MyPlayer(),
      initialRoute: '/main',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/main': (context) => MyPlayer(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/currentwin': (context) => CurrentWin(),
        '/storageBrowser': (context) => FileBrowser(),
        '/fileFolderBrowser': (contex) => FileFolderBrowser(),
      },
    ));

class MyPlayer extends StatefulWidget {
  const MyPlayer({Key? key}) : super(key: key);

  @override
  _MyPlayerState createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> with TickerProviderStateMixin {
  var files;
  var default_player_logo = 'assets/images/img2.png';
  var appbar_tabcontroller, scrollController, buttomBarTabController;
  var appBartopPadding = 0.0;
  var bottomBarPadding = 0.0;
  var buttomBarHeight = 55.0;
  var appBarheight = 120.0;
  var bodytopPadding = 0.0;
  var filesfolder = [];
  var scannerlabel;
  var appDocDir;

  void getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0]
        .rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
        //set fm.dirsTree() for directory/folder tree list
        excludedPaths: [
          "/storage/emulated/0/Android"
        ], extensions: [
      "mp3",
    ] //optional, to filter files, remove to list all,
        //remove this if your are grabbing folder list
        );
    setState(() {}); //update the UI
  }

  getCurFile(index) {
    return files[index];
  }

  @override
  void dispose() {
    appbar_tabcontroller.dispose();
    buttomBarTabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollListner() {
    // print(scrollController.offset);
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (bottomBarPadding >= 0.0) {
        setState(() {
          bottomBarPadding = -buttomBarHeight;
        });
      }
      if (appBartopPadding >= 0.0) {
        setState(() {
          // appBartopPadding=appBartopPadding-(-(scrollController.position.activity.velocity));
          // scrollController.offset
          appBartopPadding = -appBarheight;
        });
      }
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (bottomBarPadding <= 0.0) {
        setState(() {
          bottomBarPadding = 0.0;
        });
      }
      if (appBartopPadding <= 0.0) {
        setState(() {
          appBartopPadding = 0.0;
        });
      }
    }
  }

  Browse() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;

      // print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      print(file.path);
      // Tapped(file, null, null);
    } else {
      // User canceled the picker
    }

    // print("runned");
  }

  BrowseFolder() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir;
    String path = await FilesystemPicker.open(
      title: 'Choose Folder',
      context: context,
      rootDirectory: Directory(root),
      fsType: FilesystemType.folder,
      folderIconColor: Colors.teal,
    );

    var fm = FileManager(root: Directory(path)); //
    files = await fm.filesTree(
      //set fm.dirsTree() for directory/folder tree list
      excludedPaths: [
        "/storage/emulated/0/Android"
      ], //optional, to filter files, remove to list all,
      extensions: ["mp3"],
      //remove this if your are grabbing folder list
    );
    setState(() {}); //update the UI
  }

  Tapped(files, index, length) {
    Navigator.pushNamed(context, '/currentwin',
        arguments: CurrentPlayArgs(files, index, length));
  }

  NewPlyList(name)async{
    var plylst=appDocDir.path+'/Playlists';
    var file=await File('$plylst/$name.dat');

    if(!(await file.exists())){
      file.create(recursive: true);
    }
  }

  appBarActions() {
    switch (buttomBarTabController.index) {
      case 0:
        {
          return <Widget>[];
        }
      case 1:
        {
          return [
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.search_rounded,
                  size: 40,
                )),
            IconButton(
                onPressed: BrowseFolder,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 40,
                ))
          ];
        }
      case 2:
        {
          return <Widget>[
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.search_rounded,
                  size: 40,
                )),
          ];
        }
      case 3:
        {
          return <Widget>[
            IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.search_rounded,
                  size: 40,
                )),
            // DropdownButtonHideUnderline(
            //     child: DropdownButton(
            //   icon: Icon(Icons.more_vert_rounded),
            //   iconSize: 40,
            //   items: [
            //     DropdownMenuItem(child: Text("")),
            //     DropdownMenuItem(child: Text("New Playlist")),
            //     DropdownMenuItem(child: Text("Refresh"))
            //   ],
            // )),

            IconButton(
                onPressed: ()=>NewPlyList(Random().nextInt(500).toString()),
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 40,
                )),

          ];
        }
      case 4:
        {
          return <Widget>[];
        }
    }
  }

  appBar() {
    return SizedBox(
      height: appBarheight,
      child: AppBar(
        leading: SizedBox(
            height: 50, width: 50, child: Image.asset(default_player_logo)),
        title: Text("MyPlayer"),
        actions: appBarActions(),
        bottom: buttomBarTabController.index == 1
            ? TabBar(
                labelPadding: EdgeInsets.only(top: 5),
                controller: appbar_tabcontroller,
                tabs: [
                  TextButton(onPressed: null, child: Text("Artists")),
                  TextButton(onPressed: null, child: Text("Albums")),
                  TextButton(onPressed: null, child: Text("Tracks")),
                  TextButton(onPressed: null, child: Text("Genres"))
                ],
              )
            : null,
      ),
    );
  }

  BrowserBodyTapped(dir) {
    print(dir.rootDir);
    Navigator.pushNamed(context, '/fileFolderBrowser',
        arguments: FileFolderBrowserArgs(Directory(dir.rootDir)));
  }

  BrowserBody() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo;
    return storageInfo;
  }

  buttomAppBarTap(indx) {
    if (indx == 1) {
      setState(() {
        appBarheight = 120;
        bodytopPadding = appBarheight;
      });
    } else {
      setState(() {
        appBarheight = 80;
        bodytopPadding = appBarheight;
      });
    }
  }

  bottomAppBar() {
    return Container(
      color: Colors.brown,
      height: buttomBarHeight,
      child: TabBar(
          controller: buttomBarTabController,
          onTap: buttomAppBarTap,
          indicatorColor: Colors.redAccent,
          labelPadding: EdgeInsets.only(top: 5),
          tabs: [
            Container(
              child: Column(
                children: [Icon(Icons.videocam_rounded), Text("Video")],
              ),
            ),
            Container(
              child: Column(
                children: [Icon(Icons.music_note_rounded), Text("Audio")],
              ),
            ),
            Container(
              child: Column(
                children: [Icon(Icons.folder_rounded), Text("Browse")],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Icon(Icons.playlist_play_rounded),
                  Text("Playlists")
                ],
              ),
            ),
            Container(
              child: Column(
                children: [Icon(Icons.more_horiz_rounded), Text("More")],
              ),
            ),
          ]),
    );
  }

  tmpBody() {
    return ListView.builder(
      controller: scrollController,
      // padding: EdgeInsets.only(top: _topPadding + _appBarHeight),
      itemCount: 200,
      itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
    );
  }

  AudioList() async {
    // print("here2");
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var tmp = [];
    var fm, files;
    Permission.storage.request();
    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }

    // if (await Permission.storage.request().isGranted) {
    //   print("here221");
    //   fm = await FileManager(root: Directory(storageInfo[1].rootDir));
    //   print("here222");
    //   files = await fm.filesTree(
    //     // extensions: ["mp3"],
    //     excludedPaths: ["/storage/emulated/0/Android",'/storage/emulated/0/Android/data'],
    //   );
    //   print("here223");
    //   print(files);
    //   tmp = List.from(tmp)..addAll(files);
    //   print("here224");
    //   print(tmp);
    // }
    if (await Permission.storage.request().isGranted) {
      for (int i = 0; i < storageInfo.length.toInt(); i++) {
        fm = FileManager(root: Directory(storageInfo[i].rootDir));
        files = await fm.filesTree(
          extensions: ["mp3"],
          excludedPaths: ["/storage/emulated/0/Android"],
        );
        tmp = List.from(tmp)..addAll(files);
      }
    }
    return tmp;
  }

  ScanFolder(folder) async {
    // print(scannerlabel);
    var f = await FileManager.listDirectories(folder);
    var fls = await FileManager.listFiles(folder.path, extensions: ['mp3']);
    for (var ff in f) {
      ScanFolder(ff);
    }
    setState(() {
      scannerlabel = folder.path.toString();
      filesfolder = List.from(filesfolder)..addAll(fls);
    });
    return;
  }

  FileFolderScanner() async {
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var tmp = [];
    var fm, files, folders;
    Permission.storage.request();
    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }
    if (await Permission.storage.request().isGranted) {
      for (var storages in storageInfo) {
        // print(storages.rootDir);
        folders =
            await FileManager.listDirectories(Directory(storages.rootDir));
        files =
            await FileManager.listFiles(storages.rootDir, extensions: ['mp3']);
        tmp = await List.from(tmp)
          ..addAll(files);
        filesfolder = List.from(filesfolder)..addAll(tmp);
        for (var folder in folders) {
          if ((folder.path.toString().split('/').last == 'Android') ||
              (folder.path.toString().split('/').last == '.android_secure')) {
            continue;
          }
          await ScanFolder(folder);
        }
        // print(folders);
        // print(tmp);
      }
    }
    // print(tmp);
    // return tmp;
  }

  PlayLists() async {
    var plylst = appDocDir.path + '/Playlists';
    // print(await FileManager.listDirectories(Directory(plylst)));
    plylst = await FileManager.listFiles(plylst);

    // new Directory(appDocPath).create(recursive: true);
    // var file=File('$appDocPath/counter.txt');
    // file.writeAsString("csdfnncvn");
    // print(file);
    // print("ds");
    // print(await file.readAsString());
    // return Container(
    //   color: Colors.green,
    //   child: Column(
    //     children: [],
    //   ),
    // );
    return plylst;
  }

  InitialStuff() async {
    appDocDir = await getApplicationDocumentsDirectory();
    if (!(await new Directory(appDocDir.path + '/Playlists').exists())) {
      new Directory(appDocDir.path + '/Playlists').create(recursive: true);
    }
  }

  Body() {
    switch (buttomBarTabController.index) {
      case 0:
        {
          return Container();
        }
      case 1:
        {
          bodytopPadding = appBarheight;
          if (filesfolder == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Loading...")],
              ),
            );
          } else if (filesfolder.length == 0) {
            return Center(
              child: Text("No mp3 file found!"),
            );
          } else {
            return ListView.builder(
              // padding: EdgeInsets.only(top: _topPadding + _appBarHeight),
              itemCount: filesfolder.length.toInt(),
              itemBuilder: (_, i) => ListTile(
                  leading: Icon(Icons.music_note_rounded),
                  onTap: () {
                    Navigator.pushNamed(context, '/currentwin',
                        arguments: CurrentPlayArgs(
                            filesfolder, i, filesfolder.length.toInt()));
                  },
                  title: Text(filesfolder[i].path.toString().split('/').last)),
            );
          }
        }
      case 2:
        {
          bodytopPadding = appBarheight;
          return FutureBuilder(
              future: BrowserBody(),
              builder: (context, AsyncSnapshot snapshot) {
                // print(snapshot.connectionState);
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  // print(snapshot.connectionState);
                  return ListView.builder(
                    // padding: EdgeInsets.only(top: _topPadding + _appBarHeight),
                    itemCount: snapshot.data.length.toInt(),
                    itemBuilder: (_, i) => ListTile(
                        leading: Icon(Icons.folder_rounded),
                        onTap: () => BrowserBodyTapped(snapshot.data[i]),
                        title: Text(snapshot.data[i].rootDir.toString())),
                  );
                  return Container();
                } else {
                  return Container(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              });
          // if(files==null){
          //   return Container(child: Center(child: Text("Loading.."),),);
          // }else{
          //   return  Navigator.pushNamed(context, '/fileBrowser');
          // }
        }
      case 3:
        {
          bodytopPadding = appBarheight;
          return FutureBuilder(
              future: PlayLists(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return GridView.builder(
                    itemCount: snapshot.data.length.toInt(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0),
                    itemBuilder: (_, i) => Card(
                      child: Text(
                          snapshot.data[i].path.toString().split('/').last),
                      margin: EdgeInsets.all(10),
                    ),
                  );
                  // return ListView.builder(
                  //   itemCount: snapshot.data.length.toInt(),
                  //   itemBuilder: (_, i) => ListTile(
                  //       leading: Icon(Icons.folder_rounded),
                  //       title: Text(snapshot.data[i].path.toString().split('/').last)),
                  // );
                } else {
                  return Container(
                    child: Center(
                        child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text("Loading..."),
                      ],
                    )),
                  );
                }
              });
        }
      case 4:
        {
          return Container();
        }
    }
  }

  Widget BodyContent() {
    return files == null
        ? Text("Searching Files")
        : ListView.builder(
            //if file/folder list is grabbed, then show here
            itemCount: files?.length ?? 0,
            itemBuilder: (context, index) {
              return Card(
                  child: ListTile(
                title: Text(files[index].path.split('/').last),
                leading: Icon(Icons.music_note_rounded),
                // onTap: ()=>playLocal(files[index].path),
                onTap: () => Tapped(files, index, files.length),
                // trailing: Icon(Icons.delete, color: Colors.redAccent,),
              ));
            },
          );
  }

  @override
  void initState() {
    // getFiles(); //call getFiles() function on initial state.
    appbar_tabcontroller = TabController(length: 4, vsync: this);
    buttomBarTabController =
        TabController(length: 5, vsync: this, initialIndex: 1);
    scrollController = ScrollController();
    scrollController.addListener(scrollListner);
    FileFolderScanner();
    InitialStuff();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // FileFolderScanner();
    // AudioList();
    // print(filesfolder);
    // PlayLists();
    return Scaffold(
      body: Stack(
        children: [
          // Positioned(top: 200,left: 0,right: 0,child: scannerlabel!=null?Text(scannerlabel+filesfolder.length.toString()):Text("Something went wrong bro!"),),

          Positioned(
              top: bodytopPadding, right: 0, left: 0, bottom: 0, child: Body()),
          Positioned(top: appBartopPadding, right: 0, left: 0, child: appBar()),
          Positioned(
              bottom: bottomBarPadding,
              right: 0,
              left: 0,
              child: bottomAppBar())
        ],
      ),
    );
  }
}

class CurrentPlayArgs {
  var files;
  var index;
  var length;
  CurrentPlayArgs(this.files, this.index, this.length);
}

class StorageBrowserArgs {
  var root;

  StorageBrowserArgs(this.root);
}

class FileFolderBrowserArgs {
  var dir;
  FileFolderBrowserArgs(this.dir);
}

//
// bodytopPadding = appBarheight;
// return FutureBuilder(
// future: AudioList(),
// builder: (context, AsyncSnapshot audiosnap) {
// // print(snapshot.connectionState);
// if (audiosnap.connectionState==ConnectionState.done && audiosnap.hasData) {
// // print(audiosnap.connectionState);
// // print("here1111125");
// // print(audiosnap.data);
// return ListView.builder(
// // padding: EdgeInsets.only(top: _topPadding + _appBarHeight),
// itemCount: audiosnap.data.length.toInt(),
// itemBuilder: (_, i) => ListTile(
// leading: Icon(Icons.music_note_rounded),
// onTap: () {
// Navigator.pushNamed(context, '/currentwin',
// arguments: CurrentPlayArgs(audiosnap.data, i,
// audiosnap.data.length.toInt()));
// },
// title: Text(
// audiosnap.data[i].path.split('/').last)),
// );
// return Container();
// } else if(audiosnap.connectionState==ConnectionState.waiting) {
// return Container(
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Center(child: CircularProgressIndicator()),
// Center(child: Text("Loading..."),),
// ],
// ),
// );
// } else{
// return Container(
// child: Center(child: CircularProgressIndicator()),
// );
// }
// });

//APK builder without nullsaftey
// flutter build apk --split-per-abi --no-sound-null-safety
