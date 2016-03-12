package com.dmennenoh.lab
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.net.*;
	import flash.ui.Mouse;
	
	
	public class HoloVid extends MovieClip
	{
		private var file:FileReference;
		private var fileLoader:Loader;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var vid:Video;
				
		private var frameData:BitmapData; //sized for displaying
		
		private var topImage:Sprite;
		private var leftImage:Sprite;
		private var bottomImage:Sprite;
		private var rightImage:Sprite;
		
		private var topY:int;
		private var leftX:int;
		private var bottomY:int;
		private var rightX:int;

		private var mat:Matrix;
		
		private var vertCenter:int = 960;
		private var horizCenter:int = 540;
		
		private var leftRightGap:int = 576;
		private var topBottomGap:int = 300;
		
		private var offset:int;
		private var initMouseX:int;
		private var initMouseY:int;
		
		public function HoloVid()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			nc = new NetConnection(); 
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			vid = new Video(1280, 736);//hardcoded for testign with tes_heli.flv on desktop
			vid.attachNetStream(ns);
			//play in memory and image from it...		
			
			frameData = new BitmapData(320, 184, false); //.25 times original size...
			
			topImage = new Sprite();
			var topBmp:Bitmap = new Bitmap(frameData);
			topImage.x = 800;//960-160
			topImage.y = horizCenter - topBottomGap - frameData.height;
			topImage.addChild(topBmp);
			addChild(topImage);
			
			leftImage = new Sprite();
			var leftBmp:Bitmap = new Bitmap(frameData);
			leftImage.x = vertCenter - leftRightGap - frameData.height;
			leftImage.y = 700;//540+160
			leftImage.rotation = -90;//top left goes to bottom left
			leftImage.addChild(leftBmp);
			addChild(leftImage);
			
			bottomImage = new Sprite();
			var botBmp:Bitmap = new Bitmap(frameData);
			bottomImage.x = 1120;//960+160
			bottomImage.y = horizCenter + topBottomGap + frameData.height;
			bottomImage.rotation = -180;//top left to bottom right
			bottomImage.addChild(botBmp);
			addChild(bottomImage);
			
			rightImage = new Sprite();
			var rightBmp:Bitmap = new Bitmap(frameData);
			rightImage.x = vertCenter + leftRightGap + frameData.height;
			rightImage.y = 380;//540-160
			rightImage.rotation = 90;//top left to top right
			rightImage.addChild(rightBmp);
			addChild(rightImage);
			
			mat = new Matrix();
			mat.scale(.25, .25);//scales 1280x736 original to 320x184
			
			rightImage.addEventListener(MouseEvent.MOUSE_DOWN, initLeftRight);
			bottomImage.addEventListener(MouseEvent.MOUSE_DOWN, initTopBottom);
			
			btnOpen.addEventListener(MouseEvent.MOUSE_DOWN, showDialog);
		}
		
		private function initLeftRight(e:MouseEvent):void
		{
			leftX = leftImage.x;
			rightX = rightImage.x;
			offset = mouseX - rightImage.x;
			initMouseX = mouseX;
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving);
			addEventListener(Event.ENTER_FRAME, movingLeftRight);
		}
		
		private function movingLeftRight(e:Event):void
		{
			var delta:int = mouseX - initMouseX;
			leftImage.x = leftX - delta;			
			rightImage.x = rightX + delta;
		}
		
		private function initTopBottom(e:MouseEvent):void
		{
			topY = topImage.y;
			bottomY = bottomImage.y;
			offset = mouseY - bottomImage.y;
			initMouseY = mouseY;
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving);
			addEventListener(Event.ENTER_FRAME, movingTopBottom);
		}
		
		private function movingTopBottom(e:Event):void
		{
			var delta:int = mouseY - initMouseY;	
			topImage.y = topY - delta;
			bottomImage.y = bottomY + delta;
		}
		
		private function stopMoving(e:MouseEvent):void
		{			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMoving);
			removeEventListener(Event.ENTER_FRAME, movingLeftRight);
			removeEventListener(Event.ENTER_FRAME, movingTopBottom);
		}
		
		private function showDialog(event:MouseEvent):void
		{
			file = new FileReference();
			 
			//var fileTypes:FileFilter = new FileFilter("Videos (*.mpg, *.png)", "*.jpg;*.png");
			 
			file.browse();
			file.addEventListener(Event.SELECT, selectFile);
		}
		
		
		private function selectFile(e:Event):void		
		{
			 var file:FileReference = FileReference(e.target);
			 ns.play(file.name);
			 addEventListener(Event.ENTER_FRAME, updateBitmaps, false, 0, true);
		}
		
		
		private function updateBitmaps(e:Event):void
		{
			frameData.draw(vid, mat, null, null, null, true);
		}
		
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void 
		{ 
			// ignore error 
		}
		
	}
	
}