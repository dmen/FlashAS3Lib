/**
 * Uses AIR NativeProcess to run FFMPEG
 * Assumes path of: c:/ffmpeg/bin/ffmpeg.exe
 * Converts FLV to MOV for SAP 
 */
package com.gmrmarketing.sap.ticker
{
	import flash.events.*;
	import flash.filesystem.*;
	import flash.desktop.*;
	
	public class FFMPEG extends EventDispatcher
	{
		public static const COMPLETE:String = "conversionComplete";
		public static const DELETED:String = "deletedOldMOV";
		
		private var _process:NativeProcess;
		private var _processArgs:Vector.<String>;
		private var _nativeProcessStartupInfo:NativeProcessStartupInfo;

		
		public function FFMPEG()
		{			
		}
		
		
		public function convert(inf:String, outf:String):void
		{
			var inPath:String = File.documentsDirectory.resolvePath(inf).nativePath;
			var outFile:File = File.documentsDirectory.resolvePath(outf);
			var outPath:String = outFile.nativePath;
			
			if (outFile.exists) {
				outFile.deleteFile();
				dispatchEvent(new Event(DELETED));
			}
			
			_nativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			// set executable to the location of ffmpeg.exe
			_nativeProcessStartupInfo.executable = File.applicationDirectory.resolvePath("c:/ffmpeg/bin/ffmpeg.exe");
			
			// set up the process aarguments - these arguments work for WebM
			// you can find arguments on the net for specific formats by searching google
			// for example: ffmpeg convert mov to ogv
			_processArgs = new Vector.<String>();
			
			_processArgs.push('-i'); // input flag
			_processArgs.push(inPath);
			_processArgs.push('-vcodec'); //video codec
			_processArgs.push('libx264'); 
			//_processArgs.push('-preset'); 
			//_processArgs.push('lossless_max'); 
			//_processArgs.push('libxvid'); 
			//_processArgs.push('libx264'); 
			_processArgs.push('-r'); // frame rate
			_processArgs.push('30');
			_processArgs.push('-s'); // video size flag
			_processArgs.push('1280x1024'); 
			_processArgs.push('-g'); //GOP size
			_processArgs.push('15');
			_processArgs.push('-b:v'); // bitrate:video flag
			_processArgs.push('3000K');
			//_processArgs.push('-bt'); 
			//_processArgs.push('300K'); // bitrate
			_processArgs.push('-acodec');//audio codec 
			_processArgs.push('copy');
			_processArgs.push('-y'); // always overwrite existing file
			_processArgs.push('-pix_fmt');
			_processArgs.push('yuv420p');
			_processArgs.push('-me_method');//motion estimation
			_processArgs.push('umh');
			_processArgs.push('-vf');
			_processArgs.push('mp=eq=0:3');
			//_processArgs.push('epzs');
			_processArgs.push('-strict');
			_processArgs.push('-2');			
			_processArgs.push(outPath); // output path
			
			_nativeProcessStartupInfo.arguments = _processArgs;
			
			// create new native process
			_process = new NativeProcess();
			
			// add listeners
			// ffmpeg sends conversion status data through the STANDARD_ERROR_DATA channel
			_process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, progress);

			// when conversion is completed
			_process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			
			// start the process
			_process.start(_nativeProcessStartupInfo);
			
		}
		
		
		private function progress(e:ProgressEvent):void 
		{
			// read the data from the error channel bytearray to string
			var s:String = _process.standardError.readUTFBytes(_process.standardError.bytesAvailable);
			trace(s);
		}
		
		private function onExit(e:NativeProcessExitEvent):void 
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}