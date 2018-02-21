package com.gmrmarketing.utilities
{	
	import flash.events.EventDispatcher;
	import flash.filesystem.*;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.desktop.NativeProcess;
 

	public class DisableCharms extends EventDispatcher
	{
		public function DisableCharms()
		{
			
		}
		
		public function disable():void
		{
			var myApp:File = File.applicationDirectory.resolvePath("regedt32.exe");
			var myAppProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var myAppProcess:NativeProcess = new NativeProcess();
			myAppProcessStartupInfo.executable = myApp;
			myAppProcess.start(myAppProcessStartupInfo);
		}
	}
	
}