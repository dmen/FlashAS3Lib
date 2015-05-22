package com.gmrmarketing.comcast.nascar.sanshelmet
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.net.*;	
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.CamPic;	
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	
	public class Preview extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const TAKE_PHOTO:String = "takePhotoPressed";
		public static const CLOSE_PREVIEW:String = "closeButtonPressed";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		private var currPhoto:BitmapData;
		private var countDown:Countdown;
		private var overlay:BitmapData;
		private var chaseShowing:Boolean;
		
		
		public function Preview()
		{
			clip = new mcPreview();
			cam = new CamPic();
		}
		
		
		public function setContainer(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			chaseShowing = false;
			
			clip.instructions.alpha = 0;			
				
			clip.btnTake.y = 1100;
			
			TweenMax.to(clip.instructions, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.btnTake, .5, { y:847, delay:.6, ease:Back.easeOut } );
			TweenMax.to(clip.suits, .5, { x:1411, delay:.7, ease:Back.easeOut} );
			TweenMax.to(clip.drivers, .5, { x:1450, delay:.8, ease:Back.easeOut} );	
			
			redJersey();//default
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			clip.btnRed.addEventListener(MouseEvent.MOUSE_DOWN, redJersey, false, 0, true);
			clip.btnGray.addEventListener(MouseEvent.MOUSE_DOWN, grayJersey, false, 0, true);
			clip.btnBlue.addEventListener(MouseEvent.MOUSE_DOWN, blueJersey, false, 0, true);
			clip.btnBrendan.addEventListener(MouseEvent.MOUSE_DOWN, brendanOverlay, false, 0, true);
			clip.btnTy.addEventListener(MouseEvent.MOUSE_DOWN, tyOverlay, false, 0, true);
			clip.btnBrian.addEventListener(MouseEvent.MOUSE_DOWN, brianOverlay, false, 0, true);
			clip.btnChase.addEventListener(MouseEvent.MOUSE_DOWN, chaseOverlay, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doClose, false, 0, true);
			
			cam.init(1280, 960, 0, 0, 992, 744, 30);
			cam.show(clip.camImage);//black box behind bg image	- 1093x615
				
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );			
		}
		
		
		
		private function redJersey(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = true;
			clip.suitCircle.x = 1561;
			clip.suitCircle.y = 292;
			clip.driverCircle.visible = false;
			cam.clearOverlays();
			cam.addOverlay(new suitRed(), new Point(213, 317));			
		}		
		
		
		private function grayJersey(e:MouseEvent = null):void
		{	
			clip.suitCircle.visible = true;
			clip.suitCircle.x = 1707;
			clip.suitCircle.y = 292;
			clip.driverCircle.visible = false;
			cam.clearOverlays();
			cam.addOverlay(new suitGray(), new Point(213, 317));
		}
		
		
		private function blueJersey(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = true;
			clip.suitCircle.x = 1412;
			clip.suitCircle.y = 292;
			clip.driverCircle.visible = false;
			cam.clearOverlays();
			cam.addOverlay(new suitBlue(), new Point(213, 317));
		}
		
		
		private function brendanOverlay(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = false;
			clip.driverCircle.x = 1454;
			clip.driverCircle.y = 495;
			clip.driverCircle.visible = true;
			cam.clearOverlays();			
			cam.addOverlay(new brendan(), new Point(213, 30));
		}
		private function tyOverlay(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = false;
			clip.driverCircle.x = 1635;
			clip.driverCircle.y = 495;
			clip.driverCircle.visible = true;
			cam.clearOverlays();
			cam.addOverlay(new ty(), new Point(213, 30));
		}
		private function brianOverlay(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = false;
			clip.driverCircle.x = 1451;
			clip.driverCircle.y = 676;
			clip.driverCircle.visible = true;
			cam.clearOverlays();
			cam.addOverlay(new brian(), new Point(213, 30));
		}
		private function chaseOverlay(e:MouseEvent = null):void
		{
			clip.suitCircle.visible = false;
			clip.driverCircle.x = 1639;
			clip.driverCircle.y = 674;
			clip.driverCircle.visible = true;
			cam.clearOverlays();
			cam.addOverlay(new chase(), new Point(213, 30));
		}
		
		
		private function doClose(e:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_PREVIEW));
		}		
	
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}			
			cam.dispose();			
		}
		
		
		private function takePic(e:MouseEvent):void
		{
			dispatchEvent(new Event(TAKE_PHOTO));
		}
		
		
		public function getPic():BitmapData
		{
			return cam.getCameraDirect();//992x744
		}
		/*
		private function showPhoto():void
		{	
			var camIm:BitmapData = cam.getDisplay();//1093x615
			
			var displayIm:BitmapData = new BitmapData(900, 615);
			displayIm.copyPixels(camIm, new Rectangle(96, 0, 900, 615), new Point(0, 0));
			displayIm.copyPixels(overlay, new Rectangle(0, 0, 900, 615), new Point(0, 0), null, null, true);
			
			displayPhoto = new Bitmap(displayIm);
			displayPhoto.x = 545;
			displayPhoto.y = 141;
			clip.addChildAt(displayPhoto, 1); //put right in front of camImage
			
			clip.btnTake.visible = false;
			clip.btnRetake.visible = true;
			clip.btnLoveIt.visible = true;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, show, false, 0, true);
			clip.btnLoveIt.addEventListener(MouseEvent.MOUSE_DOWN, showThanks, false, 0, true);
		}
*/
		
	}
	
}