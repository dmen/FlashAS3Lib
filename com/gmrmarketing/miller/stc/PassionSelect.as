package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class PassionSelect extends EventDispatcher
	{
		public static const COMPLETE:String = "complete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var myPassion:String;//user selection - sports,music
		
		
		public function PassionSelect()
		{
			clip = new mcPassion();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.cap.scaleX = clip.cap.scaleY = 0;
			clip.arrows.scaleX = 0;
			clip.arrows.alpha = 1;
			clip.sports.x = -1050;
			clip.music.x = 2160;
			
			clip.capText.gotoAndStop(1);//tap for a chance to win
			clip.titleText.visible = false;
			
			TweenMax.to(clip.cap, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.arrows, .5, { scaleX:1, ease:Back.easeOut, delay:.4 } );
			
			TweenMax.to(clip.sports, .5, { x:40, ease:Back.easeOut, delay:.75 } );
			TweenMax.to(clip.music, .5, { x:1082, ease:Back.easeOut, delay:.75 } );
			
			clip.sports.addEventListener(MouseEvent.MOUSE_DOWN, sportsSelect);
			clip.music.addEventListener(MouseEvent.MOUSE_DOWN, musicSelect);
			
			myContainer.addEventListener(Event.ENTER_FRAME, rotateCap);
		}
		
		
		public function hide():void
		{
			myContainer.removeEventListener(Event.ENTER_FRAME, rotateCap);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		public function get passion():String
		{
			return myPassion;
		}
		
		private function rotateCap(e:Event):void
		{
			clip.cap.rotation += .3;
		}
		
		
		private function sportsSelect(e:MouseEvent):void
		{
			clip.sports.removeEventListener(MouseEvent.MOUSE_DOWN, sportsSelect);
			clip.music.removeEventListener(MouseEvent.MOUSE_DOWN, musicSelect);
			
			clip.titleText.theText.text = "YOU HAVE GREAT TASTE IN SPORTS";
			myPassion = "sports";
			
			TweenMax.to(clip.sports, .5, { x:-1050, ease:Back.easeIn } );
			TweenMax.to(clip.music, .5, { x:2160, ease:Back.easeIn, onComplete:showTitle } );
			TweenMax.to(clip.arrows, .5, { alpha:0 } );
		}
		
		
		private function musicSelect(e:MouseEvent):void
		{
			clip.sports.removeEventListener(MouseEvent.MOUSE_DOWN, sportsSelect);
			clip.music.removeEventListener(MouseEvent.MOUSE_DOWN, musicSelect);
			
			clip.titleText.theText.text = "YOU HAVE GREAT TASTE IN MUSIC";
			myPassion = "music";
			
			TweenMax.to(clip.sports, .5, { x:-1050, ease:Back.easeIn } );
			TweenMax.to(clip.music, .5, { x:2160, ease:Back.easeIn, onComplete:showTitle } );
			TweenMax.to(clip.arrows, .5, { alpha:0 } );
		}
		
		
		private function showTitle():void
		{
			clip.capText.gotoAndStop(2);//take the challenge
			clip.titleText.visible = true;
			clip.titleText.scaleX = 0;
			TweenMax.to(clip.titleText, .5, { scaleX:1, ease:Back.easeOut } );
			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, capClicked);
		}
		
		
		private function capClicked(e:MouseEvent):void
		{
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, capClicked);
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}