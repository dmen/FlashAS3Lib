package com.gmrmarketing.sap.superbowl.gda
{	
	public interface IModuleMethods
	{		
		function init(initValue:String = ""):void; //called once on all tasks. Passes any config data from xml and preloads from its web service
		function isReady():Boolean; //returns true if the task has successfuly retrieved data from its web service
		function show():void;//called once the task is placed on stage by the player
		function cleanup():void; //called when the task is removed from stage -stops any listeners - refreshes service data if needed
	}	
}