package com.gmrmarketing.nissan.motorsports.videokiosk_2013
{
	import flash.events.*;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	
	public class ProcessVideo extends EventDispatcher
	{
		public static const COMPLETE:String = "processComplete";
		public static const ERROR:String = "processError";
		
		private var process:NativeProcess;
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var vidName:String;
		
		public function ProcessVideo()
		{			
		}
		
		
		/**
		 * Called from Main once both user videos have been recorded
		 * Runs the user 1 batch file which turns user1.flv to user1.mp4
		 * 
		 * @param $vidName - the user id (qr code value)
		 */
		public function startProcess($vidName:String):void
		{			
			var unique:String = String(new Date().valueOf());
			vidName = $vidName + "_" + unique;
			
			var cmd:File = new File("C:\\WINDOWS\\system32\\cmd.exe");
			var batFile:File = new File("C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\nissanCap\\streams\\_definst_\\process.bat");
			var workingDir:File = new File("C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\nissanCap\\streams\\_definst_");
			
			var processArgs:Vector.<String> = new Vector.<String>;

			processArgs.push("/c");
			processArgs.push(batFile.nativePath);
		
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.arguments = processArgs;
            nativeProcessStartupInfo.executable = cmd;
			nativeProcessStartupInfo.workingDirectory = workingDir;
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputDataHandler, false, 0, true);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorOutputDataHandler, false, 0, true);
			process.addEventListener(NativeProcessExitEvent.EXIT, processComplete, false, 0, true);
			
			process.start(nativeProcessStartupInfo);
		}
		
		
		public function getVidName():String
		{
			return vidName;
		}
		
		
		private function onStandardErrorOutputDataHandler(e:ProgressEvent):void
		{
			var status:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
			trace("standard error:", status);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, onStandardErrorOutputDataHandler);
			//process.exit();
			dispatchEvent(new Event(ERROR));
		}
		
		
		private function onStandardOutputDataHandler(e:ProgressEvent):void
		{
			var status:String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			trace("standard output",status)
		}
		
		
		private function processComplete(e:NativeProcessExitEvent):void
		{
			var sourceFile:File = new File("C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\nissanCap\\streams\\_definst_\\combined.mp4");
			//sourceFile = sourceFile.resolvePath("Kalimba.snd");
			var destination:File = new File("C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\nissanCap\\streams\\_definst_\\" + vidName + ".mp4");
			//destination = destination.resolvePath("test.snd");
			
			try  
			{
				sourceFile.moveTo(destination, true);
			}
			catch (error:Error)
			{
				trace("Error:" + error.message);
			}

			dispatchEvent(new Event(COMPLETE));
		}
	}	
}