package com.gmrmarketing.sap.levisstadium
{
	
	public interface ISchedulerMethods
	{
		function init(initValue:String = ""):void;//first method called
		function show():void;//called once the 'ready' event has been received
		function hide():void;//not currently used
		function doStop():void;//called on the previous task once the new task dispatches ready - called right before the task is animated off stage
		function kill():void; //called once the task is off stage and right before it is nulled.
	}
	
}