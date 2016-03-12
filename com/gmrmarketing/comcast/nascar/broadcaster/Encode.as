package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.events.*;
	import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	
	public class Encode extends EventDispatcher
	{
		public static const COMPLETE:String = "encodeComplete";
		private var process:NativeProcess;
		private var userPath:String;//videos from FMS
		private var outputPath:String;//where to save compiled mp4
		
		
		public function Encode()
		{
			userPath = "c:/Program Files/Adobe/Flash Media Server 4.5/applications/comcastBTB/streams/_definst_/";
			outputPath = File.applicationStorageDirectory.nativePath + "\\";			
		}
		
		
		public function doEncode(guid:String):void
		{
			process = new NativeProcess();
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
    
			// set executable to the location of ffmpeg.exe
			var ffm:File = new File();
			ffm.nativePath = "c:/ffmpeg/bin/ffmpeg.exe"
			nativeProcessStartupInfo.executable = ffm;		
			
			var args:Vector.<String> = new Vector.<String>();
			
			args.push('-i');
			args.push(userPath + "user.flv");//AMS4.5 _definst_ folder	
			
			args.push('-vcodec');
			args.push('libx264');			
			args.push('-r');		
			args.push('29.97');
			args.push('-s');		
			args.push('640x360');
			args.push('-g');		
			args.push('15');
			args.push('-b');		
			args.push('1500k');
			args.push('-bt');		
			args.push('300k');
			args.push('-acodec');
			args.push('aac');//libvo_aacenc
			args.push('-ac');		
			args.push('1');
			args.push('-ab');		
			args.push('128k');
			args.push('-ar');		
			args.push('44100');
			args.push('-async');		
			args.push('1');
			args.push('-y');
			args.push('-pix_fmt');		
			args.push('yuv420p');
			args.push('-me_method');		
			args.push('epzs');
			args.push('-strict');		
			args.push('-2');
			args.push(outputPath + guid + ".mp4");//applicationStorageDirectory
			
			nativeProcessStartupInfo.arguments = args;			
			
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, progress);

			//when conversion is completed
			process.addEventListener(NativeProcessExitEvent.EXIT, encodeComplete);
    
			//start the process
			process.start(nativeProcessStartupInfo);			
		}
		
		
		private function encodeComplete(e:NativeProcessExitEvent):void
		{	
			process.removeEventListener(NativeProcessExitEvent.EXIT, encodeComplete);
			process.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, progress);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function progress(e:ProgressEvent):void 
		{
			// read the data from the error channel bytearray to string
			var s:String = process.standardError.readUTFBytes(process.standardError.bytesAvailable);
			trace(s);
		}
		
	}
	
}