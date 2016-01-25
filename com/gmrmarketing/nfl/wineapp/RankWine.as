package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import flash.geom.Point;
	
	
	public class RankWine extends EventDispatcher
	{
		public static const COMPLETE:String = "rankComplete";
		public static const HIDDEN:String = "rankHidden";
		
		private const circleScale:Number = .728973388671875;
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var clipDragging:MovieClip;
		private var offsetX:int;
		private var offsetY:int;
		private var originalLoc1:Point;
		private var originalLoc2:Point;
		private var originalLoc3:Point;
		private var whichClip:int; //1,2,3 - circle being dragged
		private var buckets:Array;//tracks which circle (1,2,3) is in which bucket
		
		private var rankTop:int = 1276;//y position for the rank buckets at the bottom
		
		
		public function RankWine()
		{
			clip = new mcRankWine();
			
			originalLoc1 = new Point(clip.circ1.x, clip.circ1.y);
			originalLoc2 = new Point(clip.circ2.x, clip.circ2.y);
			originalLoc3 = new Point(clip.circ3.x, clip.circ3.y);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns the ranking in a 3 element array
		 * ranking is 1,2,3 - in order of their favorite
		 * 1 is favorite, 3 least favorite
		 * so if users choices were #3 favorite, #2 liked it, #1 loved it
		 * this array would be [2,3,1]
		 */
		public function get selection():Array
		{
			var rank:Array = [0, 0, 0];
			
			rank[0] = 3 - buckets.indexOf(1);
			rank[1] = 3 - buckets.indexOf(2);
			rank[2] = 3 - buckets.indexOf(3);
			
			return rank;
			
		}
		
		
		public function show():void
		{
			clip.x = 0;
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			
			buckets = [0, 0, 0];	
			
			clip.circ1.x = originalLoc1.x;
			clip.circ1.y = originalLoc1.y;
			
			clip.circ2.x = originalLoc2.x;
			clip.circ2.y = originalLoc2.y;
			
			clip.circ3.x = originalLoc3.x;
			clip.circ3.y = originalLoc3.y;
			
			clip.circ1.theText.text = "1";
			clip.circ2.theText.text = "2";
			clip.circ3.theText.text = "3";
			
			clip.rank1.theText.text = "Like It";
			clip.rank2.theText.text = "Love It";
			clip.rank3.theText.text = "Favorite";
			
			clip.rank1.star1.visible = false;
			clip.rank1.star3.visible = false;
			
			clip.rank2.star1.visible = false;
			clip.rank2.star2.x = 429;
			clip.rank2.star3.x = 479;
			
			clip.circ1.scaleX = clip.circ1.scaleY = 0;
			clip.circ2.scaleX = clip.circ2.scaleY = 0;
			clip.circ3.scaleX = clip.circ3.scaleY = 0;
			
			clip.rank1.y = 1824;//off bottom of screen
			clip.rank2.y = 1824;
			clip.rank3.y = 1824;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.circ1, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1} );
			TweenMax.to(clip.circ2, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1.2} );
			TweenMax.to(clip.circ3, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1.4} );
			
			TweenMax.to(clip.rank1, .5, { y:rankTop, ease:Back.easeOut, delay:1.6 } );
			TweenMax.to(clip.rank2, .5, { y:rankTop, ease:Back.easeOut, delay:1.8 } );
			TweenMax.to(clip.rank3, .5, { y:rankTop, ease:Back.easeOut, delay:2, onComplete:addListeners } );
		}
			
			
		private function addListeners():void
		{
			clip.circ1.addEventListener(MouseEvent.MOUSE_DOWN, startDragging1, false, 0, true);
			clip.circ2.addEventListener(MouseEvent.MOUSE_DOWN, startDragging2, false, 0, true);
			clip.circ3.addEventListener(MouseEvent.MOUSE_DOWN, startDragging3, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging3);
			
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			myContainer.removeEventListener(Event.ENTER_FRAME, updateDragging);
			
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function startDragging1(e:MouseEvent):void
		{
			clipDragging = MovieClip(e.currentTarget);
			whichClip = 1;
			doDrag();
		}
		
		
		private function startDragging2(e:MouseEvent):void
		{
			clipDragging = MovieClip(e.currentTarget);
			whichClip = 2;
			doDrag();
		}
		
		
		private function startDragging3(e:MouseEvent):void
		{
			clipDragging = MovieClip(e.currentTarget);
			whichClip = 3;
			doDrag();
		}
		
		
		private function doDrag():void
		{
			if (clipDragging.scaleX < .7) {
				TweenMax.to(clipDragging, .3, { scaleX:.728973388671875, scaleY:.728973388671875 } );
			}
			offsetX = myContainer.mouseX - clipDragging.x;
			offsetY = myContainer.mouseY - clipDragging.y;
			myContainer.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			myContainer.addEventListener(Event.ENTER_FRAME, updateDragging, false, 0, true);
		}
		
		
		private function updateDragging(e:Event):void
		{
			clipDragging.x = myContainer.mouseX - offsetX;
			clipDragging.y = myContainer.mouseY - offsetY;
			
			if (clipDragging.y > 1000) {
				//in lower portion of screen
				if (clipDragging.x < 900) {
					TweenMax.to(clip.rank1, .25, { y:rankTop - 50 } );
					TweenMax.to(clip.rank2, .25, { y:rankTop } );
					TweenMax.to(clip.rank3, .25, { y:rankTop } );					
				}else if (clipDragging.x < 1815) {
					TweenMax.to(clip.rank2, .25, { y:rankTop - 50 } );
					TweenMax.to(clip.rank1, .25, { y:rankTop } );
					TweenMax.to(clip.rank3, .25, { y:rankTop } );	
				}else {
					TweenMax.to(clip.rank3, .25, { y:rankTop - 50 } );
					TweenMax.to(clip.rank1, .25, { y:rankTop } );
					TweenMax.to(clip.rank2, .25, { y:rankTop } );	
				}
			}else {
				TweenMax.to(clip.rank3, .25, { y:rankTop } );
				TweenMax.to(clip.rank1, .25, { y:rankTop } );
				TweenMax.to(clip.rank2, .25, { y:rankTop } );
			}
		}
				
		
		private function stopDragging(e:MouseEvent):void
		{
			if (clipDragging.y < 1000) {
				
				//let go above a bucket - put back to original loc
				switch(whichClip) {
					case 1:
						TweenMax.to(clipDragging, .5, { x:originalLoc1.x, y:originalLoc1.y, ease:Back.easeOut } );
						break;
					case 2:
						TweenMax.to(clipDragging, .5, { x:originalLoc2.x, y:originalLoc2.y, ease:Back.easeOut } );
						break;
					case 3:
						TweenMax.to(clipDragging, .5, { x:originalLoc3.x, y:originalLoc3.y, ease:Back.easeOut } );
						break;
				}
				
			}else {
				//need to scale down circle to fit hole...
				//whichClip == 1,2,3 the circle we started with
				var toX:int;
				var toY:int = rankTop + 200;
				
				if (clipDragging.x < 900) {
					toX = clip.rank1.x + 454;
					
					if (buckets[0] != 0) {
						//already a circle in the bucket
						if (buckets[0] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[0] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[0] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					buckets[0] = whichClip;
					cleaner(0, whichClip);
					
				}else if (clipDragging.x < 1815) {
					toX = clip.rank2.x + 454;
					
					if (buckets[1] != 0) {
						//already a circle in the bucket
						if (buckets[1] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[1] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[1] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					
					buckets[1] = whichClip;
					cleaner(1, whichClip);
					
				}else {
					toX = clip.rank3.x + 454;
					
					if (buckets[2] != 0) {
						//already a circle in the bucket
						if (buckets[2] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[2] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[2] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					
					buckets[2] = whichClip;
					cleaner(2, whichClip);
				}
				
				TweenMax.to(clipDragging, .5, { x:toX, y:toY, scaleX:.45, scaleY:.45 } );
				
				//move rank boxes down
				TweenMax.to(clip.rank3, .25, { y:rankTop } );
				TweenMax.to(clip.rank1, .25, { y:rankTop } );
				TweenMax.to(clip.rank2, .25, { y:rankTop } );
			}
			
			myContainer.removeEventListener(Event.ENTER_FRAME, updateDragging);
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			
			if (buckets[0] != 0 && buckets[1] != 0 && buckets[2] != 0) {
				//buckets are full move on
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		
		/**
		 * cleans the buckets array so when a circle is dropped on a new bucket it's zeroed in it's last bucket
		 * @param	index index in buckets array where circle is now
		 * @param	which which circle 1,2 or 3
		 */
		private function cleaner(index:int, which:int):void
		{
			for (var i:int = 0; i < buckets.length; i++) {
				if (i != index && buckets[i] == which) {
					buckets[i] = 0;
				}
			}
		}
		
	}
	
}