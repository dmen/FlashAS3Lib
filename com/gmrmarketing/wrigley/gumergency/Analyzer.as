package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	
	
	public class Analyzer extends EventDispatcher
	{
		public static const SHOWING:String = "analyzerShowing";
		public static const COMPLETE:String = "analyzerComplete";
		
		//breathline containers
		private var bc1:Sprite;
		private var bc2:Sprite;
		private var bc3:Sprite;
		
		//bg vertical lines container
		private var vlc:Sprite;
		private var vlines:VLines;
		
		//tick line container
		private var tc:Sprite;
		
		//breath lines
		private var bl1:BreathLine;
		private var bl2:BreathLine;
		private var bl3:BreathLine;
		
		//tick lines
		private var tick1:TickLine;
		private var tick2:TickLine;
		private var tick3:TickLine;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var level:int; //1,2,3
		private var theX:int;//x loc where the mask stops within the level
		
		
		public function Analyzer()
		{
			clip = new mcAnalyzer();
			
			bc1 = new Sprite();
			bc2 = new Sprite();
			bc3 = new Sprite();
			vlc = new Sprite();
			tc = new Sprite();
			
			clip.addChild(vlc);
			clip.addChild(bc1);
			clip.addChild(bc2);
			clip.addChild(bc3);
			clip.addChild(tc);
			
			vlines = new VLines();
			vlines.setContainer(vlc);
			vlines.show();
			
			bl1 = new BreathLine();
			bl1.init(bc1, 0x00a5d3);			

			bl2 = new BreathLine();
			bl2.init(bc2, 0xffffff);			

			bl3 = new BreathLine();
			bl3.init(bc3, 0x045f9);

			tick1 = new TickLine();
			tick1.setContainer(tc);
			tick1.show();
			tick2 = new TickLine();
			tick2.setContainer(tc);
			tick2.show();
			tick3 = new TickLine();
			tick3.setContainer(tc);
			tick3.show();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			clip.textBegin.alpha = 1;
			clip.excel.alpha = 1;
			
			//puts excel logo over the vLines
			clip.setChildIndex(clip.excel, clip.numChildren - 1);
			
			clip.analyzing.alpha = 0;
			clip.smallExcel.alpha = 0;
			
			clip.theMask.x = -1952;
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
			
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, analyze, false, 0, true);
			
			bl1.startDrawing();
			bl2.startDrawing();
			bl3.startDrawing();			
		}
		
		
		public function hide():void
		{
			container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, analyze);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}	
		
		
		private function analyze(e:KeyboardEvent):void
		{
			if (Keys.KEYS.indexOf(e.charCode) != -1) {
				container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, analyze);
				
				bl1.analyze();
				bl2.analyze();
				bl3.analyze();
				
				//start ruler ticks moving
				tick1.analyze();
				tick2.analyze();
				tick3.analyze();
				
				vlines.start();
				
				TweenMax.to(clip.textBegin, 1, { alpha:0 } );
				TweenMax.to(clip.excel, 1, { alpha:0 } );
				TweenMax.to(clip.smallExcel, 1, { alpha:1 } );
				
				fadeAnalyzingIn();
				
				//decide the breathcon level
				level = Math.floor(1 + Math.random() * 3); //1 - 3
				//pick random location within the level
				
				if (level == 1) {				
					theX = -1952 + Math.floor(40 + Math.random() * 604);
					TweenMax.to(clip.theMask, 4, { x:theX, onComplete:analyzingFinished } );
				}else {
					TweenMax.to(clip.theMask, 4, { x: -1308, onComplete:l2 } );
				}
			}
		}
		
		private function fadeAnalyzingOut():void
		{
			TweenMax.to(clip.analyzing, .5, { alpha:0, onComplete:fadeAnalyzingIn } );
		}
		
		private function fadeAnalyzingIn():void
		{
			TweenMax.to(clip.analyzing, .5, { alpha:1, onComplete:fadeAnalyzingOut } );
		}

		
		private function l2():void
		{
			bl1.setLevel(10);
			bl2.setLevel(10);
			bl3.setLevel(10);
			
			if (level == 2) {				
				theX = -1308 + Math.floor(Math.random() * 642);
				TweenMax.to(clip.theMask, 4, { x:theX, onComplete:analyzingFinished } );
			}else {
				TweenMax.to(clip.theMask, 4, { x: -666, onComplete:l3 } );
			}		
		}
		
		private function l3():void
		{			
			bl1.setLevel(18);
			bl2.setLevel(18);
			bl3.setLevel(18);
			theX = -666 + Math.floor(Math.random() * 646);
			TweenMax.to(clip.theMask, 4, { x:theX, onComplete:analyzingFinished } );					
		}
		
		public function getLevel():int
		{
			return level;
		}
		
		public function getLevelPercent():Number
		{
			//theX is position of mask in the level box
			var delta:int;
			if (level == 1) {
				delta = theX + 1952; //gets 0 - 646
			}else if (level == 2) {
				delta = theX + 1308; //gets 0 - 646
			}else {
				delta = theX + 666; //gets 0 - 646
			}
			 
			return delta / 644; //returns 0 - 1
		}
		
		
		private function analyzingFinished():void
		{
			bl1.stop();
			bl2.stop();
			bl3.stop();
			tick1.stop();
			tick2.stop();
			tick3.stop();
			vlines.stop();
			TweenMax.killTweensOf(clip.analyzing);
			TweenMax.killTweensOf(clip.theMask);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}







