/**
 * This is an experiment using BitmapData blitting and Vectors instead of arrays
 */

package com.gmrmarketing.particles
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.Timer;	
	
	public class SnowParticles
	{
		private var particles:Vector.<BitmapData>;
		private var data:Vector.<Object>;
		private var frameTimer:Timer;
		private var myDisplay:BitmapData;
		private var displayRect:Rectangle;		
		private var particleData:Object;
		
		
		public function SnowParticles(partArray:Array, display:BitmapData, numParticles:int)
		{			
			particles = new Vector.<BitmapData>(numParticles);
			data = new Vector.<Object>(numParticles);
			
			myDisplay = display;			
			displayRect = display.rect;
			
			var pScale:Number;			
			var arIndex:int = 0;
			for (var i:int = 0; i < numParticles; i++){
				
				pScale = .2 + Math.random() * .5;
				var bmd:BitmapData = new BitmapData(partArray[arIndex].width * pScale, partArray[arIndex].height * pScale, true, 0x00000000);
				
				var m:Matrix = new Matrix();
				m.scale(pScale, pScale);
				
				var ct:ColorTransform = new ColorTransform();
				ct.alphaMultiplier = .15 + Math.random() * .45;
				
				bmd.draw(partArray[arIndex], m, ct, null, null, true);				
				particles[i] = bmd;
				
				arIndex++;
				if (arIndex >= partArray.length){
					arIndex = 0;
				}
				
				
				var angleInc:Number = .001 + Math.random() * .005;
				var xVelo:Number = .005 + Math.random() * .01;
				if (Math.random() < .5){
					xVelo *= -1;
				}
				var yVelo:Number = .01 + Math.random() * .01;
				data[i] = {point:new Point(Math.random() * 1920, Math.random() * 1080), ang:Math.random() * 6.28, angInc:angleInc, xVel:xVelo, yVel:yVelo};				
			}
			
			frameTimer = new Timer(1000 / 60);
			frameTimer.addEventListener(TimerEvent.TIMER, update);
			frameTimer.start();
		}
		
		
		/**
		 * called at 60fps by frameTimer
		 * blits the vector array of bitmapDatas to myDisplay
		 * @param	e
		 */
		private function update(e:TimerEvent):void
		{
			//myDisplay.lock();
			myDisplay.fillRect(displayRect, 0);
	
			for (var i:int = 0, c = data.length; i < c; i++)
			{				
				data[i].ang += data[i].angInc;
				if (data[i].ang > 6.28) 
				{
					data[i].ang = 0;
				}
				data[i].point.x += data[i].xVel + Math.cos(data[i].ang);
				data[i].point.y += data[i].yVel + Math.sin(data[i].ang);
				
				if (data[i].point.x > 1940){
					data[i].point.x = -20;
				}
				if (data[i].point.x < -20){
					data[i].point.x = 1940;
				}
				if (data[i].point.y > 1100){
					data[i].point.y = -20;
				}
				if (data[i].point.y < -20){
					data[i].point.y = 1100;
				}
				
				
				
				
				myDisplay.copyPixels(particles[i], particles[i].rect, data[i].point, null, null, true);
			}
			
			//myDisplay.unlock();
		}
		
	}	
}