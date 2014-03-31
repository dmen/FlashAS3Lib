package com.tastenkunst.as3.brf.container {
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.assets.AssetType;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.OcclusionMaterial;
	import away3d.textures.BRFVideoTexture;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;

	/**
	 * A 3D container for Away3D v4.0
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class Away3D_v4_1 extends BRFContainerFP11 {
		
		private var _view : View3D;
		private var _baseNode : ObjectContainer3D;
		private var _occlusionNode : ObjectContainer3D;
		private var _holder : ObjectContainer3D;

		private var _videoPlaneTexture : BRFVideoTexture;
		private var _occlusionMaterial : OcclusionMaterial;
	
		public function Away3D_v4_1(container : Sprite) {			
			super(container);
			
			_far = 10000;
			_fov = 36.6;
		}
		
		override public function init(rect : Rectangle) : void {
			//Enable all file formats. So we don't need to care about obj, dae, awd etc.
			Parsers.enableAllBundled();
			
			_view = new View3D(null, new Camera3D(new PerspectiveLens(_fov)));
			_view.x = rect.x;
			_view.y = rect.y;
			_view.width = rect.width;
			_view.height = rect.height;
			_view.antiAlias = 4;
			//pause?
			_container.addChild(_view);
			
			_view.camera.lens.far = _far;
			_view.camera.position = new Vector3D(0, 0, 0);
			_view.camera.lookAt(new Vector3D(0, 0, 500));
			
			//make the occlusion head visible with new OcclusionMaterial(false);
			//or _occlusionMaterial.occlude = false; //maybe a toggle
			_occlusionMaterial = new OcclusionMaterial();
			
			_baseNode = new ObjectContainer3D();
			_view.scene.addChild(_baseNode);
			
			super.init(rect);
		}
		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
		override public function initVideo(bitmapData : BitmapData) : void {
			_videoPlaneTexture = new BRFVideoTexture(bitmapData, 1024, true);
			_view.background = _videoPlaneTexture;
		}
		//And then update it, whenever the video was updated
		override public function updateVideo() : void {
			_videoPlaneTexture.update();
			//The video image is updated after all other things were done.
			//So we render the view here once for every update.
			_view.render();
		}
		//more GPU power? Then let's hide the glasses bows behind a invisible head! 
		//(or any other object behind any other invisible object)
		override public function initOcclusion(url : String) : void {
			var l : Loader3D = new Loader3D();
			l.addEventListener(AssetEvent.ASSET_COMPLETE, onCompleteOcclusion);
			l.load(new URLRequest(url));
		}
		//We extract the occlusion object and remove it from the scene
		//the _scene ges a render event and handles drawing semi-automatically
		override protected function onCompleteOcclusion(event : Event) : void {
			var assetEvent : AssetEvent = event as AssetEvent;
			if (assetEvent.asset.assetType == AssetType.MESH) {
				var mesh : Mesh = (assetEvent.asset as Mesh);
				mesh.material = _occlusionMaterial;
				mesh.x = 3;
				mesh.y = 22;
				mesh.scale(1.07);
			
				_occlusionNode = new ObjectContainer3D();
				_occlusionNode.addChild(mesh);
				
				_view.scene.addChild(_occlusionNode);
			}
		}
		
		override protected function onUpdateMatrix(vec : Vector.<Number>) : void {
			if(_initialized) {
				_baseNode.transform.copyRawDataFrom(vec);
				_baseNode.transform.prependRotation(45, Vector3D.X_AXIS);
				_baseNode.transform = _baseNode.transform;
				
				if(_occlusionNode) {
					_occlusionNode.transform = _baseNode.transform;
				}
			}
		}
		/** here you can set bound the 3d objects may not exceed. Might be usefull is some cases. */
		override public function isValidPose() : Boolean {
			var validPose : Boolean = true;
			var pos : Vector3D = _baseNode.position;
			
			if(pos.x < -150 || pos.x > 150 || pos.y < -100 || pos.y > 150 || pos.z < 100 || pos.z > 900) {
				validPose = false;					
			}
			if(_baseNode.rotationY < -30 || _baseNode.rotationY > 30 || _baseNode.rotationZ < -30 || _baseNode.rotationZ > 30) {
				validPose = false;				
			}
		
			return validPose;
		}

		override public function set model(model : String) : void {
			if(_model != null) {				
				_baseNode.removeChild(_holder);
				_models[_model] = _holder;
				_model = null;
			}
			_holder = null;
			if(model != null) {
				var holderOld : ObjectContainer3D = _models[model];
				
				if(holderOld != null) {
					_holder = holderOld;					
					_baseNode.addChild(_holder);
				} else {
					_holder = new ObjectContainer3D();
					_baseNode.addChild(_holder);
					var l : Loader3D = new Loader3D();
					//We have to offset that model a little bit
					//if you use your own models, just realign it for your needs
					//don't forget the occlusion head, see aboth
					l.load(new URLRequest(model));
					l.x = 3;
					l.y = 22;
					l.scale(1.07);
					_holder.addChild(l);
				}
			}			
			_model = model;
		}

		override public function get model() : String {
			return _model;
		}

		override public function getScreenshot() : BitmapData {
			var bmd : BitmapData = new BitmapData(_view.width, _view.height);
			
			_view.renderer.queueSnapshot(bmd);
			_view.render();
			
			return bmd;
		}
	}
}
