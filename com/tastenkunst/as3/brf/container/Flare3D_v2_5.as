package com.tastenkunst.as3.brf.container {	
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
	public class Flare3D_v2_5 extends BRFContainerFP11 {
		public const LOADED:String = "modelLoaded";
		
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
		private var currentTeam:String;
		
		
		public function Flare3D_v2_5(container : Sprite) {
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
		
		public function setTeam(team:String):void
		{
			currentTeam = team;
		}
		
		//Stage3D is not transparent. We need to create a video plane and map the video bitmapdata to it.
		override public function initVideo(bitmapData : BitmapData) : void {
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
			var f : Number = 1.16;//1.015;
			
			head.setPosition(pos.x + 1.5, pos.y + 10, pos.z + 15);
			head.setScale(scale.x * f, scale.y * f, scale.z * f);
			
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
					_holder.setPosition(4,45,56);
					_holder.setRotation(-10,0,0);
					//_holder.setScale(1.2, 1.2, 1.2);
					_holder.setScale(33,33,33);
					_holder.name = "_holder_" + model;
					_baseNode.addChild(_holder);
					_scene.addEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
					_scene.addChildFromFile(model, _holder);
				}
			}			
			_model = model;
		}
		
		override public function get model() : String {
			return _model;
		}
		//loading is complete
		override protected function onCompleteLoading(e : Event) : void {
			_scene.removeEventListener(Scene3D.COMPLETE_EVENT, onCompleteLoading);
			_scene.camera = _camera;
			_scene.resume();
			_scene.lights.defaultLight = null;
			_scene.lights.maxPointLights = 3;
			//trace(_scene.lights.list[0].x,_scene.lights.list[0].scaleX);
			//changeHelmet(currentTeam);
			
//			traceChildren(_scene, ">");
//			trace("-------");
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
		
		
		override public function getScreenshot() : BitmapData 
		{
			var bmd : BitmapData = new BitmapData(_scene.viewPort.width, _scene.viewPort.height);
					
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
		
		public function getAlphaShot():BitmapData
		{
			var maskBottom:BitmapData = new suit2();// whiteBottom();/// - suit2 has neck alpha
			var mm:Matrix = new Matrix();
			mm.scale(1.2, 1.2);//matches scale done in jerseyBMD in exampleWebcam3D
			var maskScaled:BitmapData = new BitmapData(854, 934, true, 0x00000000);
			maskScaled.draw(maskBottom, mm, null, null, null, true);
			
			var bmd:BitmapData = new BitmapData(_scene.viewPort.width, _scene.viewPort.height);
			//var bmd2:BitmapData = new BitmapData(_scene.viewPort.width, _scene.viewPort.height, true, 0x00000000);
			_videoPlane.visible = false;
			_scene.context.clear();
			// we draw into the texture without any color, just to store depth buffer values.
			//_scene.context.setColorMask( false, false, false, false );
			_scene.render();
			_scene.context.drawToBitmapData(bmd);			
			
			var out:BitmapData = new BitmapData(_scene.viewPort.width, _scene.viewPort.height, true);			

			bmd.copyPixels(maskScaled, new Rectangle(0, 0, maskScaled.width, maskScaled.height), new Point(150,1), maskScaled, null, true);
			
			//out.threshold(bmd, new Rectangle(0, 0, bmd.width, bmd.height), new Point(0, 0), "==", 0xff000000, 0x00000000, 0xffFFFFFF, true);			
			out.threshold(bmd, new Rectangle(0, 0, bmd.width, bmd.height), new Point(0, 0), "!=", 0xFF000000, 0x00000000, 0xFFFFFFFF, true);			
			
			var filter:BlurFilter = new BlurFilter(5, 5, 2);
			out.applyFilter(out, new Rectangle(0,0,out.width,out.height), new Point(0, 0), filter);
			 
			_videoPlane.visible = true;
			return out;
		}
		
		//cardinals, falcons, ravens, bills, panthers, bears, bengals, browns, cowboys, broncos, lions, packers, texans, colts, jaguars, chiefs, dolphins, vikings, patriots, saints, giants, jets, raiders, eagles, steelers, chargers, seahawks, 49ers, rams, buccaneers, titans, redskins
		public function changeHelmet(team:String):void
		{
			helmetShader = _scene.getMaterialByName( "ID15" ) as Shader3D;
			//stripeShader = _scene.getMaterialByName( "ID5" ) as Shader3D;
			//maskShader = _scene.getMaterialByName( "ID20" ) as Shader3D;
			
			//var stripe:Pivot3D = _scene.getChildByName("TopStripes01");			
			//stripe.visible = true;			
			
			switch(team) {
				case "cardinals":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetArizonaCardinals.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeArizonaCardinals.jpg" );
					setMask(0xa5acaf);					
					break;
				case "falcons":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetAtlantaFalcons.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeAtlantaFalcons.jpg" );
					setMask(0x111c24);
					break;
				case "ravens":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetBaltimoreRavens.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeBaltimoreRavens.jpg" );
					setMask(0x111c24);
					break;
				case "bills":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetBuffaloBills.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeBuffaloBills.jpg" );
					setMask(0xffffff);
					break;
				case "panthers":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetCarolinaPanthers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeCarolinaPanthers.jpg" );
					setMask(0x111c24);
					break;
				case "bears":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetChicagoBears.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeChicagoBears.jpg" );
					setMask(0x031e2f);
					break;
				case "bengals":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetCincinnatiBengals.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeCincinnatiBengals.jpg" );
					//stripe.visible = false;
					setMask(0x111c24);
					break;
				case "browns":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetClevelandBrowns.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeClevelandBrowns.jpg" );
					setMask(0xffffff);
					break;
				case "cowboys":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetDallasCowboys.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeDallasCowboys.jpg" );
					setMask(0xffffff);
					break;
				case "broncos":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetDenverBroncos.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeDenverBroncos.jpg" );
					setMask(0x002147);
					break;
				case "lions":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetDetroitLions.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeDetroitLions.jpg" );
					setMask(0x111c24);
					break;
				case "packers":
					//helmetShader.filters[0].texture = new Texture3D( path + "HelmetGreenBayPackers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeGreenBayPackers.jpg" );
					//setMask(0x2c5e4f);
					break;
				case "texans":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetHoustonTexans.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeHoustonTexans.jpg" );
					setMask(0x031e2f);
					break;
				case "colts":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetIndianapolisColts.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeIndianapolisColts.jpg" );
					setMask(0xffffff);
					break;
				case "jaguars":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetJacksonvilleJaguars.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeJacksonvilleJaguars.jpg" );
					setMask(0x111c24);
					break;
				case "chiefs":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetKansasCityChiefs.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeKansasCityChiefs.jpg" );
					setMask(0xffffff);
					break;
				case "dolphins":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetMiamiDolphins.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeMiamiDolphins.jpg" );
					setMask(0x006265);
					break;
				case "vikings":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetMinnesotaVikings.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeMinnesotaVikings.jpg" );
					setMask(0x4b306a);
					break;
				case "patriots":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetNewEnglandPatriots.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeNewEnglandPatriots.jpg" );
					setMask(0xc60c30);
					break;
				case "saints":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetNewOrleansSaints.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeNewOrleansSaints.jpg" );
					setMask(0x111c24);
					break;
				case "giants":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetNewYorkGiants.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeNewYorkGiants.jpg" );
					setMask(0xffffff);
					break;
				case "jets":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetNewYorkJets.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeNewYorkJets.jpg" );
					setMask(0x2c5e4f);
					break;
				case "raiders":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetOaklandRaiders.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeOaklandRaiders.jpg" );
					setMask(0xffffff);
					break;
				case "eagles":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetPhiladelphiaEagles.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripePhiladelphiaEagles.jpg" );
					setMask(0x111c24);
					break;
				case "steelers":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetPittsburghSteelers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripePittsburghSteelers.jpg" );
					setMask(0x111c24);
					break;
				case "chargers":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetSanDiegoChargers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeSanDiegoChargers.jpg" );
					setMask(0x002244);
					break;
				case "seahawks":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetSeattleSeahawks.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeSeattleSeahawks.jpg" );
					setMask(0x011831);
					break;
				case "49ers":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetSanFrancisco49ers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeSanFrancisco49ers.jpg" );
					setMask(0xffffff);
					break;
				case "rams":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetStLouisRams.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeStLouisRams.jpg" );
					setMask(0x002147);
					break;
				case "buccaneers":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetTampaBayBuccaneers.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeTampaBayBuccaneers.jpg" );
					setMask(0x111c24);
					break;
				case "titans":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetTennesseeTitans.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeTennesseeTitans.jpg" );
					setMask(0x002147);
					break;
				case "redskins":
					helmetShader.filters[0].texture = new Texture3D( path + "HelmetWashingtonRedskins.jpg" );
					//stripeShader.filters[0].texture = new Texture3D( path + "StripeWashingtonRedskins.jpg" );
					setMask(0xffb612);
					break;
			}			
			_scene.freeMemory();			
		}
		
		
		private function setMask(color:uint):void
		{
			maskShader = _scene.getMaterialByName( "ID20" ) as Shader3D;
			var b:BitmapData = new BitmapData(64, 64, false, color);
			var t:Texture3D = new Texture3D();
			t.bitmapData = b;
			maskShader.filters[0].texture = t;
		}
		
	}
}