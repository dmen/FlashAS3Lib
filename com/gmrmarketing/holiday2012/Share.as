package com.gmrmarketing.holiday2012
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;	
	
	
	public class Share extends EventDispatcher
	{
		public static const SHOWING:String = "SHOWING";
		public static const CANCEL:String = "CANCEL";
		public static const EMAIL:String = "EMAIL";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var preview:Bitmap;
		private var drop:DropShadowFilter;
		
		
		public function Share()
		{			
			clip = new mc_share();
			drop = new DropShadowFilter(0, 0, 0, .8, 11, 11, 1, 2, false, false, false);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(previewData:BitmapData):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			preview = new Bitmap(previewData);
			preview.x = 127;
			preview.y = 88;
			preview.filters = [drop];
			
			clip.addChild(preview);
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailClicked);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
				clip.removeChild(preview);
			}
		}
		
		
		private function showing():void
		{
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, emailClicked, false, 0, true);
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
			
			dispatchEvent(new Event(SHOWING));
		}
		
		private function cancelClicked(e:Event):void
		{
			dispatchEvent(new Event(CANCEL));
		}
		
		private function emailClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(EMAIL));
		}
	}	
	
}