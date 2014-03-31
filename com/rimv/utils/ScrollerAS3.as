// Dynamic Scroller - Gradient Effect
// RimV: www.mymedia-art.com || trieuduchien@gmail.com 
// Please read documentation before customizing


package com.rimv.utils 
{
	// Flash libs
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import gs.TweenMax;
	import gs.easing.Quint;
	
	// Main class
	public class ScrollerAS3 extends Sprite
	{
		// Parameters
		private var _mainXML:String = "DScroller.xml";   // XML Path
		private var _mainCSS:String = "css/styles.css" // CSS path
		private var _width:Number = 300;
		private var _height:Number = 200;
		private var _padding:Number = 10;
		private var _scrollerDist:Number = 10;
		private var _autoCenter:Boolean = true;
		private var _scrollerHeight:Number;
		private var _paddingX:Number;
		private var _paddingY:Number;
		private var _backgroundAlpha:Number;
		private var _easing:Number;
		private var _mouseWheelSpeed:Number;
		
		//------------------------ XML VARS --------------------------//
		
		private var xmlLoader:URLLoader = new URLLoader();
		private	var xmlData:XML = new XML();
		
		//--------------- end of -- XML VARS -----------------------//
		
		// MISC Vars
		private var css:StyleSheet = new StyleSheet(); // StyleSheet
		private var range:Number;
		
		
		// Get / set XML and CSS path
		private function set mainXML(s:String):void
		{
			_mainXML = s;
		}
		
		private function set mainCSS(s:String):void
		{
			_mainCSS = s;
		}
		
		// Constructor
		public function ScrollerAS3()
		{
			// Hide display
			display.visible = false;
			container.content.mouseWheelEnabled = false;
		}
		
		public function config(configObject:Object):void
		{
			// apply configuration
			_width = configObject.width;
			_height = configObject.height;
			_paddingX = configObject.paddingX;
			_paddingY = configObject.paddingY;
			_scrollerDist = configObject.scrollerDistance;
			_scrollerHeight = configObject.scrollerHeight;
			_mouseWheelSpeed = configObject.mouseWheelSpeed;
			_easing = configObject.easing;
			// Mask area
			gradientMask.width = _width;
			gradientMask.height = _height;
			gradientMask.alpha = 1;
			container.background.alpha = 0;
		}
		
		public function applyText(data:XMLList):void
		{
			//Main content and padding
			container.content.htmlText = data;
			container.content.width = _width - 3 * _paddingX;
			container.content.x = container.content.y = _paddingY;
			container.alpha = 1;
			container.y = 0;
			// To check if scroller is necessary
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			if (container.height <= _height) scroller.visible = false; else 
			{
				scroller.visible = true;
				// mouse scroller
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			}
			// scroller
			scroller.x = _width + _scrollerDist;
			scroller.height = _scrollerHeight;
			scroller.y = (_height - _scrollerHeight) * .5;
			scroller.alpha = 1;
			range = -container.height + _height - 50;
			// scroller interactive
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberPressed);
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_UP, scrubberReleased);
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_OVER, scrubberOver);
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_OUT, scrubberOut);
			scroller.track.addEventListener(MouseEvent.MOUSE_DOWN, scrollerPressed);
			scroller.scrubber.y = 0;
			// adjust dimension and apply mask
			container.cacheAsBitmap = gradientMask.cacheAsBitmap = true;
			container.mask = gradientMask;
		}
		
		// Mouse Wheel Handler
		public function mouseWheelHandler(e:MouseEvent):void
		{
			var num = Math.round(e.delta / 3);
			var target = scroller.scrubber; 
			target.y -= num * _mouseWheelSpeed;
			target.y = (target.y <= 0) ? 0 : target.y;
			target.y = (target.y > 170) ? 170 : target.y;
			scrubberEnterFrame();
		}
		
		// Scroller interactive
		private function scrubberPressed(e:Event):void
		{
			scroller.scrubber.startDrag(false, new Rectangle(0, 0, 0, 170));
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
			scroller.scrubber.removeEventListener(MouseEvent.MOUSE_OUT, scrubberOut);
			stage.addEventListener(MouseEvent.MOUSE_UP, scrubberReleased);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
		}
		
		private function scrubberReleased(e:Event):void
		{
			scroller.scrubber.stopDrag();
			scroller.scrubber.gotoAndPlay(21);
			scroller.scrubber.removeEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
			scroller.scrubber.addEventListener(MouseEvent.MOUSE_OUT, scrubberOut);
			stage.removeEventListener(MouseEvent.MOUSE_UP, scrubberReleased);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
		}
		
		private function scrubberMove(e:Event):void
		{
			scrubberEnterFrame();
		}
		
		private function scrubberEnterFrame():void
		{
			var targetY:Number = Math.round((scroller.scrubber.y / 170) * range);
			TweenMax.to(container, _easing, { y:targetY, overwrite:1 } );
		}
		
		private function scrubberOver(e:Event):void
		{
			e.target.parent.gotoAndPlay(2);
		}
		
		private function scrubberOut(e:Event):void
		{
			e.target.parent.gotoAndPlay(21);
		}
		
		private function scrollerPressed(e:Event):void
		{
			(scroller.mouseY > 170) ? (scroller.scrubber.y = 170) : (scroller.scrubber.y = scroller.mouseY);
			scrubberEnterFrame();
		}
	}
}
