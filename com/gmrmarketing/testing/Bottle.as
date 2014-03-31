package com.gmrmarketing.testing
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	
	
	
	public class Bottle extends Sprite
	{

		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;

		//material objects
		private var material:ColorMaterial;

		//scene objects
		private var plane:Plane;
	



		/**
		 * Global initialise function
		 */
		public function Bottle():void
		{
			initEngine();
			initMaterials();
			initObjects();
			initListeners();
		}
		

		/**
		 * Initialise the engine
		 */
		function initEngine():void
		{
			scene = new Scene3D();
			
			//camera = new Camera3D({z:-1000});
			camera = new Camera3D();
			camera.z = -1000;
			
			//view = new View3D({scene:scene, camera:camera});
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			
			//view.addSourceURL("srcview/index.html");
			addChild(view);			
			view.x = stage.stageWidth / 2;
			view.y = stage.stageHeight / 2;
		}

		/**
		 * Initialise the materials
		 */
		function initMaterials():void
		{
			material = new ColorMaterial(0xCC0000);
		}

		/**
		 * Initialise the scene objects
		 */
		function initObjects():void
		{
			//plane = new Plane({material:material, width:500, height:500, yUp:false, bothsides:true});
			plane = new Plane();
			plane.material = material;
			plane.width = 500;
			plane.height = 500;
			plane.yUp = false;
			plane.bothsides = true;
			scene.addChild(plane);
		}

		/**
		 * Initialise the listeners
		 */
		function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/**
		 * Navigation and render loop
		 */
		function onEnterFrame( e:Event ):void
		{
			plane.rotationY += 2;
			
			view.render();
		}
	}
}