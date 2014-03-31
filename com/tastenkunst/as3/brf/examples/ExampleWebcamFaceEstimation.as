package com.tastenkunst.as3.brf.examples {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * This example does the face detection and the face estimation. 
	 * No pose estimation here. But all face shape points are shown, so
	 * you can see, which point has which index.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcamFaceEstimation extends BRFBasicWebcam {
		
		//change to false to not show the numbers
		private var _showPoints : Boolean = false;
		private var _tfContainer : Sprite;
		private var _pointsToShow : Vector.<Point>;
		
		public function ExampleWebcamFaceEstimation() {
			super();
		}
		
		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		
		/**
		 * In this example we don't want to overlay the face shape, but want to
		 * draw all the shape points. That's why we don't calculate the 3d pose.
		 */
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			//disables pose estimation
			_brfManager.isEstimatingPose = false;
			
			//create all necessary TextFields etc.
			if(_showPoints) {
				createPointTextFields();
			}
		}
		/**
		 * The calculations are done and we draw the result on screen
		 * and addionally we position the points.
		 */
		override public function showResult(showAll : Boolean = false) : void {
			super.showResult(showAll);
			if(_showPoints) {
				showPoints();
			}
		}
		/** Create all necessary TextFields etc. */
		private function createPointTextFields() : void {
			//choose the point group you want to see
//			_pointsToShow = _brfManager.faceShape.pointsRightBrow;
//			_pointsToShow = _brfManager.faceShape.pointsRightEye;
//			_pointsToShow = _brfManager.faceShape.pointsLeftBrow;
//			_pointsToShow = _brfManager.faceShape.pointsLeftEye;
//			_pointsToShow = _brfManager.faceShape.pointsLowerLip;
//			_pointsToShow = _brfManager.faceShape.pointsUpperLip;
			_pointsToShow = _brfManager.faceShape.shapePoints;
			
			_tfContainer = new Sprite();
			addChild(_tfContainer);
			
			var tf : TextField;
			var i : int = 0;
			var l : int = _pointsToShow.length;
			
			while(i < l) {
				tf = new TextField();
				tf.textColor = 0xe75562;
				tf.text = i.toString();
				tf.width = tf.textWidth + 6;
				
				_tfContainer.addChild(tf);
				
				i++;
			}
		}
		/** Position the TextFiels. */
		private function showPoints() : void {
			var points : Vector.<Point> = _pointsToShow;
			var point : Point;
			var tf : TextField;
			var i : int = 0;
			var l : int = _tfContainer.numChildren;
			
			_draw.beginFill(0xb3f000);
			while(i < l) {
				point = points[i];
				_draw.drawCircle(point.x, point.y, 3);
				tf = _tfContainer.getChildAt(i) as TextField;
				tf.x = point.x;
				tf.y = point.y;
				
				i++;
			}
			_draw.endFill();
		}
	}
}
