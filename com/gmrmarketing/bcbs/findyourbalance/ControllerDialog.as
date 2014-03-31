/**
 * messaging dialog - for validation etc.
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class ControllerDialog
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function ControllerDialog()
		{
			clip = new mcDialog();
			clip.x = 357;
			clip.y = 300;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(mess:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.theText.text = mess;
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:remove } );
		}
		
		
		private function remove():void
		{
			TweenMax.to(clip, 1, { alpha:0, delay:2, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
	}
	
}