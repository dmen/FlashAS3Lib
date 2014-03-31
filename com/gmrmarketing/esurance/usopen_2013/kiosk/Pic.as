package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import flash.display.*;	
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.SliderV;
	import com.gmrmarketing.utilities.Slider;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import fl.motion.MatrixTransformer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Pic extends EventDispatcher
	{
		public static const GO_BACK:String = "backPressed";
		public static const MYPIK_LOADED:String = "imageLoaded";
		public static const MYPIK_FAILED:String = "noImage";//dispatched if getting the user image from the service failed
		public static const IMAGE_READY:String = "imageReady";//dispatched when image is ready for encoding
		public static const NO_IMAGE:String = "NoImageForRFID";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var templateHolder:Sprite;
		private var myPikHolder:Sprite;
		private var myPikZoomHolder:Sprite;
		private var maskHolder:Sprite;
		private var noiseHolder:Sprite;
		private var broHolder:Sprite;
		private var overlayHolder:Sprite;
		private var borderHolder:Sprite;
		private var authToken:String;
		
		private var bmd:BitmapData;
		private var zoomSlider:Slider;
		private var offsetX:Number;
		private var offsetY:Number;
		private var tim:TimeoutHelper;
		
		
		public function Pic()
		{
			clip = new mcPic();
			
			templateHolder = new Sprite();//container for pik, mask, template, overlay
			templateHolder.x = 480;
			templateHolder.y = 230;
			
			myPikHolder = new Sprite();
			myPikZoomHolder = new Sprite();
			
			myPikHolder.addChild(myPikZoomHolder);
			myPikZoomHolder.x = 640;
			myPikZoomHolder.y = 360;
			templateHolder.addChild(myPikHolder);
			
			maskHolder = new Sprite();
			maskHolder.graphics.beginFill(0x00ff00, 1);
			maskHolder.graphics.drawRect(0, 0, 1280, 720);
			maskHolder.alpha = 0;
			templateHolder.addChild(maskHolder);
			
			noiseHolder = new Sprite();
			noiseHolder.addChild(new Bitmap(new noise()));
			templateHolder.addChild(noiseHolder);
			noiseHolder.alpha = 0;
			
			broHolder = new Sprite();
			templateHolder.addChild(broHolder);
			
			overlayHolder = new Sprite();
			var over:Bitmap = new Bitmap(new overlay());
			overlayHolder.addChild(over);
			over.y = 720 - over.height;
			templateHolder.addChild(overlayHolder);
			
			borderHolder = new Sprite();
			borderHolder.graphics.lineStyle(2, 0x1e153a, 1, true);
			borderHolder.graphics.drawRect(0, 0, 1280, 720);
			templateHolder.addChild(borderHolder);
			
			zoomSlider = new Slider(clip.slider, clip.track);
			
			tim = TimeoutHelper.getInstance();
			
			clip.addChild(templateHolder);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(rfid:String, token:String):void
		{	
			tim.buttonClicked();
			
			authToken = token;//null or "" if there is no token
			if (authToken == "") {
				authToken = null;
			}
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			
			clip.btnA.addEventListener(MouseEvent.MOUSE_DOWN, templateAClicked, false, 0, true);
			clip.btnB.addEventListener(MouseEvent.MOUSE_DOWN, templateBClicked, false, 0, true);
			clip.btnC.addEventListener(MouseEvent.MOUSE_DOWN, templateCClicked, false, 0, true);
			clip.btnD.addEventListener(MouseEvent.MOUSE_DOWN, templateDClicked, false, 0, true);
			
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			
			if (authToken == null) {
				clip.btnPost.theText.text = "send to email";
				clip.instText.text = "Position your image by clicking and dragging it. Change its size using the zoom slider. Once complete press the 'send to email' button.";
			}else {				
				clip.btnPost.theText.text = "post to facebook";
				clip.instText.text = "Position your image by clicking and dragging it. Change its size using the zoom slider. Once complete press the 'post to facebook' button.";
			}
			clip.btnPost.addEventListener(MouseEvent.MOUSE_DOWN, beginFBPost, false, 0, true);
			
			getMyPikImage(rfid);
		}
		
		
		public function hide():void
		{
			tim.buttonClicked();
			clip.btnA.removeEventListener(MouseEvent.MOUSE_DOWN, templateAClicked);
			clip.btnB.removeEventListener(MouseEvent.MOUSE_DOWN, templateBClicked);
			clip.btnC.removeEventListener(MouseEvent.MOUSE_DOWN, templateCClicked);
			clip.btnD.removeEventListener(MouseEvent.MOUSE_DOWN, templateDClicked);
			
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			clip.btnPost.removeEventListener(MouseEvent.MOUSE_DOWN, beginFBPost);			
			
			noiseHolder.alpha = 0;
			myPikZoomHolder.scaleX = myPikZoomHolder.scaleY = 1;
			myPikZoomHolder.x = 640;
			myPikZoomHolder.y = 360;
			while (myPikZoomHolder.numChildren > 0) {
				myPikZoomHolder.removeChildAt(0); //remove image
			}
			while (broHolder.numChildren > 0) {
				broHolder.removeChildAt(0); //remove template image
			}
			
			zoomSlider.reset();
			
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
		}
		
		
		private function backPressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(GO_BACK));
		}
		
		
		private function templateAClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			TweenMax.killTweensOf(clip.highlight);
			TweenMax.to(clip.highlight, .5, { y:MovieClip(e.currentTarget).y, ease:Back.easeOut } );
			
			if (broHolder.numChildren > 0) {
				broHolder.removeChildAt(0);
			}
			
			var bros:Bitmap = new Bitmap(new bros_1());
			broHolder.addChild(bros);
			
			bros.alpha = 0;
			TweenMax.to(bros, .5, { alpha:1 } );
			
			//sepia tone the myPik image
			TweenMax.to(myPikZoomHolder, 1, { colorMatrixFilter: { colorize:0xeeddcc, saturation:0 }} );
			TweenMax.to(noiseHolder, 1, { alpha:.1 } );
		}
		
		private function templateBClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			TweenMax.killTweensOf(clip.highlight);
			TweenMax.to(clip.highlight, .5, { y:MovieClip(e.currentTarget).y, ease:Back.easeOut } );
			
			if (broHolder.numChildren > 0) {
				broHolder.removeChildAt(0);
			}
			
			var bros:Bitmap = new Bitmap(new bros_2());
			broHolder.addChild(bros);
			
			bros.alpha = 0;
			TweenMax.to(bros, .5, { alpha:1 } );
			
			//colorize myPik image
			TweenMax.to(myPikZoomHolder, 1, { colorMatrixFilter: {colorize:0xeedddd, amount:.6, contrast:1.3, saturation:1.1, brightness:1.2}} );
			TweenMax.to(noiseHolder, 1, { alpha:.1 } );			
		}
		
		private function templateCClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			TweenMax.killTweensOf(clip.highlight);
			TweenMax.to(clip.highlight, .5, { y:MovieClip(e.currentTarget).y, ease:Back.easeOut } );
			
			if (broHolder.numChildren > 0) {
				broHolder.removeChildAt(0);
			}
			
			var bros:Bitmap = new Bitmap(new bros_3());
			broHolder.addChild(bros);
			
			bros.alpha = 0;
			TweenMax.to(bros, .5, { alpha:1 } );
			
			//colorize myPik image
			TweenMax.to(myPikZoomHolder, 1, { colorMatrixFilter: {contrast:1.5, saturation:1.3}} );
			TweenMax.to(noiseHolder, 1, { alpha:.15 } );
		}
		
		private function templateDClicked(e:MouseEvent = null):void
		{
			tim.buttonClicked();
			if(e != null){
				TweenMax.killTweensOf(clip.highlight);
				TweenMax.to(clip.highlight, .5, { y:MovieClip(e.currentTarget).y, ease:Back.easeOut } );
			}else {
				//called from myPikLoaded()
				TweenMax.killTweensOf(clip.highlight);
				TweenMax.to(clip.highlight, .5, { y:767, ease:Back.easeOut } );
			}
			
			if (broHolder.numChildren > 0) {
				broHolder.removeChildAt(0);
			}
			
			var bros:Bitmap = new Bitmap(new bros_4());
			broHolder.addChild(bros);
			
			bros.alpha = 0;
			TweenMax.to(bros, .5, { alpha:1 } );
			
			//colorize myPik image
			TweenMax.to(myPikZoomHolder, 1, { colorMatrixFilter: {}} );
			TweenMax.to(noiseHolder, 1, { alpha:0 } );
		}
		
		
		private function beginFBPost(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.btnPost.highlight.alpha = 1;
			TweenMax.to(clip.btnPost.highlight, .5, { alpha:0 } );
			
			bmd = new BitmapData(1280, 720);
			bmd.draw(templateHolder);
			
			dispatchEvent(new Event(IMAGE_READY));
		}
		
		/**
		 * called from Main after IMAGE_READY is dispatched
		 * @return
		 */
		public function getImage():BitmapData
		{
			return bmd;
		}
		
		
		private function startDragging(e:MouseEvent):void
		{
			myPikZoomHolder.startDrag();
		}
		
		private function endDragging(e:MouseEvent):void
		{
			myPikZoomHolder.stopDrag();
		}
		
		private function zoomChange(e:Event):void
		{
			var za:Number = zoomSlider.getPosition();//0-1
			myPikZoomHolder.scaleX = myPikZoomHolder.scaleY = 1 + za;
		}
		
		
		private function getMyPikImage(rfid:String):void
		{	
			var req:URLRequest = new URLRequest("http://esuranceusopen2013.thesocialtab.net/api/Image");
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var vars:URLVariables = new URLVariables();
			vars.rfid = rfid;// coffee cup pic of aarons desk "F24313CE";
			vars.imageType = "MyPik_1"; //get original
			
			req.requestHeaders.push(hdr);//to accept json in the response
			req.data = vars;
			req.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, getImageError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, gotImage, false, 0, true);
			lo.load(req);
		}
		
		
		private function getImageError(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(MYPIK_FAILED));
		}
		
		
		private function gotImage(e:Event):void
		{
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if(j.length > 0){			
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, myPikLoaded, false, 0, true);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, getImageError, false, 0, true);
				
				l.load(new URLRequest(j[0].ImageUrl)); //load the first image from the array		
			}else {
				dispatchEvent(new Event(NO_IMAGE));
			}
		}
		
		
		/**
		 * called once the bitmap from myPik has been downloaded
		 * @param	e
		 */
		private function myPikLoaded(e:Event):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(MYPIK_LOADED));
			
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			
			b.width = 1280;//actual size of images from myPik
			b.height = 960;			
			
			myPikZoomHolder.addChild(b);
			b.x = -640;
			b.y = -480;
			myPikHolder.mask = maskHolder;
			
			b.alpha = 0;
			TweenMax.to(b, 1, { alpha:1 } );
			
			//add zoom/pan listeners
			templateHolder.addEventListener(MouseEvent.MOUSE_DOWN, startDragging, false, 0, true);			
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDragging, false, 0, true);
			zoomSlider.addEventListener(Slider.DRAGGING, zoomChange, false, 0, true);
			
			//show initial bros template
			templateDClicked();
		}
		
	}
	
}