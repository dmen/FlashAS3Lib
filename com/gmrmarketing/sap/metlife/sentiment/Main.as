package com.gmrmarketing.sap.metlife.sentiment
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip// implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		
		private var maskContainer:Sprite;
		private var tweenObject:Object;		
		private var speed:Number;
		private var limit:Number;
		private var deg2rad:Number;
		
		
		public function Main()
		{
			maskContainer = new Sprite();
			maskContainer.cacheAsBitmap = true;
			addChild(maskContainer);
			greenPie.mask = maskContainer;
			
			theMask.scaleX = 0;
			pie.scaleX = pie.scaleY = 0;
			
			TweenMax.to(pie, .5, { scaleX:.78, scaleY:.78, ease:Back.easeOut, delay:.5, onComplete:showStats } );			
		}
		
		
		/**
		 * ISchedulerMethods
		 * @param	initValue String value from initData attribute of config.xml
		 */
		private function init(initValue:String = ""):void
		{
			
		}
		
		
		private function showStats():void
		{
			TweenMax.to(theMask, .5, { scaleX:1 } );
			var per:Number = 79 / 100 * 360;
			drawPie(per);
		}
		
		private function drawPie(percent:int):void
		{
			tweenObject = { percent:0 };
			speed = 0;
			limit = 0;
			deg2rad = Math.PI / 180;
			
			maskContainer.x = greenPie.x;
			maskContainer.y = greenPie.y;
			maskContainer.rotation = 270 - percent * .5;
			
			TweenMax.to(tweenObject, 2, { percent:percent, onUpdate:draw_circle } );
		}
		
		
		private function draw_circle():void
        {
            speed += 0.4;
            limit = tweenObject.percent;
            
            maskContainer.graphics.clear();
            maskContainer.graphics.lineStyle(4, 0x00FF00, 1, false, "normal", "none");
            
            for(var i:Number = 0; i <= limit; i++)
            {
                var px:Number =  Math.sin(i * deg2rad) * greenPie.width * .5;
                var py:Number = -Math.cos(i * deg2rad) * greenPie.width * .5;
                maskContainer.graphics.lineTo(px, py);
                maskContainer.graphics.moveTo(0, 0);
            }			
        }		
		
	}
	
}