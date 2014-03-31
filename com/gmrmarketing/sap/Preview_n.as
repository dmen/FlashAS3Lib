package com.gmrmarketing.sap
{	
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import com.tastenkunst.as3.brf.container.*;
	import com.gmrmarketing.utilities.CamPic;
	import flash.display.*;	
	import flash.events.*;
	import flash.geom.*;
	import flash.media.Camera;
	import flash.utils.getTimer;
	import flash.filters.*;
	import com.greensock.TweenMax;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	
	
	public class Preview_n extends EventDispatcher 
	{		
		public static const SHOWING:String = "previewShowing";
		public static const TAKE_PHOTO:String = "btnTakePhoto";
		
		private var _brfManager:BeyondRealityFaceManager;
		private var _contentContainer:BRFContainer;
		
		private var _containerContent:Sprite;	
		private var _containerDraw:Sprite;		
		private var _draw:Graphics;
		
		private var _faceDetectionROI:Rectangle;
		private var _leftEyeDetectionROI:Rectangle;
		private var _rightEyeDetectionROI:Rectangle;
		private var _faceShapeVertices:Vector.<Number>;
		private var _faceShapeTriangles:Vector.<int>;		
	
		[Embed(source="C:\\Users\\dmennenoh\\Desktop\\texture_wacko.png")]
		private var IMAGE_WACKO:Class;
		[Embed(source="C:\\Users\\dmennenoh\\Desktop\\uv_wacko.txt", mimeType="application/octet-stream")]
		private var UVDATA_WACKO:Class;
		
		//currently used texture/data
		private var _uvData:Vector.<Number>;
		private var _texture:BitmapData;
		
		private const _outlinePoints:Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints:Vector.<Point> = new Vector.<Point>(11, true);		
				
		private var _containerDrawMask:Sprite;
		private var _drawMask:Graphics;
		private var cam:CamPic;
		private var _container3D:BRFContainerFP11;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var faceContainer:Sprite; //holds BRF containers
		private var ulPreview:Bitmap; //small upper left camera preview
		private var facePreview:Bitmap;
		private var textureMatrix:Matrix;
		
		
		public function Preview_n() 
		{
			clip = new mcPreview();
			
			facePreview = new Bitmap(new BitmapData(593, 774, false, 0x000000));
			clip.addChild(facePreview);
			facePreview.x = 657;
			facePreview.y = 164;
			
			faceContainer = new Sprite();
			faceContainer.x = 657;
			faceContainer.y = 163;
			clip.addChild(faceContainer);
			
			ulPreview = new Bitmap(new BitmapData(440, 330, false, 0x000000));
			clip.addChild(ulPreview);
			ulPreview.x = 100;
			ulPreview.y = 275;
			
			textureMatrix = new Matrix();
			textureMatrix.scale(2, 2);
			textureMatrix.translate(-343, -93);
			
			_containerDraw = new Sprite();
			_containerContent = new Sprite();			
			_draw = _containerDraw.graphics;
			
			//faceContainer.addChild(_containerDraw);
			faceContainer.addChild(_containerContent);
			
			_containerDrawMask = new Sprite();
			_containerDrawMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;
		}		
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;			
		}
		
		
		public function show():void
		{			
			if (container) {
				if (!container.contains(clip)) {
					container.addChild(clip);					
				}
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );			
			
			cam = new CamPic();
			cam.init(1280, 960, 440, 330, 640, 480, 36);//cam res, capture res, display res, fps				
				
			_container3D = new Flare3D_v2_5(_containerContent);
			_container3D.init(new Rectangle(0, 0, 640, 480));
			_container3D.initVideo(cam.getCameraDirect());			
			_container3D.initOcclusion("c:/beyondreality/bin/media/f3d/brf_fp11_occlusion_head.zf3d");
			//_container3D.model = "c:/beyondreality/bin/media/f3d/brf_fp11_glasses_blue.zf3d";
			_container3D.model = "c:/beyondreality/bin/media/f3d/helmet_football.zf3d";
			
			_contentContainer = _container3D;
			
			//_containerContent.addChild(_containerDraw);
			//_containerContent.addChild(_containerDrawMask);	
			
			_brfManager = new BeyondRealityFaceManager(container.stage);
			_brfManager.addEventListener(Event.INIT, onInitBRF);
		}
		
		
		private function showing():void
		{			
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function onInitBRF(e:Event = null):void 
		{
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			_brfManager.init(cam.getCameraDirect(), _contentContainer);
		}		
		
		
		private function onReadyBRF(e:Event = null):void 
		{
			_brfManager.removeEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			
			_faceShapeVertices = BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			_faceShapeTriangles = BRFUtils.getFaceShapeTriangles();			
			_faceDetectionROI = _brfManager.vars.faceDetectionVars.faceDetectionROI;
			_leftEyeDetectionROI = _brfManager.vars.faceDetectionVars.leftEyeDetectionROI;			
			_rightEyeDetectionROI = _brfManager.vars.faceDetectionVars.rightEyeDetectionROI;			
			
			_texture = (new IMAGE_WACKO() as Bitmap).bitmapData;
			_uvData = Vector.<Number>((new UVDATA_WACKO()).toString().split(","));
			
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

			for (var i:int = 0; i < _outlinePoints.length; i++) {
				_outlinePoints[i] = new Point();
			}			
			
			//init the webcam
			cam.addEventListener(CamPic.CAMERA_UPDATE, onCamUpdate);
			cam.beginUpdating();//starts timer so CAMERA_UPDATE event is dispatched			
			
			//webcam apps should stabilize slow movements, so the objects don't jitter too much.
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = false;				
		}
		
		
		private function onCamUpdate(e:Event):void 
		{			
			_brfManager.update();
			_container3D.updateVideo();
			ulPreview.bitmapData = cam.getCapture();//small cam preview at upper left
			var b:BitmapData = cam.getCamera();//1280x960
			facePreview.bitmapData.copyPixels(b, new Rectangle(343, 93, 593, 774), new Point(0, 0));
			facePreview.bitmapData.draw(_containerDraw, textureMatrix);
			showResult();
		}
		
		
		private function showResult():void 
		{			
			var i:int;
			var l:int;	
			var shapePoints:Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center:Point = shapePoints[67];
			var tmpPointShape:Point;
			var tmpPointOutline:Point;
			var fac:Number = 0.08;			
			
			BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			
			_draw.clear();			
			_draw.lineStyle();
			_draw.beginBitmapFill(_texture);
			_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles, _uvData);
			_draw.endFill();
			
			//getting the outline of the face shape mask
			//inlined from calculateFaceOutline()
			i = 0;
			l = 18;
			for (i = 0; i < l; i++) {
				tmpPointShape = shapePoints[i];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
			var k:int = 23;
			l = _outlinePoints.length;
			for (; i < l; i++, k--) {
				tmpPointShape = shapePoints[k];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
			//inlined calculateFaceOutline()
			
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
			//and drawing the mouth whole into the blurry mask
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
	}
}
