package com.tastenkunst.as3.brf.examples 
{	
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import com.tastenkunst.as3.brf.container.*;
	import com.tastenkunst.as3.video.CameraManager;
	import com.tastenkunst.as3.video.VideoManager1280x960;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	/**
	 * This examples does the whole job. 
	 * Flare3D, Away3D and Away3DLite are available at the moment.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcam3D_1280x960 extends BRFBasicWebcam 
	{
		public static const TAKE_PHOTO:String = "btnTakePhotoPressed";
		public static const CLOSE_PREVIEW:String = "closeButtonPressed";
		
		public var _container3D : BRFContainerFP11;
		private var _brfBmd : BitmapData;
		private var _brfMatrix : Matrix;

		[Embed(source="c:/users/dmennenoh/desktop/sap/assets/plain_guy_texture3.png")]
		public var IMAGE : Class;
		
		[Embed(source="c:/users/dmennenoh/desktop/sap/assets/uv_plain_guy.txt", mimeType="application/octet-stream")]
		public var UVDATA : Class;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;
		
		private var _containerAll : Sprite;
		private var clip:MovieClip;
		private var previewBMD:BitmapData;
		private var prevMatrix:Matrix;		
			
		private const jerseyPath:String = "jerseys/";
		private var jerseyBMD:BitmapData;
		private var jerseyMatrix:Matrix;
		private var currentTeam:String;
		
		private var _pointsToShow : Vector.<Point>;
		private var introAnimStarted:Boolean;
		private var introAnimFinished:Boolean;
		private var introAlpha:Number;
		private var meshAlpha:Number;
		
		private var messages:Array;
		private var messageCounter:int;
		private var animInc:int;
		private var tim:TimeoutHelper;
		private var firstName:String;

		public function ExampleWebcam3D_1280x960() 
		{			
			super();			
			//setFace((new IMAGE() as Bitmap).bitmapData, Vector.<Number>((new UVDATA()).toString().split(",")));	
			
			tim = TimeoutHelper.getInstance();
			messages = new Array("calibrating", "pupil detection", "delta", "update", "calculating", "variance", "accuracy");
		}
		
		public function setTeam(favTeam:String, fName:String):void
		{
			firstName = fName;
			doSwap(favTeam);
		}
		
		public function hide():void
		{
			super.stopVid();//call in BRFBasicView2
			if (contains(clip)) {
				removeChild(clip);
			}
			//Flare3D_v2_5(_container3D).clear();
		}
		
		public function show():void
		{
			introAnimStarted = false;
			if(clip){
				clip.rvline.visible = true;
				clip.rhline.visible = true;
				clip.rpupil.visible = true;
				clip.lvline.visible = true;
				clip.lhline.visible = true;
				clip.lpupil.visible = true;
				
				if (!contains(clip)) {
					addChild(clip);
				}
				
				//clip.fname.text = "Welcome " + firstName;
			}
			if(_videoManager){
				super.startVid();
			}			
		}

		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void {
			_cameraManager = new CameraManager(this);
			//changed _videoManager to be of type * in BRFBasicView
			_videoManager = new VideoManager1280x960();
		}

		
		override public function initGUI() : void 
		{
			super.initGUI();
//trace("BRFinitGUI");
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
			
			clip = new mcPreview();//graphic in the lib
			//clip.fname.text = "Welcome " + firstName;
			addChild(clip);		
			
			jerseyBMD = new BitmapData(1,1);
			jerseyMatrix = new Matrix();
			jerseyMatrix.scale(1.2, 1.2);
			jerseyMatrix.translate(150, 0);//-43
			
			//small camera preview at upper left
			previewBMD = new BitmapData(486, 364, false, 0xff000000);//onscreen preview window is 486 x 344
			var pre:Bitmap = new Bitmap(previewBMD);
			pre.x = 41;
			pre.y = 165;//window top at 235 - move it up 10 to compensate for 364 size vs 344window size
			clip.addChildAt(pre, 0);//add behind main background so it gets shadow cast on it
			
			prevMatrix = new Matrix();//for scaling 1280x960 image to 448x336
			prevMatrix.scale(.3796875, .3796875);			
			
			clip.rvline.visible = true;
			clip.rhline.visible = true;
			clip.rpupil.visible = true;
			clip.lvline.visible = true;
			clip.lhline.visible = true;
			clip.lpupil.visible = true;
			clip.rvline.alpha = 0;
			clip.rhline.alpha = 0;
			clip.rpupil.alpha = 0;
			clip.lvline.alpha = 0;
			clip.lhline.alpha = 0;
			clip.lpupil.alpha = 0;
			clip.textHolder.previewText.text = "";
			messageCounter = 0;
			
			//Don't add the new _containerAll to the stage. It's just used to draw into the VideoData
			addListeners();
			jerseyLoaded();//nascar - load suit from lib
		}
		
		
		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		override public function onInitBRF(event : Event = null) : void {
			//trace("onInitBRF");
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			//override the face detection regions of interest, if needed.
			
			//we need a seperate BitmapData for BRF, that is 640x480
			_brfBmd = new BitmapData(640, 480, false, 0x000000);
			//The video is double the size, so we need to draw it half that size
			_brfMatrix = new Matrix();
			_brfMatrix.scale(.5, .5);
			//we don't use the videoData directly, but the _brfBmd
//			_brfManager.init(_videoManager.videoData, _contentContainer);
			_brfManager.init(_brfBmd, _contentContainer);
		}

		
		override public function onReadyBRF(event : Event = null) : void {
			//trace("onReadyBRF");
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
			
			//base scale is the starting depth. Change it to 2 to find small faces in
			//the image (eg. when people are standing far away from the camera)
			//For an installation at the client, the user will stand in front of
			//the screen/camera at a very certain distance, I would suggest to
			//choose one base depth, scaleIncrement 0.1 and only maxScale = baseScale + 1.0
			//This way the user has to stay in the distance from the screen you want him
			//to be.
			_brfManager.vars.faceDetectionVars.baseScale = 1.0;
			//step size of the depth
			//so: starting with 4, 4.5, 5, 5.5, 6.0 face size are searched for
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;
			//end scale for depth search
			_brfManager.vars.faceDetectionVars.maxScale = 5.0;
			
			//set this to a high number to get more results --defaults to 12
			_brfManager.vars.faceDetectionVars.minRectsToFind = 15;
			
			//add some space between the face rectangles searches. default is 0.02, 
			//which is really few space between the rects
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;			
			
			super.onReadyBRF(event);
		}
		
		
		/** Init the 3D content overlay. */
		override public function initContentContainer() : void {
			//trace("initContentContainer");
			//you can use either Flare3D v2.5
			_container3D = new Flare3D_v2_5(_containerContent);
			//just tell the Flare3D scene to be as big as the video size and
			//place it where you want.
			//for the 593x774 you need to cover with a hole for the Stage3D content
			
			//I only changed one thing to get the correct video plane size:
			//var planeDist : Number = (1 / _scene.camera.zoom * _scene.viewPort.width) * _planeFactor * 0.25; //instead of 0.5;
			
			//onscreen window is 717x780
			_container3D.init(new Rectangle(356, 3, 1280, 960)); //316
			_container3D.initVideo(_videoManager.videoData);//1280x960 bmd
			_container3D.initOcclusion("brf_fp11_occlusion_head.zf3d");
			//_container3D.model = "helm_cut2.zf3d";			
			_container3D.model = "sap.zf3d";			
			
			//load helmet and jersey from user data...
			//Flare3D_v2_5(_container3D).setTeam(currentTeam);
			//loadJersey(currentTeam);			
			
			_contentContainer = _container3D;			
		}
		
		
		public function addListeners():void
		{
			//trace("addListeners");
			//NFL icon buttons and take photo
			/*
			clip.btnCardinals.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnFalcons.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnRavens.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBills.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnPanthers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBears.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBengals.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBrowns.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnCowboys.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBroncos.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnLions.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnPackers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnTexans.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnColts.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnJaguars.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);			
			clip.btnChiefs.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnDolphins.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnVikings.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnPatriots.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnSaints.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnGiants.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnJets.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnRaiders.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnEagles.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnSteelers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnChargers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnSeahawks.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btn49ers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			
			clip.btnRams.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnBuccaneers.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnTitans.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);
			clip.btnRedskins.addEventListener(MouseEvent.MOUSE_DOWN, helmetSwap, false, 0, true);			
			*/
			clip.btnTakePhoto.addEventListener(MouseEvent.MOUSE_DOWN, takePhoto, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doClose, false, 0, true);
		}
		
		
		private function doClose(e:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_PREVIEW));
		}
		
		/**
		 * Called whenever a helmet / team button is clicked
		 * @param	e
		 */
		private function helmetSwap(e:MouseEvent):void
		{
			var team:String = MovieClip(e.currentTarget).name.substr(3).toLowerCase();
			buttonFade(MovieClip(e.currentTarget));
			tim.buttonClicked();
			doSwap(team);
		}
		
		
		private function buttonFade(btn:MovieClip):void
		{			
			btn.alpha = 1;
			TweenMax.to(btn, 1, { alpha:0 } );
		}
		
		
		private function doSwap(team:String):void
		{
			//trace("doSwap - team swap");
			currentTeam = team;
			loadJersey(team);
			if (_container3D) {
				
				Flare3D_v2_5(_container3D).changeHelmet(team);
				//_container3D.model = "helm_cut2.zf3d";	
			}
		}
		
		
		public function getTeam():String
		{
			return currentTeam;
		}
		
		
		//cardinals, falcons, ravens, bills, panthers, bears, bengals, browns, cowboys, broncos, lions, packers, texans, colts, jaguars, chiefs, dolphins, vikings, patriots, saints, giants, jets, raiders, eagles, steelers, chargers, seahawks, 49ers, rams, buccaneers, titans, redskins
		private function loadJersey(team:String):void
		{
			//trace("loadJersey");
			team = team.charAt(0).toUpperCase() + team.substr(1);
			
			//var l:Loader = new Loader();
			//l.contentLoaderInfo.addEventListener(Event.COMPLETE, jerseyLoaded, false, 0, true);
			//l.load(new URLRequest(jerseyPath + "Jersey_" + team + ".png"));			
		}
		
		
		private function jerseyLoaded(e:Event = null):void
		{
			//trace("jerseyLoaded");
			//var b:Bitmap = Bitmap(e.target.content);
			//b.smoothing = true;
			//jerseyBMD = b.bitmapData;
			
			jerseyBMD = new suit();//nascar
		}
		
		
		//update the 3d webcam video plane, when there is a new image from the webcam
		override public function onVideoUpdate() : void {
			//draw the video half the size to the BRF BitmapData - 640x480
			_brfBmd.draw(_videoManager.videoData, _brfMatrix, null, null, null, true);
			previewBMD.draw(_videoManager.videoData, prevMatrix, null, null, null, true);
			
			//update BRF
			super.onVideoUpdate();
			
			//Draw the mask and jersey image to the video data
			(_videoManager.videoData as BitmapData).draw(_containerAll, null, null, null, null, true);
			(_videoManager.videoData as BitmapData).draw(jerseyBMD, jerseyMatrix, null, null, null, true);
			
			//upload the videoData as Texture to the GPU
			_container3D.updateVideo();
		}
		
		
		/**
		 * Called when the take photo button has been pressed
		 * @param	e
		 */
		private function takePhoto(e:MouseEvent):void
		{
			dispatchEvent(new Event(TAKE_PHOTO));
		}
		
		
		//called by main
		//returns a 1280x960 camera shot
		public function shotReady():BitmapData
		{
			return Flare3D_v2_5(_container3D).getScreenshot();
		}
		public function getAlphaShot():BitmapData
		{
			return Flare3D_v2_5(_container3D).getAlphaShot();
		}
		
		/** Draws the analysis results. */
		override public function showResult(showAll : Boolean = false) : void 
		{			
			//Draw the mask
			var shapePoints : Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center : Point = shapePoints[67];
			var tmpPointShape : Point;
			var tmpPointOutline : Point;
			var fac : Number = 0.08;
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
			
			//if anim hasn't started and we can estimate then start the anim
			if (!introAnimStarted && _brfManager.task == BRFStatus.FACE_ESTIMATION) {
				introAnimStarted = true;
				introAnimFinished = false;
				clip.rvline.alpha = .8;
				clip.rhline.alpha = .8;
				clip.rpupil.alpha = .9;
				clip.lvline.alpha = .8;
				clip.lhline.alpha = .8;
				clip.lpupil.alpha = .9;
				meshAlpha = .8;
				introAlpha = .975; //decrement multiplier
				animInc = 250;
			}
			
			if(!introAnimFinished && introAnimStarted ){
				
				BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
				meshAlpha *= introAlpha;
				
				if (meshAlpha < .03) {
					//done
					introAnimFinished = true;
					clip.rvline.visible = false;
					clip.rhline.visible = false;
					clip.rpupil.visible = false;
					clip.lvline.visible = false;
					clip.lhline.visible = false;
					clip.lpupil.visible = false;
				}
				/*
				//no mesh per Nick
				//draw face mesh
				_draw.lineStyle(0.5, 0x000000, meshAlpha);
				_draw.beginFill(0x00ff66, meshAlpha * .6);
				_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles);
				_draw.lineStyle();
				_draw.endFill();
				*/
				//track eyes with crosshairs			
				_pointsToShow = _brfManager.faceShape.shapePoints;				
				
				clip.rvline.alpha = meshAlpha;
				clip.rhline.alpha = meshAlpha;
				clip.rpupil.alpha = meshAlpha;
				clip.rvline.x = 337 + (_pointsToShow[28].x * 2) + animInc;
				clip.rhline.y = 20 + (_pointsToShow[28].y * 2) + animInc;
				clip.rpupil.x = 330 + (_pointsToShow[28].x * 2) + animInc;
				clip.rpupil.y = 20 + (_pointsToShow[28].y * 2) + animInc;
				
				clip.lvline.alpha = meshAlpha;
				clip.lhline.alpha = meshAlpha;
				clip.lpupil.alpha = meshAlpha;
				clip.lvline.x = 337 + (_pointsToShow[33].x * 2) + animInc;
				clip.lhline.y = 20 + (_pointsToShow[33].y * 2) + animInc;
				clip.lpupil.x = 330 + (_pointsToShow[33].x * 2) + animInc;
				clip.lpupil.y = 20 + (_pointsToShow[33].y * 2) + animInc;
				
				animInc -= 12;
				if (animInc <= 0) {
					animInc = 0;
				}
			}
			/*
			messageCounter++;
			if (messageCounter == 3) {
				messageCounter = 0;
				message();
			}
			*/
		}

		
		private function message(mess:String = null):void
		{
			if (mess == null) {
				var ind:int = Math.floor(messages.length * Math.random());
				mess = messages[ind];
				if (Math.random() < .5) {
					mess += ": " + String(Math.random());
				}
			}
			
			clip.textHolder.previewText.text = mess;			
		}

		
		public function setFace(texture : BitmapData, uvData : Vector.<Number>) : void {
			_texture = texture;
			_uvData = uvData;
		}
		
	}
}