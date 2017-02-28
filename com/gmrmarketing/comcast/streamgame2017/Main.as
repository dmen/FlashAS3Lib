package com.gmrmarketing.comcast.streamgame2017
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import flash.utils.Timer; 
	
	
	public class Main extends MovieClip
	{
		private const speed:int = 5;
		
		private var top:MovieClip;
		private var middle:MovieClip;
		private var bottom:MovieClip;
		private var posTop:Point;
		private var blueRects:Sprite;
		private var visCount:int;		
		
		private var topContainer:Sprite;
		
		private var config:Config;
		private var win:Win;
		private var restartTimer:Timer;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;

			blueRects = new Sprite();
			topContainer = new Sprite();
			
			top = new mcTop();
			middle = new mcMiddle();
			bottom = new mcBottom();
			top.y = 1930;
			addChild(top);
			addChild(middle);
			addChild(bottom);
			
			addChild(blueRects);
			
			addChild(topContainer);
			
			config = new Config();
			config.container = this;
			
			win = new Win();
			win.container = this;			
			
			middle.y = top.y + top.height + 8;
			bottom.y = middle.y + middle.height + 8;	
			
			restartTimer = new Timer(10000, 1);
			restartTimer.addEventListener(TimerEvent.TIMER, doRestart);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
			addEventListener(Event.ENTER_FRAME, scrollUp);
		}
		
		
		private function scrollUp(e:Event):void
		{
			top.y -= speed;
			middle.y -= speed;
			bottom.y -= speed;
			
			if (top.y + top.height + 200 < 0){
				top.y = bottom.y + bottom.height + 8;
			}
			if (middle.y + middle.height + 200< 0){
				middle.y = top.y + top.height + 8;
			}			
			if (bottom.y + bottom.height + 200 < 0){
				bottom.y = middle.y + middle.height + 8;
			}
		}
		
		
		private function checkKey(e:KeyboardEvent):void
		{
			if (e.charCode == 65 || e.charCode == 97){
				//a
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
				removeEventListener(Event.ENTER_FRAME, scrollUp);
				TweenMax.killAll(true);//makes all the sliding anims finish
				
				//find the clips on screen
				var onScreen:Array = [];
				var i:int;
				var n:int;
				var m:DisplayObject;//can be a mask sprite, or an image movie clip
				var pos:Point;
				
				n = top.numChildren;				
				for (i = 0; i < n; i++){
					m = top.getChildAt(i);
					m.alpha = .4;
					if (top.y + m.y > 0 && top.y + m.y + m.height < 1920 && m.name != "mask"){
						//clip on screen
						onScreen.push([m.x, top.y + m.y, m.width, m.height, m]);
					}
				}
				
				n = middle.numChildren;
				for (i = 0; i < n; i++){
					m = middle.getChildAt(i);
					m.alpha = .4;
					if (middle.y + m.y > 0 && middle.y + m.y + m.height < 1920 && m.name != "mask"){
						//clip on screen
						onScreen.push([m.x, middle.y + m.y, m.width, m.height, m]);
					}
				}
				
				n = bottom.numChildren;
				for (i = 0; i < n; i++){
					m = bottom.getChildAt(i);
					m.alpha = .4;
					if (bottom.y + m.y > 0 && bottom.y + m.y + m.height < 1920 && m.name != "mask"){
						//clip on screen
						onScreen.push([m.x, bottom.y + m.y, m.width, m.height, m]);
					}
				}
				
				for (i = 0; i < onScreen.length; i++){
					var a:Array = onScreen[i];
					var s:MovieClip = new MovieClip();
					blueRects.addChild(s);
					s.alpha = 0;
					s.x = a[0];
					s.y = a[1];
					
					//inject the image clip ref - used for fading image alpha with blue rect
					s.image = a[4];
					
					s.graphics.lineStyle(5, 0x00AEEF, 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
					s.graphics.beginFill(0x00AEEF, .8);
					s.graphics.drawRect(0, 0, a[2], a[3]);	
					s.graphics.endFill();
				}
				
				
				//animate the blue rects for a selector looking thingy
				visCount = 0;
				blueOn();
			}else if (e.charCode == 67 || e.charCode == 99){
				showConfig();
			}
		}
		
		
		private function blueOn(e:TimerEvent = null):void
		{	
			var m:MovieClip = blueRects.getChildAt(Math.floor(Math.random() * (blueRects.numChildren -1))) as MovieClip;
			m.alpha = 1;
			m.image.alpha = 1;
			
			visCount++;
			if(visCount < 11){			
				TweenMax.to(m, .2 + (visCount * .05), {alpha:0, onComplete:blueOn});
				TweenMax.to(m.image, .2 + (visCount * .05), {alpha:.4});
			}else{
				
				TweenMax.to(m, .5, {alpha:0});				
				TweenMax.to(m, .5, {alpha:1, delay:.5});
				TweenMax.to(m, .5, {alpha:0, delay:1});
				TweenMax.to(m, .5, {alpha:1, delay:1.5});	
				TweenMax.to(m, .5, {alpha:0, delay:2, onComplete:showWin});
				
			}
		}
		
		
		private function showWin():void
		{
			//done show winner screen
			var n:int = pickStar();
			win.addEventListener(Win.COMPLETE, restartGame, false, 0, true);
			win.show(n);
		}
		
		
		
		private function restartGame(e:Event):void
		{
			win.removeEventListener(Win.COMPLETE, restartGame);
			//start 20 second timer - and listen for A press again
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkRestart, false, 0, true);
			restartTimer.reset();
			restartTimer.start();
		}
		
		private function checkRestart(e:KeyboardEvent):void
		{
			if (e.charCode == 65 || e.charCode == 97){
				doRestart();
			}
		}
		
		private function doRestart(e:TimerEvent = null):void
		{
			restartTimer.reset();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRestart);
			win.hide();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
			addEventListener(Event.ENTER_FRAME, scrollUp);
			
			while (blueRects.numChildren){
				blueRects.removeChildAt(0);
			}
			
			var n:int;
			var i:int;
			var m:DisplayObject;
			n = top.numChildren;				
			for (i = 0; i < n; i++){
				m = top.getChildAt(i);
				m.alpha = 1;
			}
			n = middle.numChildren;				
			for (i = 0; i < n; i++){
				m = middle.getChildAt(i);
				m.alpha = 1;
			}
			n = bottom.numChildren;				
			for (i = 0; i < n; i++){
				m = bottom.getChildAt(i);
				m.alpha = 1;
			}
		}
		
		
		private function pickStar():int
		{
			var n:Number = Math.random();
			var percents:Array = config.data;
			
			if (percents[0] == 1){
				return 3;
			}else if (percents[1] == 1){
				return 2;
			}else if (percents[0] == 0 && percents[1] == 0){
				return 1;
			}
			
			if (percents[0] + percents[1] == 1){
				//no chance of one stars
				if (n < percents[0]){
					return 3;
				}else{
					return 2;
				}
			}			
			
			if (n < percents[0]){
				return 3;
			}else if (n < percents[1]){
				return 2;
			}else{
				return 1;
			}
		}
		
		
		private function showConfig():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKey);
			config.addEventListener(Config.CLOSED, relisten, false, 0, true);
			config.show();
		}
		
		
		private function relisten(e:Event):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKey, false, 0, true);
		}
		
	}
	
}