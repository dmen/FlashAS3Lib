package com.gmrmarketing.sap.levisstadium
{
	
	public interface ISchedulerMethods
	{
		function init(initValue:String = ""):void;//first method called - receives any data from the initData attribute in the config.xml file
		function show():void;//called once the 'ready' event has been received from task
		function hide():void;//not currently used - triggers the tasks own out transition
		function doStop():void;//called on the previous task once the new task dispatches ready - called right before the task is animated off stage
		function kill():void; //called once the task is off stage and right before it is nulled.
	}
	
}