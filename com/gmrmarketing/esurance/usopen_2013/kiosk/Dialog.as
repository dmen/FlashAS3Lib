package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import flash.display.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	
	public class Dialog
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var rotValue:int;
		
		
		public function Dialog()
		{
			clip = new mcDialog();
			rotValue = 3;			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * displays a message in the dialog
		 * @param	message
		 */
		public function show(message:String):void
		{
			TweenMax.killTweensOf(clip);
			TweenMax.killDelayedCallsTo(hide);
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = message;
			clip.theText.y = Math.round((213 - clip.theText.textHeight) * .5);//center text vertically
			clip.ballText.text = "";
			clip.ball.visible = false;
			
			clip.x = 678;
			clip.y = 500;
			clip.alpha = 0;			
			
			TweenMax.to(clip, 1, { y:380, alpha:1, ease:Back.easeOut } );
			TweenMax.delayedCall(3, hide);
			
			clip.removeEventListener(Event.ENTER_FRAME, updateBall);
		}
		
		
		/**
		 * displays a message with a spinning tennis ball to the left of it
		 * @param	message
		 */
		public function progress(message:String):void
		{
			TweenMax.killTweensOf(clip);
			TweenMax.killDelayedCallsTo(hide);
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
				
			clip.ballText.text = message;
			clip.theText.text = "";
			clip.ball.visible = true;
			
			rotValue *= -1;
			
			clip.x = 678;				
			clip.y = 500;
			clip.alpha = 0;
			TweenMax.to(clip, 1, { y:380, alpha:1, ease:Back.easeOut } );								
			
			clip.addEventListener(Event.ENTER_FRAME, updateBall, false, 0, true);
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function updateBall(e:Event):void
		{
			clip.ball.rotation += rotValue;
		}
		
	}
	
}