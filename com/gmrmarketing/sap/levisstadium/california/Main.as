package com.gmrmarketing.sap.levisstadium.california
{
	import flash.display.MovieClip;
	import flash.events.*;
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.primitives.*;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		//Flare3D extension
		private var _scene : Scene3D;
		private var _camera : Camera3D;
		private var map:Pivot3D;
		
		private var orangeCirc:Texture3D;
		private var orangeMat:Shader3D;
		
		
		public function Main()
		{
			_scene = new Scene3D(this);
			//_scene.setViewport(0, 0, 1280,720);
			//_scene.antialias = 8;
			//_scene.pause();
			
			map = _scene.addChildFromFile("cali.zf3d");
			
			orangeMat = new Shader3D();
			orangeCirc = _scene.addTextureFromFile("orangeCirc.png");			
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, tt );
		}
		
		
		private function tt(e:Event):void
		{			
			var tf:TextureMapFilter = new TextureMapFilter(orangeCirc);
			orangeMat.filters = [tf];
			var sp:Sphere = new Sphere("la", 5, 10);
			sp.setMaterial(orangeMat);
			
			_scene.addChild(sp);
			sp.setPosition(45.8, 33, -141.141);
			
			//lat lon of SF: 37.45N 122.40.48W
			
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