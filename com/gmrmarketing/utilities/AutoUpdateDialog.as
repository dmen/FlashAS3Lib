package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;

	public class AutoUpdateDialog extends MovieClip
	{
		public function AutoUpdateDialog()
		{
			addEventListener(Event.ADDED_TO_STAGE, drawDialog);
		}
		
		
		private function drawDialog(e:Event):void
		{
			trace(stage.stageWidth, stage.stageHeight);
		}
	}
	
}