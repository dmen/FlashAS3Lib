/**
 * Instantiated by ModelDetail.as
 */

package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.Loader;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.nissan.next.StaticData;
	
	
	
	public class ThreeSixty extends EventDispatcher
	{
		public static const THREESIXTY_READY:String = "threeSixty_ready";
		
		private var container:DisplayObjectContainer;
		private var loader:Loader;
		private var bg:MovieClip;
	
		private var lastMousePos:int;
		private var mouseDelta:int;	
		
		private var content:MovieClip;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function ThreeSixty()
		{
			timeoutHelper = TimeoutHelper.getInstance();
			
			loader = new Loader();
			bg = new modalBG(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer, whichSWF:String):void
		{
			container = $container;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded, false, 0, true);			
			loader.load(new URLRequest(StaticData.getAssetPath() + whichSWF));
		}
		
		public function hide(e:MouseEvent = null):void
		{		
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, gestureStart);
			
			TweenMax.killTweensOf(bg);
			TweenMax.killTweensOf(content);
			
			TweenMax.to(bg, .5, { alpha:0 } );
			TweenMax.to(content, 1, { y:767, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		private function swfLoaded(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfLoaded);
			
			container.addChild(bg);
			bg.alpha = 0;			
			TweenMax.to(bg, .5, { alpha:.90 } );
			
			content = MovieClip(loader.content);
			container.addChild(content);			
			
			content.stop();
			
			//all 360's are 800x500
			content.x = 315;
			content.y = 768;
			
			TweenMax.to(content, 1, { y:140, ease:Back.easeOut, onComplete:ready } );
		}
		
		private function ready():void
		{
			dispatchEvent(new Event(THREESIXTY_READY));	
		}
		
		
		public function listen():void
		{			
			container.stage.addEventListener(MouseEvent.MOUSE_DOWN, gestureStart, false, 0, true);
		}
		
		
		private function gestureStart(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();			
			
			lastMousePos = container.stage.mouseX;
			container.stage.addEventListener(Event.ENTER_FRAME, gestureMid, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, gestureEnd, false, 0, true);
		}
		
		
		/**
		 * Called on ENTER_FRAME while swiping
		 * @param	e
		 */
		private function gestureMid(e:Event):void
		{	
			mouseDelta = container.stage.mouseX - lastMousePos;
			lastMousePos =  container.stage.mouseX;
			
			if (mouseDelta > 12) {
				if (content.currentFrame == content.totalFrames) {
					content.gotoAndStop(1);
				}else{
					content.nextFrame();
				}
			}else if (mouseDelta < -12) {
				if (content.currentFrame == 1) {
					content.gotoAndStop(content.totalFrames);
				}else{
					content.prevFrame();
				}
			}
		}
		
		
		private function gestureEnd(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			container.stage.removeEventListener(Event.ENTER_FRAME, gestureMid);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, gestureEnd);
			TweenMax.to(content, Math.abs(mouseDelta / 45), { frame:Math.round(content.currentFrame + mouseDelta / 2)} );
		}
		
		
		
		private function kill():void
		{
			if(container.contains(bg)){
				container.removeChild(bg);
			}
			if(container.contains(content)){
				container.removeChild(content);	
			}
			loader.unload();
		}
		
	}
	
}