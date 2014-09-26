package com.gmrmarketing.sap.metlife
{	
	public interface ISchedulerMethods
	{
		function init(initValue:String = ""):void;//first method called - receives any data from the initData attribute in the config.xml file
		function isReady():Boolean; //returns true if the task has successfuly retrieved data from its web service
		function show():void;//called right before the task is placed on screen	
		function cleanup():void; //stops any listeners - refresh service data if needed
	}	
}