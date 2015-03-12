package com.tastenkunst.as3.brf.container {
	import com.tastenkunst.as3.brf.poseestimation.ResultMatrix;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * The Away3D v3.6 example is not optimized yet.
	 * It only shows, that/how you can use Away3D.
	 * I know the 3D model is shit, fill it with your own!
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class BRFContainerFP11 extends BRFContainer {
		
		protected var _far : int = 50000;
		protected var _fov : Number = 36.6;
				
		protected var _initialized : Boolean = false;
		protected var _model : String;
		protected var _models : Dictionary = new Dictionary();
		
		protected const _tmpRawData : Vector.<Number> = new Vector.<Number>(16, true);

		public function BRFContainerFP11(container : Sprite) {	
			trace("initbrfc");
			super(container);
		}
		
		override public function init(rect : Rectangle) : void {			
			_initialized = true;
			resetPose();
		}
		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
		public function initVideo(bitmapData : BitmapData) : void {
		}
		//And then update it, whenever the video was updated
		public function updateVideo() : void {
		}
		//more GPU power? Then let's hide the glasses bows behind a invisible head! 
		//(or any other object behind any other invisible object)
		public function initOcclusion(url : String) : void {
		}
		//We extract the occlusion object and remove it from the scene
		//the _scene ges a render event and handles drawing semi-automatically
		protected function onCompleteOcclusion(event : Event) : void {
		}
		
		override public function updatePose(matrix : ResultMatrix) : void {
			const rawData : Vector.<Number> = _rawData;

			//The rXX values define the rotation matrix. tx, ty, tz are the coords in 3D space.
			rawData[0] = matrix.r00; rawData[1] = matrix.r10; rawData[2] = matrix.r20; rawData[3] = 0;				
			rawData[4] = matrix.r01; rawData[5] = matrix.r11; rawData[6] = matrix.r21; rawData[7] = 0;				
			rawData[8] = matrix.r02; rawData[9] = matrix.r12; rawData[10] = matrix.r22; rawData[11] = 0;			
			rawData[12] = matrix.tx; rawData[13] = matrix.ty; rawData[14] = matrix.tz; rawData[15] = 1;
			
			onUpdateMatrix(rawData);
		}
		//Update the 3D containers here (_baseNode and _occlusionNode).
		protected function onUpdateMatrix(vec : Vector.<Number>) : void {
		}
		//here you can set bound the 3d objects may not exceed. Might be usefull is some cases. 
		override public function isValidPose() : Boolean {			
			return true;
		}
		//Add a model to the scene and remove previous ones
		public function set model(model : String) : void {			
		}
		//get the current model as URL
		public function get model() : String {
			return _model;
		}
		//If you need to set something after loading a model, do it here:
		protected function onCompleteLoading(event : Event) : void {
		}
		//Implement a screenshot function here
		public function getScreenshot() : BitmapData {
			throw new Error("Implement a screenshot behaviour here");
		}
	}
}
