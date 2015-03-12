package com.gmrmarketing.sap.nhl2015.avatar {	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.tastenkunst.as3.brf.container.BRFContainerFP11;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * A 3D container for Flare3D v2.0 version.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class Avatar_Flare3D_v2_5 extends BRFContainerFP11 {
		public const LOADED:String = "modelLoaded";
		public static const SHOT_READY:String = "maskReady";
		
		//Flare3D extension
		private var _scene : Scene3D;
		private var _camera : Camera3D;
		private var _occlusion : Pivot3D;
		private var _occlusionNode : Pivot3D;
		private var _baseNode : Pivot3D;
		private var _holder : Pivot3D;
		
		private var _videoPlane : Plane;
		private var _videoPlaneTexture : Texture3D;
		private var _videoPlaneMaterial : Shader3D;
		
		private var helmetShader:Shader3D;
		private var stripeShader:Shader3D;
		private var maskShader:Shader3D;
		
		private const path:String = "textures/";
		
		private var _planeFactor : int = 16;
		private var bmd : BitmapData;//for screenshot
		
		
		public function Avatar_Flare3D_v2_5(container : Sprite) {
			super(container);
			_far = 50000;
			_fov = 48.6;
		}
		public function clear():void
		{
			_scene.dispose();
		}
		override public function init(rect : Rectangle) : void 
		{
			_scene = new Scene3D(_container);
			_scene.setViewport(rect.x, rect.y, rect.width, rect.height, 8);
			_scene.antialias = 8;
			_scene.pause();
			
			bmd = new BitmapData(_scene.viewPort.width, _scene.viewPort.height);			
			
			_camera = new Camera3D();
			_camera.parent = null;
			_camera.far = _far;
			_camera.fieldOfView = _fov;
			_camera.setPosition(0, 0, 0);
			_camera.lookAt(0, 0, 500);
			_scene.camera = _camera;
			
			_occlusionNode = new Pivot3D(); 
			_occlusionNode.name = "_occlusionNode";
			_scene.addChild(_occlusionNode);
			
			_baseNode = new Pivot3D(); 
			_baseNode.name = "_baseNode";
			_baseNode.x = 3;
			_scene.addChild(_baseNode);
			
			super.init(rect);
		}		
		
		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
		override public function initVideo(bitmapData : BitmapData) : void
		{			
			_videoPlaneTexture = new Texture3D(bitmapData, true);
			_videoPlaneTexture.mipMode = Texture3D.MIP_NONE;
			
			_videoPlaneMaterial = new Shader3D("_videoPlaneMaterial", [new TextureMapFilter(_videoPlaneTexture)], false);
			_videoPlaneMaterial.twoSided = false;//was true???
			_videoPlaneMaterial.build();
			
			_videoPlane = new Plane("_videoPlane", 640 * _planeFactor, 480 * _planeFactor, 10, _videoPlaneMaterial, "+xy");
			_scene.addChild(_videoPlane);
				
			//Update scene elemente here, if you have to (right before rendering of the scene)
			var pos : Vector3D = _scene.camera.getPosition();
			var dir : Vector3D = _scene.camera.getDir();
			var rot : Vector3D = _scene.camera.getRotation();
			var planeDist : Number = (1 / _scene.camera.zoom * _scene.viewPort.width) * _planeFactor * 0.25; //0.5;
			
			_videoPlane.setPosition(
				pos.x + dir.x * planeDist, 
				pos.y + dir.y * planeDist, 
				pos.z + dir.z * planeDist);
			_videoPlane.setRotation(rot.x, rot.y, rot.z);
		}
		
		
		//And then update it, whenever the video was updated
		override public function updateVideo() : void {
			_videoPlaneTexture.uploadTexture();
		}
		
		
		//more GPU power? Then let's hide the glasses bows behind a invisible head! 
		//(or any other object behind any other invisible object)
		override public function initOcclusion(url : String) : void {
			_scene.addEventListener(Scene3D.COMPLETE_EVENT, onCompleteOcclusion);
			_scene.addChildFromFile(url, _occlusionNode);
		}
		
		
		//We extract the occlusion object and remove it from the scene
		//the _scene gets a render event and handles drawing semi-automatically
		override protected function onCompleteOcclusion(event : Event) : void {
			
			_scene.removeEventListener(Scene3D.COMPLETE_EVENT, onCompleteOcclusion);
			//if there is an occlusion object, we set it
			var head : Pivot3D = _occlusionNode.getChildByName("occlusion");
			var pos : Vector3D = head.getPosition();
			var scale : Vector3D = head.getScale();
			var f : Number = 1.08;// 1.016;//1.015;
			
			//head.setPosition(pos.x + 1.5, pos.y + 10, pos.z + 15);
			head.setPosition(pos.x+2, pos.y+10, pos.z+15);
			head.setScale(scale.x * 1.12, scale.y * f, scale.z * f);
			
			_occlusion = _occlusionNode;
			if(_occlusion != null) {
				_occlusion.parent = null;
				_occlusion.upload(_scene);
			}			
			
			_scene.addEventListener(Scene3D.RENDER_EVENT, onRender);
			_scene.resume();
		}
		
		
		//Setting the 2 holder of the models and the occlusion
		override protected function onUpdateMatrix(vec : Vector.<Number>) : void {
			if(_initialized) {
				_baseNode.transform.rawData = vec;
				_baseNode.transform.prependRotation(47, Vector3D.X_AXIS);
				_baseNode.updateTransforms(true);
				
				if(_occlusion) {
					_occlusion.transform.rawData = vec;
					_occlusion.transform.prependRotation(47, Vector3D.X_AXIS);
					_occlusion.updateTransforms(true);
				}
			}
		}
		
		
		/** here you can set bound the 3d objects may not exceed. Might be usefull is some cases. */
		override public function isValidPose() : Boolean {
			var validPose : Boolean = true;
			var pos : Vector3D = _baseNode.getPosition();
			var dir : Vector3D = _baseNode.getDir();
			
			if(pos.x < -150 || pos.x > 150 || pos.y < -100 || pos.y > 150 || pos.z < 100 || pos.z > 900) {
				validPose = false;					
			}
			if(dir.x < -0.45 || dir.x > 0.45 || dir.y < -0.40 || dir.y > 0.2) {
				validPose = false;				
			}
		
			return validPose;
		}
		
		
		/** Sets the model, which will be cached and reused. */
		override public function set model(model : String) : void {
			trace("modelset", model);
			_scene.pause();
			if(_model != null) {				
				_baseNode.removeChild(_holder);
				_models[_model] = _holder;
				_model = null;
			}
			_holder = null;
			if(model != null) {
				var holderOld : Pivot3D = _models[model];
				
				if(holderOld != null) {
					_holder = holderOld;					
					_baseNode.addChild(_holder);
					_scene.resume();
				} else {
					_holder = new Pivot3D();
					_holder.setPosition(5,16,17);
					_holder.setRotation(0,0,-1);					
					_holder.setScale(1.1, 1.12, 1.18);
					_holder.name = "_holder_" + model;
					_baseNode.addChild(_holder);
					_scene.addEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
					_scene.addChildFromFile(model, _holder);
				}
			}			
			_model = model;
		}
		
		
		override public function get model() : String 
		{
			return _model;
		}
		
		
		//loading is complete
		override protected function onCompleteLoading(e : Event) : void {
			trace("model complete loading");
			trace(_holder.x, _holder.y, _holder.z);
			
			_scene.removeEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
			_scene.camera = _camera;
			_scene.resume();
		}
		
		
		/** utility function to trace all children of the scene. */
		public function traceChildren(base : Pivot3D, prefix : String = null) : void {
			var i : int = 0;
			var l : int = base.children.length;
			var c : Pivot3D;
			
			for(; i < l; i++) {
				c = base.children[i];
				trace(prefix + "name: " + c.name);
				traceChildren(c, prefix + "> ");
			}
		}
		public function maxPointLights(n:int):void
		{
			_scene.lights.maxPointLights = n;
		}
		
		override public function getScreenshot() : BitmapData 
		{
			var bmd:BitmapData = new BitmapData(_scene.viewPort.width, _scene.viewPort.height);
			
			_scene.context.clear();
			_videoPlane.draw();
			
			if(_occlusion != null) {
				//... write it to the buffer, but hide all coming polys behind it
				_scene.context.setColorMask(false, false, false, false);
				_occlusion.draw();
				_scene.context.setColorMask(true, true, true, true);
			}
			
			_scene.render();
			_scene.context.drawToBitmapData(bmd);
			
			return bmd;
		}
		
		
		/**
		 * returns a bitmapData containing the helmet and occlusion object
		 * and alpha zero anywhere else called from Webcam3D_1280x960.shotReady()
		 * @return
		 */
		public function getMaskImage():BitmapData 
		{
			_scene.context.clear(0,0,0,0);
			
			bmd = new BitmapData(_scene.viewPort.width, _scene.viewPort.height, true);
			_videoPlane.visible = false;//hide webcam image
			
			_scene.setupFrame( _scene.camera );
			_holder.draw();
			//_videoPlane.draw();
			
			if(_occlusion != null) {
				//... write it to the buffer, but hide all coming polys behind it
				//_scene.context.setColorMask(false, false, false, false);
				_occlusion.draw();
				//_scene.context.setColorMask(true, true, true, true);
			}
			
			//_scene.render();
			_scene.context.drawToBitmapData(bmd);
			
			_videoPlane.visible = true;
			
			return bmd;			
		}

		
		//the occlusion magic goes here
		private function onRender(event : Event = null) : void {			
			//first: draw the video plane in the background
			_videoPlane.draw();
			//if there is an occlusion object, ...
			
			if(_occlusion != null) {
				//... write it to the buffer, but hide all coming polys behind it
				_scene.context.setColorMask(false, false, false, false);
				_occlusion.draw();				
				_scene.context.setColorMask(true, true, true, true);
			}
			//all objects, that where not drawn here, will be drawn by Flare3D automatically			
		}
		
	}
}