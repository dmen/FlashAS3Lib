package com.gmrmarketing.comcast.laacademia2011
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class DialogController extends EventDispatcher
	{
		public static const DIALOG_CLOSED:String = "dialogClosed";
		
		private var dlg:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function DialogController($container:DisplayObjectContainer)
		{
			container = $container;			
			dlg = new dialog(); //lib clip
		}
		
		
		public function showDialog(message:String, delayTime:Number = 1.5):void
		{
			dlg.x = 657;
			dlg.y = 350;
			
			dlg.theText.htmlText = message;
			dlg.theText.y = Math.floor((192 - dlg.theText.textHeight) * .5);
			
			container.addChild(dlg);
			
			TweenLite.to(dlg, .5, { y: -500, delay:delayTime, onComplete:dClosed } );
		}
		
		
		private function dClosed():void
		{
			dispatchEvent(new Event(DIALOG_CLOSED));
		}
		
	}
	
}