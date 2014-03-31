/**
 * Choose your fight card
 */

package com.gmrmarketing.ufc.fightcard
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenLite;
	
	
	public class TemplateChoices extends EventDispatcher
	{
		public static const TEMPLATE_CHOICES_ADDED:String = "templateChoicesAdded";
		public static const TEMPLATE_PICKED:String = "templateChoiceMade";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var theTemplate:int;
		
		
		
		public function TemplateChoices()
		{
			clip = new template_chooser(); //library clip
		}
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			clip.alpha = 0;
			clip.select.alpha = 0; //top text - select your card
			container.addChild(clip);
			clip.t1.addEventListener(MouseEvent.CLICK, chooseT1, false, 0, true);
			clip.t2.addEventListener(MouseEvent.CLICK, chooseT2, false, 0, true);
			clip.t3.addEventListener(MouseEvent.CLICK, chooseT3, false, 0, true);
			clip.t4.addEventListener(MouseEvent.CLICK, chooseT4, false, 0, true);
			clip.t1.buttonMode = true;
			clip.t2.buttonMode = true;
			clip.t3.buttonMode = true;
			clip.t4.buttonMode = true;
			
			clip.t1.addEventListener(MouseEvent.MOUSE_OVER, glow, false, 0, true);
			clip.t1.addEventListener(MouseEvent.MOUSE_OUT, noGlow, false, 0, true);
			clip.t2.addEventListener(MouseEvent.MOUSE_OVER, glow, false, 0, true);
			clip.t2.addEventListener(MouseEvent.MOUSE_OUT, noGlow, false, 0, true);
			clip.t3.addEventListener(MouseEvent.MOUSE_OVER, glow, false, 0, true);
			clip.t3.addEventListener(MouseEvent.MOUSE_OUT, noGlow, false, 0, true);
			clip.t4.addEventListener(MouseEvent.MOUSE_OVER, glow, false, 0, true);
			clip.t4.addEventListener(MouseEvent.MOUSE_OUT, noGlow, false, 0, true);
			
			TweenLite.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		public function hide():void
		{
			container.removeChild(clip);
			clip.t1.removeEventListener(MouseEvent.CLICK, chooseT1);
			clip.t2.removeEventListener(MouseEvent.CLICK, chooseT2);
			clip.t1.removeEventListener(MouseEvent.MOUSE_OVER, glow);
			clip.t1.removeEventListener(MouseEvent.MOUSE_OUT, noGlow);
			clip.t2.removeEventListener(MouseEvent.MOUSE_OVER, glow);
			clip.t2.removeEventListener(MouseEvent.MOUSE_OUT, noGlow);
			clip.t3.removeEventListener(MouseEvent.MOUSE_OVER, glow);
			clip.t3.removeEventListener(MouseEvent.MOUSE_OUT, noGlow);
			clip.t4.removeEventListener(MouseEvent.MOUSE_OVER, glow);
			clip.t4.removeEventListener(MouseEvent.MOUSE_OUT, noGlow);
			TweenLite.killTweensOf(clip.cardGlow);
		}
		
		public function getTemplate():int
		{
			return theTemplate;
		}
		
		private function clipAdded():void
		{
			TweenLite.to(clip.select, 1, { alpha:1 } );
			dispatchEvent(new Event(TEMPLATE_CHOICES_ADDED));
		}
		
		private function chooseT1(e:MouseEvent):void
		{
			theTemplate = 1;
			dispatchEvent(new Event(TEMPLATE_PICKED));
		}
		
		private function chooseT2(e:MouseEvent):void
		{
			theTemplate = 2;
			dispatchEvent(new Event(TEMPLATE_PICKED));
		}
		
		private function chooseT3(e:MouseEvent):void
		{
			theTemplate = 3;
			dispatchEvent(new Event(TEMPLATE_PICKED));
		}
		
		private function chooseT4(e:MouseEvent):void
		{
			theTemplate = 4;
			dispatchEvent(new Event(TEMPLATE_PICKED));
		}
		
		private function glow(e:MouseEvent):void
		{			
			clip.highlight.x = MovieClip(e.currentTarget).x;
			clip.highlight.y = MovieClip(e.currentTarget).y;
			clip.highlight.gotoAndPlay(2);
		}
		
		private function noGlow(e:MouseEvent):void
		{
			clip.highlight.gotoAndStop(1);
		}
		
	}
	
}