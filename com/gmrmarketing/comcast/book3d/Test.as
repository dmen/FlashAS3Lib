package com.gmrmarketing.comcast.book3d
{
	import flare.basic.Scene3D;
	import flare.core.*;
	import flare.materials.Shader3D;
	import flare.materials.filters.TextureMapFilter;
	import flare.primitives.Plane;
	import flare.primitives.Cube;
	import flash.display.*;
	import flash.geom.Vector3D;
	import flash.events.*;
	
	
	public class Test extends MovieClip
	{
		private var scene:Scene3D;
		
		public function Test()
		{
			scene = new Scene3D( this );
			scene.camera.setPosition( 10, 20, -30 );
			scene.camera.lookAt( 0, 0, 0 );
			scene.addChild( new Cube() );
		}
	}
	
}