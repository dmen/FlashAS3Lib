/**
 * Animated logo
 */
package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const FINISHED:String = "finished";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			
			//mask the wave with the Challenge text
			clip.challenge.wave.cacheAsBitmap = true;
			clip.challenge.theMask.cacheAsBitmap = true;
			clip.challenge.wave.mask = clip.challenge.theMask;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * fades out and then removes itself from the container
		 */
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		public function quickShow():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.alpha = 1;
		}
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.alpha = 1;
			clip.question.blendMode = BlendMode.NORMAL;
			clip.question.scaleX = clip.question.scaleY = 0;
			
			clip.lWheat.gotoAndStop(1);
			clip.rWheat.gotoAndStop(1);
			
			clip.challenge.scaleX = .1
			clip.challenge.scaleY = .2
			clip.challenge.alpha = 0;
			
			clip.my.scaleX = clip.my.scaleY = .1;
			clip.secret.scaleX = clip.secret.scaleY = .1;
			clip.taste.scaleX = clip.taste.scaleY = .1;
			clip.drips.alpha = 0;
			clip.tm.alpha = 0;
			
			clip.beerBottom.scaleX = clip.beerBottom.scaleY = .1;
			clip.beerBottom.alpha = 0;
			clip.beerFill.gotoAndStop(1);//masked
			clip.topFoam.gotoAndStop(1);//masked			
			
			TweenMax.to(clip.question, .75, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			
			TweenMax.to(clip.my, .4, { scaleX:1, scaleY:1, delay:.1 } );
			TweenMax.to(clip.secret, .4, { scaleX:1, scaleY:1, delay:.2 } );
			TweenMax.to(clip.taste, .4, { scaleX:1, scaleY:1, delay:.3 } );
			TweenMax.to(clip.drips, .5, {alpha:1, delay:.5 } );			
			
			clip.pint.y = 1500;
			clip.pint.alpha = 0;
			TweenMax.to(clip.pint, 0, { blurFilter: { blurX:8, blurY:60 }} );
			TweenMax.to(clip.pint, .4, { delay:.6, y:596, alpha:1, onComplete:questionBlend } );
			TweenMax.to(clip.pint, .2, { blurFilter: { blurX:0, blurY:0 }, delay:.9 } );
			
			TweenMax.to(clip.challenge, 0, { blurFilter: { blurX:20, blurY:8 }} );
			TweenMax.to(clip.challenge, 1, { scaleX:1, scaleY:1, alpha:1, delay:1, ease:Back.easeOut, onComplete:startWave } );
			TweenMax.to(clip.challenge, .5, { blurFilter: { blurX:0, blurY:0 }, delay:1.8 } );
			
			TweenMax.to(clip.beerBottom, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:1.4 } );
			TweenMax.delayedCall(1.9, startFill);
		}
		
		
		private function questionBlend():void
		{
			clip.question.blendMode = BlendMode.DARKEN;
			clip.lWheat.gotoAndPlay(2);
			clip.rWheat.gotoAndPlay(2);
			TweenMax.to(clip.tm, 2, { alpha:1, delay:1 } );
		}
		
		
		public function startWave():void
		{
			clip.addEventListener(Event.ENTER_FRAME, updateWave);
		}
		
		
		public function stopWave():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateWave);
		}
		
		
		private function startFill():void
		{
			clip.beerFill.gotoAndPlay(2);
			TweenMax.delayedCall(.8, startFoam);
			TweenMax.delayedCall(1.5, finished);
		}
		
		
		private function startFoam():void
		{
			clip.topFoam.gotoAndPlay(2);
		}
		
		
		private function finished():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		private function updateWave(e:Event):void
		{
			clip.challenge.wave.x += 1;
			if (clip.challenge.wave.x >= -448) {
				clip.challenge.wave.x = -1341;//-1342
			}
		}
		
	}
	
}