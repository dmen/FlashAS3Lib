package com.gmrmarketing.reeses.scratchgame
{
	import flash.display.*;	
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.events.*;
	import flash.geom.Rectangle;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	public class Scratch extends EventDispatcher
	{
		public static const STARTED:String = "gameStarted";
		public static const WINNER:String = "win";
		public static const LOSER:String = "lose";
		public static const DONE_FADING:String = "doneFading";
		
		//scratch off images		
		private var scratchImage1:BitmapData;
		private var scratchImage2:BitmapData;
		private var scratchImage3:BitmapData;
		private var scratchImage4:BitmapData;
		private var playAgain:BitmapData;
		
		//reveal image contains the scratch images - it is used together with drawBmp as the alpha, to copy
		//pixels into the the diffImage
		private var revealImage:BitmapData;
		
		private var frameCount:int;
		
		//drawBmp is a bitmap that is used to draw the image of the draw2 sprite into
		//that is then used with revealImage (the image containing the icons) to copyPixels into the the diffImage
		private var drawBmp:BitmapData;
		//sprite used for drawing lines into
		private var draw2:Sprite;
		private var lastPoint:Point;
		
		//diffImage is the image seen on stage and is linked to the diffBmpData bitmapData. The image is created by
		//first drawing the vector line data inside draw2 into the drawBmp bitmapData. The drawBmp is then used as the
		//alpha image to copy pixels the revealImage into diffBmpData
		private var diffBmpData:BitmapData;
		private var diffImage:Bitmap;
		
		private var rectList:Array;
		private var usedRects:Array;
		private var scratchedRects:Array;
		private var scratchedImages:Array;
		private var winnerImages:Array; 
		private var randArray:Array; //randomized images
		
		private var r:Rectangle; //predefined for speed - used only in checkRects()		
		
		private var scratchedOffThree:Boolean;		
		
		//gray square - used for copying into the reveal image once three other squares have been scratched in
		private var gray:BitmapData;
		
		//true if the current player is a winner
		private var winner:Boolean;
		
		//used in checkScratched for threshold comparison
		private var sq1:BitmapData;
		private var sq2:BitmapData;
		private var sq3:BitmapData;		
		
		private const sqSize:int = 184;
		private const screenWidth:int = 1024;
		private const screenHeight:int = 768;
		private const zeroPoint:Point = new Point(0, 0);
		private const sqRect:Rectangle = new Rectangle(0, 0, sqSize, sqSize);
		private const screenRect:Rectangle = new Rectangle(0, 0, screenWidth, screenHeight);
		
		private var gameTheme:String;		
		
		private var channel:SoundChannel;
		private var sound:Sound;//scratch sound
		private var bell:Sound;//lib sounds
		private var buzz:Sound;
		private var soundPlaying:Boolean = false;
		private var lastX:int = -1000;
		
		private var animIcon:MovieClip;
		
		private var num:int;
		private var circShadow:DropShadowFilter;
		private var container:DisplayObjectContainer;
		private var topIcons:MovieClip;
		
		private var intro:MovieClip; //instructions dialog
		private var winPercent:Number;
		
		
		//CONSTUCTOR
		public function Scratch(){}
		
		
		public function show($container:DisplayObjectContainer, wp:Number):void
		{	
			container = $container;
			winPercent = wp / 100;
			
			intro = new scratchIntro(); //lib clip
			intro.x = 0;
			intro.y = 755;
			
			container.addChild(intro);
			TweenLite.to(intro, .5, { y:0 } );
			
			intro.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, begin, false, 0, true);
		}
		
		
		/**
		 * Hides everything in the container
		 */
		public function hide():void
		{
			var n:int = container.numChildren;
			for (var i:int = n - 1; i >= 0; i--) {
				TweenLite.to(container.getChildAt(i), .5, { delay:1, overwrite:0, alpha:0, onComplete:killChild, onCompleteParams:[i, DisplayObject(container.getChildAt(i))] } );
			}			
			channel.removeEventListener(Event.SOUND_COMPLETE, soundDone);
		}
		
		
		private function killChild(i:int, c:DisplayObject):void
		{	
			if(container.contains(c)){
				container.removeChild(c);
			}
			if (i == 1) {
				//last item removed
				dispatchEvent(new Event(DONE_FADING));
			}
		}		
		
		
		private function begin(e:MouseEvent):void
		{
			intro.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, begin);			
			TweenLite.to(intro, .5, { y:755, onComplete:init } );			
		}
		
		
		private function init():void
		{
			dispatchEvent(new Event(STARTED));
			
			if (container.contains(intro)) {
				container.removeChild(intro);
			}
			
			circShadow = new DropShadowFilter(0, 0, 0, .2, 5, 5, .3, 2);
			
			topIcons = new topIconsMC(); //lib clip
			topIcons.x = 417;
			topIcons.y = 117;
			//topIcons.filters = [circShadow];
			container.addChild(topIcons);
			
			sound = new scratch(); //library sounds
			bell = new bellSound();//played when a square is complete enough
			buzz = new soundBuzzer();
			
			soundPlaying = false;
			
			scratchedRects = new Array();
			scratchedImages = new Array();
			
			if(diffImage){
				if (container.contains(diffImage)) {
					container.removeChild(diffImage);
				}
			}			
			
			var circles:Bitmap = new Bitmap(new circs(1280, 752));
			//circles.filters = [circShadow];
			container.addChild(circles);
			circles.alpha = 0;
			TweenLite.to(circles, 1, { alpha:1 } );
			
			gray = new circ(sqSize, sqSize); //library image			
			
			winner = Math.random() < winPercent ? true : false;
			
			sq1 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			sq2 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			sq3 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			
			scratchedOffThree = false;
			
			//screen rects of the scratch off boxes
			rectList = new Array(new Rectangle(236, 280, sqSize, sqSize), new Rectangle(546, 280, sqSize, sqSize), new Rectangle(856, 280, sqSize, sqSize),
			new Rectangle(236, 480, sqSize, sqSize), new Rectangle(546, 480, sqSize, sqSize), new Rectangle(856, 480, sqSize, sqSize));
			
			//pushed to in checkRects - contains the rects that are 'dirty' ie scratched or partially scratched
			usedRects = new Array();
			
			scratchImage1 = new blank(sqSize, sqSize);
			scratchImage2 = new logo(sqSize, sqSize);			
			scratchImage3 = new mascot(sqSize, sqSize);
			scratchImage4 = new pbc(sqSize, sqSize);
			playAgain = new playAgainData(sqSize, sqSize);
				
			revealImage = new BitmapData(screenWidth, screenHeight, true, 0x00ffffff);

			var sRect:Rectangle = new Rectangle(0, 0, sqSize, sqSize);
			
			//randomize the image positions
			var bitArray:Array;
			if (winner) {
				bitArray = new Array(scratchImage1, scratchImage1, scratchImage1, scratchImage1, scratchImage1, scratchImage1);
			}else {
				if(Math.random() < .5){
					bitArray = new Array(playAgain, playAgain, playAgain, playAgain, scratchImage2, scratchImage3);
				}else {
					bitArray = new Array(playAgain, playAgain, playAgain, playAgain, scratchImage3, scratchImage4);
				}
			}
			randArray = new Array();
			while (bitArray.length) {
				randArray.push(bitArray.splice(Math.floor(Math.random() * bitArray.length), 1)[0]);
			}
			
			//copy randomized images into reveal image
			for (var i:int = 0; i < 6; i++) {
				var rect:Rectangle = Rectangle(rectList[i]);
				revealImage.copyPixels(randArray[i], sRect, new Point(rect.x, rect.y));
			}
			
			var ra:Array = new Array(scratchImage2, scratchImage3, scratchImage4);
			winnerImages = new Array();
			while (ra.length) {
				winnerImages.push(ra.splice(Math.floor(Math.random() * ra.length), 1)[0]);
			}
			
			drawBmp = new BitmapData(screenWidth, screenHeight, true, 0x00000000);
			
			draw2 = new Sprite();
			draw2.graphics.lineStyle(30, 0x000000);
			lastPoint = new Point(0, 0);
			
			diffBmpData = new BitmapData(screenWidth, screenHeight, true, 0x00ffffff);
			diffImage = new Bitmap(diffBmpData);
			container.addChild(diffImage);
			
			container.stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDraw, false, 0, true);	
			
			frameCount = 0;
		}
		
		
		/**
		 * Called on mouseDown
		 * @param	e
		 */
		private function beginDraw(e:MouseEvent):void
		{			
			lastPoint.x = container.mouseX; lastPoint.y = container.mouseY;
			draw2.graphics.moveTo(container.mouseX, container.mouseY);
			container.addEventListener(Event.ENTER_FRAME, moveMouse);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDraw);
		}

		
		
		private function endDraw(e:MouseEvent):void
		{	
			container.removeEventListener(Event.ENTER_FRAME, moveMouse);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
			if(!scratchedOffThree){
				checkRects();
			}
			if(channel){
				channel.stop();
			}
			soundPlaying = false;
			lastX = -20;
		}
			
		
		
		/**
		 * Called on EnterFrame once the users mouses down and begins to 'scratch'
		 * Draws a line from the last mouse position, to current mouse position every four frames
		 * @param	e
		 */
		private function moveMouse(e:Event = null):void
		{
			if(!scratchedOffThree){
				checkRects();
			}else {
				
				if ((scratchedRects[0] == true) && (scratchedRects[1] == true) && (scratchedRects[2] == true)) {
					
					//remove listeners
					container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, beginDraw);
					container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
					container.removeEventListener(Event.ENTER_FRAME, moveMouse);
					
					if(channel){
						channel.removeEventListener(Event.SOUND_COMPLETE, soundDone);
					}					
					
					if(winner){										
						dispatchEvent(new Event(WINNER));
					}else{						
						dispatchEvent(new Event(LOSER));						
					}
				}
			}
			
			if(usedRects[0] != undefined && scratchedRects[0] != true){
				sq1.copyPixels(diffBmpData, usedRects[0], zeroPoint);
				num = sq1.threshold(sq1, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 25439) {//20439
					scratchedRects[0] = true;
					bell.play();
					if (scratchedImages[0] == scratchImage2) {
						bell.play();
						checkIcons(2, usedRects[0]);
					}else if (scratchedImages[0] == scratchImage3) {
						bell.play();
						checkIcons(3, usedRects[0]);
					}else if (scratchedImages[0] == scratchImage4) {
						bell.play();
						checkIcons(4, usedRects[0]);
					}else {
						buzz.play();
					}
				}
			}
			
			if(usedRects[1] != undefined && scratchedRects[1] != true){
				sq2.copyPixels(diffBmpData, usedRects[1], zeroPoint);
				num = sq2.threshold(sq2, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 25439) {
					scratchedRects[1] = true;
					
					if (scratchedImages[1] == scratchImage2) {
						bell.play();
						checkIcons(2, usedRects[1]);
					}else if (scratchedImages[1] == scratchImage3) {
						bell.play();
						checkIcons(3, usedRects[1]);
					}else if (scratchedImages[1] == scratchImage4) {
						bell.play();
						checkIcons(4, usedRects[1]);
					}else {
						buzz.play();
					}
				}				
			}
			
			if(usedRects[2] != undefined && scratchedRects[2] != true){
				sq3.copyPixels(diffBmpData, usedRects[2], zeroPoint);
				num = sq3.threshold(sq3, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 25439) {
					scratchedRects[2] = true;
					
					if (scratchedImages[2] == scratchImage2) {
						bell.play();
						checkIcons(2, usedRects[2]);
					}else if (scratchedImages[2] == scratchImage3) {
						bell.play();
						checkIcons(3, usedRects[2]);
					}else if (scratchedImages[2] == scratchImage4) {
						bell.play();
						checkIcons(4, usedRects[2]);
					}else {
						buzz.play();
					}
				}
			}			
			//check every 4 frames
			frameCount++;
			//if(frameCount == 1){
				frameCount = 0;
				
				draw2.graphics.lineTo(container.mouseX, container.mouseY);
				lastPoint.x = container.mouseX; lastPoint.y = container.mouseY;
				
				drawBmp.draw(draw2);							
				
				diffBmpData.copyPixels(revealImage, screenRect, zeroPoint, drawBmp, null, true);
				
				if (!scratchedOffThree) {
					checkRects();
				}				
			//}
			//sound done and mouse moved?
			if (!soundPlaying && (lastX != container.mouseX)) {			
				soundPlaying = true;
				lastX = container.mouseX;						
				channel = sound.play();
				channel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0, true);
			}			
		}
		
		
		private function soundDone(e:Event):void
		{
			TweenLite.delayedCall(.1, musicOK);
		}
		private function musicOK():void
		{
			soundPlaying = false;
		}
		
		private function checkIcons(whichClip:int, whichRect:Rectangle):void
		{			
			var baseX:int = topIcons.x;
			var baseY:int = topIcons.y;
			
			switch(whichClip) {
				case 2:
					animIcon = new iconLogo(); //logo
					container.addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.logo.x + 2, y:baseY + topIcons.logo.y + 27, width:86, height:32, onComplete:killIcon } );
					TweenLite.to(topIcons.logo, .5, { alpha:1, delay:.75 } );
					break;
				case 3:
					animIcon = new iconMascot(); //mascot
					container.addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.mascot.x + 10, y:baseY + topIcons.mascot.y + 13, width:72, height:65, onComplete:killIcon } );
					TweenLite.to(topIcons.mascot, .5, { alpha:1, delay:.75 } );
					break;
				case 4:
					animIcon = new iconPBC(); //pbc
					container.addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.pbc.x + 6, y:baseY + topIcons.pbc.y + 14, width:75, height:62, onComplete:killIcon } );
					TweenLite.to(topIcons.pbc, .5, { alpha:1, delay:.75 } );
					break;
			}
		}
		
		
		private function killIcon():void
		{
			if (container.contains(animIcon)) {
				container.removeChild(animIcon);
			}
			
			//if all icons are exposed call moveMouse
			if (topIcons.pbc.alpha == 1 && topIcons.logo.alpha == 1 && topIcons.mascot.alpha == 1) {
				moveMouse();
			}
		}
		
		/**
		 * Called from moveMouse while scratchedOffThree is false
		 * Checks the mouse (finger) position agains the rectList
		 * Removes a rect from rectList once it's been scratched in
		 * If the user is a winner (winner = true) places the triplePlay logo
		 * into the rect being scratched off 
		 * Once three rects have been scratched in sets scratchedOffThree to true
		 * Once scratchedOffThree is true, copies the gray/blanks image into the remaining
		 * rects so that scratching them seems to do nothing
		 */
		private function checkRects():void
		{			
			var num:int;
			
			for (var i:int = 0; i < rectList.length; i++) {		
				sq1 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
				sq1.copyPixels(diffBmpData, rectList[i], zeroPoint);
				num = sq1.threshold(sq1, sqRect, zeroPoint, "==", 0x00000000);
				
				if (num < 33856) {
					//scratched in rect...
					r = Rectangle(rectList[i]);
					//trace("pushing rect to usedRects:", r);
					rectList.splice(i, 1);
					usedRects.push(r);
					
					if (winner) {						
						var curScratch = winnerImages.splice(0, 1)[0];						
						revealImage.copyPixels(curScratch, sqRect, new Point(r.x, r.y));
						scratchedImages.push(curScratch);
						
					}else {						
						var im:BitmapData = randArray.splice(i, 1)[0];
						scratchedImages.push(im); //should match indexes of scratchedRects
					}
					
					//copy gray boxes into the remaining rects so scratching them doesn't do anything
					if (usedRects.length == 3) {
						scratchedOffThree = true;	
						//trace("scratchedOffThree");
						for (var j:int = 0; j < 3; j++) {
							r = Rectangle(rectList[j]);
							//trace("covering three remaining rects:", r);
							revealImage.copyPixels(gray, sqRect, new Point(r.x, r.y));
						}
					}
					break;
				}
			}
				
		}
	
	}	
}