package com.gmrmarketing.sap.metlife
{	
	public interface ISchedulerMethods
	{
		//receives any data from the initData attribute in the config.xml file - called on all tasks to preload data from the web services. 
		function init(initValue:String = ""):void;	
		function getFlareList():Array; //returns an array of lens flares to be displayed for the task
		function isReady():Boolean; //returns true if the task has successfuly retrieved data from its web service
		function show():void;//called right before the task is placed on screen	
		function cleanup():void; //called when the task is removed from stage -stops any listeners - refresh service data if needed
	}	
}