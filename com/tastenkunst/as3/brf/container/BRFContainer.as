package com.tastenkunst.as3.brf.container {
	import com.tastenkunst.as3.brf.IBRFContentContainer;
	import com.tastenkunst.as3.brf.poseestimation.ResultMatrix;
	import flash.events.EventDispatcher;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Basic class for all overlay containers.
	 * See the subclasses for Flash Player 10 and 11.
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class BRFContainer implements IBRFContentContainer {
		
		protected const _resetMatrix : ResultMatrix = new ResultMatrix();
		protected const _rawData : Vector.<Number> = new Vector.<Number>(16, true);
		protected var _container : Sprite;		

		public function BRFContainer(container : Sprite) {
			_container = container;
			_resetMatrix.setResetValues(Vector.<Number>([
				1.0,  0.0,   0.0,   0.0,
				0.0,  0.735, 0.677, 0.0,
				0.0, -0.677, 0.735, 500.0
			]));
			_resetMatrix.reset();
		}
		
		public function init(rect : Rectangle) : void {
		}
		
		public function updatePoseByEyes(pointLeftEyeCenter : Point, pointRightEyeCenter : Point, 
				task : int, nextTask : int) : void {
		}
		
		public function updatePose(m : ResultMatrix) : void {
		}		
		
		public function isValidPose() : Boolean {
			return true;
		}

		public function resetPose() : void {
			updatePose(_resetMatrix);
		}
	}
}
