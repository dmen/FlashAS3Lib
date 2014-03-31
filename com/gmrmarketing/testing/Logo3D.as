package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.geom.*;
	import flash.events.*;
	
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ShadingColorMaterial;
	import away3d.materials.WireColorMaterial;
	import away3d.materials.WireframeMaterial;
	import away3d.lights.AmbientLight3D;
	import away3d.core.base.Object3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.utils.Cast;	
	import away3d.primitives.Cube;
	import away3d.lights.*;
	
	public class Logo3D extends MovieClip
	{
		private var view:View3D;
		private var light:AmbientLight3D;
		private var cube:Cube;
		
		public function Logo3D()
		{			
			view = new View3D();
			view.x = 400;
			view.y = 200;
			
			cube = new Cube( { width:200, height:200, depth:200, segmentsH:3, segmentsW:3 } );			
			
			view.camera.moveTo(0, 0, -1500);
			view.camera.lookAt(new Vector3D(0, 0, 0));
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addChild(view);
			
			view.scene.addChild(cube);
		}
		
		private function onEnterFrame( e: Event ):void  
		{    
			view.render();
		}
		
	}	
}