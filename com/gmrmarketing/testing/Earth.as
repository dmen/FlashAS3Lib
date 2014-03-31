package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.MovieClip;
	import flash.events.*;
	
	// import the required parts of Away3D
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import away3d.core.utils.Cast;
	import away3d.cameras.*;

	// import some filters we'll use later
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GlowFilter;
	
	import flash.ui.Multitouch;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;

	
	public class Earth extends MovieClip
	{
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var skies:Sphere;
		private var view:View3D;
		private var camera:HoverCamera3D;
		private const cameraSpeed:Number = 0.3; // Approximately same speed as mouse movement.
		

		public function Earth()
		{
			// Set the scene
			var scene:Scene3D = new Scene3D();
			
			// Create and set up the camera
			camera = new HoverCamera3D({zoom:2, focus:300, distance:400});
			camera.panAngle = -180;
			camera.tiltAngle = 15;
			camera.hover(true);
			camera.yfactor = 1;
			
			view = new View3D({scene:scene, camera:camera});
			// Add viewport to the Flash display list so it's visible
			addChild(view);
			// Adjust view 
			view.x = 512; 
			view.y = 384;
			
			var globe:Sphere = new Sphere( { material:"blue#white", radius:250, segmentsH:18, segmentsW:26 } );
			globe.material = new BitmapMaterial(Cast.bitmap("earthMap"),{smooth:true});
			view.scene.addChild(globe);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
			//stage.addEventListener(MouseEvent.MOUSE_UP, MouseUp);
			stage.addEventListener(TransformGestureEvent.GESTURE_ZOOM, onGesturePinch);
		}
		
		
		private function MouseDown(e:MouseEvent):void
		{
			lastPanAngle = camera.panAngle;
			lastTiltAngle = camera.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
		}

		
		private function MouseUp(e:MouseEvent):void
		{
			move = false;
		}

		
		private function onEnterFrame(e:Event):void
		{		
			if (move) {
				camera.panAngle = cameraSpeed * (stage.mouseX - lastMouseX) + lastPanAngle;
				camera.tiltAngle = cameraSpeed * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			camera.hover();
			view.render();
		}
		
		
		private function onGesturePinch(e:TransformGestureEvent):void{
			camera.distance += (e.scaleX + e.scaleY) / 2; 
		}

	
		
	}
	
}