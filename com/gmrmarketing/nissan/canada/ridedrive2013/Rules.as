package com.gmrmarketing.nissan.canada.ridedrive2013
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class Rules
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var lang:String;
		
		public function Rules()
		{
			clip = new mcRules();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function setLanguage($lang:String):void
		{
			lang = $lang;
			
			if (lang == "en") {
				clip.en.visible = 1;
				clip.fr.visible = 0;
			}else {
				clip.en.visible = 0;
				clip.fr.visible = 1;
			}
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.x = 0;
			clip.y = 1011;
			clip.btnTab.addEventListener(MouseEvent.MOUSE_DOWN, tabClicked, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeClicked, false, 0, true);
		}
		
		
		private function tabClicked(e:MouseEvent):void
		{
			if (clip.y == 1011) {
				//clip in down position
				if(lang == "en"){
					TweenMax.to(clip, .5, { y:420 } );
				}else {
					TweenMax.to(clip, .5, { y:190 } );
				}
			}else {
				TweenMax.to(clip, .5, { y:1011 } );
			}
		}
		
		
		private function closeClicked(e:MouseEvent):void
		{
			TweenMax.to(clip, .5, { y:1011 } );
		}
	}
	
}