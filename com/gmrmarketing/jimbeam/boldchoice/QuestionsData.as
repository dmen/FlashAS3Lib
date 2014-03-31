package com.gmrmarketing.jimbeam.boldchoice 
{
	import flash.events.IOErrorEvent;
	import flash.net.*;
	import flash.events.Event;
	import com.gmrmarketing.utilities.Utility; //for randomize array

	public class QuestionsData
	{		
		private var sportsQuestions:XMLList;
		private var musicQuestions:XMLList;
		private var bourbonQuestions:XMLList;
		
		private var sportsIndexes:Array;
		private var musicIndexes:Array;
		private var bourbonIndexes:Array;
		
		private var currentSportsIndex:int;
		private var currentMusicIndex:int;
		private var currentBourbonIndex:int;
		
		
		public function QuestionsData()
		{
			init();
		}
		
		
		public function init():void
		{
			loadQuestions();			
		}
		
		
		/**
		 * Returns the next sports question
		 * @return
		 */
		public function getSportsQuestion():Array
		{
			var ques:Array = new Array();			
			ques.push(sportsQuestions[sportsIndexes[currentSportsIndex]].question);
			ques.push(sportsQuestions[sportsIndexes[currentSportsIndex]].answer.(@correct == "yes"));
			var ans:Array = new Array();
			for(var i:int = 0; i < sportsQuestions[sportsIndexes[currentSportsIndex]].answer.length(); i++){
				ans.push(sportsQuestions[sportsIndexes[currentSportsIndex]].answer[i]);
			}
			ques.push(ans);
			currentSportsIndex++;
			if (currentSportsIndex >= sportsIndexes.length) {
				currentSportsIndex = 0;
			}
			return ques;
		}
		
		
		/**
		 * Returns the next music Question
		 * @return
		 */
		public function getMusicQuestion():Array
		{
			var ques:Array = new Array();
			ques.push(musicQuestions[musicIndexes[currentMusicIndex]].question);
			ques.push(musicQuestions[musicIndexes[currentMusicIndex]].answer.(@correct == "yes"));
			var ans:Array = new Array();
			for(var i:int = 0; i < musicQuestions[musicIndexes[currentMusicIndex]].answer.length(); i++){
				ans.push(musicQuestions[musicIndexes[currentMusicIndex]].answer[i]);
			}
			ques.push(ans);
			currentMusicIndex++;
			if (currentMusicIndex >= musicIndexes.length) {
				currentMusicIndex = 0;
			}
			return ques;
		}
		
		
		public function getBourbonQuestion():Array
		{
			var ques:Array = new Array();
			ques.push(bourbonQuestions[bourbonIndexes[currentBourbonIndex]].question);
			ques.push(bourbonQuestions[bourbonIndexes[currentBourbonIndex]].answer.(@correct == "yes"));
			var ans:Array = new Array();
			for(var i:int = 0; i < bourbonQuestions[bourbonIndexes[currentBourbonIndex]].answer.length(); i++){
				ans.push(bourbonQuestions[bourbonIndexes[currentBourbonIndex]].answer[i]);
			}
			ques.push(ans);
			currentBourbonIndex++;
			if (currentBourbonIndex >= bourbonIndexes.length) {
				currentBourbonIndex = 0;
			}
			return ques;
		}
		
		
		/**
		 * Returns either a sports or a music question
		 * @return
		 */
		public function getBothQuestion():Array
		{
			if (Math.random() < .5) {
				return getMusicQuestion();
			}else {
				return getSportsQuestion();
			}
		}
		
		
		private function loadQuestions():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, sportsLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			loader.load(new URLRequest("questions_sports.xml"));
		}
		
		
		private function sportsLoaded(e:Event):void
		{
			var xml:XML = new XML(e.target.data);	
			sportsQuestions = xml.item;			
			currentSportsIndex = 0;			
			loadMusic();
		}
		
		
		private function loadMusic():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, musicLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			loader.load(new URLRequest("questions_music.xml"));
		}
		
		
		private function musicLoaded(e:Event):void
		{
			var xml:XML = new XML(e.target.data);	
			musicQuestions = xml.item;			
			currentMusicIndex = 0;			
			loadBourbon();
		}
		
		
		private function loadBourbon():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, bourbonLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			loader.load(new URLRequest("questions_bourbon.xml"));
		}
		
		
		private function bourbonLoaded(e:Event):void
		{
			var xml:XML = new XML(e.target.data);	
			bourbonQuestions = xml.item;			
			currentBourbonIndex = 0;			
			randomizeArrays();
		}
		
		
		private function fileNotFound(e:IOErrorEvent):void
		{
			trace("file not found");
		}
		
		
		private function randomizeArrays():void
		{
			musicIndexes = new Array();
			sportsIndexes = new Array();
			bourbonIndexes = new Array();
			
			for (var i:int = 0; i < musicQuestions.length(); i++) {
				musicIndexes.push(i);
			}
			for (var j:int = 0; j < sportsQuestions.length(); j++) {
				sportsIndexes.push(j);
			}
			for (var k:int = 0; k < bourbonQuestions.length(); k++) {
				bourbonIndexes.push(k);
			}
			
			musicIndexes = Utility.randomizeArray(musicIndexes);
			sportsIndexes = Utility.randomizeArray(sportsIndexes);
			bourbonIndexes = Utility.randomizeArray(bourbonIndexes);
		}
	}
	
}