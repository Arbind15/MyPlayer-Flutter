import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:marquee/marquee.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:palette_generator/palette_generator.dart';
import 'visualizer.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CurrentWin extends StatefulWidget {
  const CurrentWin({Key? key}) : super(key: key);

  @override
  _CurrentWinState createState() => _CurrentWinState();
}

class _CurrentWinState extends State<CurrentWin> {
  AudioPlayer audioPlayer = AudioPlayer(playerId: 'myID');
  bool pauseply = true;
  bool v_first = true;
  var cur_indx, fils;
  var slider_pos = 0.0;
  var max_dur;
  var total_itm, body_listView_Sel_indx;
  var timer1, timer2;
  final tagger = new Audiotagger();
  var mp3Info, cur_album_art;
  bool playst_toogle = true;
  var cur_color;
  var cur_img;
  bool visulaizer_status = true;
  bool suffel_btn = false;
  bool repeat_btn = false;
  var random = Random();
  var onComplete = false;
  var appDocDir;



  var default_player_logo = 'assets/images/img2.png';

  ItemScrollController ListViewController = ItemScrollController();

  var title_text_style = TextStyle(
    fontSize: 20,
    wordSpacing: 1,
  );
  var sub_title_text_style = TextStyle(
    fontSize: 15,
    wordSpacing: 1,
  );

  Color plyr_btn_clrs = Colors.black.withOpacity(0.6);
  var plyr_btn_size = 35.0;

  playLocal(localpath) async {
    if (pauseply == false || visulaizer_status == false) {
      setState(() {
        pauseply = true;
        visulaizer_status = true;
      });
    }

    getMP3info(localpath);

    // audioPlayer.onPlayerStateChanged
    //     .listen((s) => {print('Current player state: $s')});

    audioPlayer.onPlayerCompletion.listen((e) {
      // print("Completed");
      // onComplete?null:next(fils);
      // next(fils);
    });

    audioPlayer.onDurationChanged.listen((Duration d) {
      // print('Max duration:');
      // print(d.inSeconds);
      max_dur = d.inSeconds.toDouble();
      timer2 = _printDuration(d);
      // print(slider_step_size);
    });

    int result = await audioPlayer.play(localpath, isLocal: true);

    audioPlayer.onAudioPositionChanged.listen((Duration p) => {
          setState(() => {onPosChanged(p)})
        });

    audioPlayer.onPlayerCompletion.listen((event) {
      audioPlayer.stop();
      next(fils);
    });

    // everySecond=Timer.periodic(Duration(seconds: 1,), (Timer t) {
    //   slider_pos.toInt()==1?slider_pos=0:(slider_pos=slider_pos+slider_step_size);
    //   print(slider_pos);
    //   setState(() {});
    //   // print(slider_pos);
    //
    // });
    // print("cur_color");

    // print(cur_color);

    // print("cur_color");
  }

  onPosChanged(Duration p) {
    if (p.inSeconds.toDouble() <= max_dur) {
      slider_pos = p.inSeconds.toDouble();
      timer1 = _printDuration(p);
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours >= 1) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  next(files) {
    setState(() {
      suffel_btn
          ? cur_indx = random.nextInt(total_itm - 1)
          : cur_indx == (total_itm - 1)
              ? (null)
              : (cur_indx = cur_indx + 1);
    });
    playLocal(files[cur_indx].path);
    ListViewController.scrollTo(
        index: cur_indx, duration: Duration(milliseconds: 1));
    onComplete = false;
  }

  previous(files) {
    setState(() {
      cur_indx == 0 ? (null) : (cur_indx = cur_indx - 1);
    });
    playLocal(files[cur_indx].path);
    ListViewController.scrollTo(
        index: cur_indx, duration: Duration(milliseconds: 1));
  }

  PausePlay() {
    setState(() {
      pauseply = !pauseply;
      visulaizer_status = !visulaizer_status;
      pauseply ? (audioPlayer.resume()) : (audioPlayer.pause());
    });
  }

  getMP3info(file) async {
    mp3Info = await tagger.readTagsAsMap(path: file);
    cur_album_art = await tagger.readArtwork(path: file);
    cur_album_art!=null?cur_album_art=ResizeImage(MemoryImage(cur_album_art),height: 300,width: 300):null;
    cur_album_art == null
        ? cur_color = await PaletteGenerator.fromImageProvider(
            AssetImage(default_player_logo),
            size: Size(100, 100))
        : cur_color = await PaletteGenerator.fromImageProvider(
            cur_album_art,
            size: Size(100, 100));
    cur_color = cur_color.lightMutedColor != null
        ? cur_color.lightMutedColor
        : PaletteColor(Colors.red, 2);
    cur_color = cur_color.color;

    cur_img = cur_album_art == null
        ? AssetImage(default_player_logo)
        : cur_album_art;

    // print(file);
    // print (tag);
  }

  getFileInfo(file)async{
    var f_info=[];
    var fil,lengths,album_art;
    fil= await tagger.readTagsAsMap(path: file);
    album_art= await tagger.readArtwork(path: file);
    lengths= await tagger.readAudioFileAsMap(path: file);
    // f_info['title']
    if(fil!=null){
      f_info.add(fil['title']);
      f_info.add(fil['album']);
      f_info.add(fil['artist']);
    }
    f_info.add(album_art);
    if(lengths!=null){
      f_info.add(lengths['length']);
    }

    return f_info;
  }

  PlayListTap(indx) {
    cur_indx = indx;
    playLocal(fils[indx].path);
  }

  NewPlyList(name)async{
    var plylst=appDocDir.path+'/Playlists';
    var file=await File('$plylst/$name.dat');

    if(!(await file.exists())){
      file.create(recursive: true);
    }
  }

  InitialStuff()async{
    appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState(){
    cur_img = cur_album_art == null
        ? AssetImage(default_player_logo)
        : MemoryImage(cur_album_art);
    cur_color==null?cur_color=Colors.blue:null;
    InitialStuff();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cur_args =
        ModalRoute.of(context)!.settings.arguments as CurrentPlayArgs;
    v_first ? cur_indx = cur_args.index : null;
    total_itm = cur_args.length;
    var file = cur_args.files[cur_indx];
    v_first ? playLocal(file.path) : null;
    fils = cur_args.files;

    // print(cur_args.length);
    // Psply();
    v_first = false;
    // NewPlyList("Arbind");

    // print(getMP3info(file.path));
    // getMP3info(file.path);
    // print(mp3Info);
    // print(mp3Info['title']);
    // print(cur_indx);

    // print(getFileInfo(fils[cur_indx].path));


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: cur_color.withOpacity(0.8),
        title: SizedBox(
          width: double.infinity,
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                // color: Colors.amber,
                width: 50,
                height: 50,
                margin: EdgeInsets.only(left: 3),
                child: cur_album_art == null
                    ? Image.asset(default_player_logo)
                    : Image(image: cur_album_art),
              ),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Container(
                  // width: 215,
                  margin: EdgeInsets.only(
                    left: 3,
                  ),
                  // color: Colors.red,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Text(
                          //   mp3Info == null
                          //       ? file.path.split('/').last
                          //       : mp3Info['title'] == ""
                          //           ? file.path.split('/').last
                          //           : mp3Info['title'],
                          //   style: title_text_style,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          Expanded(
                            child: SizedBox(
                              height: 25,
                              child: Marquee(
                                text: mp3Info == null
                                    ? file.path.split('/').last
                                    : mp3Info['title'] == ""
                                        ? file.path.split('/').last
                                        : mp3Info['title'],
                                style: title_text_style,
                                blankSpace: 100,
                                startPadding: 10,
                                velocity: 35.0,
                              ),
                            ),
                          )
                        ],

                      ),
                      Row(
                        children: [
                          // Text(
                          //   mp3Info == null
                          //       ? ""
                          //       : mp3Info['album'] +
                          //           " " +
                          //           mp3Info['artist'] +
                          //           " " +
                          //           mp3Info['year'],
                          //   style: sub_title_text_style,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          Expanded(
                            child: SizedBox(
                              height: 20,
                              child: Marquee(
                                text: mp3Info == null
                                    ? ""
                                    : mp3Info['album'] +
                                        " " +
                                        mp3Info['artist'] +
                                        " " +
                                        mp3Info['year'],
                                style: sub_title_text_style,
                                blankSpace: 25,
                                velocity: 30.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 120,
                // color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          // color: Colors.red,
                          // width: 40,
                          height: 40,
                          child: TextButton(
                            onPressed: null,
                            child: Icon(
                              Icons.search_rounded,
                              size: 40,
                            ),
                          )),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          // color: Colors.yellow,
                          // width: 40,
                          child: IconButton(
                              onPressed: (){
                                setState(() {
                                  playst_toogle = !playst_toogle;
                                });
                              },
                              icon: Icon(
                                Icons.playlist_play_rounded,
                                size: 40,
                              ))),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Container(
                          // color: Colors.pink,
                          // width: 40,
                          child: IconButton(
                              onPressed: null,
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 40,
                              ))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: cur_img,
            fit: BoxFit.cover,
          ),
        ),
        // color: cur_color.withOpacity(0.6),
        child: new BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: new Container(
            decoration: new BoxDecoration(color: cur_color.withOpacity(0.2)),
            child: playst_toogle
                ? ScrollablePositionedList.builder(
              initialScrollIndex: cur_indx,
                    itemCount: fils?.length ?? 0,
                    itemScrollController: ListViewController,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTileTheme(
                            selectedColor: Colors.black,
                            child: ListTile(

                              title: Text(
                                fils[index].path.split('/').last,
                                style: TextStyle(fontSize: 17),
                              ),
                              // subtitle: Text(getFileInfo(fils[index].path).toString()),
                              leading: index == cur_indx
                                  ? MyVisualizer(visulaizer_status)
                                  : Icon(
                                      Icons.music_note_rounded,
                                      size: 40,
                                    ),
                              trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.more_vert_rounded),
                                alignment: Alignment.centerRight,
                              ),
                              onTap: () => PlayListTap(index),
                              selected: index == cur_indx,
                              // selectedTileColor: Colors.green,
                            ),
                          ),
                          Divider(
                            height: 0.2,
                            thickness: 0.2,
                            color: cur_color.withOpacity(0.9),
                          ),
                        ],
                      );
                    })
                : Center(
                    child: Container(
                      height: 500,
                      width: 500,
                      child: cur_album_art == null
                          ? Image.asset(default_player_logo)
                          : Image(image: cur_album_art),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: cur_color.withOpacity(0.4),
        elevation: 0,
        child: Container(
          height: 115,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                  width: double.infinity,
                  child: Slider(
                      value: slider_pos,
                      max: max_dur,
                      min: 0,
                      onChanged: (val) {
                        setState(() {
                          slider_pos = val;
                          // print((slider_pos*max_dur).toInt());
                          audioPlayer
                              .seek(Duration(seconds: (slider_pos).toInt()));
                        });
                      })),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(timer1.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: Text(timer2.toString()),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // IconButton(onPressed: null, icon: Icon(Icons.))
                  IconButton(
                      onPressed: () {
                        setState(() {
                          suffel_btn = !suffel_btn;
                        });
                      },
                      icon: suffel_btn
                          ? Icon(
                              Icons.shuffle_on_rounded,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )
                          : Icon(
                              Icons.shuffle_rounded,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )),
                  IconButton(
                      onPressed: () => previous(cur_args.files),
                      icon: Icon(
                        Icons.skip_previous,
                        color: plyr_btn_clrs,
                        size: plyr_btn_size,
                      )),
                  IconButton(
                      onPressed: () => PausePlay(),
                      icon: pauseply
                          ? Icon(
                              Icons.pause,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )
                          : Icon(
                              Icons.play_arrow,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )),
                  IconButton(
                      onPressed: () => next(cur_args.files),
                      icon: Icon(
                        Icons.skip_next,
                        color: plyr_btn_clrs,
                        size: plyr_btn_size,
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          repeat_btn = !repeat_btn;
                        });
                      },
                      icon: repeat_btn
                          ? Icon(
                              Icons.repeat_on_rounded,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )
                          : Icon(
                              Icons.repeat,
                              color: plyr_btn_clrs,
                              size: plyr_btn_size,
                            )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
