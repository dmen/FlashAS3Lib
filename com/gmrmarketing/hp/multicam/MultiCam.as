package com.gmrmarketing.hp.multicam
{
	import flash.filesystem.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.Camera;
	import flash.media.Video;
	import com.gmrmarketing.utilities.FolderWatcher;
	import com.greensock.TweenMax;
	import fl.data.DataProvider;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class MultiCam extends MovieClip
	{
		private var v1:Video;
		private var v2:Video;
		private var v3:Video;
		
		private var cam1:Camera;
		private var cam2:Camera;
		private var cam3:Camera;
		
		private var frames:Array;
		private var frameCount:int;
		private var maxFrames:int;
		private var everyNth:int;
		
		private var fileLoader1:URLLoader;
		private var fileLoader2:URLLoader;
		private var fileLoader3:URLLoader;
		private var watcher1:FolderWatcher; //watches for start1.txt
		private var watcher2:FolderWatcher; //watches for start2.txt
		private var watcher3:FolderWatcher; //watches for start3.txt
		private var recording1:Boolean;
		private var recording2:Boolean;
		private var recording3:Boolean;
		private var email1:String;
		private var email2:String;
		private var email3:String;
		
		private var gif1:String;
		private var gif2:String;
		private var gif3:String;
		
		private var encoder:Encoder;
		private var queue:Queue;
		
		private var dp:DataProvider;//camera names for drop downs
		private var so:SharedObject;
		
		private var camW:int;
		private var camH:int;
		
		
		public function MultiCam()
		{
			var cams:Array = Camera.names;
			
			queue = new Queue();
			
			so = SharedObject.getLocal("multicamconfig");
			//so.clear();
			
			dp = new DataProvider();
			for (var i:int = 0; i < cams.length; i++) {
				dp.addItem( { label:cams[i], value:i.toString() } );
			}			
			
			combo1.dataProvider = dp;
			combo2.dataProvider = dp;
			combo3.dataProvider = dp;			
			
			v1 = new Video(320, 213);
			v2 = new Video(320, 213);
			v3 = new Video(320, 213);			
			
			var largestIndex:int = Math.max(so.data.cam1, so.data.cam2, so.data.cam3);
			
			if (so.data.cam1 != undefined && largestIndex < cams.length) {
				combo1.selectedIndex = so.data.cam1;
				combo2.selectedIndex = so.data.cam2;
				combo3.selectedIndex = so.data.cam3;
				startSeconds.text = String(so.data.startSeconds);
				numSeconds.text = String(so.data.numSeconds);
				everyNthFrame.text = String(so.data.everyNthFrame);
				folderName.text = so.data.folderName;
				theX.visible = so.data.saveGif;
				camWidth.text = String(so.data.camWidth);
				camHeight.text = String(so.data.camHeight);
				camW = so.data.camWidth;
				camH = so.data.camHeight;
				gifWidth.text = String(so.data.gifWidth);
			}else {
				so.data.cam1 = 0;
				so.data.cam2 = 0;
				so.data.cam3 = 0;
				so.data.startSeconds = 10;
				so.data.numSeconds = 10;
				so.data.everyNthFrame = 10; //at 30 fps - this records at 3 fps
				so.data.folderName = "gifs";
				so.data.saveGif = false;
				so.data.camWidth = 720;
				so.data.camHeight = 480;
				camW = 720; camH = 480;
				so.data.gifWidth = 300;
				so.flush();
			}
			
			combo1.selectedIndex = so.data.cam1;
			combo2.selectedIndex = so.data.cam2;
			combo3.selectedIndex = so.data.cam3;						
			
			changeCam1();
			changeCam2();
			changeCam3();
			
			v1.attachCamera(cam1);
			v2.attachCamera(cam2);
			v3.attachCamera(cam3);
			
			addChild(v1);
			addChild(v2);
			addChild(v3);
			v1.x = 10;
			v1.y = 50;
			v2.x = 340;
			v2.y = 50;
			v3.x = 670;
			v3.y = 50;			
			
			combo1.addEventListener(Event.CHANGE, changeCam1);
			combo2.addEventListener(Event.CHANGE, changeCam2);
			combo3.addEventListener(Event.CHANGE, changeCam3);
			
			//make sure that c:\test exists
			var fold:File = new File(); 
			fold.nativePath = "c:\\cams_vmworld";
			if(!fold.exists){
				fold.createDirectory();
			}
			
			watcher1 = new FolderWatcher();
			watcher1.setFolder("c:\\cams_vmworld\\");
			watcher1.setWatchFile("start1.txt");
			watcher1.addEventListener(FolderWatcher.FILE_FOUND, startRecording1, false, 0, true);			
			
			watcher2 = new FolderWatcher();
			watcher2.setFolder("c:\\cams_vmworld\\");
			watcher2.setWatchFile("start2.txt");
			watcher2.addEventListener(FolderWatcher.FILE_FOUND, startRecording2, false, 0, true);			
			
			watcher3 = new FolderWatcher();
			watcher3.setFolder("c:\\cams_vmworld\\");
			watcher3.setWatchFile("start3.txt");
			watcher3.addEventListener(FolderWatcher.FILE_FOUND, startRecording3, false, 0, true);			
			
			startSeconds.addEventListener(Event.CHANGE, calcMaxFrames);
			everyNthFrame.addEventListener(Event.CHANGE, calcMaxFrames);
			numSeconds.addEventListener(Event.CHANGE, calcMaxFrames);
			folderName.addEventListener(Event.CHANGE, folderChange);
			camWidth.addEventListener(Event.CHANGE, camSizeChange);
			camHeight.addEventListener(Event.CHANGE, camSizeChange);
			gifWidth.addEventListener(Event.CHANGE, gifSizeChange);
			btnSave.addEventListener(MouseEvent.CLICK, folderSave);
			
			encoder = new Encoder();
			
			init();
			calcMaxFrames();
			camSizeChange();
		}
		
		
		private function init():void
		{			
			frames = [[],[],[]];
			frameCount = 0;	
			
			email1 = "";
			email2 = "";
			email3 = "";
			
			gif1 = "";
			gif2 = "";
			gif3 = "";
			
			recording1 = false;
			recording2 = false;
			recording3 = false;
			
			watcher1.startWatching();
			watcher2.startWatching();
			watcher3.startWatching();
		}
		
		private function camSizeChange(e:Event = null):void
		{
			camW = parseInt(camWidth.text);
			camH = parseInt(camHeight.text);
			
			so.data.camWidth = camW;
			so.data.camHeight = camH;				
			so.flush();
			
			changeCam1();
			changeCam2();
			changeCam3();
			
			gifSizeChange();
		}
		
		private function gifSizeChange(e:Event = null):void
		{
			so.data.gifWidth = parseInt(gifWidth.text);		
			so.flush();
			gifHeight.text = String(Math.floor((parseInt(gifWidth.text) / camW) * camH));
			encoder.setSize(parseInt(gifWidth.text), parseInt(gifHeight.text));
		}
		
		private function changeCam1(e:Event = null):void
		{		
			v1.attachCamera(null);
			cam1 = Camera.getCamera(combo1.selectedItem.value);			
			v1.attachCamera(cam1);
			cam1.setMode(camW, camH, 30);
			
			so.data.cam1 = combo1.selectedIndex;
			so.flush();
			
			size1.text = String(cam1.width) + "x" + String(cam1.height);
		}
		private function changeCam2(e:Event = null):void
		{		
			v2.attachCamera(null);
			cam2 = Camera.getCamera(combo2.selectedItem.value);
			v2.attachCamera(cam2);
			cam2.setMode(camW, camH, 30);
			
			so.data.cam2 = combo2.selectedIndex;
			so.flush();
			
			size2.text = String(cam2.width) + "x" + String(cam2.height);
		}
		private function changeCam3(e:Event = null):void
		{		
			v3.attachCamera(null);
			cam3 = Camera.getCamera(combo3.selectedItem.value);
			v3.attachCamera(cam3);
			cam3.setMode(camW, camH, 30);
			
			so.data.cam3 = combo3.selectedIndex;
			so.flush();
			
			size3.text = String(cam3.width) + "x" + String(cam3.height);
		}
		
		
		/**
		 * called when folder watcher1 finds start1.txt in the watch folder
		 * @param	e
		 */
		private function startRecording1(e:Event):void
		{
			p1.text = "player 1: waiting to start";
			calcMaxFrames();			
			watcher1.stopWatching();
			loadFile1();
			
			TweenMax.to(p1Outline.outline, .5, { tint:0x00cc00 } );
			
			var t:Timer = new Timer(1000 * parseInt(startSeconds.text), 1);
			t.addEventListener(TimerEvent.TIMER, rec1, false, 0, true);
			t.start();
		}
		private function rec1(e:TimerEvent):void
		{
			recording1 = true;
			p1.text = "player 1: recording";
			TweenMax.to(p1Outline.outline, .5, { tint:0xff0000 } );
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}	
		
		/**
		 * called when folder watcher2 finds start2.txt in the watch folder
		 * @param	e
		 */
		private function startRecording2(e:Event):void
		{
			p2.text = "player 2: waiting to start";
			calcMaxFrames();
			watcher2.stopWatching();
			loadFile2();
			
			TweenMax.to(p2Outline.outline, .5, { tint:0x00cc00 } );
			
			var t:Timer = new Timer(1000 * parseInt(startSeconds.text), 1);
			t.addEventListener(TimerEvent.TIMER, rec2, false, 0, true);
			t.start();
		}
		private function rec2(e:TimerEvent):void
		{
			recording2 = true;
			p2.text = "player 2: recording";
			TweenMax.to(p2Outline.outline, .5, { tint:0xff0000 } );
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}
		
		/**
		 * called when folder watcher3 finds start3.txt in the watch folder
		 * @param	e
		 */
		private function startRecording3(e:Event):void
		{
			p3.text = "player 3: waiting to start";
			calcMaxFrames();
			watcher3.stopWatching();
			loadFile3();
			
			TweenMax.to(p3Outline.outline, .5, { tint:0x00cc00 } );
			
			var t:Timer = new Timer(1000 * parseInt(startSeconds.text), 1);
			t.addEventListener(TimerEvent.TIMER, rec3, false, 0, true);
			t.start();
		}
		private function rec3(e:TimerEvent):void
		{
			recording3 = true;
			p3.text = "player 3: recording";
			TweenMax.to(p3Outline.outline, .5, { tint:0xff0000 } );
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}
		
		
		private function calcMaxFrames(e:Event = null):void
		{
			everyNth = parseInt(everyNthFrame.text);
			maxFrames = (30 / everyNth) * parseInt(numSeconds.text);
			framesInGIF.text = "Total frames in GIF: " + maxFrames.toString();
			
			so.data.startSeconds = parseInt(startSeconds.text);
			so.data.numSeconds = parseInt(numSeconds.text);
			so.data.everyNthFrame = parseInt(everyNthFrame.text);
			so.flush();
		}
		private function folderChange(e:Event):void
		{
			so.data.folderName = folderName.text;
			so.flush();
		}
		private function folderSave(e:MouseEvent):void
		{
			if (theX.visible) {
				theX.visible = false;
				so.data.saveGif = false;
			}else {
				theX.visible = true;
				so.data.saveGif = true;
			}
			so.flush();
		}
		
		private function loadFile1():void
		{
			fileLoader1 = new URLLoader();
			fileLoader1.addEventListener(Event.COMPLETE, loaded1);
			fileLoader1.load(new URLRequest("c:/cams_vmworld/start1.txt"));
		}
		private function loadFile2():void
		{
			fileLoader2 = new URLLoader();
			fileLoader2.addEventListener(Event.COMPLETE, loaded2);
			fileLoader2.load(new URLRequest("c:/cams_vmworld/start2.txt"));
		}
		private function loadFile3():void
		{
			fileLoader3 = new URLLoader();
			fileLoader3.addEventListener(Event.COMPLETE, loaded3);
			fileLoader3.load(new URLRequest("c:/cams_vmworld/start3.txt"));
		}
		
		
		private function loaded1(e:Event):void
		{
			fileLoader1.removeEventListener(Event.COMPLETE, loaded1);
			fileLoader1.close();
			
			var j:Object = JSON.parse(e.target.data) as Object;	//client & email keys
			email1 = j.email;
			TweenMax.delayedCall(.5, deleteFile, ["1"]);
		}
		private function loaded2(e:Event):void
		{
			fileLoader2.removeEventListener(Event.COMPLETE, loaded2);
			fileLoader2.close();
			
			var j:Object = JSON.parse(e.target.data) as Object;			
			email2 = j.email;
			TweenMax.delayedCall(.5, deleteFile, ["2"]);
		}
		private function loaded3(e:Event):void
		{
			fileLoader3.removeEventListener(Event.COMPLETE, loaded3);
			fileLoader3.close();
			
			var j:Object = JSON.parse(e.target.data) as Object;			
			email3 = j.email;
			TweenMax.delayedCall(.5, deleteFile, ["3"]);
		}
		
		
		private function deleteFile(which:String):void
		{
			var targetDir:File = new File();
			var targetFile:File = targetDir.resolvePath("c:/cams_vmworld/start" + which + ".txt");
			targetFile.deleteFile();
		}		
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % everyNth == 0) {
				
				if(recording1){
					var a:BitmapData = new BitmapData(cam1.width, cam1.height);
					cam1.drawToBitmapData(a);
					frames[0].push(a);
				}
				if(recording2){
					var b:BitmapData = new BitmapData(cam2.width, cam2.height);
					cam2.drawToBitmapData(b);
					frames[1].push(b);
				}
				if(recording3){
					var c:BitmapData = new BitmapData(cam3.width, cam3.height);
					cam3.drawToBitmapData(c);
					frames[2].push(c);
				}
				
			}
			if (frames[0].length >= maxFrames) {
				p1.text = "player 1: finished";
				recording1 = false;
				TweenMax.to(p1Outline.outline, .5, { tint:0xcccccc } );
			}
			if (frames[1].length >= maxFrames) {
				p2.text = "player 2: finished";
				recording2 = false;
				TweenMax.to(p2Outline.outline, .5, { tint:0xcccccc } );
			}
			if (frames[2].length >= maxFrames) {
				p3.text = "player 3: finished";
				recording3 = false;
				TweenMax.to(p3Outline.outline, .5, { tint:0xcccccc } );
			}
			if (recording1 == false && recording2 == false && recording3 == false) {
				p1.text = "player 1: idle";
				p2.text = "player 2: idle";
				p3.text = "player 3: idle";
				removeEventListener(Event.ENTER_FRAME, grabFrame);
				process1();
			}
		}
		
		private function process1():void
		{
			if (frames[0].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, process2, false, 0, true);
				encoder.addEventListener(Encoder.UPDATE, update1, false, 0, true);
				if (theX.visible && email1 != "") {
					encoder.addFrames(frames[0], true, email1, folderName.text);
				}else{
					encoder.addFrames(frames[0]);
				}
				TweenMax.to(p1Outline.outline, .5, { tint:0x07bcff } );//blue for encoding
			}else {
				process2();
			}
		}
		private function update1(e:Event):void
		{
			p1.text = "player 1 encoding: " + String(Math.round(100 * encoder.getProgress())) + "%";
		}
		
		private function process2(e:Event = null):void
		{
			p1.text = "player 1: idle";
			TweenMax.to(p1Outline.outline, .5, { tint:0xcccccc } );
			encoder.removeEventListener(Encoder.UPDATE, update1);
			encoder.removeEventListener(Encoder.COMPLETE, process2);
			
			if(e != null){
				gif1 = encoder.getGif();
			}
			if (frames[1].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, process3, false, 0, true);
				encoder.addEventListener(Encoder.UPDATE, update2, false, 0, true);
				if (theX.visible && email2 != "") {
					encoder.addFrames(frames[1], true, email2, folderName.text);
				}else{
					encoder.addFrames(frames[1]);
				}
				TweenMax.to(p2Outline.outline, .5, { tint:0x07bcff } );
			}else {
				process3();
			}			
		}
		private function update2(e:Event):void
		{
			p2.text = "player 2 encoding: " + String(Math.round(100 * encoder.getProgress())) + "%";
		}
		
		private function process3(e:Event = null):void
		{
			p2.text = "player 2: idle";
			TweenMax.to(p2Outline.outline, .5, { tint:0xcccccc } );
			encoder.removeEventListener(Encoder.UPDATE, update2);
			encoder.removeEventListener(Encoder.COMPLETE, process3);
			
			if(e != null){
				gif2 = encoder.getGif();
			}
			if (frames[2].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, finishProcess, false, 0, true);
				encoder.addEventListener(Encoder.UPDATE, update3, false, 0, true);
				if (theX.visible && email3 != "") {
					encoder.addFrames(frames[2], true, email3, folderName.text);
				}else{
					encoder.addFrames(frames[2]);
				}
				TweenMax.to(p3Outline.outline, .5, { tint:0x07bcff } );
			}else {
				finishProcess();
			}	
		}
		private function update3(e:Event):void
		{
			p3.text = "player 3 encoding: " + String(Math.round(100 * encoder.getProgress())) + "%";
		}
		
		private function finishProcess(e:Event = null):void
		{
			p3.text = "player 3: idle";
			TweenMax.to(p3Outline.outline, .5, { tint:0xcccccc } );
			encoder.removeEventListener(Encoder.UPDATE, update3);
			encoder.removeEventListener(Encoder.COMPLETE, finishProcess);
			
			if(e != null){
				gif3 = encoder.getGif();
			}
			
			var players:Array = [];
			
			if (gif1 != "" && email1 != "") {
				var p1:Object = { email:email1, gif:gif1 };
				players.push(p1);
			}
			if (gif2 != "" && email2 != "") {
				var p2:Object = { email:email2, gif:gif2 };
				players.push(p2);
			}
			if (gif3 != "" && email3 != "") {
				var p3:Object = { email:email3, gif:gif3 };
				players.push(p3);
			}
			
			queue.add(players);
			
			init();
		}
			
			
	}
	
}