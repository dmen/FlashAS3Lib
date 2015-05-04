package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const FINISHED_HIDING:String = "finishedHiding";//dispatched when the hide sequence is done
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var pics:Array;
		private var picOrder:Array;
		private var picIndex:int;
		private var picContainer:Sprite;
		private var finished:Boolean;
		
		public function Intro()
		{
			picContainer = new Sprite();
			picContainer.x = 0;
			picContainer.y = 249;
			
			clip = new intro();//lib
			picOrder = [0, 2, 1, 3, 4, 6, 5, 7, 8, 10, 9, 11];
			picIndex = 0;
			
			pics = [];
			var a:Bitmap;
			
			a = new Bitmap(new p1());
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p2());
			a.x = 490;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p3());
			a.x = 980;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p4());
			a.x = 1470;
			a.alpha = 0;
			pics.push(a);
			
			//
			a = new Bitmap(new p5());
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p6());
			a.x = 490;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p7());
			a.x = 980;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p8());
			a.x = 1470;
			a.alpha = 0;
			pics.push(a);
			
			//
			a = new Bitmap(new p9());			
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p10());
			a.x = 490;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p11());
			a.x = 980;
			a.alpha = 0;
			pics.push(a);
			
			a = new Bitmap(new p12());
			a.x = 1470;
			a.alpha = 0;
			pics.push(a);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * sets finished to true
		 * addPic() will call hideIt()
		 */
		public function hide():void
		{
			finished = true;			
		}
		
		
		public function show():void
		{
			finished = false;
			picIndex = 0;
			
			while (picContainer.numChildren) {
				picContainer.removeChildAt(0);
			}
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if (!clip.contains(picContainer)) {
				clip.addChild(picContainer);
			}
			
			clip.legal.alpha = 0;
			clip.bgLines.alpha = 0; //red/gray line at top/bottom
			clip.bgLines.scaleY = .1;
			clip.logo.alpha = 0;//witw logo @ upper right
			clip.visit.alpha = 0;//text below images - visit our kiosks...
			clip.border.alpha = 0;//hLines above and below the images
			clip.border.scaleY = .1;
			clip.visit.y = 700;//lands at 760
			
			clip.header.x = 1920;
			clip.header.alpha = 1;
			
			clip.discover.alpha = 1;
			clip.give.alpha = 1;
			clip.optin.alpha = 1;
			clip.discover.scaleX = clip.discover.scaleY = 1;
			clip.give.scaleX = clip.give.scaleY = 1;
			clip.optin.scaleX = clip.optin.scaleY = 1;
			clip.discover.x = 2120;			
			clip.give.x = 2120;
			clip.optin.x = 2120;
			
			clip.discover.icon.scaleX = clip.discover.icon.scaleY = .1;
			clip.discover.icon.alpha = 0;
			clip.give.icon.scaleX = clip.give.icon.scaleY = .1;
			clip.give.icon.alpha = 0;
			clip.optin.icon.scaleX = clip.optin.icon.scaleY = .1;
			clip.optin.icon.alpha = 0;
			
			TweenMax.to(clip.header, .6, { x:57, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.logo, 1, { alpha:1, delay:1.2 } );
			
			TweenMax.to(clip.visit, .75, { y:760, alpha:1, delay:1.8, ease:Back.easeOut } );
			
			TweenMax.to(clip.discover, .5, { x:302, delay:2, ease:Back.easeOut } );
			TweenMax.to(clip.discover.icon, .4, { scaleX:1, scaleY:1, alpha:1, delay:2.4, ease:Bounce.easeOut } );
			
			TweenMax.to(clip.give, .4, { x:915, delay:2.6, ease:Back.easeOut } );
			TweenMax.to(clip.give.icon, .4, { scaleX:1, scaleY:1, alpha:1, delay:2.9, ease:Bounce.easeOut } );
			
			TweenMax.to(clip.optin, .3, { x:1453, delay:3.2, ease:Back.easeOut } );			
			TweenMax.to(clip.optin.icon, .4, { scaleX:1, scaleY:1, alpha:1, delay:3.5, ease:Bounce.easeOut, onComplete:addPic } );
			
			TweenMax.to(clip.border, 1, { alpha:1, scaleY:1, delay:3.5, ease:Back.easeOut } );
			TweenMax.to(clip.bgLines, 1, { alpha:1, scaleY:1, delay:3.7, ease:Back.easeOut } );
			TweenMax.to(clip.legal, 1, { alpha:1, delay:3.8 } );
		}
		
		
		private function addPic():void
		{
			var p:Bitmap;
			
			if(!finished){
				
				if (picIndex > 3) {
					//in the second group of images					
					p =  pics[picOrder[picIndex - 4]];
					if (picContainer.contains(p)) {
						picContainer.removeChild(p);
					}
				}else {
					//picIndex < 3 - first set
					p = pics[picOrder[picIndex + 8]];
					if (picContainer.contains(p)) {
						picContainer.removeChild(p);
					}
				}
				
				p = pics[picOrder[picIndex]];
				
				if (!picContainer.contains(p)) {
					picContainer.addChild(p);
				}
				
				picIndex++;
				if (picIndex >= pics.length) {
					picIndex = 0;
				}
				
				p.x += 50;
				p.alpha = 0;
				if (picIndex == 4 || picIndex == 8 || picIndex == 0) {
					//just finished a full set
					TweenMax.to(p, 1, { alpha:1, x:"-50", onComplete:setWait } );
				}else {
					TweenMax.to(p, 1, { alpha:1, x:"-50", onComplete:addPic } );
				}
				
			}else {
				
				//finished - hide() was called
				hideIt();
				
			}
		}
		
		
		private function setWait():void
		{
			TweenMax.delayedCall(5, addPic);
		}
		
		
		/**
		 * called from addPic() after hide() has been called and any remaining Tween has completed
		 */
		private function hideIt():void
		{
			//remove images
			var n:int = picContainer.numChildren;
			for (var i:int = 0; i < n; i++) {
				TweenMax.to(Bitmap(picContainer.getChildAt(i)), 1, { alpha:0 } );
			}
			
			//image and red/gray lines
			TweenMax.to(clip.border, 1, { alpha:0, scaleY:.1, delay:1, ease:Back.easeOut } );
			TweenMax.to(clip.bgLines, 1, { alpha:0, scaleY:.1, delay:1.1, ease:Back.easeOut } );
			
			TweenMax.to(clip.visit, .5, { y:700, alpha:0, delay:1.5 } );
			
			TweenMax.to(clip.discover, .5, { alpha:0, scaleX:.2, scaleY:.2, delay:2 } );
			TweenMax.to(clip.give, .5, { alpha:0, scaleX:.2, scaleY:.2, delay:2.1 } );
			TweenMax.to(clip.optin, .5, { alpha:0, scaleX:.2, scaleY:.2, delay:2.2 } );
			
			TweenMax.to(clip.header, .5, { alpha:0, delay:2.5 } );
			TweenMax.to(clip.logo, .5, { alpha:0, delay:2.6 } );
			TweenMax.to(clip.legal, .5, { alpha:0, delay:2.6, onComplete:complete } );
		}
		
		
		private function complete():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			dispatchEvent(new Event(FINISHED_HIDING));
		}
		
	}
	
}