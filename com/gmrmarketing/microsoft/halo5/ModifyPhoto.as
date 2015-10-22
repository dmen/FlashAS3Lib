package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import com.greensock.plugins.*;
	import flash.filters.BlurFilter;
	
	public class ModifyPhoto extends EventDispatcher
	{
		public static const COMPLETE:String = "modifyComplete";
		public static const RETAKE:String = "retakeImage";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var photo:Bitmap;//user image scaled to 1920x1080
		private var originalPhoto:BitmapData;//original 1280x720		
		
		private var headPoints:MovieClip;		
		private var g:Graphics; //headPoints.graphics ref - for drawing lines through handles
		
		private var mask:Bitmap;//actual mask for user image- maskSprite is drawn into this per frame
		private var maskData:BitmapData;
		private var maskSprite:Sprite;
		private var msg:Graphics;//ref to maskSprite.graphics
		
		private var blur:BlurFilter;
		private var handles:Array;
		private var frameCounter:int;
		
		
		public function ModifyPhoto()
		{
			/*headPoints = new mcHeadPoints();//library movieClip with handles h1-h8 - has 1280x720 frame
			headPoints.x = 440;
			headPoints.y = 150;*/
			
			
			
			
			maskSprite = new Sprite();	//draw into this and then image it into the mask Bitmap
			msg = maskSprite.graphics;
			
			/*maskData = new BitmapData(1280, 720, true, 0x00FF0000);
			mask = new Bitmap(maskData);
			mask.x = 440;
			mask.y = 150;*/
			maskData = new BitmapData(1920, 1080, true, 0x00FF0000);
			mask = new Bitmap(maskData);
			mask.x = 124;
			mask.y = 132;
			
			clip = new mcModify();//currently empty...
			
			blur = new BlurFilter(6, 6, 2);//applied to maskData
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	p User Photo - 1280x720
		 */
		public function show(p:BitmapData):void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}			
			
			originalPhoto = p;
			
			//scale the 1280x720 original to 1920x1080 for working
			var a:BitmapData = new BitmapData(1920, 1080);
			var m:Matrix = new Matrix();
			m.scale(1.5, 1.5);
			a.draw(p, m, null, null, null, true);
			
			//photo = new Bitmap(p);
			//photo.x = 440;
			//photo.y = 150;
			photo = new Bitmap(a);
			photo.x = 132;
			photo.y = 124;
			clip.addChild(photo);
			
			clip.addChild(mask);//the Bitmap
			photo.cacheAsBitmap = true;
			photo.mask = mask;
			mask.cacheAsBitmap = true;
			
			headPoints = new mcHeadPoints1920();//library movieClip with handles h1-h8 - has 1280x720 frame
			headPoints.x = 124;
			headPoints.y = 132;
			g = headPoints.graphics;//ref for line drawing in drwLines()
			handles = [headPoints.h1, headPoints.h2, headPoints.h3, headPoints.h4, headPoints.h5, headPoints.h6, headPoints.h7, headPoints.h8, headPoints.h9, headPoints.h10, headPoints.h11];
			
			clip.addChild(headPoints);//the handles and drawn lines
			headPoints.h1.addEventListener(MouseEvent.MOUSE_DOWN, dragH1, false, 0, true);
			headPoints.h2.addEventListener(MouseEvent.MOUSE_DOWN, dragH2, false, 0, true);
			headPoints.h3.addEventListener(MouseEvent.MOUSE_DOWN, dragH3, false, 0, true);
			headPoints.h4.addEventListener(MouseEvent.MOUSE_DOWN, dragH4, false, 0, true);
			headPoints.h5.addEventListener(MouseEvent.MOUSE_DOWN, dragH5, false, 0, true);
			headPoints.h6.addEventListener(MouseEvent.MOUSE_DOWN, dragH6, false, 0, true);
			headPoints.h7.addEventListener(MouseEvent.MOUSE_DOWN, dragH7, false, 0, true);
			headPoints.h8.addEventListener(MouseEvent.MOUSE_DOWN, dragH8, false, 0, true);
			headPoints.h9.addEventListener(MouseEvent.MOUSE_DOWN, dragH9, false, 0, true);
			headPoints.h10.addEventListener(MouseEvent.MOUSE_DOWN, dragH10, false, 0, true);
			headPoints.h11.addEventListener(MouseEvent.MOUSE_DOWN, dragH11, false, 0, true);
			
			for (var i:int = 0; i < 11; i++) {	
				//handles[i].grip.rotation = Math.atan2(335 - handles[i].y, 600 - handles[i].x) * 57.295;
				handles[i].grip.rotation = Math.atan2(540 - handles[i].y, 960 - handles[i].x) * 57.295;
			}
			frameCounter = 0;
			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePic, false, 0, true);
			clip.btnComplete.addEventListener(MouseEvent.MOUSE_DOWN, picComplete, false, 0, true);
			
			clip.addEventListener(Event.ENTER_FRAME, drawLines, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			if (clip.contains(mask)) {
				clip.removeChild(mask);
				clip.removeChild(photo);
			}
			
			if (clip.contains(headPoints)) {
				clip.removeChild(headPoints);
			}
			
			headPoints.h1.removeEventListener(MouseEvent.MOUSE_DOWN, dragH1);
			headPoints.h2.removeEventListener(MouseEvent.MOUSE_DOWN, dragH2);
			headPoints.h3.removeEventListener(MouseEvent.MOUSE_DOWN, dragH3);
			headPoints.h4.removeEventListener(MouseEvent.MOUSE_DOWN, dragH4);
			headPoints.h5.removeEventListener(MouseEvent.MOUSE_DOWN, dragH5);
			headPoints.h6.removeEventListener(MouseEvent.MOUSE_DOWN, dragH6);
			headPoints.h7.removeEventListener(MouseEvent.MOUSE_DOWN, dragH7);
			headPoints.h8.removeEventListener(MouseEvent.MOUSE_DOWN, dragH8);
			headPoints.h9.removeEventListener(MouseEvent.MOUSE_DOWN, dragH9);
			headPoints.h10.removeEventListener(MouseEvent.MOUSE_DOWN, dragH10);
			headPoints.h11.removeEventListener(MouseEvent.MOUSE_DOWN, dragH11);
			
			headPoints = null;
			
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePic);
			clip.btnComplete.removeEventListener(MouseEvent.MOUSE_DOWN, picComplete);			
			clip.removeEventListener(Event.ENTER_FRAME, drawLines);
		}
		
		public function suspend():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, drawLines);			
		}
		
		public function wake():void
		{
			clip.addEventListener(Event.ENTER_FRAME, drawLines, false, 0, true);
		}
		
		
		public function get headImage():BitmapData
		{
			var smallMask:BitmapData = new BitmapData(1280, 720, true, 0x00000000);
			var m:Matrix = new Matrix();
			m.scale(0.6666666666666667, 0.6666666666666667);
			smallMask.draw(maskData, m, null, null, null, true);
			
			var a:BitmapData = new BitmapData(1280, 720, true, 0x00000000);
			//a.copyPixels(originalPhoto, new Rectangle(0, 0, 1280, 720), new Point(0, 0), maskData, new Point(0, 0), true);
			a.copyPixels(originalPhoto, new Rectangle(0, 0, 1280, 720), new Point(0, 0), smallMask, new Point(5, 0), true);
			return a;
		}
		
		
		private function retakePic(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function picComplete(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function drawLines(e:Event):void
		{	
			var i:int;
			
			frameCounter++;
			if(frameCounter % 10 == 0){
				for (i = 0; i < 11; i++) {	
					//handles[i].grip.rotation = Math.atan2(335 - handles[i].y, 600 - handles[i].x) * 57.295;
					handles[i].grip.rotation = Math.atan2(540 - handles[i].y, 960 - handles[i].x) * 57.295;
				}
			}
	
			msg.clear();
			msg.beginFill(0x00ff00, 1);
			
			g.clear();			
			g.lineStyle(.5, 0x999999);
			
			var beziers:Object = BezierPlugin.bezierThrough([ { x:headPoints.h1.x, y:headPoints.h1.y }, { x:headPoints.h2.x, y:headPoints.h2.y }, { x:headPoints.h3.x, y:headPoints.h3.y }, { x:headPoints.h4.x, y:headPoints.h4.y },{ x:headPoints.h5.x, y:headPoints.h5.y },{ x:headPoints.h6.x, y:headPoints.h6.y },{ x:headPoints.h7.x, y:headPoints.h7.y },{ x:headPoints.h8.x, y:headPoints.h8.y },{ x:headPoints.h9.x, y:headPoints.h9.y },{ x:headPoints.h10.x, y:headPoints.h10.y }, { x:headPoints.h11.x, y:headPoints.h11.y }, { x:headPoints.h1.x, y:headPoints.h1.y }], 1, true);
			var bx:Array = beziers.x; //the "x" Beziers
			var by:Array = beziers.y; //the "y" Beziers
			
			g.moveTo(bx[0].a, by[0].a);
			msg.moveTo(bx[0].a, by[0].a);
			
			for (i = 0; i < bx.length; i++) {
				g.curveTo(bx[i].b, by[i].b, bx[i].c, by[i].c);
				msg.curveTo(bx[i].b, by[i].b, bx[i].c, by[i].c);
			}
			
			msg.endFill();
			
			/*maskData = new BitmapData(1280, 720, true, 0x00FF0000);
			mask.bitmapData = maskData;
			maskData.draw(maskSprite, null, null, null, null, true);
			maskData.applyFilter(mask.bitmapData, new Rectangle(0, 0, 1280, 720), new Point(0,0), blur);*/
			maskData = new BitmapData(1920, 1080, true, 0x00FF0000);
			mask.bitmapData = maskData;
			maskData.draw(maskSprite, null, null, null, null, true);
			maskData.applyFilter(mask.bitmapData, new Rectangle(0, 0, 1920, 1080), new Point(0,0), blur);
		}
		
		
		private function dragH1(e:MouseEvent):void
		{	
			headPoints.h1.startDrag();
		}
		
		private function dragH2(e:MouseEvent):void
		{	
			headPoints.h2.startDrag();
		}
		
		private function dragH3(e:MouseEvent):void
		{	
			headPoints.h3.startDrag();
		}
		
		private function dragH4(e:MouseEvent):void
		{	
			headPoints.h4.startDrag();
		}
		
		private function dragH5(e:MouseEvent):void
		{	
			headPoints.h5.startDrag();
		}
		
		private function dragH6(e:MouseEvent):void
		{	
			headPoints.h6.startDrag();
		}
		
		private function dragH7(e:MouseEvent):void
		{	
			headPoints.h7.startDrag();
		}
		
		private function dragH8(e:MouseEvent):void
		{	
			headPoints.h8.startDrag();
		}
		
		private function dragH9(e:MouseEvent):void
		{	
			headPoints.h9.startDrag();
		}
		
		private function dragH10(e:MouseEvent):void
		{	
			headPoints.h10.startDrag();
		}
		
		private function dragH11(e:MouseEvent):void
		{	
			headPoints.h11.startDrag();
		}
		
		private function endDrag(e:MouseEvent):void
		{
			//check handle bounds
			headPoints.stopDrag();
		}
		
	}
	
}