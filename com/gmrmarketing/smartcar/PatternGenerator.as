package com.gmrmarketing.smartcar
{
	import away3d.events.Loader3DEvent;
	import away3d.loaders.data.GeometryData;
	import away3d.loaders.data.MaterialData;
	import away3d.loaders.utils.MaterialLibrary;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.gmrmarketing.testing.Kaleidoscope;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import away3d.core.utils.Cast;
	import away3d.cameras.*;
	import away3d.loaders.*;	
	import away3d.core.render.Renderer;
	import away3d.debug.AwayStats;
	import flash.geom.Vector3D;
	
	
	public class PatternGenerator extends MovieClip 
	{
		private var kaleid:Kaleidoscope;
		private var view:View3D;
		private var myScene:Scene3D;
		private var camera:Camera3D;
		private var meshContainer:ObjectContainer3D;
		
		private var carBody:Object3D;
		private var flWheel:Object3D;
		private var frWheel:Object3D;
		private var blWheel:Object3D;
		private var brWheel:Object3D;
		
		private var mat:TransformBitmapMaterial;
		private var car:Loader3D;
		private var canUpdate:Boolean = false;		
		
		//library images used for composing the final texture
		private var carData:BitmapData;
		private var maskData:BitmapData;
		private var shadowData:BitmapData;
		private var appliedMap:BitmapData; //the composed final texture
		private var kaleidData:BitmapData;
		
		public function PatternGenerator()
		{			
			kaleid = new Kaleidoscope(this);
			k.setImage(new kaleid1());
			k.setControlArea(new Rectangle(j.x, j.y, j.width, j.height));
			k.start();
			
			carData = new baseMap();
			maskData = new baseMask();
			shadowData = new baseShadow();
			appliedMap = new BitmapData(1500, 1500);
			
			camera = new Camera3D({zoom:15, focus:30, x:100, y:50, z:-100});
			camera.lookAt(new Vector3D(0, 0, 0));
			
			myScene = new Scene3D();
			view = new View3D( { x:780, y:220, scene:myScene, camera:camera } );
			
			//add the FPS and memory meter for testing			
			//addChild(new AwayStats(view));
			
			mat = new TransformBitmapMaterial(new baseMap(), { smooth:true, repeat:true} );
			
			car = Collada.load("smart2.xml");
			car.addEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded, false, 0, true);					
			
			addChild(view);			
			
			repSlider.addEventListener(Event.CHANGE, changeRepeat, false, 0, true);
		}
		
		
		private function modelLoaded(e:Loader3DEvent):void
		{				
			meshContainer = ObjectContainer3D(e.loader.handle);
			myScene.addChild(meshContainer);
			
			carBody = meshContainer.getChildByName("ID9");
			
			flWheel = meshContainer.getChildByName("ID45");
			blWheel = meshContainer.getChildByName("ID36");
			frWheel = meshContainer.getChildByName("ID27");
			brWheel = meshContainer.getChildByName("ID18");
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;// TransformBitmapMaterial;
		}
		
		
		/**
		 * Called by ENTER_FRAME
		 * @param	e
		 */
		private function update(e:Event):void
		{	
			kaleidData = kaleid.getTile();
			
			appliedMap.draw(carData);
			appliedMap.copyPixels(kaleidData, kaleidData.rect, new Point(0, 0), maskData, new Point(0, 0), true);
			appliedMap.draw(shadowData);
			
			mat.bitmap = appliedMap;
			
			meshContainer.rotationY += 1;
			
			//spin the wheels
			flWheel.rotationX += 8;
			frWheel.rotationX += 8;
			blWheel.rotationX += 8;
			brWheel.rotationX += 8;
			
			view.render();
		}
		
		
		/**
		 * Called by Change event on slider
		 * @param	e CHANGE event
		 */
		private function changeRepeat(e:Event):void
		{
			//mat.scaleX = mat.scaleY = repSlider.value / 10;
		}
	}
}
	