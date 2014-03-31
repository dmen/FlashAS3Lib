package com.tastenkunst.as3.brf.examples {
	import com.tastenkunst.as3.brf.container.*;
	import com.tastenkunst.as3.brf.BRFUtils;
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.filters.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	
	/**
	 * This examples does the whole job. 
	 * Flare3D, Away3D and Away3DLite are available at the moment.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcam3D extends BRFBasicView
	{				
		public var _container3D : BRFContainerFP11;		
			
		[Embed(source="C:\\Users\\dmennenoh\\Desktop\\texture_wacko.png")]
		public var IMAGE_WACKO : Class;
		[Embed(source="C:\\Users\\dmennenoh\\Desktop\\uv_wacko.txt", mimeType="application/octet-stream")]
		public var UVDATA_WACKO : Class;
		
		//currently used texture/data
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);		
				
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;
		
		
		public function ExampleWebcam3D() {
			super();	
		}

		
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);			
			
			_faceShapeVertices = BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			_faceShapeTriangles = BRFUtils.getFaceShapeTriangles();
			
			_faceDetectionROI = _brfManager.vars.faceDetectionVars.faceDetectionROI;
			_leftEyeDetectionROI = _brfManager.vars.faceDetectionVars.leftEyeDetectionROI;			
			_rightEyeDetectionROI = _brfManager.vars.faceDetectionVars.rightEyeDetectionROI;
			
			//true seems to cause the shape to morph too quickly into an invalid state
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = false;
			
			_texture = (new IMAGE_WACKO() as Bitmap).bitmapData;
			_uvData = Vector.<Number>((new UVDATA_WACKO()).toString().split(","));
			
			_brfReady = true;	
			
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
			
			_cameraManager.initCamera();
			//webcam apps should stabilize slow movements, so the objects don't jitter too much.
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = true;	
		}
		
		
		
		/** Init the 3D content overlay. */
		override public function initContentContainer() : void 
		{			
			_containerDrawMask = new Sprite();
			_containerDrawMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;			
				
			_container3D = new Flare3D_v2_5(_containerContent);
			_container3D.init(new Rectangle(0, 0, 640, 480));			
			_container3D.initVideo(_videoManager.videoData);
			_container3D.initOcclusion("media/f3d/brf_fp11_occlusion_head.zf3d");
			_container3D.model = "media/f3d/helmet_football.zf3d";			
			
			_contentContainer = _container3D;
			
			_containerContent.addChild(_containerDraw);
			_containerContent.addChild(_containerDrawMask);	
		}
		
		
		//update the 3d webcam video plane, when there is a new image from the webcam
		override public function onVideoUpdate() : void 
		{			
			_brfManager.update();			
			_container3D.updateVideo();		
			showResult();	
		}
		
		override public function showResult(showAll : Boolean = false):void
		{
			var i : int;
			var l : int;	
			
			BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			
			_draw.clear();
			//drawing the extracted texture
			_draw.lineStyle();
			_draw.beginBitmapFill(_texture);
			_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles, _uvData);
			_draw.endFill();
			
			//getting the outline of the face shape mask
			calculateFaceOutline();
			
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
			//and drawing the mouse whole into the blurry mask
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
		
		
		private function calculateFaceOutline() : void 
		{
			var shapePoints:Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center:Point = shapePoints[67];
			var tmpPointShape:Point;
			var tmpPointOutline:Point;
			var fac:Number = 0.08;
			var i:int = 0;
			var l:int = 18;

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
		}
		
	}
}