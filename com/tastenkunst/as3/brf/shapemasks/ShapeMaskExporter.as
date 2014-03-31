package com.tastenkunst.as3.brf.shapemasks {
	import com.adobe.images.PNGEncoder;
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.examples.BRFBasisImage;
	import com.tastenkunst.as3.brf.faceestimation.structs.Shape;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * This exporter analyses an image and sets face shape points onto it.
	 * These points can be rearranged, but most of the time they can be left like they are.
	 * 
	 * In the first step the big cross it a button to change to step 2 (view the extracted mask)
	 * In the second step the two big crosses are buttons to export the actual texture and the
	 * uv data for this texture.
	 * 
	 * When you saved both, you can use the ShapeMaskViewer to view your texture.
	 * 
	 * There is just a FDT launcher for this.
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class ShapeMaskExporter extends BRFBasisImage {
		
		/**
		 * Some example images. Guess who of those people wrote PhotoBoo? :)
		 * (http://7evenine.com/photoboo/)
		 * For best results use 640x480 images.
		 */
//		[Embed(source="assets/src/amy_winehouse.png")]
//		[Embed(source="assets/src/manson.png")]
//		[Embed(source="assets/src/marcel_klammer.png")]
//		[Embed(source="assets/src/michael_jackson.jpg")]
//		[Embed(source="assets/src/mona_lisa.png")]
//		[Embed(source="assets/src/tomek_augustyn.png")]
//		[Embed(source="assets/src/michael_jackson.jpg")]
		[Embed(source="assets/src/user_image.png")]
		private var IMAGE : Class;
		private var _imageData : BitmapData = new BitmapData(640, 480, false, 0x000000);
				
		private var _pointHolder : Sprite;
		private var _pointButtons : Vector.<Sprite> = new Vector.<Sprite>();
		
		private const _outlinePoints : Vector.<Point> = new Vector.<Point>(21, true);
		private const _mouthHolePoints : Vector.<Point> = new Vector.<Point>(11, true);
		private var _uvData : Vector.<Number> = new Vector.<Number>();
		private var _texture : BitmapData;
		
		private var _drawingContainerMask : Sprite;
		private var _drawMask : Graphics;
		
		private var MODUS_EXPORTER : int = 0;
		private var MODUS_VIEWER : int = 1;
		private var _modus : int = 0;
		
		public function ShapeMaskExporter() {
			super();
			scaleX = 2.0;
			scaleY = 2.0;
        }
		
		override public function initGUI() : void {
			super.initGUI();
			
			_pointHolder = new Sprite();
			addChild(_pointHolder);
		}
		
		override public function initVideoHandling() : void {
			_image = new IMAGE();
			_image.pixelSnapping = PixelSnapping.AUTO;
			_image.smoothing = true;
			
			//move the image in the center of the 640x480 BitmapData
			var matrix : Matrix = new Matrix(1, 0, 0, 1, 
				int((_imageData.width  - _image.width)  * 0.5), 
				int((_imageData.height - _image.height) * 0.5));
			_imageData.draw(_image, matrix, null, null, null, true);
			//setting the centered BitmapData as image content
			_image.bitmapData = _imageData;
			
			super.initVideoHandling();
			
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		
		override public function initContentContainer() : void {
			//We don't create a dummy content container. BRF already contains one. 
		}
				
		override public function onReadyBRF(event : Event = null) : void {
			//we don't need 3d pose estimation here, so disable it
			_brfManager.isEstimatingPose = false;
			_brfManager.vars.faceDetectionVars.minRectsToFind = 1;
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = true;
			//the face shape and its points
			var shape : Shape = _brfManager.faceShape;
			var shapePoints : Vector.<Point> = shape.shapePoints;
			//We want to cut out the mouth to have a better feeling while viewing the texture.
			//Without this, the mouth bitmapData would be stretched.
			_mouthHolePoints[0] = shape.pointsUpperLip[0];
			_mouthHolePoints[1] = shape.pointsLowerLip[5];
			_mouthHolePoints[2] = shape.pointsLowerLip[4];
			_mouthHolePoints[3] = shape.pointsLowerLip[3];
			_mouthHolePoints[4] = shape.pointsLowerLip[2];
			_mouthHolePoints[5] = shape.pointsLowerLip[1];
			_mouthHolePoints[6] = shape.pointsLowerLip[0];
			_mouthHolePoints[7] = shape.pointsUpperLip[4];
			_mouthHolePoints[8] = shape.pointsUpperLip[3];
			_mouthHolePoints[9] = shape.pointsUpperLip[2];
			_mouthHolePoints[10] = shape.pointsUpperLip[1];
			
			var i : int = 0;
			var l : int = _outlinePoints.length;
			while(i < l) {
				_outlinePoints[i] = new Point();				
				i++;
			}
			
			var button : ButtonIcon;
			i = 0;
			l = shapePoints.length;
			while(i < l) {
				button = new ButtonIcon();
				button.x = shapePoints[i].x;
				button.y = shapePoints[i].y;
				button.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownButton);
				
				_pointButtons.push(button);
				_pointHolder.addChild(button);
				
				i++;
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpStage);
			
			button = new ButtonIcon();
			button.scaleX = 5.0;
			button.scaleY = 5.0;
			button.x = 40;
			button.y = 150;
			button.addEventListener(MouseEvent.CLICK, onClickedExtract);
			
			_pointHolder.addChild(button);
			_pointHolder.visible = false;
			
			super.onReadyBRF(event);
		}
		override public function showResult(showAll : Boolean = false) : void {
			var i : int;
			var l : int;
			if(_modus == MODUS_EXPORTER) {
				//showing the results here
				super.showResult(showAll);
				//now you can rearrange the face shape points, if you want to.
				var shape : Shape = _brfManager.faceShape;
				var shapePoints : Vector.<Point> = shape.shapePoints;
				var button : Sprite;
				i = 0;
				l = shapePoints.length;
				while(i < l) {
					button = _pointButtons[i];
					button.x = shapePoints[i].x;
					button.y = shapePoints[i].y;
					i++;
				}
				_pointHolder.visible = true;
			}
			if(_modus == MODUS_VIEWER) {
				//a custom drawing to get rid of the mouth
				if(_texture && _brfManager.task == BRFStatus.FACE_ESTIMATION) {
					BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
					_draw.clear();
					_drawMask.clear();
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
				}
			}
		}
		//we need to mask the texture, so we need the outline of the face shape
		private function calculateFaceOutline() : void {
			var shapePoints : Vector.<Point> = _brfManager.faceShape.shapePoints;
			var center : Point = shapePoints[67];
			var tmpPointShape : Point;
			var tmpPointOutline : Point;
			var fac : Number = 0.08;
			var i : int = 0;
			var l : int = 18;
			
			for(i = 0; i < l; i++) {
				tmpPointShape = shapePoints[i];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
			var k : int = 23;
			l = _outlinePoints.length;
			for(; i < l; i++, k--) {
				tmpPointShape = shapePoints[k];
				tmpPointOutline = _outlinePoints[i];
				tmpPointOutline.x = tmpPointShape.x + (center.x - tmpPointShape.x) * fac;
				tmpPointOutline.y = tmpPointShape.y + (center.y - tmpPointShape.y) * fac;
			}
		}
		/**
		 * After rearranging the points, we have to save both (texture and uv data).
		 * Now you can view the generated mask.
		 * There is no possibily to go back and change the mask points.
		 * Feel free to implement this on your own.
		 */
		private function onClickedExtract(event : MouseEvent) : void {
			var shapePoints : Vector.<Point> = _brfManager.faceShape.shapePoints;
			var button : Sprite;
			var minX : int = int.MAX_VALUE;
			var maxX : int = int.MIN_VALUE;
			var minY : int = int.MAX_VALUE;
			var maxY : int = int.MIN_VALUE;
			var i : int = 0;
			//get the min and max bounds of the points
			for(i = 0; i < _pointButtons.length; i++) {
				button = _pointButtons[i];
				if(button.x < minX) minX = button.x;
				if(button.x > maxX) maxX = button.x;
				if(button.y < minY) minY = button.y;
				if(button.y > maxY) maxY = button.y;
				//setting the shapePoints to the set buttons.
				shapePoints[i].x = button.x;
				shapePoints[i].y = button.y;				
			}
			_pointHolder.visible = false;
			
			var texWidth : int = maxX - minX;
			var texHeight : int = maxY - minY;
			
			BRFUtils.getFaceShapeVertices(_brfManager.faceShape);
			
			for(i = 0; i < _faceShapeVertices.length; i++) {
				_uvData[i] = (_faceShapeVertices[i] - minX) / texWidth; i++;
				_uvData[i] = (_faceShapeVertices[i] - minY) / texHeight;
			}
			
			_texture = new BitmapData(texWidth, texHeight, true, 0xffffffff);
			_texture.copyPixels(_imageData, new Rectangle(minX, minY, texWidth, texHeight), new Point());
			
			_drawingContainerMask = new Sprite();
			_drawingContainerMask.filters = [new BlurFilter(8, 8, BitmapFilterQuality.HIGH)];
			_drawingContainerMask.cacheAsBitmap = true;
			_drawMask = _drawingContainerMask.graphics;
			_containerDraw.cacheAsBitmap = true;
			_containerDraw.mask = _drawingContainerMask;
			
			addChild(_drawingContainerMask);
			
			_videoManager.detachInput();
			_videoManager.mirrored = true;
			_cameraManager.initCamera();
			_modus = MODUS_VIEWER;
			
			button = new ButtonIcon();
			button.scaleX = 5.0;
			button.scaleY = 5.0;
			button.x = 40;
			button.y = 150;
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, onClickedExportImage);
			
			button = new ButtonIcon();
			button.scaleX = 5.0;
			button.scaleY = 5.0;
			button.x = 40;
			button.y = 230;
			addChild(button);
			button.addEventListener(MouseEvent.CLICK, onClickedExportUV);
		}

		private function onClickedExportUV(event : MouseEvent) : void {
			var fr : FileReference = new FileReference();
			fr.save(_uvData.toString(), "uv.txt");
		}

		private function onClickedExportImage(event : MouseEvent) : void {
			var texture : ByteArray = PNGEncoder.encode(_texture);
			var fr : FileReference = new FileReference();
			fr.save(texture, "texture.png");
		}

		private function onMouseUpStage(event : MouseEvent) : void {
			var i : int = 0;
			
			for(; i < _pointButtons.length; i++) {
				_pointButtons[i].stopDrag();
			}
		}

		private function onMouseDownButton(event : MouseEvent) : void {
			event.currentTarget.startDrag();
		}
	}
}