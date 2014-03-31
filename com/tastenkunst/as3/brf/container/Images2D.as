package com.tastenkunst.as3.brf.container {
	import com.tastenkunst.as3.brf.BRFStatus;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * This is a simple 2D Container doing all the model (PNG files) work.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class Images2D extends BRFContainer {
				
		//transparent images extension
		private var _models : Dictionary; //all stored model containers
		private var _baseNode : Sprite; //base container to hold all ModelContainers
		
		//points for the resetting of the glasses, if the tracking gets lost
		private var _leftEyePoint : Point = new Point(278, 194);
		private var _rightEyePoint : Point = new Point(367, 194);
		
		public function Images2D(container : Sprite) {
			super(container);
		}
		
		override public function init(rect : Rectangle) : void {
			rect;//just to avoid a warning in eclipse
			_models = new Dictionary();
			_baseNode = new Sprite();
			_baseNode.alpha = 0.0;
			_container.addChild(_baseNode);
			
			var loader : Loader = new Loader();
			var request : URLRequest = new URLRequest("media/images/model.png");
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteImage);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
			loader.load(request);
		}
		//Reset method is called, when the tracking is lost/fails.
		override public function resetPose() : void {
			updatePoseByEyes(_leftEyePoint, _rightEyePoint, -1, -1);
		}
		//We only use the eyes' position to estimate the glasses.
		//If values are invalid, the glasses will be reseted.
		override public function updatePoseByEyes(pointLeftEyeCenter : Point, pointRightEyeCenter : Point, 
				task : int, nextTask : int) : void {
			var dist : Number = Point.distance(pointLeftEyeCenter, pointRightEyeCenter);
			
			if(dist == 0 || (task == nextTask && task == BRFStatus.FACE_DETECTION)) {
				resetPose();	
			} else {
				var rot : Number = Math.tan((pointRightEyeCenter.y - pointLeftEyeCenter.y) / (pointRightEyeCenter.x - pointLeftEyeCenter.x));
				var point : Point = Point.interpolate(pointLeftEyeCenter, pointRightEyeCenter, 0.5);
				var scale : Number = dist / 110;
				
				_baseNode.rotation = 0;
				_baseNode.x = point.x;
				_baseNode.y = point.y;
				_baseNode.rotation = rot * 180 / Math.PI;
				
				_baseNode.scaleX = scale;
				_baseNode.scaleY = scale;
				_baseNode.alpha = 1.0;
			}
		}
		//sets the image position in the container.
		private function onCompleteImage(event : Event) : void {
			var loader : Loader = event.currentTarget.loader;
			var bitmap : Bitmap = loader.content as Bitmap;
			bitmap.smoothing = true;
			bitmap.scaleX = 0.36;
			bitmap.scaleY = 0.36;
			bitmap.x = -int(bitmap.width / 2);
			bitmap.y = -int(bitmap.height / 2);
			_baseNode.addChild(bitmap);
		}
		
		private function onErrorImage(event : Event) : void {
			trace(event);
		}
	}
}
