package com.gmrmarketing.telus.karaoke
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.SliderV;
	
	public class Privacy extends EventDispatcher
	{
		public static const CLOSE_PRIVACY:String = "closePrivacy";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var slider:SliderV;
		private var textRatio:Number;
		private var textInitialY:int;
		private var sliderInitialY:int;
		
		public function Privacy()
		{
			clip = new mcPrivacy();
			slider = new SliderV(clip.slider, clip.track);
			
			textRatio = clip.theText.height / (clip.track.height + 120);
			textInitialY = clip.theText.y;
			sliderInitialY = clip.slider.y;
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;			
		}
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, closePrivacy, false, 0, true);
			clip.alpha = 0;
			
			clip.slider.y = sliderInitialY;
			clip.theText.y = textInitialY;
			slider.addEventListener(SliderV.DRAGGING, updateTextPosition, false, 0, true);
			
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		public function hide():void
		{
			slider.removeEventListener(SliderV.DRAGGING, updateTextPosition);
			TweenMax.to(clip, 1, { alpha:0, onComplete:killClip } );
		}
		
		private function closePrivacy(e:MouseEvent):void
		{
			clip.btn.removeEventListener(MouseEvent.MOUSE_DOWN, closePrivacy);
			dispatchEvent(new Event(CLOSE_PRIVACY));
		}
		
		private function killClip():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function updateTextPosition(e:Event):void
		{
			clip.theText.y = textInitialY - ((clip.slider.y - sliderInitialY) * textRatio);
		}
	}
	
}