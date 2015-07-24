package com.gmrmarketing.comcast.book3d
{
	import flare.basic.*;
	import flare.collisions.*;
	import flare.core.*;
	import flare.events.*;
	import flare.modifiers.*;
	import flare.primitives.*;
	
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Vector3D;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var sceneContainer:Sprite;
		
		private var model:Pivot3D;
		private var book:Pivot3D;
		private var page:Pivot3D;
		
		private var tweenObject:Object;
		private var initRotation:Vector3D;
		
		
		
		
		public function Main()
		{
			sceneContainer = new Sprite();
			tweenObject = { r:0 };
			
			_scene = new Scene3D(sceneContainer);
			_scene.clearColor = new Vector3D ();
			_scene.antialias = 16;
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			model = _scene.addChildFromFile("xfin.zf3d");
		}
		
		
		private function mapLoaded(e:Event):void
		{
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			addChildAt(sceneContainer,0);//behind book click sprites			
		
			_camera = _scene.camera;
			//_camera.fieldOfView = 54;
			
			bookL.addEventListener(MouseEvent.MOUSE_DOWN, bookLClicked);
			bookM.addEventListener(MouseEvent.MOUSE_DOWN, bookMClicked);
			bookR.addEventListener(MouseEvent.MOUSE_DOWN, bookRClicked);
		}
		
		
		private function openBook():void
		{
			page.setRotation(initRotation.x, initRotation.y, initRotation.z + tweenObject.r);
		}
		
		
		private function bookLClicked(e:MouseEvent):void
		{
			var mesh:Mesh3D = model.getChildByName("bookL") as Mesh3D;			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			
			page = skin.root.getChildByName( "Page_L" );
			tweenObject.r = 0;
			initRotation = page.getRotation();
			
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:openBook } );
		}
		
		private function bookMClicked(e:MouseEvent):void
		{
			var mesh:Mesh3D = model.getChildByName("bookM") as Mesh3D;			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			
			page = skin.root.getChildByName( "Page_L" );
			tweenObject.r = 0;
			initRotation = page.getRotation();
			
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:openBook } );
		}
		
		private function bookRClicked(e:MouseEvent):void
		{
			var mesh:Mesh3D = model.getChildByName("bookR") as Mesh3D;			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			
			page = skin.root.getChildByName( "Page_L" );
			tweenObject.r = 0;
			initRotation = page.getRotation();
			
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:openBook } );
		}
	}
	
}