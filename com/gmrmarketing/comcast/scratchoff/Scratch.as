package com.gmrmarketing.comcast.scratchoff
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.events.*;
	import flash.geom.Rectangle;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	
	
	
	public class Scratch extends MovieClip
	{
		//scratch off images
		//private var scratchImage1:triple;
		private var scratchImage1:scratchBlank;
		private var scratchImage2:scratchMouse;
		private var scratchImage3:scratchTV;
		private var scratchImage4:scratchPhone;
		
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
		private var sound:Sound;
		private var soundPlaying:Boolean = false;
		private var lastX:Number = 0;
		
		private var stageRef:Stage;
		
		private var animIcon:MovieClip;
		
		private var num:int;
		
		private var nbaLogo:Bitmap; //bmd in the lib
		private var nbaLogo2:Bitmap;
		
		//white box at 29,170
		
		/**
		 * theme is either sixers, flyers or none
		 * Determines the image used for scratching - basketball, hockey puck, etc.
		 * @param	$gameTheme
		 */
		public function Scratch($stageRef:Stage, $gameTheme:String)
		{
			stageRef = $stageRef;			
			gameTheme = $gameTheme;
			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, clear, false, 0, true);
		}
		
		
		private final function clear(e:Event = null):void
		{
			stageRef.removeEventListener(MouseEvent.MOUSE_DOWN, beginDraw);
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
			removeEventListener(Event.ENTER_FRAME, moveMouse);
			if(channel){
				channel.removeEventListener(Event.SOUND_COMPLETE, soundDone);
			}
		}
		
		
		private final function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			sound = new scratch(); //library sound
			
			scratchedRects = new Array();
			scratchedImages = new Array();
			
			if(diffImage){
				if (contains(diffImage)) {
					removeChild(diffImage);
				}
			}
			
			//add initial scratch image to container
			if (gameTheme == "sixers") {
				addChild(new Bitmap(new circs_bball(1024, 768)));
				nbaLogo = new Bitmap(new nbatv(113, 139));
				nbaLogo2 = new Bitmap(new nbatv(113, 139));
				nbaLogo.x = 318; nbaLogo.y = 412; //596.412
				nbaLogo2.x = 596; nbaLogo2.y = 412;
				nbaLogo.alpha = .8;
				nbaLogo2.alpha = .8;
				addChild(nbaLogo);
				addChild(nbaLogo2);
				gray = new bball(sqSize, sqSize); //library image
			}else if (gameTheme == "flyers") {
				addChild(new Bitmap(new circs_pucks(1024, 768)));
				gray = new puck(sqSize, sqSize); //library image
			}else {
				//generic
				addChild(new Bitmap(new circs_generic(1024, 768)));
				gray = new graycircle(sqSize, sqSize); //library image
			}
			
			//50/50 chance of winning...
			winner = Math.random() < .5 ? true : false;
			//trace("winner:", winner);
			
			sq1 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			sq2 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			sq3 = new BitmapData(sqSize, sqSize, true, 0x00ffffff);
			
			//zeroPoint = new Point(0, 0);
			
			scratchedOffThree = false;
			
			//screen rects of the scratch off boxes
			rectList = new Array(new Rectangle(142, 278, sqSize, sqSize), new Rectangle(422, 278, sqSize, sqSize), new Rectangle(702, 278, sqSize, sqSize),
			new Rectangle(142, 524, sqSize, sqSize), new Rectangle(422, 524, sqSize, sqSize), new Rectangle(702, 524, sqSize, sqSize));
			
			//pushed to in checkRects - contains the rects that are 'dirty' ie scratched or partially scratched
			usedRects = new Array();			
			
			//scratchImage1 = new triple(sqSize, sqSize);
			scratchImage1 = new scratchBlank(sqSize, sqSize);
			scratchImage2 = new scratchMouse(sqSize, sqSize);
			//if(Math.random() < .5){
			scratchImage3 = new scratchTV(sqSize, sqSize);
			//}else {
			scratchImage4 = new scratchPhone(sqSize, sqSize);
			//}
				
			revealImage = new BitmapData(screenWidth, screenHeight, true, 0x00ffffff);

			var sRect:Rectangle = new Rectangle(0, 0, sqSize, sqSize);
			
			//randomize the image positions
			var bitArray:Array = new Array(scratchImage1, scratchImage1, scratchImage1, scratchImage2, scratchImage3, scratchImage4);
			randArray = new Array();
			while (bitArray.length) {
				randArray.push(bitArray.splice(Math.floor(Math.random() * bitArray.length), 1)[0]);
			}
			
			//copy randomized images into reveal image
			for (var i:int = 0; i < 6; i++) {
				var rect:Rectangle = Rectangle(rectList[i]);
				revealImage.copyPixels(randArray[i], sRect, new Point(rect.x, rect.y));
			}
			
			winnerImages = new Array(scratchImage2, scratchImage3, scratchImage4);
			
			drawBmp = new BitmapData(screenWidth, screenHeight, true, 0x00000000);
			
			draw2 = new Sprite();
			draw2.graphics.lineStyle(30, 0x000000);
			lastPoint = new Point(0, 0);
			
			diffBmpData = new BitmapData(screenWidth, screenHeight, true, 0x00ffffff);
			diffImage = new Bitmap(diffBmpData);
			addChild(diffImage);
			
			frameCount = 0;			
			
			stageRef.addEventListener(MouseEvent.MOUSE_DOWN, beginDraw, false, 0, true);			
		}		

		
		/**
		 * Called on mouseDown
		 * @param	e
		 */
		private final function beginDraw(e:MouseEvent):void
		{			
			lastPoint.x = mouseX; lastPoint.y = mouseY;
			draw2.graphics.moveTo(mouseX, mouseY);
			addEventListener(Event.ENTER_FRAME, moveMouse);
			stageRef.addEventListener(MouseEvent.MOUSE_UP, endDraw);
		}

		
		
		private final function endDraw(e:MouseEvent):void
		{			
			//trace("endDraw");
			removeEventListener(Event.ENTER_FRAME, moveMouse);
			stageRef.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
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
		private final function moveMouse(e:Event = null):void
		{
			if(!scratchedOffThree){
				checkRects();
			}else {
				
				if ((scratchedRects[0] == true) && (scratchedRects[1] == true) && (scratchedRects[2] == true)) {
					
					clear(); //remove listeners
					
					
					if(winner){										
						dispatchEvent(new Event("win"));
					}else {
						//any blanks?
						if (scratchedImages[0] != scratchImage1 && scratchedImages[1] != scratchImage1 && scratchedImages[2] != scratchImage1) {
							//no blanks - duplicates
							if (scratchedImages[0] != scratchedImages[1] && scratchedImages[0] != scratchedImages[2] && scratchedImages[1] != scratchedImages[2]) {
								dispatchEvent(new Event("win"));
							}else {
								//duplicates - loser
								dispatchEvent(new Event("lose"));
							}
						} else {
							//had blanks - loser
							dispatchEvent(new Event("lose"));
						}
					}
				}
			}
			
			frameCount++;
			if(frameCount == 3){
				frameCount = 0;
				
				draw2.graphics.lineTo(mouseX, mouseY);
				lastPoint.x = mouseX; lastPoint.y = mouseY;
				
				drawBmp.draw(draw2);							
				
				diffBmpData.copyPixels(revealImage, screenRect, zeroPoint, drawBmp, null, true);
				
				if (!scratchedOffThree) {
					checkRects();
				}				
			}
			
			
			if(usedRects[0] != undefined && scratchedRects[0] != true){
				sq1.copyPixels(diffBmpData, usedRects[0], zeroPoint);
				num = sq1.threshold(sq1, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 20439) {
					scratchedRects[0] = true;
					if (scratchedImages[0] == scratchImage2) {
						checkIcons(2, usedRects[0]);
					}else if (scratchedImages[0] == scratchImage3) {
						checkIcons(3, usedRects[0]);
					}else if (scratchedImages[0] == scratchImage4) {
						checkIcons(4, usedRects[0]);
					}
				}
			}
			
			if(usedRects[1] != undefined && scratchedRects[1] != true){
				sq2.copyPixels(diffBmpData, usedRects[1], zeroPoint);
				num = sq2.threshold(sq2, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 20439) {
					scratchedRects[1] = true;
					if (scratchedImages[1] == scratchImage2) {
						checkIcons(2, usedRects[1]);
					}else if (scratchedImages[1] == scratchImage3) {
						checkIcons(3, usedRects[1]);
					}else if (scratchedImages[1] == scratchImage4) {
						checkIcons(4, usedRects[1]);
					}
				}				
			}
			
			if(usedRects[2] != undefined && scratchedRects[2] != true){
				sq3.copyPixels(diffBmpData, usedRects[2], zeroPoint);
				num = sq3.threshold(sq3, sqRect, zeroPoint, "==", 0x00000000);
				if (num < 20439) {
					scratchedRects[2] = true;
					if (scratchedImages[2] == scratchImage2) {
						checkIcons(2, usedRects[2]);
					}else if (scratchedImages[2] == scratchImage3) {
						checkIcons(3, usedRects[2]);
					}else if (scratchedImages[2] == scratchImage4) {
						checkIcons(4, usedRects[2]);
					}
				}
			}
			
			
			if (!soundPlaying && (lastX != mouseX)) {
				soundPlaying = true;
				lastX = mouseX;
				channel = sound.play();
				channel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0, true);
			}			
			
		}
		
		
		private final function soundDone(e:Event):void
		{
			soundPlaying = false;
		}
		
		
		private final function checkIcons(whichClip:int, whichRect:Rectangle):void
		{			
			var baseX:int = topIcons.x;
			var baseY:int = topIcons.y;
				
			switch(whichClip) {
				case 2:
					animIcon = new iconMouseRed(); //library clip
					addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.internetCover.x + 14, y:baseY + topIcons.internetCover.y + 6, onComplete:killIcon } );
					TweenLite.to(topIcons.internetCover, .5, { alpha:0, delay:.75 } );
					break;
				case 3:
					animIcon = new iconTVRed(); //library clip
					addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.tvCover.x + 14, y:baseY + topIcons.tvCover.y + 6, onComplete:killIcon } );
					TweenLite.to(topIcons.tvCover, .5, { alpha:0, delay:.75 } );
					break;
				case 4:
					animIcon = new iconPhoneRed(); //library clip
					addChild(animIcon);
					animIcon.x = whichRect.left;
					animIcon.y = whichRect.top;
					TweenLite.to(animIcon, .75, { x:baseX + topIcons.phoneCover.x + 14, y:baseY + topIcons.phoneCover.y + 6, onComplete:killIcon } );
					TweenLite.to(topIcons.phoneCover, .5, { alpha:0, delay:.75 } );
					break;
			}
			
		}
		
		
		private final function killIcon():void
		{
			if (contains(animIcon)) {
				removeChild(animIcon);
			}
			
			//if all icons are exposed call moveMouse
			if (topIcons.tvCover.alpha == 0 && topIcons.internetCover.alpha == 0 && topIcons.phoneCover.alpha == 0) {
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
		private final function checkRects():void
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