package com.rimv.utils 
{
	
	/**
	 *
	 * @author RimV - Control grab cursor
	 */
	
	import flash.display.*;
	import flash.events.*;
	import com.rimv.utils.CustomCursor;
	
	public class MouseControl 
	{
		
		static private var clip:DisplayObject;
	
		public function MouseControl() 
		{
			
		}
		
		public static function assignClip(c:DisplayObject):void
		{
			clip = c;
		}
		
		public static function start():void
		{
			clip.addEventListener(MouseEvent.ROLL_OVER, mouseOver);
			clip.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			clip.addEventListener(MouseEvent.MOUSE_UP, mouseOver);
		}
		
		public static function stop():void
		{
			CustomCursor.hideCursor();
			clip.removeEventListener(Event.ENTER_FRAME, CustomCursor.followMouse);
			clip.removeEventListener(MouseEvent.ROLL_OVER, mouseOver);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			clip.removeEventListener(MouseEvent.MOUSE_UP, mouseOver);
		}
		
		private static function mouseDown(e:MouseEvent):void
		{
			CustomCursor.showCursor(1);
		}
		
		private static function mouseUp(e:MouseEvent):void
		{
			CustomCursor.showCursor(0);
		}
		
		private static function mouseOver(e:MouseEvent):void
		{
			CustomCursor.showCursor(0);
			clip.addEventListener(Event.ENTER_FRAME, CustomCursor.followMouse);
			clip.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}
		
		private static function mouseOut(e:MouseEvent):void
		{
			CustomCursor.hideCursor();
			clip.removeEventListener(Event.ENTER_FRAME, CustomCursor.followMouse);
			clip.removeEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}
		
	}
	
}