package com.gmrmarketing.tmobile
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.BlurFilter;	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.tmobile.Quote;
	import flash.utils.getTimer;
	
	
	
	public class TTS extends MovieClip
	{
		//maximum number of replies moving in the window at one time
		//used by checkForCull()
		private const MAX_REPLIES:int = 100;
		
		private var quesTimer:Timer;
		private var quesLoader:URLLoader;
		private var quesRequest:URLRequest;
		
		private var resultsTimer:Timer;
		private var resultsLoader:URLLoader;		
		private var replies:Array;
		
		private var curQuesID:int;
		
		private var replyContainer:Sprite;
		
		//set to true in checkForResults - used to be able to close the loader if a new question is loaded
		private var loadingResults:Boolean = false;		
		private var currentQuestion:Array;
		
		//last time the service was checked, or current time when the question changes
		private var lastTime:String;		
		
		private var displayPoints:Array;
		
		private var blur:BlurFilter;
		
		private var cullingTimer:Timer;
		
		//index in the replies list of the current large, viewable reply
		private var viewingIndex:int;		
		
		//used by viewNextReply
		private var isViewing:Boolean;
		
		//set to true in viewNextReply once all the messages in the queue have been viewed
		//when true and new messages arrive the viewingIndex is set to the end of the replies
		//array so that the new messages are seen next
		private var looped:Boolean;
		
		
		
		
		public function TTS()
		{
			curQuesID = 0;
			lastTime = "2011-05-27";//initial start - only works if setCurrentTime() is commented out in questionLoaded()
			
			blur = new BlurFilter(10, 10, 2);
			
			displayPoints = new Array(new Point(60,60), new Point(160,60), new Point(590,50), new Point(660,60), new Point(911,55));			
			
			replies = new Array();
			viewingIndex = -1;
			isViewing = false;
			
			replyContainer = new Sprite();
			//add reply balloons behind the logo
			addChildAt(replyContainer, 1);
			
			quesLoader = new URLLoader();
			quesLoader.addEventListener(Event.COMPLETE, questionLoaded, false, 0, true);
			
			quesTimer = new Timer(15000);
			quesTimer.addEventListener(TimerEvent.TIMER, checkForQuestion, false, 0, true);
			
			resultsLoader = new URLLoader();
			resultsLoader.addEventListener(Event.COMPLETE, resultsLoaded, false, 0, true);
			
			resultsTimer = new Timer(5000, 1);
			resultsTimer.addEventListener(TimerEvent.TIMER, checkForResults);
			
			cullingTimer = new Timer(1500);
			cullingTimer.addEventListener(TimerEvent.TIMER, checkForCull, false, 0, true);
			
			quesTimer.start();
			cullingTimer.start();			
			checkForResults();
		}
		
		
		
		/**
		 * called every 30 seconds by quesTimer 
		 * called initally from constructor to kickstart the process
		 * @param	e
		 */
		private function checkForQuestion(e:TimerEvent = null):void
		{
			var m:String = String(getTimer());			
			quesLoader.load(new URLRequest("http://mlive.mango2go.com/AT/T2SService.php?r="+m));
		}
		
		
		
		private function questionLoaded(e:Event):void
		{
			var tempQues:Array =  e.target.data.split("||");
			
			//new question?
			if (tempQues[0] != curQuesID && tempQues[1] != '' && tempQues[1] != null) {
				
				currentQuestion = tempQues;
				
				curQuesID = currentQuestion[0];
				
				//terminate any current results load
				if(loadingResults){
					resultsLoader.close();
				}
				resultsTimer.reset();
				
				TweenMax.to(pollQuestion, .5, { alpha:0, onComplete:fadeInNewQuestion, onCompleteParams:[currentQuestion[1]] } );
				
				clearAllReplies();
				
				setCurrentTime();
				checkForResults();
			}
		}
		
		private function fadeInNewQuestion(ques:String):void
		{
			//trace("fade", ques);
			pollQuestion.htmlText = ques;
			pollQuestion.y = 375 + Math.round((155 - pollQuestion.textHeight) * .5);
			TweenMax.to(pollQuestion, .5, { alpha:1 } );
		}
		
		
		
		private function checkForResults(e:TimerEvent = null):void
		{			
			loadingResults = true;
			
			var m:String = String(getTimer());
			var req:URLRequest = new URLRequest("http://mlive.mango2go.com/AT/T2SService.php?r=" + m);
			//var req:URLRequest = new URLRequest("http://mangoapi.com/T2SService.php?r=" + m);

			var variables:URLVariables = new URLVariables();
			variables.t = lastTime;
			
			req.data = variables;
			req.method = URLRequestMethod.POST;
			
			//calls resultsLoaded when complete
			resultsLoader.load(req);
		}
		
		
		
		private function resultsLoaded(e:Event):void
		{			
			loadingResults = false;
			var reps:XML = new XML(e.target.data);
			var c:int = reps.MSG.length();
			
			if (c > 0) {
				//set lastTime
				setCurrentTime();
				
				if(looped){
					viewingIndex = replies.length - 1;
					looped = false;
				}
			}
			for (var i:int = 0; i < c; i++) {
				
				var b:Quote = new Quote(); //attached to lib clip
				var p:Point = getNextLoc();
				
				var al:Number = (10 + Math.random() * 35) / 100; // .1 - .45
				var scal:Number = .1 + al * 2; // .3 to 1
				
				b.theText.autoSize = TextFieldAutoSize.LEFT;
				b.theText.text = reps.MSG[i].MBODY;				
				b.balloon.width = b.theText.textWidth + 30;
				b.balloon.height = b.theText.textHeight + 40;
				b.bott.y = b.theText.textHeight + 38;
				b.scaleX = b.scaleY = scal;
				b.alpha = al;
				b.x = p.x;
				b.y = p.y;
				b.filters = [blur];
				replyContainer.addChild(b);
				replies.push(b);
			}			
			
			//start the timer which calls checkForResults()
			resultsTimer.start();
			viewNextReply();
		}
		
		
		
		/**
		 * sets lastTime to a time string like 2011-05-22 18:20:00
		 * 
		 * @return
		 */
		private function setCurrentTime():void
		{	
			var now:Date = new Date();
			var t:String = String(now.getFullYear()) + "-" + String(now.getMonth() + 1) + "-" + String(now.getDate());
			t += " " + String(now.getHours()) + ":" + String(now.getMinutes()) + ":" + String(now.getSeconds());
			
			lastTime = t;
			//msg.text ="time set: "+ lastTime;
		}
		
		
		/**
		 * Called from results loaded
		 * @return
		 */
		private function getNextLoc():Point
		{			
			var p:Point = new Point();
			p.x = 1200 * Math.random();
			p.y = 690 * Math.random();			
			return p;
		}
		
		
		/**
		 * Called by cullingTimer
		 * removes the first (oldest) item in replies
		 * if there are too many replies
		 * @param	e
		 */
		private function checkForCull(e:TimerEvent):void
		{	
			if(viewingIndex != 0){
				if (replies.length > MAX_REPLIES) {
					var lastReply:Quote = replies.shift();
					viewingIndex--; //decrement index because array shifted
					viewingIndex = Math.max(0, viewingIndex);					
					TweenMax.to(lastReply, 2, { alpha:0, onComplete:cullReply, onCompleteParams:[lastReply] } );
				}
			}
		}
		
		
		private function cullReply(rep:Quote):void
		{			
			if (rep) {
				rep.kill();
				rep.filters = [];
				if(replyContainer.contains(rep)){
					replyContainer.removeChild(rep);
				}
				rep = null;
			}			
		}
		
		
		
		private function clearAllReplies():void
		{	
			cullingTimer.reset();			
			var inc:Number = 0;
			for (var i:int = 0; i < replyContainer.numChildren; i++ ) {
				var lastReply:Quote = Quote(replyContainer.getChildAt(i));
				lastReply.kill();
				TweenMax.to(lastReply, .25, { delay:inc * .02, alpha:0, onComplete:cullReply, onCompleteParams:[lastReply] } );
				inc++;
			}
			replies = new Array();
			cullingTimer.start();
			viewingIndex = -1;
			isViewing = false;
		}
		
		
		
		/**
		 * Called by resultsLoaded and restartQuoteMotion
		 */
		private function viewNextReply():void
		{			
			if (replies.length > 0 && !isViewing) {
				isViewing = true;
				
				viewingIndex++;
				if (viewingIndex >= replies.length) {
					viewingIndex = 0;
					looped = true;					
				}
				var rep:Quote = replies[viewingIndex];
				rep.kill();
				var curScaleX:Number = rep.scaleX;
				var curScaleY:Number = rep.scaleY;
				var curAlpha:Number = rep.alpha;
				var viewPoint:Point = displayPoints[Math.floor(Math.random() * displayPoints.length)];
				var over:int = (viewPoint.x + rep.theText.textWidth + 200) - 1280;
				if (over > 0) {
					viewPoint.x -= over;
				}
				replyContainer.setChildIndex(rep, replyContainer.numChildren - 1);
				TweenMax.to(rep, .5, { alpha:1, x:viewPoint.x, y:viewPoint.y, scaleX:1.5, scaleY:1.5, blurFilter: { blurX:0, blurY:0 }, onComplete:removeReply, onCompleteParams:[rep, curScaleX, curScaleY, curAlpha]} );				
			}
		}
		
		
		
		private function removeReply(rep:Quote, oldScaleX:Number, oldScaleY:Number, oldAlpha:Number):void
		{
			TweenMax.to(rep, .5, { delay:3, alpha:oldAlpha, scaleX:oldScaleX, scaleY:oldScaleY, blurFilter: { blurX:10, blurY:10 }, onComplete:restartQuoteMotion, onCompleteParams:[rep] } );
		}
		
		
		
		private function restartQuoteMotion(rep:Quote):void
		{
			isViewing = false;
			rep.nextPos();
			viewNextReply();
		}
	}
	
}