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
		private var circ:Circley;
		private var chaseShowing:Boolean;
		
		
		public function Preview()
		{
			clip = new mcPreview();
			circ = new Circley();
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
			
			clip.instructions.x = -clip.instructions.width;				
				
			clip.btnTake.y = 1100;
			clip.opt1.x = 1920;
			clip.opt2.x = 1920;
			clip.opt3.x = 1920;
			clip.opt4.x = 1920;
			clip.opt1.theText.text = "Red Fire Suit"
			clip.opt2.theText.text = "Gray Fire Suit"			
			clip.opt3.theText.text = "Blue Fire Suit"			
			clip.opt4.theText.text = "Chase Elliot"			
			
			TweenMax.to(clip.instructions, .5, { x:180, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip.btnTake, .5, { y:847, delay:.6, ease:Back.easeOut } );
			TweenMax.to(clip.opt1, .5, { x:1394, delay:.7, ease:Back.easeOut} );
			TweenMax.to(clip.opt2, .5, { x:1394, delay:.8, ease:Back.easeOut} );			
			TweenMax.to(clip.opt3, .5, { x:1394, delay:.9, ease:Back.easeOut} );			
			TweenMax.to(clip.opt4, .5, { x:1394, delay:1, ease:Back.easeOut} );			
			
			redJersey();//default
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			clip.btnRed.addEventListener(MouseEvent.MOUSE_DOWN, redJersey, false, 0, true);
			clip.btnGray.addEventListener(MouseEvent.MOUSE_DOWN, grayJersey, false, 0, true);
			clip.btnBlue.addEventListener(MouseEvent.MOUSE_DOWN, blueJersey, false, 0, true);
			clip.btnChase.addEventListener(MouseEvent.MOUSE_DOWN, chaseOverlay, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doClose, false, 0, true);
			
			//set camera and capture res to 1920x1080 and display at 1093x615	
			cam.init(1280, 960, 0, 0, 992, 744, 30);
			cam.show(clip.camImage);//black box behind bg image	- 1093x615
				
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );			
		}
		
		
		
		private function redJersey(e:MouseEvent = null):void
		{
			circ.setButton(clip.opt1);
			cam.clearOverlays();
			cam.addOverlay(new suitRed(), new Point(213, 317));			
		}		
		
		
		private function grayJersey(e:MouseEvent = null):void
		{		
			circ.setButton(clip.opt2);
			cam.clearOverlays();
			cam.addOverlay(new suitGray(), new Point(213, 317));
		}
		
		
		private function blueJersey(e:MouseEvent = null):void
		{		
			circ.setButton(clip.opt3);
			cam.clearOverlays();
			cam.addOverlay(new suitBlue(), new Point(213, 317));
		}
		
		
		private function chaseOverlay(e:MouseEvent = null):void
		{
			circ.setButton(clip.opt4);
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