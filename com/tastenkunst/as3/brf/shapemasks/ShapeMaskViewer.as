package com.tastenkunst.as3.brf.shapemasks {
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.examples.BRFBasicWebcam;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	/**
	 * Shape mask viewer takes uv data and texture to view the mask
	 * using the face shape. The mouth is cut out.
	 * 
	 * There are some more texture examples in the assets folder.
	 * 
	 * Or generate your own textures using the ShapeMaskExporter.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ShapeMaskViewer extends BRFBasicWebcam {
		
		[Embed(source="assets/texture_wacko.png")]
		public var IMAGE : Class;
		
		[Embed(source="assets/uv_wacko.txt", mimeType="application/octet-stream")]
		public var UVDATA : Class;
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _uvData : Vector.<Number>;
		private var _texture : BitmapData;
		private var _containerDrawMask : Sprite;
		private var _drawMask : Graphics;

		public function ShapeMaskViewer() {
			super();
			setFace((new IMAGE() as Bitmap).bitmapData, Vector.<Number>((new UVDATA()).toString().split(",")));
		}

		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}

		override public function initGUI() : void {
			super.initGUI();

			_containerDrawMask = new Sprite();
			_containerDrawMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_containerDrawMask.cacheAsBitmap = true;
			_drawMask = _containerDrawMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _containerDrawMask;

			addChild(_containerDrawMask);
		}

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

		override public function showResult(showAll : Boolean = false) : void {
			showAll; //just to avoid a warning in eclipse
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
				calculateFaceOutline();
				//drawing the outline of the face shape for the burry mask
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
		}

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

		public function setFace(texture : BitmapData, uvData : Vector.<Number>) : void {
			_texture = texture;
			_uvData = uvData;
		}
	}
}