package com.gmrmarketing.testing
{
	import flash.filesystem.*; ;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.Camera;
	import flash.media.Video;
	import com.gmrmarketing.utilities.FolderWatcher;
	import com.greensock.TweenMax;
	import fl.data.DataProvider;
	
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
		
		public function MultiCam()
		{
			var cams:Array = Camera.names;
			
			queue = new Queue();
			
			so = SharedObject.getLocal("multicamconfig");
			
			dp = new DataProvider();
			for (var i:int = 0; i < cams.length; i++) {
				dp.addItem( { label:cams[i], value:i.toString() } );
			}			
			
			combo1.dataProvider = dp;
			combo2.dataProvider = dp;
			combo3.dataProvider = dp;
			
			v1 = new Video(320, 240);
			v2 = new Video(320, 240);
			v3 = new Video(320, 240);			
			
			if (so.data.cam1 != undefined) {
				combo1.selectedIndex = so.data.cam1;
				combo2.selectedIndex = so.data.cam2;
				combo3.selectedIndex = so.data.cam3;
				startSeconds.text = String(so.data.startSeconds);
				numSeconds.text = String(so.data.numSeconds);
				everyNthFrame.text = String(so.data.everyNthFrame);
			}else {
				so.data.cam1 = 0;
				so.data.cam2 = 0;
				so.data.cam3 = 0;
				so.data.startSeconds = 3;
				so.data.numSeconds = 15;
				so.data.everyNthFrame = 10; //at 30 fps - this records at 3 fps
				so.flush();
			}
			
			combo1.selectedIndex = so.data.cam1;
			combo2.selectedIndex = so.data.cam2;
			combo3.selectedIndex = so.data.cam3;						
			
			changeCam1();
			changeCam2();
			changeCam3();
			
			cam1.setMode(640, 480, 30);
			cam2.setMode(640, 480, 30);
			cam3.setMode(640, 480, 30);
			
			v1.attachCamera(cam1);
			v2.attachCamera(cam2);
			v3.attachCamera(cam3);
			
			addChild(v1);
			addChild(v2);
			addChild(v3);
			v1.x = 10;
			v1.y = 30;
			v2.x = 340;
			v2.y = 30;
			v3.x = 670;
			v3.y = 30;			
			
			combo1.addEventListener(Event.CHANGE, changeCam1);
			combo2.addEventListener(Event.CHANGE, changeCam2);
			combo3.addEventListener(Event.CHANGE, changeCam3);
			
			watcher1 = new FolderWatcher();
			watcher1.setFolder("c:\\test\\");
			watcher1.setWatchFile("start1.txt");
			watcher1.addEventListener(FolderWatcher.FILE_FOUND, startRecording1, false, 0, true);
			watcher1.startWatching();
			
			watcher2 = new FolderWatcher();
			watcher2.setFolder("c:\\test\\");
			watcher2.setWatchFile("start2.txt");
			watcher2.addEventListener(FolderWatcher.FILE_FOUND, startRecording2, false, 0, true);
			watcher2.startWatching();
			
			watcher3 = new FolderWatcher();
			watcher3.setFolder("c:\\test\\");
			watcher3.setWatchFile("start3.txt");
			watcher3.addEventListener(FolderWatcher.FILE_FOUND, startRecording3, false, 0, true);
			watcher3.startWatching();
			
			everyNthFrame.addEventListener(Event.CHANGE, calcMaxFrames);
			numSeconds.addEventListener(Event.CHANGE, calcMaxFrames);
			
			init();
		}
		
		
		private function init():void
		{			
			frames = [[],[],[]];
			frameCount = 0;	
			
			email1 = "";
			email2 = "";
			email3 = "";
			
			recording1 = false;
			recording2 = false;
			recording3 = false;
		}
		
		
		private function changeCam1(e:Event = null):void
		{		
			v1.attachCamera(null);
			cam1 = Camera.getCamera(combo1.selectedItem.value);			
			v1.attachCamera(cam1);
			so.data.cam1 = combo1.selectedIndex;
			so.flush();
		}
		private function changeCam2(e:Event = null):void
		{		
			v2.attachCamera(null);
			cam2 = Camera.getCamera(combo2.selectedItem.value);
			v2.attachCamera(cam2);
			so.data.cam2 = combo2.selectedIndex;
			so.flush();
		}
		private function changeCam3(e:Event = null):void
		{		
			v3.attachCamera(null);
			cam3 = Camera.getCamera(combo3.selectedItem.value);
			v3.attachCamera(cam3);
			so.data.cam3 = combo3.selectedIndex;
			so.flush();
		}
		
		
		/**
		 * called when folder watcher1 finds start1.txt in the watch folder
		 * @param	e
		 */
		private function startRecording1(e:Event):void
		{
			p1.text = "player 1:waiting to start";
			calcMaxFrames();			
			watcher1.stopWatching();
			loadFile1();
			TweenMax.delayedCall(parseInt(startSeconds.text), rec1);
		}
		private function rec1():void
		{
			p1.text = "player 1:recording";
			recording1 = true;
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}		
		private function startRecording2(e:Event):void
		{
			p2.text = "player 2:waiting to start";
			calcMaxFrames();
			watcher2.stopWatching();
			loadFile2();
			TweenMax.delayedCall(parseInt(startSeconds.text), rec2);
		}
		private function rec2():void
		{
			p2.text = "player 2:recording";
			recording2 = true;
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}
		private function startRecording3(e:Event):void
		{
			p3.text = "player 3:waiting to start";
			calcMaxFrames();
			watcher3.stopWatching();
			loadFile3();
			TweenMax.delayedCall(parseInt(startSeconds.text), rec3);
		}
		private function rec3():void
		{
			p3.text = "player 3:recording";
			recording3 = true;
			addEventListener(Event.ENTER_FRAME, grabFrame);
		}
		
		
		private function calcMaxFrames(e:Event = null):void
		{
			everyNth = parseInt(everyNthFrame.text);
			maxFrames = (30 / everyNth) * parseInt(numSeconds.text);
			framesInGIF.text = "Frames in GIF: " + maxFrames.toString();
		}
		
		
		private function loadFile1():void
		{
			fileLoader1 = new URLLoader();
			fileLoader1.addEventListener(Event.COMPLETE, loaded1);
			fileLoader1.load(new URLRequest("c:/test/start1.txt"));
		}
		private function loadFile2():void
		{
			fileLoader2 = new URLLoader();
			fileLoader2.addEventListener(Event.COMPLETE, loaded2);
			fileLoader2.load(new URLRequest("c:/test/start2.txt"));
		}
		private function loadFile3():void
		{
			fileLoader3 = new URLLoader();
			fileLoader3.addEventListener(Event.COMPLETE, loaded3);
			fileLoader3.load(new URLRequest("c:/test/start3.txt"));
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
			var targetFile:File = targetDir.resolvePath("c:/test/start" + which + ".txt");
			targetFile.deleteFile();
		}		
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % everyNth == 0) {
				
				var a:BitmapData;
				
				if(recording1){
					a = new BitmapData(640, 480);
					cam1.drawToBitmapData(a);
					frames[0].push(a);
				}
				if(recording2){
					a = new BitmapData(640, 480);
					cam2.drawToBitmapData(a);
					frames[1].push(a);
				}
				if(recording3){
					a = new BitmapData(640, 480);
					cam3.drawToBitmapData(a);
					frames[2].push(a);
				}
				
			}
			if (frames[0].length >= maxFrames) {
				p1.text = "player 1:finished";
				recording1 = false;
			}
			if (frames[1].length >= maxFrames) {
				p2.text = "player 2:finished";
				recording2 = false;
			}
			if (frames[2].length >= maxFrames) {
				p3.text = "player 3:finished";
				recording3 = false;
			}
			if (!recording1 && !recording2 && !recording3) {
				p1.text = "player 1:idle";
				p2.text = "player 2:idle";
				p3.text = "player 3:idle";
				removeEventListener(Event.ENTER_FRAME, grabFrame);
				process1();
			}
		}
		
		private function process1():void
		{
			if (frames[0].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, process2, false, 0, true);
				encoder.addFrames(frames[0]);
			}else {
				process2();
			}
		}
		
		private function process2(e:Event = null):void
		{
			encoder.removeEventListener(Encoder.COMPLETE, process2);
			
			if(e != null){
				gif1 = encoder.getGif();
			}
			if (frames[1].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, process3, false, 0, true);
				encoder.addFrames(frames[1]);
			}else {
				process3();
			}			
		}
		
		
		private function process3(e:Event = null):void
		{
			encoder.removeEventListener(Encoder.COMPLETE, process3);
			
			if(e != null){
				gif2 = encoder.getGif();
			}
			if (frames[2].length != 0) {
				encoder.addEventListener(Encoder.COMPLETE, finishProcess, false, 0, true);
				encoder.addFrames(frames[2]);
			}else {
				finishProcess();
			}	
		}
		
		
		private function finishProcess(e:Event = null):void
		{
			encoder.removeEventListener(Encoder.COMPLETE, finishProcess);
			if(e != null){
				gif3 = encoder.getGif();
			}
			
			if (frames[0].length != 0 && email1 != "") {
				var p1:Object = { email:email1, gif:gif1 } );
				queue.add(p1);
			}
			if (frames[1].length != 0 && email2 != "") {
				var p2:Object = { email:email1, gif:gif2 } );
				queue.add(p2);
			}
			if (frames[2].length != 0 && email3 != "") {
				var p3:Object = { email:email1, gif:gif3 } );
				queue.add(p3);
			}
			
			init();
		}
			
			
	}
	
}