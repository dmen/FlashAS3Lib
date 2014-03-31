/**
 * Simple car is used in the interface
 */
package com.gmrmarketing.smartcar
{	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import away3d.core.utils.Cast;
	import away3d.cameras.*;
	import away3d.loaders.*;
	import away3d.lights.*;
	import away3d.core.render.Renderer;
	//import away3d.debug.AwayStats;
	import away3d.events.Loader3DEvent;
	import away3d.loaders.data.GeometryData;
	import away3d.loaders.data.MaterialData;
	import away3d.loaders.utils.MaterialLibrary;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import flash.events.*;
	
	//lib images
	import baseMap;
	import baseMask;
	import baseShadow;
	
	
	public class SimpleCar extends EventDispatcher
	{
		public static const CAR_LOADED:String = "CarWasLoaded";
		
		private var container:DisplayObjectContainer;
		private var view:View3D;
		private var myScene:Scene3D;
		private var camera:Camera3D;
		private var meshContainer:ObjectContainer3D;
		private var mat:PhongBitmapMaterial;	
		private var car:Loader3D;
		
		private var appliedMap:BitmapData; //the composed final texture applied to the car in update()
		private var carData:BitmapData; //the base map texture for the car
		private var maskData:BitmapData; //mask for copying scope image into composed texture
		private var shadowData:BitmapData; //shadow lines for the car	
		
		private var carBody:Object3D;
		private var flWheel:Object3D;
		private var frWheel:Object3D;
		private var blWheel:Object3D;
		private var brWheel:Object3D;
		
		private var modelIsLoaded:Boolean = false;
		
		
		
		public function SimpleCar($container:DisplayObjectContainer):void
		{
			container = $container;
			
			//library images
			carData = new baseMap(); 
			maskData = new baseMask();
			shadowData = new baseShadow();
			
			//final map applied to car - matches base map dimensions
			appliedMap = new BitmapData(1500, 1500);
			
			camera = new Camera3D({zoom:37, focus:30, x:83, y:45, z:-83});
			camera.lookAt(new Vector3D(0, 0, 0));
			
			myScene = new Scene3D();
			view = new View3D( { scene:myScene, camera:camera } );
			
			//add the FPS and memory meter for testing			
			//addChild(new AwayStats(view));
			
			car = Collada.load("smart2.xml"); //.xml for web - or need to add .dae to mime types
			car.addEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded, false, 0, true);		
			car.addEventListener(Loader3DEvent.LOAD_ERROR, modelLoadingError, false, 0, true);
			
			container.addChild(view);				
		}
		
		/**
		 * For Testing - allows changing the cameras zoom,x,y,z properties
		 * @param	zm
		 * @param	nx
		 * @param	ny
		 * @param	nz
		 */
		public function changeCam(zm:Number,nx:int,ny:int,nz:int):void
		{			
			camera.zoom = zm;
			camera.x = nx;
			camera.y = ny;
			camera.z = nz;
			camera.lookAt(new Vector3D(0, 0, 0));
			trace(zm, nx, ny, nz);
		}
		
		
		/**
		 * Called by Main.updateFromTool() when the tool = pattern
		 * @param	newTex
		 */
		public function updateTexture(newTex:BitmapData = null):void
		{
			appliedMap.draw(carData);
			if(newTex != null){
				appliedMap.copyPixels(newTex, newTex.rect, new Point(0, 0), maskData, new Point(0, 0), true);
			}
			appliedMap.draw(shadowData);			
			
			mat = new PhongBitmapMaterial (appliedMap, { shininess:50, specular:0xFFFFFF } );			
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;
		}
		
		private function modelLoadingError(e:Loader3DEvent):void
		{
			car.removeEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded);		
			car.removeEventListener(Loader3DEvent.LOAD_ERROR, modelLoadingError);
			trace("Model Load error.", e);
		}
		
		private function modelLoaded(e:Loader3DEvent):void
		{	
			meshContainer = ObjectContainer3D(e.loader.handle);
			
			car.removeEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded);		
			car.removeEventListener(Loader3DEvent.LOAD_ERROR, modelLoadingError);
			
			carBody = meshContainer.getChildByName("ID9");
			
			flWheel = meshContainer.getChildByName("ID45");
			blWheel = meshContainer.getChildByName("ID36");
			frWheel = meshContainer.getChildByName("ID27");
			brWheel = meshContainer.getChildByName("ID18");			
			
			mat = new PhongBitmapMaterial( new baseMap());			
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;			
			
			modelIsLoaded = true;
			dispatchEvent(new Event(CAR_LOADED));
		}
		
		/**
		 * Adds mesh to scene and begins calling render per frame
		 * This must be called after modelLoaded() has completed
		 */
		public function show():void
		{		
			if(modelIsLoaded){
				myScene.addChild(meshContainer);			
				container.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			}
		}
		
		
		public function hide():void
		{	
			myScene.removeChild(meshContainer);			
			container.removeEventListener(Event.ENTER_FRAME, update);
			view.render();
		}
		
		/**
		 * Renders the current camera view
		 * @param	e
		 */
		private function update(e:Event):void
		{		
			//spin the wheels			
			flWheel.rotationX += 8;
			//frWheel.rotationX += 8;
			blWheel.rotationX += 8;
			//brWheel.rotationX += 8;			
			
			view.render();
		}
	}
	
}