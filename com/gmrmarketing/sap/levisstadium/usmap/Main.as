package com.gmrmarketing.sap.levisstadium.usmap
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready"; //scheduler requires the READY event to be the string "ready"
		
		//Flare3D extension
		private var _scene : Scene3D;
		private var _camera : Camera3D;
		private var map:Pivot3D;
		
		
		public function Main()
		{
			_scene = new Scene3D(this);
			//_scene.setViewport(0, 0, 1280,720);
			_scene.antialias = 8;
			//_scene.pause();
			
			map = _scene.addChildFromFile("usmap3.zf3d");
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
		}
		
		
		private function mapLoaded(e:Event):void
		{
			//_scene.camera.translateZ(-1000);
			
			var t:Pivot3D = _scene.getChildByName("Texas");
			t.setScale(1, 1, 20);
			
			_scene.forEach(doTrace);
		}
		
		
		private function doTrace(p:Pivot3D):void
		{
			trace(p.name);
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function setConfig(config:String):void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{
		
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			
		}
	}
	
}