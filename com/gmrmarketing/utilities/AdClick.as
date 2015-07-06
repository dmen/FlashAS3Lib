package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	public class AdClick extends Sprite
	{
		private var clickURL:String;
		
		public function AdClick(m:MovieClip)
		{
			clickURL = m.loaderInfo.parameters.clickTAG;			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}	
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			graphics.beginFill(0x00ff00, 0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			buttonMode = true;			
			addEventListener(MouseEvent.CLICK, clicked, false, 0, true);
		}		
		private function clicked(e:MouseEvent):void
		{			
			if (clickURL) {
				navigateToURL(new URLRequest(clickURL), '_blank');				
			}
		}
	}	
}