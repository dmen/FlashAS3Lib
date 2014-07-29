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
	import flare.materials.*;
	import flare.materials.filters.*;
	import com.greensock.TweenMax;
	
	
	public class Main2 extends MovieClip implements ISchedulerMethods
	{
		//Flare3D extension
		private var _scene : Scene3D;
		private var _camera : Camera3D;
		private var map:Pivot3D;
		
		private var orangeCirc:Texture3D;
		private var blueCirc:Texture3D;
		private var grayCirc:Texture3D;
		private var orangeMat:Shader3D;
		private var blueMat:Shader3D;
		private var grayMat:Shader3D;
		
		private var orangeFilter:TextureMapFilter;
		private var blueFilter:TextureMapFilter;
		private var grayFilter:TextureMapFilter;
		
		private var baseHeight:Number = 38;
		
		
		public function Main2()
		{
			_scene = new Scene3D(this);
			//_scene.setViewport(0, 0, 1280,720);
			_scene.antialias = 8;
			_scene.setLayerSortMode(10, Scene3D.SORT_BACK_TO_FRONT);
			
			map = _scene.addChildFromFile("cali.zf3d");
			
			orangeMat = new Shader3D();
			blueMat = new Shader3D();
			grayMat = new Shader3D();
			
			orangeCirc = _scene.addTextureFromFile("orangeCirc.png");			
			blueCirc = _scene.addTextureFromFile("blueCirc.png");			
			grayCirc = _scene.addTextureFromFile("grayCirc.png");			
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, buildMaterials );
		}
		
		
		private function buildMaterials(e:Event):void
		{			
			orangeFilter = new TextureMapFilter(orangeCirc);			
			orangeMat.filters = [orangeFilter];
			orangeMat.filters.push( new AlphaMaskFilter( .7 ));
			orangeMat.build();
			orangeMat.twoSided = true;
			orangeMat.transparent = true;
			orangeMat.blendMode = 2;
			
			blueFilter = new TextureMapFilter(blueCirc);			
			blueMat.filters = [blueFilter];
			blueMat.filters.push( new AlphaMaskFilter( .7 ));
			blueMat.build();
			blueMat.twoSided = true;
			blueMat.transparent = true;
			blueMat.blendMode = 2;
			
			grayFilter = new TextureMapFilter(grayCirc);			
			grayMat.filters = [grayFilter];
			grayMat.filters.push( new AlphaMaskFilter( .7 ));
			grayMat.build();
			grayMat.twoSided = true;
			grayMat.transparent = true;
			grayMat.blendMode = 2;
			
			//sf
			addLoc(37.82, 122.40, 250);
			addLoc(37.45, 122.40, 150);
			
			//la
			addLoc(33.55, 118.24, 400);
			//needles
			addLoc(34.85, 114.61, 80);
		}
		
		
		private function addLoc(lat:Number, lon:Number, scale:int):void
		{
			//lat lon of SF: 
			//north extent of cali is 42.0º
			//west extent is 124.41
			
			var latDelta:Number = 42.0 - lat;
			var lonDelta:Number = 124.41 - lon;
			
			var latMultiplier:Number = 31.012; //3D units (294) divided by total degrees of lat cali takes up (9.48º)
			var lonMultiplier:Number = 23.74; //3D units (245) divided by total degrees of lon cali takes up (10.32º)
			
			var z3D:Number = latDelta * latMultiplier * -1;
			var x3D:Number = lonDelta * lonMultiplier;
			
			var pl:Plane = new Plane("disc", 5, 5, 1);
			
			if(scale < 100){
				pl.setMaterial(grayMat);
			}else if (scale < 200) {
				pl.setMaterial(orangeMat);
			}else {
				pl.setMaterial(blueMat);
			}
			
			pl.setRotation(90, 0, 0);
			
			_scene.addChild(pl);
			pl.setPosition(x3D, baseHeight, z3D);
			baseHeight += .1;
			
			pl.setLayer(10);			
			
			TweenMax.to(pl, 1.5, { scaleX:8, scaleY:8 } );// , onComplete:kill, onCompleteParams:[pl] } );
		}
		
		
		private function kill(ob:*):void
		{
			_scene.removeChild(ob);
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