/**
 * Bottom nav controller
 * 
 * Update 11/2012
 * 		removed road ahead
 */
package com.gmrmarketing.indian.heritage_updates
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class MainMenu extends EventDispatcher	
	{
		public static const ITEM_PICKED:String = "menuItemPicked";
		
		private var clip:MovieClip;
		private var bgClip:MovieClip;
		private var items:Array;
		private var btns:Array;
		private var container:DisplayObjectContainer;
		private var selectedIndex:int;
		private var bgShowing:Boolean;
		private var bgPics:Array;
		private var picLocs:Array;
		private var randomPics:Array;
		private var randomIndex:int;
		
		public function MainMenu()
		{
			items = new Array("heritage", "innovation", "racing", "scout", "war", "faithful");
			
			clip = new bottomMenu(); //lib clip
			clip.x = 0;
			clip.y = 1080 - clip.height;
			
			bgClip = new menuScreen2(); //lib clip
			picLocs = new Array([bgClip.b1.x,bgClip.b1.y], [bgClip.b2.x, bgClip.b2.y], [bgClip.b3.x, bgClip.b3.y], [bgClip.b4.x,bgClip.b4.y], [bgClip.b5.x, bgClip.b5.y], [bgClip.b6.x, bgClip.b6.y]);
			
			
			btns = new Array(clip.heritage, clip.innovation, clip.racing, clip.scout, clip.war, clip.faithful);
			
			bgShowing = true;
		}
		
		
		
		public function show($container:DisplayObjectContainer):void
		{			
			container = $container;
			
			if (!container.contains(clip)) {
				container.addChild(bgClip);
				container.addChild(clip);
			}
			
			bgShowing = true;
			bgPics = new Array(bgClip.b1, bgClip.b2, bgClip.b3, bgClip.b4, bgClip.b5, bgClip.b6);
			
			for (var i:int = 0; i < bgPics.length; i++) {
				bgPics[i].x = picLocs[i][0];
				bgPics[i].y = picLocs[i][1];
			}
			
			clip.b1.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b2.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b3.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b4.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b5.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			clip.b6.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);			
			
			bgClip.b1.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b2.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b3.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b4.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b5.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			bgClip.b6.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);	
			
			TweenMax.from(bgClip.b1, 1, { x:getRandomX(), y:getRandomY() } );
			TweenMax.from(bgClip.b2, 1, { x:getRandomX(), y:getRandomY() } );
			TweenMax.from(bgClip.b3, 1, { x:getRandomX(), y:getRandomY() } );
			TweenMax.from(bgClip.b4, 1, { x:getRandomX(), y:getRandomY() } );
			TweenMax.from(bgClip.b5, 1, { x:getRandomX(), y:getRandomY() } );
			TweenMax.from(bgClip.b6, 1, { x:getRandomX(), y:getRandomY() } );
			
			bgClip.blankPics.alpha = 0;
			TweenMax.to(bgClip.blankPics, 2, { alpha:1, delay:1, onComplete:startScaling } );
		}
		
		
		private function getRandomX():int
		{
			var m;
			if (Math.random() < .5) {
				m = 960 - Math.random() * 1920;
			}else {
				m = 960 + Math.random() * 1920;
			}
			return Math.floor(m);
		}
		
		
		private function getRandomY():int
		{
			var m;
			if (Math.random() < .5) {
				m = 540 - Math.random() * 1080;
			}else {
				m = 540 + Math.random() * 1080;
			}
			return Math.floor(m);
		}
		
		private function startScaling():void
		{
			randomIndex = -1;
			randomPics = new Array();
			while (bgPics.length) {
				randomPics.push(bgPics.splice(Math.floor(Math.random() * bgPics.length), 1)[0]);
			}
			nextScale();
		}
		private function nextScale():void
		{
			randomIndex++;
			if (randomIndex >= randomPics.length) {
				randomIndex = 0;
			}
			TweenMax.to(randomPics[randomIndex], .5, { scaleX:1.5, scaleY:1.5, ease:Back.easeOut } );
			TweenMax.to(MovieClip(randomPics[randomIndex]).ctb, 1, { alpha:1, delay:.25, onComplete:unScale } );			
		}
		private function unScale():void
		{
			TweenMax.to(randomPics[randomIndex], .5, { scaleX:1, scaleY:1, delay:2, ease:Back.easeOut } );
			TweenMax.to(MovieClip(randomPics[randomIndex]).ctb, .5, { alpha:0, delay:2, onComplete:nextScale } );	
		}
		
		/*
		private function startFloating():void		
		{
			for (var i:int = 0; i < 6; i++){
				var cx:Number = Math.cos(Math.random() * 6.28) * 9 + bgPics[i][1];
				var cy:Number = Math.sin(Math.random() * 6.28) * 9 + bgPics[i][2];
				TweenMax.to(bgPics[i][0], 1 + Math.random() * 2, {x:cx, y:cy, ease:Sine.easeInOut, onComplete:nextFloat, onCompleteParams:[i]});
			}
		}
		
		private function nextFloat(i:int):void
		{
			var cx:Number = Math.cos(Math.random() * 6.28) * 9 + bgPics[i][1];
			var cy:Number = Math.sin(Math.random() * 6.28) * 9 + bgPics[i][2];
			TweenMax.to(bgPics[i][0], 1 + Math.random() * 2, {x:cx, y:cy, ease:Sine.easeInOut, onComplete:nextFloat, onCompleteParams:[i]});
		}
		
		*/
		
		public function hide():void
		{			
			TweenMax.killAll();
			
			for (var i:int = 0; i < randomPics.length; i++) {
				randomPics[i].scaleX = randomPics[i].scaleY = 1;
				MovieClip(randomPics[i]).ctb.alpha = 0;
			}
			
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
					container.removeChild(bgClip);
				}
			}
			
			bgShowing = false;
			
			clip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			clip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);			
			
			bgClip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);			
		}
		
		
		public function hideBG():void
		{
			TweenMax.killAll();
			
			for (var i:int = 0; i < randomPics.length; i++) {
				randomPics[i].scaleX = randomPics[i].scaleY = 1;
				MovieClip(randomPics[i]).ctb.alpha = 0;
			}
			
			if(container){
				if (container.contains(bgClip)) {
					container.removeChild(bgClip);
				}
			}
			
			bgShowing = false;
			
			bgClip.b1.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b2.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b3.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b4.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b5.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			bgClip.b6.removeEventListener(MouseEvent.MOUSE_DOWN, itemClicked);			
		}
		
		
		public function isBGShowing():Boolean
		{
			return bgShowing;
		}
		
		
		public function reset():void
		{			
			for (var i:int = 0; i < btns.length; i++) {				
				TweenMax.to(btns[i], 0, { removeTint:true } );				
			}
		}
		
		
		public function getSelection():String
		{
			return items[selectedIndex];
		}
		
		
		private function itemClicked(e:MouseEvent):void
		{
			var m:MovieClip = MovieClip(e.currentTarget);
			selectedIndex = parseInt(String(m.name).substr(1, 1)); //1 - 9
			selectedIndex--; //for array index
			
			reset();
			
			//highlight new one
			TweenMax.to(btns[selectedIndex], 1, { tint:0xffffff } );
			
			dispatchEvent(new Event(ITEM_PICKED));//calls mainMenuSelection() in Main
		}
		
		
	}
	
}