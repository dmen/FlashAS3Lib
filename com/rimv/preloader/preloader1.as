package com.rimv.preloader
{
	/**
   @author    	RimV 
				www.mymedia-art.com
   @class     	preloader1 - circle
   @package   	Utilities
	*/
   
	import flash.display.*;
	import flash.events.*;
	import gs.TweenMax;
	import gs.easing.*;
	import flash.text.TextField;
	import flash.events.*;
	
   public class preloader1 extends BasePreloader
   {
	   protected var parts = [];	   
	   protected var max:Number = 0;
	   
	   // Constructor
	   public function preloader1()
	   {
		   // create white circle
		  for (var i:Number = 0; i < 360; i++)
			{
				var small:smallPart = new smallPart();
				parts[i] = small;
				small.x = small.y = 0;
				small.rotation = i;
				small.visible = false;
				this["circleWhite"].addChild(small);
			}
	   }
	   
	   override public function set value(value:Number):void
	   {
		   this.preloaderValue = value;
		   this["percent"].text = value.toString();
		   var target:Number = Math.round(value / 100 * 360);
		   for (var i:uint = max; i < target; i++) parts[i].visible = true;
		   max = target;
		}
		
		public function reset():void
		{
			for (var i:uint = 0; i < 360; i++) parts[i].visible = false;
		}
	  
	   
   }
	
}