package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
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
		
		private var tim:TimeoutHelper;
		private var isPostThanks:Boolean; //true if results is being shown after thanks - for user review...
		
		
		public function Results()
		{
			clip = new mcResults();
			arcContainer = new Sprite();
			clip.addChild(arcContainer);
			tim = TimeoutHelper.getInstance();
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
		 * @param 	postThanks - true if results is shown after the thanks screen - changes buttons
		 */
		public function show(answers:Array, answersText:Array, wines:Array, userRank:Array, postThanks:Boolean = false)
		{	
			tim.buttonClicked();
			
			theAnswers = answers;
			theWines = wines;
			isPostThanks = postThanks;
			
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
			
			if(!isPostThanks){
				clip.title.theText.text = "BLIND TASTE TEST";
				clip.subTitle.theText.text = "Here are your results. Get more details by tapping each wine.";
			}else {
				clip.title.theText.text = "FINAL REVIEW";
				clip.subTitle.theText.text = "Here are your results one more time for review.";
			}
			
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
			
			clip.pointer1.alpha = 0;
			clip.pointer1.scaleX = clip.pointer1.scaleY = .8;
			clip.pointer2.alpha = 0;
			clip.pointer2.scaleX = clip.pointer2.scaleY = .8;
			clip.pointer3.alpha = 0;
			clip.pointer2.scaleX = clip.pointer2.scaleY = .8;
			clip.pointer1.mouseEnabled = false;
			clip.pointer1.mouseChildren = false;
			clip.pointer2.mouseEnabled = false;
			clip.pointer2.mouseChildren = false;
			clip.pointer3.mouseEnabled = false;
			clip.pointer3.mouseChildren = false;
			
			if (isPostThanks) {
				clip.btnEmail.theText.text = "FINISH";
			}else {
				clip.btnEmail.theText.text = "Email Results";
			}
			
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
			
			//don't show skip button post thanks
			if (!isPostThanks) {			
				TweenMax.to(clip.skipText, .5, { alpha:1, delay:1.5 } );
			}
			
			TweenMax.to(clip.btnEmail, .5, { alpha:1, delay:1.5, onComplete:addListeners } );			
		}
		
		
		//called from drawArcs when arcs are complete
		private function showFingerPointers():void
		{	
			TweenMax.to(clip.pointer1, 1, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.pointer2, 1, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut} );
			TweenMax.to(clip.pointer3, 1, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut} );
			
			TweenMax.to(clip.pointer1, 1, { alpha:0,  scaleX:.8, scaleY:.8, delay:2, ease:Back.easeIn } );
			TweenMax.to(clip.pointer2, 1, { alpha:0, scaleX:.8, scaleY:.8, delay:2, ease:Back.easeIn} );
			TweenMax.to(clip.pointer3, 1, { alpha:0, scaleX:.8, scaleY:.8, delay:2, ease:Back.easeIn } );
		}
		
		
		public function hide():void
		{
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo3);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailSelected);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}		
		
		
		public function kill():void
		{			
			clip.circ1.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo1);
			clip.circ2.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo2);
			clip.circ3.removeEventListener(MouseEvent.MOUSE_DOWN, showInfo3);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailSelected);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			
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
			if(!isPostThanks){
				clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, emailSelected, false, 0, true);
				clip.btnSkip.addEventListener(MouseEvent.MOUSE_DOWN, skipSelected, false, 0, true);
			}else {
				//showing 'finished' text
				clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, skipSelected, false, 0, true);
			}
		}
		
		
		private function emailSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailSelected);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function skipSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, skipSelected);
			dispatchEvent(new Event(SKIP));
		}
		
		
		private function showInfo1(e:MouseEvent):void
		{		
			tim.buttonClicked();
			showInfoDialog(0);
		}
		
		
		private function showInfo2(e:MouseEvent):void
		{
			tim.buttonClicked();
			showInfoDialog(1);
		}
		
		
		private function showInfo3(e:MouseEvent):void
		{
			tim.buttonClicked();
			showInfoDialog(2);
		}
		
		
		private function showInfoDialog(index:int):void
		{
			infoDialog.l1answer.text = theWines[index].l1Answer;
			infoDialog.producer.text = theWines[index].producer;
			infoDialog.variety.text = theWines[index].variety;
			infoDialog.geo.text = theWines[index].geo;
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
			
			if (infoDialog.ratingName.textHeight < 30) {
				//single line
				infoDialog.ratingName.y = 1083;
			}else {
				//double line
				infoDialog.ratingName.y = 1063;
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
			tim.buttonClicked();
			
			infoDialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeInfoDialog);
			
			TweenMax.to(infoDialog, .5, { alpha:0, onComplete:killInfoDialog } );
		}
		
		
		private function killInfoDialog():void
		{
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
				showFingerPointers();
			}
			
		}
	}
	
}