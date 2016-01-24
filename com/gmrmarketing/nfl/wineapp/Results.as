package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Results extends EventDispatcher 
	{
		public static const COMPLETE:String = "resultsComplete";
		public static const SKIP:String = "skipEmail";
		public static const HIDDEN:String = "resultsHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var arcContainer:Sprite;
		private var angleTo:int;
		
		private var theAnswers:Array;
		private var theWines:Array;
		private var infoDialog:MovieClip;
		
		
		public function Results()
		{
			clip = new mcResults();
			arcContainer = new Sprite();
			clip.addChild(arcContainer);
			
			infoDialog = new mcInfoDialog();
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	answers three element array with 0 or 1
		 * @param 	wines Array of wine objects from the json
		 * @param	userRank Array of three items - 1,2,3
		 */
		public function show(answers:Array, answersText:Array, wines:Array, userRank:Array)
		{			
			theAnswers = answers;
			theWines = wines;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			arcContainer.graphics.clear();
			
			clip.x = 0;
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			
			clip.answer1.alpha = 0;
			clip.answer2.alpha = 0;
			clip.answer3.alpha = 0;
			
			clip.title.theText.text = "HERE'S HOW YOU DID";
			clip.subTitle.theText.text = "Tap on each wine to learn a little more about them.";
			
			clip.circ1.theText.text = "1";
			clip.circ2.theText.text = "2";
			clip.circ3.theText.text = "3";
			
			clip.circ1.theRank.theText.text = "#" + userRank[0];// String(3 - userRank.indexOf(1));
			clip.circ2.theRank.theText.text = "#" + userRank[1];//String(3 - userRank.indexOf(2));
			clip.circ3.theRank.theText.text = "#" + userRank[2];//String(3 - userRank.indexOf(3));
			
			clip.circ1.subText.text = wines[0].producer + "\n" + wines[0].variety;
			clip.circ2.subText.text = wines[1].producer + "\n" + wines[1].variety;
			clip.circ3.subText.text = wines[2].producer + "\n" + wines[2].variety;
			
			clip.answer1.theText.text = answersText[0];
			clip.answer2.theText.text = answersText[1];
			clip.answer3.theText.text = answersText[2];
			
			clip.circ1.scaleX = clip.circ1.scaleY = 0;
			clip.circ2.scaleX = clip.circ2.scaleY = 0;
			clip.circ3.scaleX = clip.circ3.scaleY = 0;
			
			clip.btnEmail.alpha = 0;
			clip.skipText.alpha = 0;
			
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(clip.circ1, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1} );
			TweenMax.to(clip.circ2, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1.2} );
			TweenMax.to(clip.circ3, .4, { scaleX:1, scaleY:1, alpha:.8, ease:Back.easeOut, delay:1.4 } );
			
			TweenMax.to(clip.answer1, .4, { alpha:1, delay:1.2 } );
			TweenMax.to(clip.answer2, .4, { alpha:1, delay:1.4 } );
			TweenMax.to(clip.answer3, .4, { alpha:1, delay:1.6 } );
			
			TweenMax.to(clip.skipText, .5, { alpha:1, delay:1.5 } );
			TweenMax.to(clip.btnEmail, .5, { alpha:1, delay:1.5, onComplete:addListeners } );			
		}
		
		
		public function hide():void
		{
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo3);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailSelected);
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			
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
			closeInfoDialog();
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function addListeners():void
		{
			angleTo = 0;
			clip.addEventListener(Event.ENTER_FRAME, drawArcs, false, 0, true);
			clip.circ1.addEventListener(MouseEvent.MOUSE_DOWN, showInfo1, false, 0, true);
			clip.circ2.addEventListener(MouseEvent.MOUSE_DOWN, showInfo2, false, 0, true);
			clip.circ3.addEventListener(MouseEvent.MOUSE_DOWN, showInfo3, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, emailSelected, false, 0, true);
			clip.btnSkip.addEventListener(MouseEvent.MOUSE_DOWN, skipSelected, false, 0, true);
		}
		
		
		private function emailSelected(e:MouseEvent):void
		{
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailSelected);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function skipSelected(e:MouseEvent):void
		{
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			dispatchEvent(new Event(SKIP));
		}
		
		
		private function showInfo1(e:MouseEvent):void
		{			
			showInfoDialog(0);
		}
		
		
		private function showInfo2(e:MouseEvent):void
		{
			showInfoDialog(1);
		}
		
		private function showInfo3(e:MouseEvent):void
		{
			showInfoDialog(2);
		}
		
		
		private function showInfoDialog(index:int):void
		{
			infoDialog.l1answer.text = theWines[index].l1Answer;
			infoDialog.producer.text = theWines[index].producer;
			infoDialog.variety.text = theWines[index].variety;
			infoDialog.notes.text = theWines[index].notes;
			infoDialog.scentsOf.text = theWines[index].l3AnswerA + ", " + theWines[index].l3AnswerB + ", " + theWines[index].l3AnswerC;
			infoDialog.pairsWith.text = theWines[index].l2AnswerA + ", " + theWines[index].l2AnswerB + ", " + theWines[index].l2AnswerC;
			//right side info
			infoDialog.vintage.text = theWines[index].vintage;
			infoDialog.abv.text = String(theWines[index].abv) + "%";
			if (theWines[index].ratingNumber != 0) {
				infoDialog.ratingTitle.text = "Rating:";
				infoDialog.ratingNumber.text = theWines[index].ratingNumber;
				infoDialog.ratingName.text = theWines[index].ratingName;
				infoDialog.ratingName.x = infoDialog.ratingNumber.x + infoDialog.ratingNumber.textWidth + 10;
			}else {
				infoDialog.ratingTitle.text = "";
				infoDialog.ratingNumber.text = "";
				infoDialog.ratingName.text = "";
			}
			
			infoDialog.alpha = 0;
			if (!myContainer.contains(infoDialog)) {
				myContainer.addChild(infoDialog);
			}
			TweenMax.to(infoDialog, .5, { alpha:1 } );
			
			infoDialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeInfoDialog, false, 0, true);
		}
		
		
		private function closeInfoDialog(e:MouseEvent = null):void
		{
			infoDialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeInfoDialog);
			
			if (myContainer) {
				if (myContainer.contains(infoDialog)) {
					myContainer.removeChild(infoDialog);
				}
			}
		}
		
		
		private function drawArcs(e:Event):void
		{			
			arcContainer.graphics.clear();				
			
			if(theAnswers[0] == 1){
				Utility.drawArc(arcContainer.graphics, clip.circ1.x, clip.circ1.y, 285, 0, angleTo, 13, 0x46ab06, 1);
			}else {
				Utility.drawArc(arcContainer.graphics, clip.circ1.x, clip.circ1.y, 285, 0, angleTo, 13, 0xa30a08, 1);
			}
			
			if(theAnswers[1] == 1){
				Utility.drawArc(arcContainer.graphics, clip.circ2.x, clip.circ2.y, 285, 0, angleTo, 13, 0x46ab06, 1);
			}else {
				Utility.drawArc(arcContainer.graphics, clip.circ2.x, clip.circ2.y, 285, 0, angleTo, 13, 0xa30a08, 1);
			}
			
			if(theAnswers[2] == 1){
				Utility.drawArc(arcContainer.graphics, clip.circ3.x, clip.circ3.y, 285, 0, angleTo, 13, 0x46ab06, 1);
			}else {
				Utility.drawArc(arcContainer.graphics, clip.circ3.x, clip.circ3.y, 285, 0, angleTo, 13, 0xa30a08, 1);
			}
			
			angleTo += 10 ;
			if (angleTo > 360) {
				clip.removeEventListener(Event.ENTER_FRAME, drawArcs);
			}
			
		}
	}
	
}