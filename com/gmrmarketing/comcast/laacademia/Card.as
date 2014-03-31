package com.gmrmarketing.comcast.laacademia
{
	import flash.display.BitmapData;	
	import flash.display.Bitmap;	
	import away3d.primitives.Cube;
	import away3d.primitives.data.CubeMaterialsData;
	import away3d.materials.BitmapMaterial;	
	import away3d.events.MouseEvent3D;	
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	

	public class Card extends Cube
	{		
		private var cube:Cube;		
		
		private var frontMaterial:BitmapMaterial;
		private var backMaterial:BitmapMaterial;
		private var sideMaterial:BitmapMaterial;
		
		
		public function Card()
		{
			frontMaterial = new BitmapMaterial(new comcast(120, 80));
			frontMaterial.smooth = true;
			backMaterial = new BitmapMaterial(new versus(120, 80));
			backMaterial.smooth = true;
			sideMaterial = new BitmapMaterial(new blackMap(20,20));
			
			var cubedata:CubeMaterialsData = new CubeMaterialsData(
			{top:sideMaterial,
			bottom:sideMaterial,
			front:frontMaterial,
			back:backMaterial,
			left:sideMaterial,
			right:sideMaterial } );	
			
			cube = new Cube( { width:120, height:80, depth:2, faces:cubedata } );
			cube.name = "Hello";
			cube.addOnMouseDown(cubeClicked);			
		}
		
		
		
		private function cubeClicked(e:MouseEvent3D):void
		{
			trace(e.object.name);
			TweenLite.to(cube, .5, { rotationX:"180" } );
			//dispatchEvent(new Event("cube
		}
	}
}
