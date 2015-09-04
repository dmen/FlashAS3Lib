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
		private var ffs:String;
		private var process:NativeProcess ;
		
		public function Stitcher()
		{
			process = new NativeProcess();
		}
		
		
		public function get commandString():String
		{
			return ffs;
		}
		
		
		/**
		 * questions array is intro, five questions, outro
		 * Builds the text file that will be given to ffmpeg
		 */
		public function set questions(q:Array):void
		{
			//adobe media server path where videos are recorded
			var userPath:String = "c:/Program Files/Adobe/Flash Media Server 4.5/applications/reesesGameday/streams/_definst_/";
			
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
			ffs += " -i \"" + "overlay.png" + "\"";
			
			ffs += " -filter_complex \"[0:0] [0:1] [1:0] [1:1] [2:0] [2:1] [3:0] [3:1] [4:0] [4:1] [5:0] [5:1] [6:0] [6:1]";
			ffs += " [7:0] [7:1] [8:0] [8:1] [9:0] [9:1] [10:0] [10:1] [11:0] [11:1]";
			ffs += " concat=n=12:v=1:a=1 [bg] [a]; [bg][12:v] overlay=0:0[v]\" -map \"[v]\" -map \"[a]\" -c:v libx264 -c:a aac -strict -2 -y output.mp4";
		}
		
		
		public function set questions2(q:Array):void
		{
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;
	
			//var userPath:String = "c:/Program Files/Adobe/Flash Media Server 4.5/applications/reesesGameday/streams/_definst_/";
			var userPath:String = "c:/users/dmennenoh/";
			var args:Vector.<String> = new Vector.<String>();
			//intro
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//q1
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//user 1
			args.push('-r');
			args.push('29.96');
			args.push('-i');
			args.push(userPath + "user1.mp4");
			//q2
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//user 2
			args.push('-r');
			args.push('29.96');
			args.push('-i');
			args.push(userPath + "user2.mp4");
			//q3
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//user 3
			args.push('-r');
			args.push('29.96');
			args.push('-i');
			args.push(userPath + "user3.mp4");
			//q4
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//user 4
			args.push('-r');
			args.push('29.96');
			args.push('-i');
			args.push(userPath + "user4.mp4");
			//q5
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());
			//user 5
			args.push('-r');
			args.push('29.96');
			args.push('-i');
			args.push(userPath + "user5.mp4");
			//outro
			//args.push('-r');
			//args.push('24');
			args.push('-i');
			args.push(q.shift());			
			//overlay
			args.push('-i');
			args.push("c:/users/dmennenoh/overlay.png");
			
			args.push('-filter_complex');
			args.push('[0:0] [0:1] [1:0] [1:1] [2:0] [2:1] [3:0] [3:1] [4:0] [4:1] [5:0] [5:1] [6:0] [6:1] concat=n=12:v=1:a=1 [bg] [a]; [bg][12:v] overlay=0:0[v]');
			
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
			
			args.push('c:/users/dmennenoh/output.mp4');
			
			nativeProcessStartupInfo.arguments = args;
			
			
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, progress);

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