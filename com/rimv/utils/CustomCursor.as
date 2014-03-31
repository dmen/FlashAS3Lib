package com.rimv.utils
{
	
	/**
	 * 
	 * @author RimV - Custom Cursor Class
	 */
	
	import flash.display.*;
	import flash.ui.Mouse;
	import flash.events.*;
	
	public class CustomCursor extends Sprite
	{
		
		static private var c0:MovieClip;
		static private var c1:MovieClip;
		static private var current:MovieClip;
		static private var stage:DisplayObject;
		
		// Constructor
		public function CustomCursor()
		{
			
		}
		
		static public function assignCursor(cursor0:MovieClip, cursor1:MovieClip, theStage:DisplayObject):void
		{
			c0 = cursor0;
			c1 = cursor1;
			stage = theStage;
		}
		
		static public function showCursor(state:Number):void
		{
			Mouse.hide();
			if (state == 0) 
			{
				current = c0;
				c0.visible = true;
				c1.visible = false;
			}
			else
			{
				current = c1;
				c0.visible = false;
				c1.visible = true;
			}
			current.x = stage.mouseX;
			current.y = stage.mouseY;
		}
		
		static public function hideCursor():void
		{
			Mouse.show();
			c0.visible = c1.visible = false;
		}
		
		static public function followMouse(e:Event):void
		{
			current.x = stage.mouseX;
			current.y = stage.mouseY;
		}
	}
	
}