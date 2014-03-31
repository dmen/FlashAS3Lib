package com.tastenkunst.as3.brf.simpleapps {
	import com.adobe.images.PNGEncoder;
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.examples.BRFBasicWebcam;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * This simple app shows you, how to use face textures for
	 * the face shape.
	 * You can find the layout elements in the FLA file (fla/BRFLayoutAssets.fla)
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class SimpleAppMasks extends BRFBasicWebcam {
		//these are two examples from our Halloween special
		[Embed(source="../shapemasks/assets/texture_wacko.png")]
		public var IMAGE_WACKO : Class;
		[Embed(source="../shapemasks/assets/texture_manson_no_eye.png")]
		public var IMAGE_MANSON : Class;
		
		[Embed(source="../shapemasks/assets/uv_wacko.txt", mimeType="application/octet-stream")]
		public var UVDATA_WACKO : Class;		
		[Embed(source="../shapemasks/assets/uv_manson.txt", mimeType="application/octet-stream")]
		public var UVDATA_MANSON : Class;
		//instantianted versions of the textures and data aboth
		private var _uvDataWacko : Vector.<Number>;
		private var _textureWacko : BitmapData;
		private var _uvDataManson : Vector.<Number>;
		private var _textureManson : BitmapData;
		//currently used texture/data
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		
		public var _layout : BRFLayoutMasks;
		public var _container3DHolder : Sprite;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;
		private var _rectHolder : Sprite;

		public function SimpleAppMasks() {
			super();
		}
		//add some buttons to the stage + preparing some masking
		override public function initGUI() : void {
			super.initGUI();
			
			_layout = new BRFLayoutMasks();
			_layout._btDownload.addEventListener(MouseEvent.CLICK, onClickedDownload);
			_layout._btWebcam.addEventListener(MouseEvent.CLICK, onClickedWebcam);
			_layout._btCam.addEventListener(MouseEvent.CLICK, onClickedSnapshot);
			_layout._bt0.addEventListener(MouseEvent.CLICK, onClickedLoadModel);
			_layout._bt1.addEventListener(MouseEvent.CLICK, onClickedLoadModel);
			
			addChild(_layout);
			
			_containerDrawMask = new Sprite();
			_containerDrawMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;

			addChild(_containerDrawMask);
			
			_rectHolder = new Sprite();
			addChildAt(_rectHolder, getChildIndex(_containerVideo) + 1);
		}
		//add the webcam video
		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		//we want to cut out the mouth to see our own mouth, these are the points
		override public function onReadyBRF(event : Event = null) : void {
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
			
			super.onReadyBRF(event);
		}
		//change the mask texture
		private function onClickedLoadModel(event : MouseEvent) : void {
			switch(event.currentTarget){
				case _layout._bt0: _texture = _textureWacko; _uvData = _uvDataWacko; break;
				case _layout._bt1: _texture = _textureManson; _uvData = _uvDataManson; break;
			}
			showResult();
		}
		//pause the whole tracking
		private function onClickedSnapshot(event : MouseEvent) : void {
			_videoManager.stop();
			
			_layout._btCam.visible = false;
			_layout._btWebcam.visible = true;
			_layout._btDownload.visible = true;
		}
		//restart the tracking
		private function onClickedWebcam(event : MouseEvent) : void {
			_brfManager.reset();
			_videoManager.start();
				
			_layout._btCam.visible = true;
			_layout._btWebcam.visible = false;
			_layout._btDownload.visible = false;
		}
		//Let's make a nice little screenshot and save it!
		private function onClickedDownload(event : MouseEvent) : void {
			var bmd : BitmapData = _videoManager.videoData.clone();
			bmd.draw(_containerDraw);
			var image : ByteArray = PNGEncoder.encode(bmd);
			var fr : FileReference = new FileReference();
			fr.save(image, "brf_snapshot.png");
		}
		//we don't need a IBRFContainer3D in this app, 
		//but we need to init the textures for the masks
		override public function initContentContainer() : void {			
			_textureWacko = (new IMAGE_WACKO() as Bitmap).bitmapData;
			_textureManson = (new IMAGE_MANSON() as Bitmap).bitmapData;
			
			_uvDataWacko = Vector.<Number>((new UVDATA_WACKO()).toString().split(","));
			_uvDataManson = Vector.<Number>((new UVDATA_MANSON()).toString().split(","));
			
			_texture = _textureWacko;
			_uvData = _uvDataWacko;
		}
		//no super.showResult() - we draw a mouth hole here
		override public function showResult(showAll : Boolean = false) : void {
			showAll; //just to avoid a warning in eclipse
			_rectHolder.graphics.clear();
			_draw.clear();
			_drawMask.clear();
			var i : int;
			var l : int;
			// no super.showResult() - we draw a mouth hole here
			//a custom drawing to get rid of the mouth
			if(_brfManager.task == BRFStatus.FACE_ESTIMATION) {
				BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
				//drawing the extracted texture
				_draw.lineStyle();
				_draw.beginBitmapFill(_texture);
				_draw.drawTriangles(_faceShapeVertices, _faceShapeTriangles, _uvData);
				_draw.endFill();
				
				//getting the outline of the face shape mask
				calculateFaceOutline();
				//drawing the outline of the face shape for the burry mask
				i = 1;
				l = _outlinePoints.length;				
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
			} else {
				var lineThickness : Number = 0.7;
				var lineAlpha : Number = 0.5;
				_rectHolder.graphics.lineStyle(lineThickness, 0xff7900, lineAlpha);
				_rectHolder.graphics.drawRect(_faceDetectionROI.x, _faceDetectionROI.y, _faceDetectionROI.width, _faceDetectionROI.height);			
				_rectHolder.graphics.lineStyle(lineThickness, 0x0079ff, lineAlpha);
				_rectHolder.graphics.drawRect(_leftEyeDetectionROI.x, _leftEyeDetectionROI.y, _leftEyeDetectionROI.width, _leftEyeDetectionROI.height);			
				_rectHolder.graphics.lineStyle(lineThickness, 0x79ff00, lineAlpha);
				_rectHolder.graphics.drawRect(_rightEyeDetectionROI.x, _rightEyeDetectionROI.y, _rightEyeDetectionROI.width, _rightEyeDetectionROI.height);
			}
		}
		//we need to calculate the masking outlines
		private function calculateFaceOutline() : void {
			var shapePoints : Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center : Point = shapePoints[67];
			var tmpPointShape : Point;
			var tmpPointOutline : Point;
			var fac : Number = 0.08;
			var i : int = 0;
			var l : int = 18;

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