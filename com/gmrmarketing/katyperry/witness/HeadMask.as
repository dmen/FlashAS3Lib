package com.gmrmarketing.katyperry.witness
{
	import brfv4.BRFFace;
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Light3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.LightFilter;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import flare.utils.Matrix3DUtils;

	import flash.display.*;	
	import flash.events.*;
	import flash.geom.*;
	
	
	public class HeadMask extends Sprite
	{
		private var scene : Scene3D;
		private var camera : Camera3D;		
		private var modelZ : int;		
		private var renderWidth : int;
		private var renderHeight : int;	
		private var light : Light3D;		
		
		private var daveHolder:Pivot3D;//parent for head1 and head2
		private var head1:Pivot3D;
		private var head2:Pivot3D;
		
		
		public function HeadMask(resolution:Rectangle)
		{
			scene = new Scene3D(this);
			scene.antialias = 2;
			scene.allowImportSettings = false;
			
			camera = new Camera3D();
			camera.orthographic = true;			
			
			modelZ = 2000;
			
			daveHolder = new Pivot3D();
			head1 = getHolder();
			head2 = getHolder();
			
			daveHolder.addChild(head1);
			daveHolder.addChild(head2);
			
			scene.addChild(daveHolder);	
			
			scene.lights.maxDirectionalLights = 1;
			scene.lights.maxPointLights = 1;
			scene.lights.techniqueName = LightFilter.PER_VERTEX;
			scene.lights.defaultLight.color.setTo(0.25, 0.25, 0.25);
			
			light = new Light3D("scene_light", Light3D.POINT);
			light.setPosition(150, 150, 0);
			light.infinite = true;
			light.color.setTo(255 / 255, 253 / 255, 244 / 255);
			light.multiplier = 1.0;
			
			scene.addChild(light);
			
			loadModels();
			
			updateLayout(resolution.width, resolution.height);
		}
		
		
		public function updateLayout(width : int, height : int) : void 
		{	
			renderWidth = width;
			renderHeight = height;
	
			scene.setViewport(0, 0, width, height, 2);
			
			camera.projection = Matrix3DUtils.buildOrthoProjection(
				-width * 0.5, 
				 width * 0.5,
				-height * 0.5,
				 height * 0.5, 
				 0, 10000
			);
			camera.setPosition(0, 0, 0);
			camera.lookAt(0, 0, 1);
			camera.near = 10;
			camera.far = 5000;
			
			scene.camera = camera;
		}
		
		
		public function update(index:int, face:BRFFace, show:Boolean):void 
		{
			//if (!daveHolder) return;
				
			var s : Number =  (face.scale / 180);
			var x : Number =  (face.translationX - (renderWidth  * 0.5));
			var y : Number = -(face.translationY - (renderHeight * 0.5));
			var z : Number =  modelZ;

			var rx : Number = -face.rotationX * 57.29577951308233;//radians to degrees
			var ry : Number = face.rotationY * 57.29577951308233;
			var rz : Number = -face.rotationZ * 57.29577951308233;
			
			// Some fiddling around with the angles to get a better rotated 3d model.
			
			if(rx > 0) {
				rx = rx * 1.35 + 5;
				//rz = rz / 2.00;	
			} else {
				var ryp : Number = Math.abs(ry) / 40.0;
				rx = rx * (1.0 - ryp * 1.0) + 5;
			}				
			
			//daveHolder.transform.identity();
			daveHolder.setPosition(x,y,z);
			daveHolder.setScale(s,s,s);
			daveHolder.setRotation(rx, ry, rz);//tilts head down
		}
		
		
		public function render() : void {
			scene.render();
		}
		
		public function showHead1():void
		{
			head1.show();
			head2.hide();
		}
		
		
		public function showHead2():void
		{
			head2.show();
			head1.hide();
		}
		
		
		public function loadModels():void
		{
			scene.addEventListener(Scene3D.COMPLETE_EVENT, headLoaded);			
			scene.addChildFromFile("assets/maleHead.zf3d", head1);
			scene.addChildFromFile("assets/female.zf3d", head2);
		}
		
		
		private function headLoaded(e:Event):void
		{
			head2.hide();			
			//scene.removeEventListener(Scene3D.COMPLETE_EVENT, headLoaded);			
		}
		
		
		private function getHolder() : Pivot3D {
			var p : Pivot3D = new Pivot3D();
		
			p.setPosition(-5, -20, 125);
			p.setScale(1.5, 1.6, 1.2);
			p.setRotation(-20, 0, 0);
		
			return p;
		}

	
		public function getScreenshot() : BitmapData 
		{			
			var bmd : BitmapData = new BitmapData(scene.viewPort.width, scene.viewPort.height, true, 0x00000000);
			
			scene.context.clear();
			
			//onRender();
			
			scene.render();
			scene.context.drawToBitmapData(bmd);
			
			return bmd;
		}
	}	
}