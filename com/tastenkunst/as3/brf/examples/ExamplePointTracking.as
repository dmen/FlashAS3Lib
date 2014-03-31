package com.tastenkunst.as3.brf.examples {
	import net.hires.debug.Stats;

	import com.tastenkunst.as3.brf.pointtracking.PointTrackingManager;
	import com.tastenkunst.as3.video.CameraManager;
	import com.tastenkunst.as3.video.ICameraHandler;
	import com.tastenkunst.as3.video.IVideoHandler;
	import com.tastenkunst.as3.video.VideoManager;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.utils.getTimer;

	/**
	 * This is a basic example of the point tracking class.
	 * It starts up the lib, activates the webcam.
	 * You just have to click once to add a points.
	 * 
	 * You can change the tracking to be faster in onInitPT()
	 * and add 100 points on Click (see onClickedVideo)
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class ExamplePointTracking extends Sprite implements ICameraHandler, IVideoHandler {
		
		/** The camera manager reports, if the web cam is available */
		public var _cameraManager : CameraManager;
		/** The video manager draws the current web cam image and calls the BRF update handler */
		public var _videoManager : VideoManager;
		/** The library class, see the documentation of IPointTracking for more information. */
		public var _ptManager : PointTrackingManager;
		/** Set to true, when the point tracking dispatched "ready". */
		public var _ptReady : Boolean = false;
		
		// GUI
		/** 
		 * Container for the video image, that gets drawn by the VideoManager, 
		 * might not be used, when the video image is drawn in 3D space (like with Stage3D).
		 */
		public var _containerVideo : Sprite;
		/** All graphics will be drawn in this container. */
		public var _containerDraw : Sprite;
		/** This is the graphics object of _containerDraw. */
		public var _draw : Graphics;
		/** Stats show the calculation time as red number in ms. */
		public var _stats : Stats;
		
		// some drawing helpers
		/** The points that get tracked. */
		private var _points : Vector.<Point> = new Vector.<Point>();
		/** A temp point vector. */
		private var _tmpVector : Vector.<Point> = new Vector.<Point>();

		public function ExamplePointTracking() {
			if (stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else {
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.quality = StageQuality.HIGH;
				stage.frameRate = 36;
				onAddedToStage();
			}
		}

		/** Init all components, when the stage is available. */
		public function onAddedToStage(event : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

			initVideoHandling();
			initGUI();
			initPT();
		}

		/** Init the video and camera handling. */
		public function initVideoHandling() : void {
			_cameraManager = new CameraManager(this);
			_videoManager = new VideoManager();
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

		/** Init GUI elements. */
		public function initGUI() : void {
			_containerVideo = new Sprite();
			_containerDraw = new Sprite();
			_stats = new Stats();

			_draw = _containerDraw.graphics;
			_stats.x = 640 - 70;
			_stats.y = 380;

			addChild(_containerVideo);
			addChild(_containerDraw);
			addChild(_stats);

			_containerVideo.addChild(_videoManager.videoBitmap);
		}

		/** Instantiates the Library and sets a listener to wait for the lib to be ready. */
		public function initPT() : void {
			_ptManager = new PointTrackingManager(stage);
			_ptManager.addEventListener(Event.INIT, onInitPT);
		}

		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		public function onInitPT(event : Event = null) : void {
			_ptManager.removeEventListener(Event.INIT, onInitPT);
			_ptManager.addEventListener(PointTrackingManager.READY, onReadyPT);
			// More accurate - use it with adding one point at a point (see onClickedVideo)
			_ptManager.init(_videoManager.videoData, 12, 3, 50, 0.00006);
			//Faster - try this with adding 100 points (see onClickedVideo)
//			_ptManager.init(_videoManager.videoData, 10, 3, 10, 0.1);
		}

		/** BRF is now ready and the tracking is available. */
		public function onReadyPT(event : Event = null) : void {
			_ptReady = true;

			_containerVideo.addEventListener(MouseEvent.CLICK, onClickedVideo);
			_cameraManager.initCamera();
		}

		/** This method is called to track faces. */
		public function onVideoUpdate() : void {
			if (_ptReady) {
				var start : int = getTimer();
				_ptManager.update(_points);
				checkPoints();
				_stats.input = getTimer() - start;
				showResult();
			}
		}

		/** Draws the resulting/tracked points */
		public function showResult() : void {
			_draw.clear();

			var i : int = -1;
			var l : int = _points.length;
			var point : Point;

			_draw.beginFill(0xff9933);

			while (++i < l) {
				point = _points[i];
				_draw.drawCircle(point.x, point.y, 10);
			}

			_draw.endFill();
		}

		/** Click on the video to add points. */
		private function onClickedVideo(event : MouseEvent) : void {
			// Add 1 point:
			_points.push(new Point(event.localX, event.localY));

			//Add 100 points
//			var w : int = 100;
//			var step : int = 10;
//			var xStart : Number = event.localX - w * 0.5;
//			var xEnd : Number = event.localX + w * 0.5;
//			var yStart : Number = event.localY - w * 0.5;
//			var yEnd : Number = event.localY + w * 0.5;
//			var y : Number = yStart;
//			var x : Number = xStart;
//			
//			for(; y < yEnd; y += step) {
//				for(x = xStart; x < xEnd; x += step) {
//					_points.push(new Point(x, y));
//				}	
//			}
		}

		/**
		 * Checks, whether point got lost. You can define own parameters, maybe you
		 * want to check for boundaries etc.
		 */
		private function checkPoints() : void {
			// helper vector
			var tmpPoints : Vector.<Point> = _tmpVector;
			// point states
			var pointStates : Vector.<Boolean> = _ptManager.getPointStates();
			// old helper vector length
			var lt : int = tmpPoints.length;
			// current point vector length
			var l : int = _points.length;
			var l2 : int = pointStates.length;
			// counter
			var i : int = -1;
			var k : int = 0;
			var point : Point;

			// go through all points and check their status
			while (++i < l) {
				point = _points[i];

				if(i < l2 && // maybe you want to check against boundaries
						(point.x > 5 && point.x < 635 && point.y > 5 && point.y < 475) && 
						// or you just let optical flow tell you, which points were not trackable 
						pointStates[i]) {
					// store point for future use
					tmpPoints[k++] = point;
				}
			}

			// we don't need the rest of the helper vector, so delete it
			tmpPoints.splice(k, lt - k);
			// empty the point vector before refill
			_points.splice(0, l);
			l = tmpPoints.length;
			i = -1;

			// fill the point vector for the next round
			while (++i < l) {
				_points[i] = tmpPoints[i];
			}
		}
	}
}
