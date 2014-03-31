package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var analyzer:Analyzer;
		private var results:Results;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			intro = new Intro();
			intro.setContainer(this);
			
			analyzer = new Analyzer();
			analyzer.setContainer(this);
			
			results = new Results();
			results.setContainer(this);
			
			init();
		}
		
		private function init():void
		{
			intro.addEventListener(Intro.BEGIN, startAnalyzing, false, 0, true);
			intro.show();
		}
		
		
		private function startAnalyzing(e:Event):void
		{
			intro.removeEventListener(Intro.BEGIN, startAnalyzing);
			
			analyzer.addEventListener(Analyzer.SHOWING, removeIntro, false, 0, true);
			analyzer.addEventListener(Analyzer.COMPLETE, showResults, false, 0, true);
			analyzer.show();
		}
		
		
		private function removeIntro(e:Event):void
		{
			intro.hide();
			analyzer.removeEventListener(Analyzer.SHOWING, removeIntro);
		}
		
		
		private function showResults(e:Event):void
		{
			analyzer.removeEventListener(Analyzer.COMPLETE, showResults);			
			
			results.addEventListener(Results.COMPLETE, reset, false, 0, true);
			results.show(analyzer.getLevel(), analyzer.getLevelPercent());			
		}
		
		
		private function reset(e:Event):void
		{
			analyzer.hide();
			results.hide();
			init();
		}
	}
	
}







