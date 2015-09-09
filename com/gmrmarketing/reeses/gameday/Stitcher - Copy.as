/**
 * Used by Capture
 * 
 * creates the ffmpeg command
 */

package com.gmrmarketing.reeses.gameday
{
	import com.adobe.air.logging.FileTarget;
	import flash.events.*;
	import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	public class Stitcher extends EventDispatcher
	{
		private var questions:Array;
		private var ffs:String;
		private var process:NativeProcess ;
		private var userPath:String;//videos from FMS
		private var outputPath:String;//where to save compiled mp4
		private var overlayPath:String;//path to overlay.png - part of install
		
		
		public function Stitcher()
		{
			userPath = "c:/Program Files/Adobe/Flash Media Server 4.5/applications/reesesGameday/streams/_definst_/";
			overlayPath = File.applicationDirectory.nativePath + "\\";
			//outputPath = File.applicationStorageDirectory.nativePath + "\\";
			outputPath = File.applicationDirectory.nativePath + "\\";			
		}
		
		
		public function get commandString():String
		{
			return ffs;
		}
		
		
		/*
		public function set questions(q:Array):void
		{			
			ffs = "";			
			
			ffs += "ffmpeg -r 24 -i \"" + q.shift() + "\" -r 24 -i \"" + q.shift() + "\"";//intro q1
			ffs += " -r 29.96 -i \"" + userPath + "user1.flv\"";
			ffs += " -r 24 -i \"" + q.shift() + "\"";//q2
			ffs += " -r 29.96 -i \"" + userPath + "user2.flv\"";
			ffs += " -r 24 -i \"" + q.shift() + "\"";//q3
			ffs += " -r 29.96 -i \"" + userPath + "user3.flv\"";
			ffs += " -r 24 -i \"" + q.shift() + "\"";//q4
			ffs += " -r 29.96 -i \"" + userPath + "user4.flv\"";
			ffs += " -r 24 -i \"" + q.shift() + "\"";//q5
			ffs += " -r 29.96 -i \"" + userPath + "user5.flv\"";
			ffs += " -r 24 -i \"" + q.shift() + "\"";//outro
			
			//overlay
			ffs += " -i \"" + overlayPath + "overlay.png" + "\"";
			
			ffs += " -filter_complex \"[0:0] [0:1] [1:0] [1:1] [2:0] [2:1] [3:0] [3:1] [4:0] [4:1] [5:0] [5:1] [6:0] [6:1]";
			ffs += " [7:0] [7:1] [8:0] [8:1] [9:0] [9:1] [10:0] [10:1] [11:0] [11:1]";
			ffs += " concat=n=12:v=1:a=1 [bg] [a]; [bg][12:v] overlay=0:0[v]\" -map \"[v]\" -map \"[a]\" -c:v libx264 -c:a aac -strict -2 -y ";
			ffs += outputPath + "output.mp4";
		}
		*/
		
		/**
		 * Called from Capture.interviewComplete()
		 * questions array is intro, five questions, outro
		 */
		public function set questions2(q:Array):void
		{
			questions = q;
			
			process = new NativeProcess();
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-y');
			args.push('-r');
			args.push('29.97');
			args.push('-i');
			args.push(userPath + "user1.flv");
			args.push('-vcodec');
			args.push('png');
			args.push('-acodec');
			args.push('copy');
			args.push(outputPath + "user1.mov");
			
			nativeProcessStartupInfo.arguments = args;			
			
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, progress);

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, user1Complete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		private function user1Complete(e:NativeProcessExitEvent):void
		{	
			process.removeEventListener(NativeProcessExitEvent.EXIT, user1Complete);
			
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-y');
			args.push('-r');
			args.push('29.97');
			args.push('-i');
			args.push(userPath + "user2.flv");
			args.push('-vcodec');
			args.push('png');
			args.push('-acodec');
			args.push('copy');
			args.push(outputPath + "user2.mov");
			
			nativeProcessStartupInfo.arguments = args;	

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, user2Complete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		private function user2Complete(e:NativeProcessExitEvent):void
		{		
			process.removeEventListener(NativeProcessExitEvent.EXIT, user2Complete);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-y');
			args.push('-r');
			args.push('29.97');
			args.push('-i');
			args.push(userPath + "user3.flv");
			args.push('-vcodec');
			args.push('png');
			args.push('-acodec');
			args.push('copy');
			args.push(outputPath + "user3.mov");
			
			nativeProcessStartupInfo.arguments = args;		

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, user3Complete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		private function user3Complete(e:NativeProcessExitEvent):void
		{	
			process.removeEventListener(NativeProcessExitEvent.EXIT, user3Complete);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-y');
			args.push('-r');
			args.push('29.97');
			args.push('-i');
			args.push(userPath + "user4.flv");
			args.push('-vcodec');
			args.push('png');
			args.push('-acodec');
			args.push('copy');
			args.push(outputPath + "user4.mov");
			
			nativeProcessStartupInfo.arguments = args;	
			
			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, user4Complete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		private function user4Complete(e:NativeProcessExitEvent):void
		{			
			process.removeEventListener(NativeProcessExitEvent.EXIT, user4Complete);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-y');
			args.push('-r');
			args.push('29.97');
			args.push('-i');
			args.push(userPath + "user5.flv");
			args.push('-vcodec');
			args.push('png');
			args.push('-acodec');
			args.push('copy');
			args.push(outputPath + "user5.mov");
			
			nativeProcessStartupInfo.arguments = args;					

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, user5Complete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		private function user5Complete(e:NativeProcessExitEvent):void
		{		
			process.removeEventListener(NativeProcessExitEvent.EXIT, user5Complete);
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();			
			
			//intro
			args.push('-i');
			args.push(questions.shift());
			//q1			
			args.push('-i');
			args.push(questions.shift());
			//user 1			
			args.push('-i');
			args.push(outputPath + "user1.mov");
			//q2			
			args.push('-i');
			args.push(questions.shift());
			//user 2			
			args.push('-i');
			args.push(outputPath + "user2.mov");
			//q3			
			args.push('-i');
			args.push(questions.shift());
			//user 3			
			args.push('-i');
			args.push(outputPath + "user3.mov");
			//q4			
			args.push('-i');
			args.push(questions.shift());
			//user 4
			args.push('-i');
			args.push(outputPath + "user4.mov");
			//q5
			args.push('-i');
			args.push(questions.shift());
			//user 5
			args.push('-i');
			args.push(outputPath + "user5.mov");
			//outro
			args.push('-i');
			args.push(questions.shift());			
			//overlay
			args.push('-i');
			args.push(overlayPath + "overlay.png");
			
			args.push('-filter_complex');
			args.push('[0:0][0:1][1:0][1:1][2:0][2:1][3:0][3:1][4:0][4:1][5:0][5:1][6:0][6:1][7:0][7:1][8:0][8:1][9:0][9:1][10:0][10:1][11:0][11:1]concat=n=12:v=1:a=1[bg][a];');
			args.push('[bg][12:v]overlay=0:0[v]');
			
			args.push('-map');
			args.push('[v]');
			
			args.push('-map');
			args.push('[a]');
			
			args.push('-c:v');
			args.push('libx264');
			
			args.push('-c:a');
			args.push('aac');
			
			args.push('-strict');
			args.push('-2');
			
			args.push('-y');
			
			args.push(outputPath + "output.mp4");
			
			nativeProcessStartupInfo.arguments = args;	

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
    
			//start the process
			process.start(nativeProcessStartupInfo);
		}
		
		
		private function progress(e:ProgressEvent):void 
		{
			// read the data from the error channel bytearray to string
			var s:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
			trace(s);
		}
		
		
		private function onExit(e:NativeProcessExitEvent):void 
		{
			trace("Conversion complete.");
		}
	}
	
}