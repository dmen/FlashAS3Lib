package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.geom.Point;
	
	
	public class Challenge extends EventDispatcher
	{
		public static const COMPLETE:String = "challengeComplete";
		public static const HIDDEN:String = "challengeHidden";
		
		private const circleScale:Number = .728973388671875;//original circle scale
		
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
		
		private var rankTop:int = 1156;//y position for the rank buckets at the bottom
		
		private var rankOrder:Array;//the bucket order
		
		private var answerText:Array; //filled in show() - used by Results to show answers under circles
		
		private var tim:TimeoutHelper;
		
		
		public function Challenge()
		{
			clip = new mcChallenge();
			
			originalLoc1 = new Point(clip.circ1.x, clip.circ1.y);
			originalLoc2 = new Point(clip.circ2.x, clip.circ2.y);
			originalLoc3 = new Point(clip.circ3.x, clip.circ3.y);
			
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns the answers in String form
		 * Used for under the circles on the results screen
		 */
		public function get answersText():Array
		{
			return answerText;
		}
		
		
		/**
		 * returns the ranking in a 3 element array
		 * ranking is 1,2,3
		 */
		public function get selection():Array
		{
			var ans:Array = [0,0,0];
			
			if (buckets[0] == 1) {
				ans[0] = 1;
			}
			if (buckets[1] == 2) {
				ans[1] = 1;
			}
			if (buckets[2] == 3) {
				ans[2] = 1;
			}
			return ans;
		}
		
		
		/**
		 * 
		 * @param	theLevel String Novice, Seasoned or Sommelier
		 * @param	theWines Array of three white or red wine objects from the JSON
		 * 			array order matches the selection order in the config dialog
		 * @param	qData Object with l1,l2,l3 properties/objects - each of those containing title and subTitle properties
		 */
		public function show(theLevel:String, theWines:Array, qData:Object):void
		{
			tim.buttonClicked();
			
			buckets = [0, 0, 0];		
			answerText = [];
			
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			var sel:Number;
			
			switch(theLevel) {
				case "Novice":
					clip.title.theText.text = qData.l1.title;
					clip.subTitle.theText.text = qData.l1.subTitle;
					
					clip.rank1.theText.text = theWines[0].l1Answer;
					clip.rank1.subText.text = theWines[0].l1AnswerSub;
					
					clip.rank2.theText.text = theWines[1].l1Answer;
					clip.rank2.subText.text = theWines[1].l1AnswerSub;
					
					clip.rank3.theText.text = theWines[2].l1Answer;
					clip.rank3.subText.text = theWines[2].l1AnswerSub;//could just randomize the rank positions???									
					
					clip.rank1.subText.y = clip.rank1.theText.y + clip.rank1.theText.textHeight + 30;
					clip.rank2.subText.y = clip.rank2.theText.y + clip.rank2.theText.textHeight + 30;
					clip.rank3.subText.y = clip.rank3.theText.y + clip.rank3.theText.textHeight + 30;
					
					answerText = [theWines[0].l1Answer, theWines[1].l1Answer, theWines[2].l1Answer];
					
					break;
					
				case "Seasoned":
					clip.title.theText.text = qData.l2.title;
					clip.subTitle.theText.text = qData.l2.subTitle;
					
					clip.rank1.subText.text = "";
					clip.rank2.subText.text = "";
					clip.rank3.subText.text = "";
					
					//select answer a b or c from the json
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank1.theText.text = theWines[0].l2AnswerA;
						answerText[0] = theWines[0].l2AnswerA;
					}else if (sel < .66) {
						clip.rank1.theText.text = theWines[0].l2AnswerB;
						answerText[0] = theWines[0].l2AnswerB;
					}else {
						clip.rank1.theText.text = theWines[0].l2AnswerC;
						answerText[0] = theWines[0].l2AnswerC;
					}
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank2.theText.text = theWines[1].l2AnswerA;
						answerText[1] = theWines[1].l2AnswerA;
					}else if (sel < .66) {
						clip.rank2.theText.text = theWines[1].l2AnswerB;
						answerText[1] = theWines[1].l2AnswerB;
					}else {
						clip.rank2.theText.text = theWines[1].l2AnswerC;
						answerText[1] = theWines[1].l2AnswerC;
					}
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank3.theText.text = theWines[2].l2AnswerA;
						answerText[2] = theWines[2].l2AnswerA;
					}else if (sel < .66) {
						clip.rank3.theText.text = theWines[2].l2AnswerB;
						answerText[2] = theWines[2].l2AnswerB;
					}else {
						clip.rank3.theText.text = theWines[2].l2AnswerC;
						answerText[2] = theWines[2].l2AnswerC;
					}
					
					break;
					
				case "Sommelier":
					clip.title.theText.text = qData.l3.title;
					clip.subTitle.theText.text = qData.l3.subTitle;
					
					clip.rank1.subText.text = "";
					clip.rank2.subText.text = "";
					clip.rank3.subText.text = "";
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank1.theText.text = theWines[0].l3AnswerA;
						answerText[0] = theWines[0].l3AnswerA;
					}else if (sel < .66) {
						clip.rank1.theText.text = theWines[0].l3AnswerB;
						answerText[0] = theWines[0].l3AnswerB;
					}else {
						clip.rank1.theText.text = theWines[0].l3AnswerC;
						answerText[0] = theWines[0].l3AnswerC;
					}
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank2.theText.text = theWines[1].l3AnswerA;
						answerText[1] = theWines[1].l3AnswerA;
					}else if (sel < .66) {
						clip.rank2.theText.text = theWines[1].l3AnswerB;
						answerText[1] = theWines[1].l3AnswerB;
					}else {
						clip.rank2.theText.text = theWines[1].l3AnswerC;
						answerText[1] = theWines[1].l3AnswerC;
					}
					
					sel = Math.random();
					
					if (sel < .33) {
						clip.rank3.theText.text = theWines[2].l3AnswerA;
						answerText[2] = theWines[2].l3AnswerA;
					}else if (sel < .66) {
						clip.rank3.theText.text = theWines[2].l3AnswerB;
						answerText[2] = theWines[2].l3AnswerB;
					}else {
						clip.rank3.theText.text = theWines[2].l3AnswerC;
						answerText[2] = theWines[2].l3AnswerC;
					}
					
					break;
			}
			
			clip.circ1.x = originalLoc1.x;
			clip.circ1.y = originalLoc1.y;
			
			clip.circ2.x = originalLoc2.x;
			clip.circ2.y = originalLoc2.y;
			
			clip.circ3.x = originalLoc3.x;
			clip.circ3.y = originalLoc3.y;
			
			clip.circ1.theText.text = "1";
			clip.circ2.theText.text = "2";
			clip.circ3.theText.text = "3";
			
			clip.circ1.scaleX = clip.circ1.scaleY = 0;
			clip.circ2.scaleX = clip.circ2.scaleY = 0;
			clip.circ3.scaleX = clip.circ3.scaleY = 0;
			
			clip.rank1.x = 0;
			clip.rank2.x = 913;
			clip.rank3.x = 1827;
			
			clip.rank1.y = 1824;//off screen bottom
			clip.rank2.y = 1824;
			clip.rank3.y = 1824;
			
			rankOrder = [0, 1, 2];//the order the rank buckets are in
			
			var n:Number = Math.random();
			if (n < .33) {
				clip.rank1.x = 0;
			
				if (Math.random() < .5) {
					clip.rank2.x = 913;
					
				}else {
					clip.rank2.x = 1827;
					clip.rank3.x = 913;
					
					rankOrder[1] = 2;
					rankOrder[2] = 1;
				}
				
			}else if (n < .66) {
				clip.rank1.x = 913;
				rankOrder[1] = 0;
				
				if (Math.random() < .5) {
					clip.rank2.x = 0;
					rankOrder[0] = 1;
				}else {
					clip.rank2.x = 1827;
					clip.rank3.x = 0;
					rankOrder[2] = 1;
					rankOrder[0] = 2;
				}
				
			}else {
				clip.rank1.x = 1827;
				rankOrder[2] = 0;
				if (Math.random() < .5) {
					clip.rank3.x = 0;
					rankOrder[0] = 2;
				}else {
					clip.rank2.x = 0;
					clip.rank3.x = 913;
					rankOrder[0] = 1;
					rankOrder[1] = 2;
				}
			}
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.x = 0;
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.circ1, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1} );
			TweenMax.to(clip.circ2, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1.2} );
			TweenMax.to(clip.circ3, .4, { scaleX:circleScale, scaleY:circleScale, alpha:.8, ease:Back.easeOut, delay:1.4} );
			
			TweenMax.to(clip.rank1, .5, { y:rankTop, ease:Back.easeOut, delay:1.6 } );
			TweenMax.to(clip.rank2, .5, { y:rankTop, ease:Back.easeOut, delay:1.8 } );
			TweenMax.to(clip.rank3, .5, { y:rankTop, ease:Back.easeOut, delay:2, onComplete:addListeners } );
		}
		
		
		public function hide():void
		{
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging3);
			
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			myContainer.removeEventListener(Event.ENTER_FRAME, updateDragging);
			
			//TweenMax.to(clip, 1, { x: -2736, ease:Back.easeIn, onComplete:kill } );
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}		
		
		
		public function kill():void
		{	
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, startDragging3);
			
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			myContainer.removeEventListener(Event.ENTER_FRAME, updateDragging);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function addListeners():void
		{
			clip.circ1.addEventListener(MouseEvent.MOUSE_DOWN, startDragging1, false, 0, true);
			clip.circ2.addEventListener(MouseEvent.MOUSE_DOWN, startDragging2, false, 0, true);
			clip.circ3.addEventListener(MouseEvent.MOUSE_DOWN, startDragging3, false, 0, true);
		}
		
		
		private function startDragging1(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clipDragging = MovieClip(e.currentTarget);
			whichClip = 1;
			doDrag();
		}
		
		
		private function startDragging2(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clipDragging = MovieClip(e.currentTarget);
			whichClip = 2;
			doDrag();
		}
		
		
		private function startDragging3(e:MouseEvent):void
		{
			tim.buttonClicked();
			
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
					if(rankOrder[0] == 0){
						TweenMax.to(clip.rank1, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else if (rankOrder[0] == 1) {
						TweenMax.to(clip.rank2, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else {
						TweenMax.to(clip.rank3, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
					}
				}else if (clipDragging.x < 1815) {
					if(rankOrder[1] == 0){
						TweenMax.to(clip.rank1, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else if (rankOrder[1] == 1) {
						TweenMax.to(clip.rank2, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else {
						TweenMax.to(clip.rank3, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
					}
				}else {
					if(rankOrder[2] == 0){
						TweenMax.to(clip.rank1, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else if (rankOrder[2] == 1) {
						TweenMax.to(clip.rank2, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
						TweenMax.to(clip.rank3, .25, { y:rankTop } );
					}else {
						TweenMax.to(clip.rank3, .25, { y:rankTop - 50 } );
						TweenMax.to(clip.rank2, .25, { y:rankTop } );
						TweenMax.to(clip.rank1, .25, { y:rankTop } );
					}
				}
			}else {
				TweenMax.to(clip.rank3, .25, { y:rankTop } );
				TweenMax.to(clip.rank1, .25, { y:rankTop } );
				TweenMax.to(clip.rank2, .25, { y:rankTop } );
			}
		}
				
		
		private function stopDragging(e:MouseEvent):void
		{
			tim.buttonClicked();			
			
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
					toX = 454;
					
					if (buckets[rankOrder[0]] != 0) {
						//already a circle in the bucket
						if (buckets[rankOrder[0]] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[0]] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[0]] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					//trace("buckets[" + rankOrder[0] + "] = " + whichClip);
					buckets[rankOrder[0]] = whichClip;
					cleaner(rankOrder[0], whichClip);//removes whichClip from previous bucket
					
				}else if (clipDragging.x < 1815) {
					toX = 1367;
					
					if (buckets[rankOrder[1]] != 0) {
						//already a circle in the bucket
						if (buckets[rankOrder[1]] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[1]] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[1]] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					//trace("buckets[" + rankOrder[1] + "] = " + whichClip);
					buckets[rankOrder[1]] = whichClip;
					cleaner(rankOrder[1], whichClip);
					
				}else {
					toX = 2281;
					
					if (buckets[rankOrder[2]] != 0) {
						//already a circle in the bucket
						if (buckets[rankOrder[2]] == 1) {
							TweenMax.to(clip.circ1, .5, { x:originalLoc1.x, y:originalLoc1.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[2]] == 2) {
							TweenMax.to(clip.circ2, .5, { x:originalLoc2.x, y:originalLoc2.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
						if (buckets[rankOrder[2]] == 3) {
							TweenMax.to(clip.circ3, .5, { x:originalLoc3.x, y:originalLoc3.y,  scaleX:.728973388671875, scaleY:.728973388671875, ease:Back.easeOut } );
						}
					}
					//trace("buckets[" + rankOrder[2] + "] = " + whichClip);
					buckets[rankOrder[2]] = whichClip;
					cleaner(rankOrder[2], whichClip);
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
		 * cleans the buckets array so when a circle is dropped on a new bucket it's zeroed in it's previous bucket
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