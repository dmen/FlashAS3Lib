package com.gmrmarketing.comcast.nascar
{	
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import com.tastenkunst.as3.brf.container.*;
	import com.tastenkunst.as3.video.CameraManager;
	import com.tastenkunst.as3.video.VideoManager1280x960;
	import com.gmrmarketing.sap.levisstadium.avatar.testing.BRFBasicView;	
	import flash.net.URLRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.utils.Timer;
	import flash.ui.*;
	
	
	
	/**
	 * This examples does the whole job. 
	 * Flare3D, Away3D and Away3DLite are available at the moment.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class Webcam3D_1280x960 extends BRFBasicView 
	{
		public static const TAKE_PHOTO:String = "btnTakePhotoPressed";
		public static const CLOSE_PREVIEW:String = "closeButtonPressed";
		public static const BG_CHANGE:String = "changeBackground";
		public static const MASK_READY:String = "maskReady";
		
		public var _container3D : Avatar_Flare3D_v2_5;
		private var _brfBmd : BitmapData;
		private var _brfMatrix : Matrix;//for scaling video data to 640x480 for BRF
		
		//Overlay image and face vertex data
		[Embed(source="c:/users/dmennenoh/desktop/sap/assets/plain_guy_texture3_old.png")]
		public var IMAGE:Class;
		
		[Embed(source="c:/users/dmennenoh/desktop/sap/assets/uv_plain_guy.txt", mimeType="application/octet-stream")]
		public var UVDATA:Class;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;
		
		private var _containerAll : Sprite;
		private var clip:MovieClip;	
			
		private const jerseyPath:String = "jerseys/";
		private var jerseyBMD:BitmapData;
		private var jerseyMatrix:Matrix;
		
		private var _pointsToShow : Vector.<Point>;
		private var introAnimStarted:Boolean;
		private var introAnimFinished:Boolean;
		private var introAlpha:Number;
		private var meshAlpha:Number;
		
		private var animInc:int;
		private var tim:TimeoutHelper;
		private var firstName:String;
		
		private var shapePoints : Vector.<Point>;
		private var center : Point;
		private var tmpPointShape : Point;
		private	var tmpPointOutline : Point;
		private	var fac : Number = 0.08;
		
		private var brfReady:Boolean = false;		
		private var brfPaused:Boolean = false;
		
		private var circ:Circley;
		private var usingHelmet:Boolean = true;
		
		public function Webcam3D_1280x960() 
		{	
			super();			
			setFace((new IMAGE() as Bitmap).bitmapData, Vector.<Number>((new UVDATA()).toString().split(",")));			
			tim = TimeoutHelper.getInstance();
			clip = new mcPreview();
			circ = new Circley();
		}		
		
		
		//called from Main.reset()
		public function hide():void
		{			
			//super.stopVid();//call in BRFBasicView
			if (contains(clip)) {
				removeChild(clip);
			}
		}
		
		
		public function isBrfReady():Boolean
		{
			return brfReady;			
		}
		
		
		public function show():void
		{
			//enable face estimation and pose estimation
			//_brfManager.isEstimatingFace = true;
			//_brfManager.deleteLastDetectedFace = false;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			brfPaused = false;
			introAnimStarted = true;
			introAnimFinished = true;
			
			if (clip) {
				
				if (!contains(clip)) {
					addChild(clip);
				}				
				
				clip.instructions.x = -clip.instructions.width;				
				
				clip.btnTake.y = 1100;
				clip.opt1.x = 1920;
				clip.opt2.x = 1920;
				clip.opt1.theText.text = "Fire Suit\nw/ helmet"
				clip.opt2.theText.text = "Fire Suit"
				TweenMax.delayedCall(3,addControls);
			}
			if(_videoManager){
				super.startVid();
			}
		}
		

		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void 
		{
			_cameraManager = new CameraManager(this);
			_videoManager = new VideoManager1280x960();
		}

		
		override public function initGUI() : void 
		{
			super.initGUI();
			_containerDrawMask = new Sprite();
			_containerDrawMask.scaleX = 2.0;
			_containerDrawMask.scaleY = 2.0;
			_containerDrawMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.scaleX = 2.0;
			_containerDraw.scaleY = 2.0;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;
			
			_containerAll = new Sprite();
			_containerAll.addChild(_containerDraw);
			_containerAll.addChild(_containerDrawMask);			
			
			jerseyBMD = new BitmapData(1,1);
			jerseyMatrix = new Matrix();
			jerseyMatrix.scale(1.1, 1.1);
			jerseyMatrix.translate(288, 540);	//100 was 250
		}
		
		
		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		override public function onInitBRF(event : Event = null) : void 
		{
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			//override the face detection regions of interest, if needed.
			
			//we need a separate BitmapData for BRF, that is 640x480
			_brfBmd = new BitmapData(640, 480, false, 0x000000);
			
			//The video is 1280x960 - brf needs 640x480
			_brfMatrix = new Matrix();
			_brfMatrix.scale(.5, .5);
			
			//we don't use the videoData directly, but the _brfBmd
			//_brfManager.init(_videoManager.videoData, _contentContainer);
			_brfManager.init(_brfBmd, _contentContainer);
		}

	
		override public function onReadyBRF(event : Event = null) : void 
		{			
			brfReady = true;
			
			_mouthHolePoints[0] = _brfManager.faceShape.pointsUpperLip[0];
			_mouthHolePoints[1] = _brfManager.faceShape.pointsLowerLip[5];
			_mouthHolePoints[2] = _brfManager.faceShape.pointsLowerLip[4];
			_mouthHolePoints[3] = _brfManager.faceShape.pointsLowerLip[3];
			_mouthHolePoints[4] = _brfManager.faceShape.pointsLowerLip[2];
			_mouthHolePoints[5] = _brfManager.faceShape.pointsLowerLip[1];
			_mouthHolePoints[6] = _brfManager.faceShape.pointsLowerLip[0];
			_mouthHolePoints[7] = _brfManager.faceShape.pointsUpperLip[4];
			_mouthHolePoints[8] = _brfManager.faceShape.pointsUpperLip[3];
			_mouthHolePoints[9] = _brfManager.faceShape.pointsUpperLip[2];
			_mouthHolePoints[10] = _brfManager.faceShape.pointsUpperLip[1];

			for (var i : int = 0; i < _outlinePoints.length; i++) {
				_outlinePoints[i] = new Point();
			}			
			
			//default is 80 - allows for smaller 3d objects
			_brfManager.vars.faceEstimationVars.minShapeDimension = 40;
			
			//disables face estimation and pose estimation
			//tracking only
			//_brfManager.isEstimatingFace = false;
			//_brfManager.deleteLastDetectedFace = true;
			
			//base scale is the starting depth. Change it to 2 to find small faces in
			//the image (eg. when people are standing far away from the camera)
			//For an installation at the client, the user will stand in front of
			//the screen/camera at a very certain distance, I would suggest to
			//choose one base depth, scaleIncrement 0.1 and only maxScale = baseScale + 1.0
			//This way the user has to stay in the distance from the screen you want him
			//to be.
			_brfManager.vars.faceDetectionVars.baseScale = 1;// 3.5;
			//step size of the depth
			//so: starting with 4, 4.5, 5, 5.5, 6.0 face size are searched for
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;
			//end scale for depth search
			_brfManager.vars.faceDetectionVars.maxScale = 4;
			
			//set this to a high number to get more results --defaults to 12
			_brfManager.vars.faceDetectionVars.minRectsToFind = 15;// 12;
			
			//add some space between the face rectangles searches. default is 0.02, 
			//which is really few space between the rects
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;//.05			
			
			super.onReadyBRF(event);
			
			_cameraManager.initCamera();//moved here from basicWebCam class
		}
		
		
		/** Init the 3D content overlay. */
		override public function initContentContainer() : void 
		{
			_container3D = new Avatar_Flare3D_v2_5(_containerContent);
			//just tell the Flare3D scene to be as big as the video size and place it where you want.
			//for the 593x774 you need to cover with a hole for the Stage3D content
			
			//I only changed one thing to get the correct video plane size:
			//var planeDist : Number = (1 / _scene.camera.zoom * _scene.viewPort.width) * _planeFactor * 0.25; //instead of 0.5;
			
			//onscreen window is 587x687
			_container3D.init(new Rectangle(375, 50, 1280, 960)); //316
			_container3D.initVideo(_videoManager.videoData);//1280x960 bmd
			_container3D.initOcclusion("brf_fp11_occlusion_head.zf3d");
			_contentContainer = _container3D;			
		}
		
		
		private function addControls():void
		{
			TweenMax.to(clip.instructions, .5, { x:180, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip.btnTake, .5, { y:847, delay:.6, ease:Back.easeOut, onComplete:introAnim } );
			TweenMax.to(clip.opt1, .5, { x:1434, delay:.7, ease:Back.easeOut} );
			TweenMax.to(clip.opt2, .5, { x:1434, delay:.8, ease:Back.easeOut} );
			circ.setButton(clip.opt1);
			usingHelmet = true;
			addListeners();
		}
		
		
		//called by Main.reset()
		//resets brf to tracking only - not estimation
		//disables face estimation and pose estimation
		/*
		public function track():void
		{
			_brfManager.isEstimatingFace = false;
			_brfManager.deleteLastDetectedFace = true;
		}
		*/
		
		public function addListeners():void
		{
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePhoto, false, 0, true);
			clip.btnSuit.addEventListener(MouseEvent.MOUSE_DOWN, removeHelmet, false, 0, true);
			clip.btnHelmet.addEventListener(MouseEvent.MOUSE_DOWN, addHelmet, false, 0, true);
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doClose, false, 0, true);
		}
		
		private function doClose(e:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_PREVIEW));
		}
		
		private function removeHelmet(e:MouseEvent):void
		{
			usingHelmet = false;
			circ.setButton(clip.opt2);
			_container3D.removeHelmet();
		}
		private function addHelmet(e:MouseEvent):void
		{
			usingHelmet = true;
			circ.setButton(clip.opt1);	
			_container3D.addHelmet();
		}
		
		
		
		private function introAnim():void
		{
			_container3D.model = "nascar.zf3d";			
			loadJersey();
			introAnimStarted = false;
			introAnimFinished = false;
			_container3D.maxPointLights(6);
		}		
		
		
		
		private function loadJersey():void
		{
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, jerseyLoaded, false, 0, true);			
			l.load(new URLRequest(jerseyPath + "FireSuitRed.png"));			
		}
		
		
		/**
		 * Jersey is drawn into the video image in onVideoUpdate() 
		 * @param	e
		 */
		private function jerseyLoaded(e:Event = null):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			jerseyBMD = b.bitmapData;
			
			//_brfManager.isEstimatingFace = true;
			//_brfManager.deleteLastDetectedFace = false;
		}
		
		public function pause():void
		{
			circ.pause();	
			brfPaused = true;
		}
		public function unPause():void
		{
			circ.resume();
			brfPaused = false;
		}
		
		//update the 3d webcam video plane, when there is a new image from the webcam
		override public function onVideoUpdate() : void 
		{			
			if(!brfPaused){
				//draw the 1280x960 video half the size to the BRF BitmapData - 640x480
				_brfBmd.draw(_videoManager.videoData, _brfMatrix);
				
				//update BRF
				super.onVideoUpdate();
				
				//Draw the mask and jersey image to the video data
				(_videoManager.videoData as BitmapData).draw(_containerAll, null, null, null, null, true);
				(_videoManager.videoData as BitmapData).draw(jerseyBMD, jerseyMatrix, null, null, null, true);
				
				//upload the videoData as Texture to the GPU
				_container3D.updateVideo();
			}
		}
		
		
		/**
		 * Called when the take photo button has been pressed
		 * @param	e
		 */
		private function takePhoto(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(TAKE_PHOTO));
		}
		
		
		//called by main.takePhoto once the TAKE_PHOTO event is received
		//returns a 1280x960 camera shot
		public function shotReady():BitmapData
		{
			var baseImage:BitmapData = Avatar_Flare3D_v2_5(_container3D).getScreenshot();	
			
			var blurImage:BitmapData = new BitmapData(baseImage.width, baseImage.height);
			blurImage.applyFilter(baseImage, new Rectangle(0, 0, baseImage.width, baseImage.height), new Point(0, 0), new BlurFilter(25, 25, 3));
			
			var bmd:BitmapData = Avatar_Flare3D_v2_5(_container3D).getMaskImage();
			bmd.draw(jerseyBMD, jerseyMatrix, null, null, null, true);
			
			var m:BitmapData = new BitmapData(bmd.width, bmd.height, true, 0xff000000);
			m.threshold(bmd, bmd.rect, new Point(0, 0), ">", 0x00000000, 0xffff0000, 0xff000000, true);
			
			var mBlur:BitmapData = new BitmapData(m.width, m.height);
			mBlur.applyFilter(m, new Rectangle(0, 0, m.width, m.height), new Point(0, 0), new BlurFilter(5, 5, 3));

			blurImage.copyPixels(baseImage, new Rectangle(0, 0, baseImage.width, baseImage.height), new Point(0, 0), mBlur, new Point(0, 0), true);
			
			if(!usingHelmet){
				return baseImage;
			}else{
				return blurImage;
			}
		}
		
		
		/** Draws the analysis results. */
		override public function showResult(showAll : Boolean = false) : void 
		{	
			//Draw the mask
			shapePoints = _brfManager.faceShape.shapePoints;
			center = shapePoints[67];
			
			var i : int;
			var l : int;
			
			// no super.showResult() - we draw a mouth hole here
			//a custom drawing to get rid of the mouth
			if(_texture && _brfManager.task == BRFStatus.FACE_ESTIMATION) {
				BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
				_draw.clear();
				//drawing the extracted texture
				_draw.lineStyle();
				_draw.beginBitmapFill(_texture);
				_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles, _uvData);
				_draw.endFill();
				
				//getting the outline of the face shape mask
				i = 0;
				l = 18;
				for (i = 0; i < l; i++) {
				tmpPointShape = shapePoints[i];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
				}
				var k : int = 23;
				l = _outlinePoints.length;
				for (; i < l; i++, k--) {
					tmpPointShape = shapePoints[k];
					tmpPointOutline = _outlinePoints[i];
					tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
					tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
				}
				//drawing the outline of the face shape for the blurry mask
				i = 1;
				l = _outlinePoints.length;
				_drawMask.clear();
				_drawMask.beginFill(0xff0000, 0.7);
				_drawMask.moveTo(_outlinePoints[0].x, _outlinePoints[0].y);
				while(i < l) {
					_drawMask.lineTo(_outlinePoints[i].x, _outlinePoints[i].y);
					i++;
				}
				_drawMask.lineTo(_outlinePoints[0].x, _outlinePoints[0].y);
				//and drawing the mouth hole into the blurry mask
				i = 1;
				l = _mouthHolePoints.length;
				_drawMask.moveTo(_mouthHolePoints[0].x, _mouthHolePoints[0].y);
				while(i < l) {
					_drawMask.lineTo(_mouthHolePoints[i].x, _mouthHolePoints[i].y);
					i++;
				}
				_drawMask.lineTo(_mouthHolePoints[0].x, _mouthHolePoints[0].y);
				_drawMask.endFill();
			}
			//super.showResult();//will draw shape points
		}
		
		
		public function setFace(texture : BitmapData, uvData : Vector.<Number>) : void {
			_texture = texture;
			_uvData = uvData;
		}
		
	}
}