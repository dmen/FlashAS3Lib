/**
 * Home screen - Novice, Seasoned, Sommelier selection
 */
package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;	
	
	public class Home extends EventDispatcher
	{
		public static const COMPLETE:String = "homeComplete";
		public static const HIDDEN:String = "homeHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var theLevel:String; //novice,seasoned,sommelier		
		
		private var angleTo:int = 0;
		
		private var arcContainer:Sprite;
		private var arcX:int;
		private var arcY:int;
		
		
		public function Home()
		{
			clip = new mcHome();
			arcContainer = new Sprite();
			clip.addChild(arcContainer);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns the users selected level - Novice, Seasoned, Sommelier
		 */
		public function get selection():String
		{
			return theLevel;
		}
		
		
		public function show()
		{
			theLevel = "";//not selected
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.x = 0;
			
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			
			clip.circNovice.theText.text = "";
			clip.circSeasoned.theText.text = "";
			clip.circAdvanced.theText.text = "";
			
			clip.circNovice.alpha = 0;
			clip.circSeasoned.alpha = 0;
			clip.circAdvanced.alpha = 0;
			clip.circNovice.scaleX = clip.circNovice.scaleY = 0;
			clip.circSeasoned.scaleX = clip.circSeasoned.scaleY = 0;
			clip.circAdvanced.scaleX = clip.circAdvanced.scaleY = 0;
			
			clip.grapesNovice.alpha = 0;
			clip.grapesSeasoned.alpha = 0;
			clip.grapesAdvanced.alpha = 0;
			
			clip.grapesNovice.scaleX = clip.grapesNovice.scaleY = .5;
			clip.grapesSeasoned.scaleX = clip.grapesSeasoned.scaleY = .5;
			clip.grapesAdvanced.scaleX = clip.grapesAdvanced.scaleY = .5;
			
			clip.labelNovice.alpha = 0;
			clip.labelSeasoned.alpha = 0;
			clip.labelAdvanced.alpha = 0;
			
			clip.btnNext.alpha = 0;
			
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.circNovice, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.circSeasoned, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1.2 } );
			TweenMax.to(clip.circAdvanced, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1.4 } );
			
			TweenMax.to(clip.grapesNovice, .4, { alpha:.9, scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.2 } );
			TweenMax.to(clip.grapesSeasoned, .4, { alpha:.9, scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.4 } );
			TweenMax.to(clip.grapesAdvanced, .4, { alpha:.9, scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.6 } );
			
			TweenMax.to(clip.labelNovice, .5, { alpha:1, delay:1.4 } );
			TweenMax.to(clip.labelSeasoned, .5, { alpha:1, delay:1.6 } );
			TweenMax.to(clip.labelAdvanced, .5, { alpha:1, delay:1.8 } );
			
			TweenMax.to(clip.btnNext, .5, { alpha:.2, delay:1.8, onComplete:addListeners } );
		}
		
		
		private function addListeners():void
		{			
			clip.btnNovice.addEventListener(MouseEvent.MOUSE_DOWN, noviceSelected, false, 0, true);
			clip.btnSeasoned.addEventListener(MouseEvent.MOUSE_DOWN, seasonedSelected, false, 0, true);
			clip.btnAdvanced.addEventListener(MouseEvent.MOUSE_DOWN, advancedSelected, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			
			clip.addEventListener(Event.ENTER_FRAME, updateArc, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.btnNovice.removeEventListener(MouseEvent.MOUSE_DOWN, noviceSelected);
			clip.btnSeasoned.removeEventListener(MouseEvent.MOUSE_DOWN, seasonedSelected);
			clip.btnAdvanced.removeEventListener(MouseEvent.MOUSE_DOWN, advancedSelected);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			
			clip.removeEventListener(Event.ENTER_FRAME, updateArc);
			
			//TweenMax.to(clip, 1, { x: -2736, ease:Back.easeIn, onComplete:kill } );
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			arcContainer.graphics.clear();
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function noviceSelected(e:MouseEvent):void
		{
			angleTo = 0;
			TweenMax.to(clip.btnNext, 1, { alpha:1 } );
			arcX = clip.circNovice.x;
			arcY = clip.circNovice.y;
			theLevel = "Novice";
		}
		
		
		private function seasonedSelected(e:MouseEvent):void
		{	
			angleTo = 0;
			TweenMax.to(clip.btnNext, 1, { alpha:1 } );
			arcX = clip.circSeasoned.x;
			arcY = clip.circSeasoned.y;
			theLevel = "Seasoned";
		}
		
		
		private function advancedSelected(e:MouseEvent):void
		{
			angleTo = 0;
			TweenMax.to(clip.btnNext, 1, { alpha:1 } );
			arcX = clip.circAdvanced.x;
			arcY = clip.circAdvanced.y;
			theLevel = "Sommelier";
		}
		
		
		private function doNext(e:MouseEvent):void
		{
			if (theLevel != "") {
				dispatchEvent(new Event(COMPLETE));
			}
		}
			
		
		/**
		 * called on EnterFrame once a selection is made
		 * draws an arc between startAngle and endAngle
		 * @param	e
		 */
		private function updateArc(e:Event):void
		{
			if(theLevel != ""){
				arcContainer.graphics.clear();				
				
				Utility.drawArc(arcContainer.graphics, arcX, arcY, 285, 0, angleTo, 13, 0xbc9942, 1);				
				
				angleTo += 10 ;
				if (angleTo > 360) {
					angleTo = 360;
				}
			}
		}
	}
	
}