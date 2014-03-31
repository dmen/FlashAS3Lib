package com.gmrmarketing.smartcar
{
	import away3d.events.Loader3DEvent;
	import away3d.loaders.data.GeometryData;
	import away3d.loaders.data.MaterialData;
	import away3d.loaders.utils.MaterialLibrary;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.gmrmarketing.smartcar.Kaleidoscope;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
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
	import away3d.debug.AwayStats;
	import flash.geom.Vector3D;
	
	
	public class KaleidTester extends MovieClip 
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
		
		//private var mat:TransformBitmapMaterial;
		//private var mat:EnviroBitmapMaterial ;
		private var mat:PhongBitmapMaterial;
		///private var tireMat:BitmapMaterial;
		private var car:Loader3D;
		private var canUpdate:Boolean = false;		
		
		//library images used for composing the final texture
		private var carData:BitmapData; //the base map texture for the car
		private var maskData:BitmapData; //mask for copying scope image into composed texture
		private var shadowData:BitmapData; //shadow lines for the car	
		private var kaleidData:BitmapData; //the current kaleidoscope image - set in update()
		private var appliedMap:BitmapData; //the composed final texture applied to the car in update()
		
		//contains the tiled kaleidscope
		private var tileData:BitmapData;
		private var tilingMatrix:Matrix;
		private var tiling:int = 1; //changed by slider: 1 - 6
		
		private var xTiling:int;
		private var yTiling:int;
		
		private var dLight:PointLight3D;
		
		
		
		public function KaleidTester()
		{	
			//stage.quality = StageQuality.LOW;
			
			//library images
			carData = new baseMap(); 
			maskData = new baseMask();
			shadowData = new baseShadow();
			
			//final map applied to car - matches base map dimensions
			appliedMap = new BitmapData(1500, 1500);
			
			tileData = new BitmapData(1500, 1500, false, 0xff000000);
			
			camera = new Camera3D({zoom:20, focus:30, x:100, y:50, z:-100});
			camera.lookAt(new Vector3D(0, 0, 0));
			
			myScene = new Scene3D();
			view = new View3D( { x:700, y:240, scene:myScene, camera:camera } );
			
			dLight = new PointLight3D( { x:0, y:200, z:100, brightness:5, ambient:30, diffuse:500, specular:180 } );			
			myScene.addLight(dLight);
			
			//add the FPS and memory meter for testing			
			//addChild(new AwayStats(view));
			
			//mat = new TransformBitmapMaterial(new baseMap(), { smooth:true, repeat:true} );
			
			//tireMat = new BitmapMaterial(new baseMap());
			
			car = Collada.load("smart2.xml");
			car.addEventListener(Loader3DEvent.LOAD_SUCCESS, modelLoaded, false, 0, true);					
			
			addChild(view);			
			
			repSlider.addEventListener(Event.CHANGE, changeRepeat, false, 0, true);
			
			k1.addEventListener(MouseEvent.CLICK, k1Image, false, 0, true);
			k2.addEventListener(MouseEvent.CLICK, k2Image, false, 0, true);
			k3.addEventListener(MouseEvent.CLICK, k3Image, false, 0, true);
			k4.addEventListener(MouseEvent.CLICK, k4Image, false, 0, true);
			k5.addEventListener(MouseEvent.CLICK, k5Image, false, 0, true);
			k6.addEventListener(MouseEvent.CLICK, k6Image, false, 0, true);
			k7.addEventListener(MouseEvent.CLICK, k7Image, false, 0, true);
			
			kaleid = new Kaleidoscope(this);			
			kaleid.setControlArea(new Rectangle(0, 0, 500, 500));
			k1Image();
			//getKaleidTile();
			kaleid.addEventListener(Kaleidoscope.KALEID_CHANGED, getKaleidTile, false, 0, true);
			kaleid.start();
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
			
			//carBody.materialLibrary.getMaterial("ID3").material = mat;
			
			mat = new PhongBitmapMaterial( new baseMap());			
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;
			
			getKaleidTile();
		}
		
		
		/**
		 * Called by listener when the kaleidscope changes
		 * Tiles the current kaleidoscope image into tileData
		 * @param	e Kaleidoscope.KALEID_CHANGED
		 */
		private function getKaleidTile(e:Event = null):void
		{
			//get 400x346 scope image
			kaleidData = kaleid.getTile();
			
			xTiling = Math.round(400 / tiling);
			yTiling = Math.round(346 / tiling);
			
			tilingMatrix = new Matrix();
			tilingMatrix.scale(xTiling / kaleidData.width, yTiling / kaleidData.height);
			
			var theTile:BitmapData = new BitmapData(xTiling, yTiling);
			theTile.draw(kaleidData, tilingMatrix, null, null, null, true);
			
			for (var row:int = 0; row < 1500 / yTiling; row++) {
				for (var col:int = 0; col < 1500 / xTiling; col++) {
					tileData.copyPixels(theTile, theTile.rect, new Point(xTiling * col, yTiling * row));
				}
			}
			
			appliedMap.draw(carData);
			appliedMap.copyPixels(tileData, tileData.rect, new Point(0, 0), maskData, new Point(0, 0), true);
			appliedMap.draw(shadowData);
			
			
			mat = new PhongBitmapMaterial (appliedMap, { shininess:50, specular:0xFFFFFF } );			
			var matData:MaterialData = meshContainer.materialLibrary.getMaterial("ID3");
			matData.material = mat;
		}
		
		
		/**
		 * These set the kaleidoscope base image and background color
		 */
		private function k1Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal()); //library image
			kaleid.changeBGColor(0xffffffff);			
		}
		private function k2Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal2()); //library image
			kaleid.changeBGColor(0xff000000);			
		}
		private function k3Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal3()); //library image
			kaleid.changeBGColor(0xffffffff);			
		}
		private function k4Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal4()); //library image
			kaleid.changeBGColor(0xffffffff);			
		}
		private function k5Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal5()); //library image
			kaleid.changeBGColor(0xffffffff);			
		}
		private function k6Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal6()); //library image
			kaleid.changeBGColor(0xff01364f);			
		}
		private function k7Image(e:MouseEvent = null):void
		{			
			kaleid.setImage(new kal7()); //library image
			kaleid.changeBGColor(0xffffffff);			
		}
		
		
		
		
		/**
		 * Updates the texture map applied to the car
		 * Composes three images into appliedMap
		 * 1. the base car texture map
		 * 2. the tileData from the kaleidoscope - uses the mask in maskData
		 * 3. the shadow map
		 * 
		 * @param	e ENTER_FRAME
		 */
		private function update(e:Event):void
		{			
			
			//mat.bitmap = appliedMap;
			//mat.updateTexture();
			
			meshContainer.rotationY += 1;
			
			//spin the wheels
			/*
			flWheel.rotationX += 8;
			frWheel.rotationX += 8;
			blWheel.rotationX += 8;
			brWheel.rotationX += 8;
			*/
			
			view.render();
		}
		
		
		/**
		 * Called by Change event on slider
		 * @param	e CHANGE event
		 */
		private function changeRepeat(e:Event):void
		{
			tiling = repSlider.value;
			getKaleidTile();
		}
	}
}
	