/**
 * White or Red Selection Screen
 */
package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class SelectPreference extends EventDispatcher
	{
		public static const COMPLETE:String = "preferenceComplete";
		public static const HIDDEN:String = "preferenceHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var arcContainer:Sprite;
		private var arcX:int;
		private var arcY:int;
		private var angleTo:int;
		
		private var preference:String;
		
		private var tim:TimeoutHelper;
		
		
		public function SelectPreference()
		{
			tim = TimeoutHelper.getInstance();
			clip = new mcSelectPreference();
			arcContainer = new Sprite();
			clip.addChild(arcContainer);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * Returns White or Red
		 */
		public function get selection():String
		{
			return preference;
		}
		
		/**
		 * 
		 * @param	level String Novice,Seasoned,Sommelier
		 */
		public function show(level:String):void
		{
			tim.buttonClicked();
			
			preference = "";
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);	
			}
			clip.x = 0;
			clip.title.theText.text = level.toUpperCase() + " BLIND TASTE TEST"; 
			//clip.subTitle.theText.text = "To Begin the " + level + " Blind Taste Test";
			
			clip.circWhite.theText.text = "WHITE";
			clip.circRed.theText.text = "RED";
			
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			
			clip.circWhite.alpha = 0;
			clip.circWhite.alpha = 0;
			clip.circWhite.scaleX = clip.circWhite.scaleY = 0;
			clip.circRed.scaleX = clip.circRed.scaleY = 0;			
			
			clip.btnNext.alpha = 0;
			
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.circWhite, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1} );
			TweenMax.to(clip.circRed, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1.2 } );			
			
			TweenMax.to(clip.btnNext, .5, { alpha:.2, delay:1.5, onComplete:addListeners} );
		}
		
		
		private function addListeners():void
		{			
			clip.btnWhite.addEventListener(MouseEvent.MOUSE_DOWN, whiteSelected, false, 0, true);
			clip.btnRed.addEventListener(MouseEvent.MOUSE_DOWN, redSelected, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			
			clip.addEventListener(Event.ENTER_FRAME, updateArc, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.btnWhite.removeEventListener(MouseEvent.MOUSE_DOWN, whiteSelected);
			clip.btnRed.removeEventListener(MouseEvent.MOUSE_DOWN, redSelected);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			
			clip.removeEventListener(Event.ENTER_FRAME, updateArc);			
			
			//TweenMax.to(clip, 1, { x: -2736, ease:Back.easeIn, onComplete:kill } );
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}
		
		
		public function kill():void
		{		
			clip.btnWhite.removeEventListener(MouseEvent.MOUSE_DOWN, whiteSelected);
			clip.btnRed.removeEventListener(MouseEvent.MOUSE_DOWN, redSelected);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			
			clip.removeEventListener(Event.ENTER_FRAME, updateArc);		
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			arcContainer.graphics.clear();
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		
		private function whiteSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			arcX = clip.circWhite.x;
			arcY = clip.circWhite.y;			
			angleTo = 0;
			TweenMax.to(clip.btnNext, 1, { alpha:1 } );
			preference = "White";
		}
		
		
		private function redSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			arcX = clip.circRed.x;
			arcY = clip.circRed.y;
			angleTo = 0;
			TweenMax.to(clip.btnNext, 1, { alpha:1 } );
			preference = "Red";
		}
		
		
		private function doNext(e:MouseEvent):void
		{
			tim.buttonClicked();
			if(preference != ""){
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
			if(preference != ""){
				arcContainer.graphics.clear();				
				
				Utility.drawArc(arcContainer.graphics, arcX, arcY, 285, 0, angleTo, 13, 0xbc9942, 1);				
				
				angleTo += 10;
				if (angleTo > 360) {
					angleTo = 360;
				}
			}
		}
		
	}
	
}