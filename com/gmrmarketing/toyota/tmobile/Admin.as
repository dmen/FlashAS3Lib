package com.gmrmarketing.tmobile
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import fl.data.DataProvider;
	import com.greensock.TweenLite;
	
	
	public class Admin extends MovieClip
	{
		private var mySO:SharedObject;
		private var questions:Array;
		private var loader:URLLoader;
		private var currentType:String = "poll"; //poll or tts
		
		
		public function Admin()
		{			
			loader = new URLLoader();	
			theGrid.columns = ["question", "active"];
			theGrid.columns[1].width = 50;
			btnSelect.addEventListener(MouseEvent.CLICK, selectQuestion, false, 0, true);			
			btnPoll.addEventListener(MouseEvent.CLICK, getPollQuestions, false, 0, true);
			btnTts.addEventListener(MouseEvent.CLICK, getTTSQuestions, false, 0, true);
			getQuestions();
		}		
		
		
		private function getPollQuestions(e:MouseEvent = null):void
		{
			currentType = "poll";
			btnPoll.alpha = 1;
			btnTts.alpha = .36;
			getQuestions();
			
			clearBottomText();
		}
		
		
		private function getTTSQuestions(e:MouseEvent = null):void
		{
			currentType = "tts";
			btnTts.alpha = 1;
			btnPoll.alpha = .36;
			getQuestions();
			
			clearBottomText();
		}
		
		
		private function clearBottomText():void
		{
			qText.text = "";
			r1.text = "";
			r2.text = "";
			r3.text = "";
			r4.text = "";
			r5.text = "";
			a1.text = "";
			a2.text = "";
			a3.text = "";
			a4.text = "";
			a5.text = "";
			chkActive.selected = false;
		}
		
		
		private function getQuestions():void
		{
			questions = new Array();
			loader.addEventListener(Event.COMPLETE, questionsLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError, false, 0, true);			
			loader.dataFormat = URLLoaderDataFormat.TEXT;			
			
			var variables:URLVariables = new URLVariables();                
			variables.type =  currentType;
			
			var req:URLRequest = new URLRequest("http://tmobile.mangoapi.com/getQuestions.php");
			req.data = variables;
			req.method = URLRequestMethod.POST;
			
			loader.load(req);			
		}
		
		
		private function catchIOError(e:IOErrorEvent):void
		{
			loader.removeEventListener(Event.COMPLETE, questionsLoaded);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, catchIOError);
			loader.removeEventListener(Event.COMPLETE, questionUpdated);
			//trace("IOError:",e.text);
		}
		
		
		private function questionsLoaded(e:Event):void
		{	
			loader.removeEventListener(Event.COMPLETE, questionsLoaded);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, catchIOError);
			
			var dp:DataProvider = new DataProvider();
			var recs:Array = e.target.data.split("+++");
			
			for (var i:int = 0; i < recs.length; i++) {
				var rec:String = recs[i];
				var r:Array = rec.split("||");
				//poll: id,question,key1,ans1,key2,ans2,key3,ans3,key4,ans4,key5,ans5,active
				//tts: id,question,active
				if(currentType == "poll"){
					dp.addItem( { id:r[0], question:r[1], k1:r[2], ans1:r[3], k2:r[4], ans2:r[5], k3:r[6], ans3:r[7], k4:r[8], ans4:r[9], k5:r[10], ans5:r[11], active:r[12] } );
				}else {
					dp.addItem( { id:r[0], question:r[1], active:r[2] } );
				}
			}
			
			theGrid.dataProvider = dp;
			theGrid.addEventListener(Event.CHANGE, gridClicked, false, 0, true);			
		}
		
		
		
		private function gridClicked(e:Event):void
		{
			var q:Object = theGrid.selectedItem;
			qText.text = q.question;
			chkActive.selected = q.active == 1 ? true : false;
			
			if(currentType == "poll"){
				r1.text = q.k1;
				a1.text = q.ans1;
				r2.text = q.k2;
				a2.text = q.ans2;
				r3.text = q.k3;
				a3.text = q.ans3;
				r4.text = q.k4;
				a4.text = q.ans4;
				r5.text = q.k5;
				a5.text = q.ans5;
			}			
		}
		
		
		
		private function selectQuestion(e:MouseEvent):void
		{	
			var req:URLRequest = new URLRequest("http://tmobile.mangoapi.com/pollupdate.php");
			
			var variables:URLVariables = new URLVariables();                
			variables.id =  theGrid.selectedItem.id;
			variables.type = currentType;
			req.data = variables;
			req.method = URLRequestMethod.POST; 
			loader.addEventListener(Event.COMPLETE, questionUpdated, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, catchIOError, false, 0, true);
			
			loader.load(req);
		}
		
		private function questionUpdated(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, questionUpdated);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, catchIOError);
			message("question updated");
			if (currentType == "poll"){
				getPollQuestions();
			}else {
				getTTSQuestions();
			}
		}
		
		private function message(m:String):void
		{
			msg.text = m;
			msg.alpha = 1;
			TweenLite.to(msg, 2, { alpha:0, delay:1 } );
		}
	}
	
}