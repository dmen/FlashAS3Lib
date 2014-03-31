package com.gmrmarketing.tmobile
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	
	
	public class Poll extends MovieClip
	{
		private var mySO:SharedObject;
		private var curQuesID:int;
		
		private var quesTimer:Timer;
		private var quesLoader:URLLoader;
		private var quesRequest:URLRequest;
		
		private var resultsTimer:Timer;
		private var resultsLoader:URLLoader;
		private var resultsRequest:URLRequest;
		private var replies:Array;
		
		private var replyContainer:Sprite;
		private var graphContainer:Sprite;
		
		private const MAX_WIDE:int = 820;
		private const V_SPACE:int = 100;
		
		private var extraSpace:int;
		
		private var totalReplies:int;
		//set to true in checkForResults - used to be able to close the loader if a new question is loaded
		private var loadingResults:Boolean = false;
		private var currentQuestion:Array;
		
		private var formatter:TextFormat;		
		
		
		
		
		public function Poll()
		{
			curQuesID = 0;
			
			replyContainer = new Sprite();			
			replyContainer.x = 0;
			addChild(replyContainer);
			
			graphContainer = new Sprite();			
			graphContainer.x = 317;
			addChild(graphContainer);			
			
			quesLoader = new URLLoader();
			quesLoader.addEventListener(Event.COMPLETE, questionLoaded, false, 0, true);			
			
			quesTimer = new Timer(15000);
			quesTimer.addEventListener(TimerEvent.TIMER, checkForQuestion, false, 0, true);
			
			resultsLoader = new URLLoader();
			resultsLoader.addEventListener(Event.COMPLETE, resultsLoaded, false, 0, true);			
			
			resultsTimer = new Timer(5000,1);
			resultsTimer.addEventListener(TimerEvent.TIMER, checkForResults);
			
			formatter = new TextFormat();
			formatter.letterSpacing = -2;
			
			quesTimer.start();
			checkForQuestion();
		}
		
		
		/**
		 * called every 30 seconds by quesTimer 
		 * called initally from constructor to kickstart the process
		 * @param	e
		 */
		private function checkForQuestion(e:TimerEvent = null):void
		{
			var m:String = String(getTimer());			
			quesLoader.load(new URLRequest("http://tmobile.mangoapi.com/getactivepollquestion.php?r="+m));
		}
		
		
		//id,question,key1,ans1,key2,ans2,key3,ans3,key4,ans4,key5,ans5
		private function questionLoaded(e:Event):void
		{
			currentQuestion = e.target.data.split("||");
			
			if (currentQuestion[0] != curQuesID) {
				
				curQuesID = currentQuestion[0];
				
				//terminate any current results load
				if(loadingResults){
					resultsLoader.close();
				}
				resultsTimer.reset();
				
				//add extra space for positioning the graph bars if there are only 4 answers
				
				if (currentQuestion[10] == '' || currentQuestion[11] == '') {
					extraSpace = 20;
					replyContainer.y = 220;
					graphContainer.y = 220;					
				}else {
					//all 5
					extraSpace = 0;
					replyContainer.y = 200;
					graphContainer.y = 200;	
				}
				
				//this is a new question
				while (replyContainer.numChildren) {
					replyContainer.removeChildAt(0);
				}
				
				pollQuestion.text = currentQuestion[1];
				
				var curY:int = 0;
				
				var rep:MovieClip = new barLeft();
				rep.theChoice.text = String(currentQuestion[2]).toUpperCase();
				rep.theChoice.setTextFormat(formatter);
				rep.theText.text = currentQuestion[3];
				rep.theText.y = 10 + Math.round((75 - rep.theText.textHeight) * .5);
				rep.y = curY;
				replyContainer.addChild(rep);
				
				curY += V_SPACE + extraSpace;
				
				rep = new barLeft();
				rep.theChoice.text = String(currentQuestion[4]).toUpperCase();
				rep.theChoice.setTextFormat(formatter);
				rep.theText.text = currentQuestion[5];
				rep.theText.y = 10 + Math.round((75 - rep.theText.textHeight) * .5);
				rep.y = curY;
				replyContainer.addChild(rep);
				
				curY += V_SPACE + extraSpace;
				
				rep = new barLeft();
				rep.theChoice.text = String(currentQuestion[6]).toUpperCase();
				rep.theChoice.setTextFormat(formatter);
				rep.theText.text = currentQuestion[7];
				rep.theText.y = 10 + Math.round((75 - rep.theText.textHeight) * .5);
				rep.y = curY;
				replyContainer.addChild(rep);
				
				curY += V_SPACE + extraSpace;				
				
				rep = new barLeft();
				rep.theChoice.text = String(currentQuestion[8]).toUpperCase();
				rep.theChoice.setTextFormat(formatter);
				rep.theText.text = currentQuestion[9];
				rep.theText.y = 10 + Math.round((75 - rep.theText.textHeight) * .5);
				rep.y = curY;
				replyContainer.addChild(rep);
				
				curY += V_SPACE + extraSpace;	
				
				if(currentQuestion[10] != ''){
					rep = new barLeft();
					rep.theChoice.text = String(currentQuestion[10]).toUpperCase();
					rep.theChoice.setTextFormat(formatter);
					rep.theText.text = currentQuestion[11];
					rep.theText.y = 10 + Math.round((75 - rep.theText.textHeight) * .5);
					rep.y = curY;
					replyContainer.addChild(rep);
					
					addGraph(5);
				}else {
					addGraph(4);
				}
				
				checkForResults();
			}
		}
		
		
		
		/**
		 * Called when a new question is loaded - adds the number of bars
		 * according to how many replies the question has
		 * @param	numBars
		 */
		private function addGraph(numBars:int):void
		{
			while (graphContainer.numChildren) {
				graphContainer.removeChildAt(0);
			}
			var barY:int = 0;
			for (var i:int = 0; i < numBars; i++) {				
				var bar:MovieClip = new dataBar();
				bar.x = 0;
				bar.y = barY;
				barY += V_SPACE + extraSpace;
				bar.theBar.width = 0;
				bar.hilite.x = -116;
				bar.thePercent.x = 20;
				graphContainer.addChild(bar);
			}				
		}
		
		
		
		private function beginResultsChecking():void
		{
			resultsTimer.start();
		}
		
		
		
		private function checkForResults(e:TimerEvent = null):void
		{
			loadingResults = true;
			var m:String = String(getTimer());
			resultsRequest = new URLRequest("http://mlive.mango2go.com/AT/T2SService.php?r=" + m);			
			resultsLoader.load(resultsRequest);
		}		
		
		
		//currentQuestion array: id,question,key1,ans1,key2,ans2,key3,ans3,key4,ans4
		private function resultsLoaded(e:Event):void
		{			
			loadingResults = false;
			var qs:XML = new XML(e.target.data);
			
			replies = new Array();
			totalReplies = 0;			
			var rec:XMLList;
			for (var i:int = 2; i < 11; i += 2) {
				
				rec = qs.VOTE.(KEYWORD == String(currentQuestion[i]).toUpperCase());
				
				if(rec.length()){
					replies.push( { keyword:currentQuestion[i], count:parseInt(rec.COUNT) } );				
					totalReplies += parseInt(rec.COUNT);
				}else {
					replies.push( { keyword:currentQuestion[i], count:0 } );		
				}
			}			
			//trace("results loaded", replies);
			drawGraph();
			beginResultsChecking();
		}
		
		
		
		
		private function drawGraph():void
		{
			for (var i:int = 0; i < replies.length; i++) {
				var percent:Number = replies[i].count / totalReplies;
				
				if(!isNaN(percent) && percent != 0){					
					var bar:MovieClip = MovieClip(graphContainer.getChildAt(i));
					
					bar.thePercent.text = String(Math.round(percent * 100)) + "%";
					TweenMax.to(bar.theBar, 3, { width:Math.round(percent * MAX_WIDE), onUpdate:updateHilite, onUpdateParams:[bar], onComplete:updateHilite, onCompleteParams:[bar], ease:Bounce.easeOut, delay:.5 * i } );
				}
			}
		}
		
		
		
		private function updateHilite(bar:MovieClip):void
		{
			bar.hilite.x = bar.theBar.width - 115;
			bar.thePercent.x = bar.theBar.width + 20;
		}
		
	}
	
}