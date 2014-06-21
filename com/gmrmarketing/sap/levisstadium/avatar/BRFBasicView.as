/**
 * Custom implementation of BRFBasicView taken from
 * com.tastenkunst.as3.brf.examples.BRFBasicView
 */
package com.gmrmarketing.sap.levisstadium.avatar 
{
	//import net.hires.debug.Stats;

	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.vars.FaceDetectionVars;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import com.tastenkunst.as3.brf.container.BRFContainer;
	import com.tastenkunst.as3.video.CameraManager;
	import com.tastenkunst.as3.video.ICameraHandler;
	import com.tastenkunst.as3.video.IVideoHandler;
	import com.tastenkunst.as3.video.VideoManager1280x960;
	import flash.display.Stage;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.utils.getTimer;

	/**
	 * @author Marcel Klammer, 2012
	 */
	public class BRFBasicView extends Sprite implements ICameraHandler, IVideoHandler {
		
		/** The camera manager reports, if the web cam is available */
		public var _cameraManager : CameraManager;
		/** The video manager draws the current web cam image and calls the BRF update handler */
		public var _videoManager : *;
		/** The library class, see the documentation of IBeyondRealityFace for more information. */
		public var _brfManager : BeyondRealityFaceManager;
		/** Holds the content that might be overlayed on top of the face, like 3D content. */
		public var _contentContainer : BRFContainer;
		/** Set to true, when BRF dispatched "ready". */
		public var _brfReady : Boolean = false;
		
		//GUI
		/** 
		 * Container for the video image, that gets drawn by the VideoManager, 
		 * might not be used, when the video image is drawn in 3D space (like with Stage3D).
		 */
		public var _containerVideo : Sprite;
		/** The container for the IBRFContentContainer. */
		public var _containerContent : Sprite;		
		/** All graphics will be drawn in this container. */
		public var _containerDraw : Sprite;		
		/** This is the graphics object of _containerDraw. */
		public var _draw : Graphics;
		/** Stats show the calculation time as red number in ms. */
		//public var _stats : Stats;
		
		//some drawing helpers
		/** Region of interest a face is searched in. */
		public var _faceDetectionROI : Rectangle;
		/** Region of interest the left eye has to be in. */
		public var _leftEyeDetectionROI : Rectangle;
		/** Region of interest the right eye has to be in. */
		public var _rightEyeDetectionROI : Rectangle;
		/** Helper for working with drawTriangles. */
		public var _faceShapeVertices : Vector.<Number>;
		/** Helper for working with drawTriangles. */
		public var _faceShapeTriangles : Vector.<int>;
		/** To know, whether the found face is in a valid position. */		
		public var _leftEyePoint : Point; 
		/** To know, whether the found face is in a valid position. */
		public var _rightEyePoint : Point; 
		
		public var _stage:Stage;
		
				
		public function BRFBasicView() {
			if(stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else {
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.quality = StageQuality.HIGH;
				stage.frameRate = 60;
				onAddedToStage();
			}
		}
		/** Init all components, when the stage is available. */
		public function onAddedToStage(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_stage = this.stage;
			initGUI();
			initVideoHandling();
			initContentContainer();
			initBRF();
		}
		/** Init the video and camera handling. */
		public function initVideoHandling() : void {
			_cameraManager = new CameraManager(this);
			_videoManager = new VideoManager1280x960();
		}
		/** Called, when the Camera is available. */
		public function onCameraActive(camera : Camera) : void {
			_videoManager.handler = this;
			_videoManager.attachInput(camera);
		}
		/** Called, when the Camera isn't available. */
		public function onCameraInactive() : void {
			_videoManager.handler = null;
			_videoManager.detachInput();
		}
		public function stopVid():void
		{
			//_videoManager.handler = null;
			_videoManager.detachInput();
		}
		public function startVid():void
		{
			_videoManager.attachInput(_cameraManager.getCamera());
			//_videoManager.handler = this;
		}
		/** Init GUI elements. */
		public function initGUI() : void {
			_containerVideo = new Sprite();
			_containerDraw = new Sprite();
			_containerContent = new Sprite();
			//_stats = new Stats();
			
			_draw = _containerDraw.graphics;
			//_stats.x = 640 - 70;
			//_stats.y = 380;
						
			addChild(_containerVideo);
			addChild(_containerDraw);
			addChild(_containerContent);
			//addChild(_stats);
		}		
		/** Override this method in order to use another IBRFContentContainer implementation. */
		public function initContentContainer() : void {
			_contentContainer = new BRFContainer(new Sprite());
		}
		/** Instantiates the Library and sets a listener to wait for the lib to be ready. */
		public function initBRF() : void {
			_brfManager = new BeyondRealityFaceManager(stage);
			_brfManager.addEventListener(Event.INIT, onInitBRF);
			_leftEyePoint = new Point();
			_rightEyePoint = new Point();
		}		
		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		public function onInitBRF(event : Event = null) : void {
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			
			//override the face detection regions of interest, if needed.
			_brfManager.init(_videoManager.videoData, _contentContainer);
		}
		/** BRF is now ready and the tracking is available. */
		public function onReadyBRF(event : Event = null) : void {
			_brfManager.removeEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			
			_faceShapeVertices = BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			_faceShapeTriangles = BRFUtils.getFaceShapeTriangles();
			_faceDetectionROI = _brfManager.vars.faceDetectionVars.faceDetectionROI;
			_leftEyeDetectionROI = _brfManager.vars.faceDetectionVars.leftEyeDetectionROI;
			_rightEyeDetectionROI = _brfManager.vars.faceDetectionVars.rightEyeDetectionROI;
			
			//true seems to cause the shape to morph too quickly into an invalid state
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = true;
			
			_brfReady = true;
		}
		/** This method is called to track faces. */
		//overridden by webcam3d_1280x960
		public function onVideoUpdate() : void {		
			
			if (_brfReady) {
				
				//var start : int = getTimer();
				_brfManager.update();
				//_stats.input = getTimer() - start;
				showResult();
			}
		}
		/** Draws what BRF analysed: LastDetectedFace/s, ROIs, FaceShape. */
		public function showResult(showAll : Boolean = false) : void {
			_draw.clear();
			/*
			if(showAll || _brfManager.task == BRFStatus.FACE_DETECTION) {
				drawROIs();
				drawLastDetectedFaces(0x66ff00);
				drawLastDetectedFace(0xff7900, 3.0, 0.9);		
			}
			*/
			
			//if(showAll || _brfManager.task == BRFStatus.FACE_ESTIMATION) {
				BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
				drawShape();
			//}
		}		
		/** Draws the resulting shape. */
		public function drawShape(color : Number = 0x66ff00, alpha : Number = 0.15, 
				lineColor : Number = 0x000000, lineThickness : Number = 0.5, lineAlpha : Number = 0.5) : void {
			_draw.lineStyle(lineThickness, lineColor, lineAlpha);
			_draw.beginFill(color, alpha);
			_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles);
			_draw.lineStyle();
			_draw.endFill();
			
			//draw eyes
			var rect : Rectangle = _brfManager.lastDetectedFace;
			
			if (rect != null) {
				/*
				BRFUtils.estimateEyes(rect, _leftEyePoint, _rightEyePoint);
				if(BRFUtils.areEyesValid(_leftEyePoint, _rightEyePoint)) {
					_draw.beginFill(0x12c326, 0.5);	
				} else {
					_draw.beginFill(0xc32612, 0.5);	
				}
				_draw.drawCircle(_leftEyePoint.x, _leftEyePoint.y, 5);
				_draw.drawCircle(_rightEyePoint.x, _rightEyePoint.y, 5);
				*/
			}
		}		
		/** Draw the last detected face. */
		public function drawLastDetectedFace(lineColor : Number = 0xff0000, 
				lineThickness : Number = 0.5, lineAlpha : Number = 0.5) : void {
			var rect : Rectangle = _brfManager.lastDetectedFace;

			if(rect != null) {
				_draw.lineStyle(lineThickness, lineColor, lineAlpha);
				_draw.drawRect(rect.x, rect.y, rect.width, rect.height);
				_draw.lineStyle();
				BRFUtils.estimateEyes(rect, _leftEyePoint, _rightEyePoint);
				if(BRFUtils.areEyesValid(_leftEyePoint, _rightEyePoint)) {
					_draw.beginFill(0x12c326, 0.5);	
				} else {
					_draw.beginFill(0xc32612, 0.5);	
				}
				_draw.drawCircle(_leftEyePoint.x, _leftEyePoint.y, 5);
				_draw.drawCircle(_rightEyePoint.x, _rightEyePoint.y, 5);
			}
			
			_draw.lineStyle();
			_draw.endFill();
		}
		/** Draw all last detected face references. */
		public function drawLastDetectedFaces(lineColor : Number = 0xff0000, 
				lineThickness : Number = 0.5, lineAlpha : Number = 0.5) : void {
			var rects : Vector.<Rectangle> = _brfManager.lastDetectedFaces;

			if(rects != null) {
				var i : int = 0;
				var l : int = rects.length;
				var rect : Rectangle;
				
				for(; i < l; i++) {
					rect = rects[i];
					_draw.lineStyle(lineThickness, lineColor, lineAlpha);
					_draw.drawRect(rect.x, rect.y, rect.width, rect.height);
				}
				_draw.lineStyle();
				_draw.endFill();
			}			
		}
		/** Draw the regions of interest. */
		public function drawROIs(lineThickness : Number = 0.5, lineAlpha : Number = 0.5) : void {
			_draw.lineStyle(lineThickness, 0xffde00, lineAlpha);
			_draw.drawRect(_faceDetectionROI.x, _faceDetectionROI.y, _faceDetectionROI.width, _faceDetectionROI.height);			
			_draw.lineStyle(lineThickness, 0x0079ff, lineAlpha);
			_draw.drawRect(_leftEyeDetectionROI.x, _leftEyeDetectionROI.y, _leftEyeDetectionROI.width, _leftEyeDetectionROI.height);			
			_draw.lineStyle(lineThickness, 0x79ff00, lineAlpha);
			_draw.drawRect(_rightEyeDetectionROI.x, _rightEyeDetectionROI.y, _rightEyeDetectionROI.width, _rightEyeDetectionROI.height);	
			_draw.lineStyle();	
		}
	}
}
