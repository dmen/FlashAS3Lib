package com.gmrmarketing.pm.quickdraw
{
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.text.TextFieldAutoSize;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	
	
	public class LevelOne extends MovieClip
	{
		
		private var w:Sprite;
		private var sPoint:Point;
		private var timers:Array;
		private var dialog:timeDialog; //lib clip
		private var tb:tombstoneBroken;
		private var targets:Array;
		
		private var channel:SoundChannel; //for playing sounds
		
		public const LEVEL_COMPLETE:String = "theLevelIsFinished";
		
		
		public function LevelOne()
		{
			w = new Sprite(); //holds web when spider is on screen
			
			timers = new Array();
			
			bg.addChild(w);
			
			w.mask = bg.webMask;
			bg.spider.mask = bg.spiderMask;
			bg.tombstone.mask = bg.tombstoneMask;
			bg.monster.mask = bg.monsterMask;
			
			targets = new Array();
			
			sPoint = new Point(bg.spider.x, bg.spider.y);
			
			//start();
		}
		
		public function start():void
		{
			TweenMax.to(bg,60,{width:1700,height:1000});
			TweenMax.to(bg.spider,2,{onStart:startSpiderTimer, y:-40, delay:2, onUpdate:drawWeb, onComplete:removeSpider});
			TweenMax.to(bg.ghost,3,{onStart:startGhostTimer, scaleX:1.3, scaleY:1.3, alpha:.8, delay:8, onComplete:removeGhost});
			TweenMax.to(bg.tombstone, .25, {onStart:startTombstoneTimer,  y:190, delay:13, onComplete:removeTombstone } );
			TweenMax.to(bg.monster, .2, {onStart:startMonsterTimer, y: -123, delay:17, onComplete:removeMonster } );
		}
		
		public function doPause():void
		{
			TweenMax.pauseAll();
		}
		
		public function doResume():void
		{
			TweenMax.resumeAll();
		}
		
		public function startSpiderTimer():void
		{			
			targets = new Array(bg.spider);
			timers[0] = getTimer();
		}
		public function startGhostTimer():void
		{			
			targets = new Array(bg.ghost);
			timers[1] = getTimer();
		}
		public function startTombstoneTimer():void
		{			
			targets = new Array(bg.tombstone);
			timers[2] = getTimer();
		}
		public function startMonsterTimer():void
		{			
			targets = new Array(bg.monster);
			timers[3] = getTimer();
		}
		
		public function getTargets():Array
		{
			return targets;
		}
		
		public function shoot(targetName:String):void
		{
			switch(targetName) {
				case "spider":
					shootSpider();
					break;
				case "ghost":
					shootGhost();
					break;
				case "tombstone":
					shootTombstone();
					break;
				case "monster":
					shootMonster();
					break;
			}
		}
		
		private function drawWeb():void
		{	
			w.graphics.clear();
			w.graphics.moveTo(sPoint.x, sPoint.y);
			w.graphics.lineStyle(1,0x444444,1);
			w.graphics.lineTo(bg.spider.x, bg.spider.y);
		}

		private function removeSpider():void
		{	
			TweenMax.to(bg.spider,1,{y:-542, delay:2, onUpdate:drawWeb, onComplete:killSpider});
		}
		
		private function killSpider():void
		{
			timers[0] = getTimer() - timers[0];
			bg.removeChild(bg.spider);
		}
		
		private function killSpider2():void
		{			
			bg.removeChild(bg.spider);
		}
		
		public function shootSpider():void
		{
			var aSound:spiderSound = new spiderSound();				
			channel = aSound.play();
			
			TweenMax.killTweensOf(bg.spider);
			timers[0] = getTimer() - timers[0];
			w.graphics.clear();
			bg.spider.mask = null;
			bg.removeChild(bg.spiderMask);
			var rx:int = -270 + Math.random() * 400; //back of tunnel
			var ry:int = -245 + Math.random() * 350;
			var r:int = 180 + Math.random() * 300;
			if (Math.random() < .5) {
				r *= -1;
			}
			TweenMax.to(bg.spider, 1, { scaleX:.25, scaleY:.25, x:rx, y:ry, rotation:r, alpha:0, onComplete:killSpider2 } );
		}
		
		private function removeGhost():void
		{	
			TweenMax.to(bg.ghost,1,{scaleX:3, scaleY:3, y:"100",alpha:0, onComplete:killGhost});
		}
		
		private function killGhost():void
		{
			timers[1] = getTimer() - timers[1];
			bg.removeChild(bg.ghost);
		}
		
		private function killGhost2():void
		{			
			bg.removeChild(bg.ghost);
		}
		
		public function shootGhost():void
		{
			var aSound:ghostSound = new ghostSound();				
			channel = aSound.play();
			
			TweenMax.killTweensOf(bg.ghost);
			timers[1] = getTimer() - timers[1];			
			var rx:int = -270 + Math.random() * 400; //back of tunnel
			var ry:int = -245 + Math.random() * 350;
			var r:int = 180 + Math.random() * 300;
			if (Math.random() < .5) {
				r *= -1;
			}
			TweenMax.to(bg.ghost, 1, { scaleX:.75, scaleY:.75, x:rx, y:ry, rotation:r, alpha:0, onComplete:killGhost2 } );
		}
		
		private function removeTombstone():void
		{
			TweenMax.to(bg.tombstone, .25, {y:465, delay:2, onComplete:killTombstone});
		}
		
		private function killTombstone():void
		{
			timers[2] = getTimer() - timers[2];
			bg.removeChild(bg.tombstone);
		}
		
		public function shootTombstone():void
		{
			var aSound:tombSound = new tombSound();				
			channel = aSound.play();
			
			TweenMax.killTweensOf(bg.tombstone);
			timers[2] = getTimer() - timers[2];
			tb = new tombstoneBroken();
			tb.x = bg.tombstone.x;
			tb.y = bg.tombstone.y;
			bg.removeChild(bg.tombstone);
			bg.addChild(tb);			
		}
				
		private function removeMonster():void
		{
			TweenMax.to(bg.monster, .25, {y:-417, delay:2, onComplete:killMonster});
		}
		
		private function killMonster():void
		{
			timers[3] = getTimer() - timers[3];
			bg.removeChild(bg.monster);
			dispatchEvent(new Event(LEVEL_COMPLETE));
		}
		
		private function killMonster2():void
		{			
			bg.removeChild(bg.monster);
			dispatchEvent(new Event(LEVEL_COMPLETE));
		}
		
		public function shootMonster():void
		{
			var aSound:monsterSound = new monsterSound();				
			channel = aSound.play();
			
			TweenMax.killTweensOf(bg.monster);
			timers[3] = getTimer() - timers[3];
			TweenMax.to(bg.monster, .5, { rotationX: -90, alpha:0, onComplete:killMonster2 } );
		}
		
		public function addTimes(numShots:int):void
		{
			dialog = new timeDialog();
			dialog.theText.autoSize = TextFieldAutoSize.LEFT;
			dialog.x = 650;
			dialog.y = 127;
			
			var acc:int = Math.floor(4 / numShots * 100); //four monsters...
			
			var n1:String = String(timers[0] / 1000).substr(0, 4);
			var n2:String = String(timers[1] / 1000).substr(0, 4);
			var n3:String = String(timers[2] / 1000).substr(0, 4);
			var n4:String = String(timers[3] / 1000).substr(0, 4);
			var t:String = String((timers[0] / 1000) + ( timers[1] / 1000) + ( timers[2] / 1000) + ( timers[3] / 1000)).substr(0, 4);
			
			var s:String = "Spider:  " + n1 + "<br/>Ghost: " + n2
			s += "<br/>Tombstone: " + n3 + "<br/>Monster: " + n4;
			s += "<br/>Total: " + t;
			s += "<br/>Accuracy: " + acc + "%";
			
			dialog.theText.htmlText = s;
			addChild(dialog);
		}
	}
	
}