package com.gmrmarketing.sap.levisstadium
{
	
	public interface ISchedulerMethods
	{
		function setConfig(config:String):void;//called immediately if there is config data in the xml for the task
		function show():void;//called once the 'ready' event has been received
		function hide():void;//not currently used
		function doStop():void;//called on the previous task once the new task dispatches ready
	}
	
}