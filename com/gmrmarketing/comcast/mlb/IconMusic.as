package com.gmrmarketing.comcast.mlb
{
	
	import flash.display.MovieClip;	
	import flash.events.Event;
	import com.gmrmarketing.comcast.mlb.Engine;
	import com.greensock.TweenLite;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	
	public class IconMusic extends MovieClip
	{
		private var engineRef:Engine;
		private var mySpeed:int;
		
		/*
		private var gColors:Array = [0x3389DD, 0xFFFFFF];
		private var gAlphas:Array = [1, 1];
		private var gRatio:Array = [0,255];
		private var mat:Matrix;
		*/
		
		public function IconMusic(eRef:Engine)
		{	
			x = -10;
			y = 250 + Math.random() * 400;
			engineRef = eRef;
			mySpeed = engineRef.getLevel() + 2 + (Math.random() * 8);
			//blur.scaleX = engineRef.getLevel() / 4;
			
			//mat = new Matrix();
			//mat.createGradientBox(15,15,0,22,22);
			
			addEventListener(Event.ENTER_FRAME, move, false, 0, true);
		}
		
		public function kill():void
		{
			removeEventListener(Event.ENTER_FRAME, move);
		}			
		
		private function move(e:Event):void
		{
			x += mySpeed;
			
			/*
			gRatio[1] += 10;
			if(gRatio[1] > 255){
				gRatio[1] = 128;
			}
			grad.graphics.clear();
			grad.graphics.beginGradientFill(GradientType.RADIAL,gColors,gAlphas,gRatio,mat,SpreadMethod.REFLECT);  
			grad.graphics.drawCircle(30,30,30);
			*/
			
			if (x > Engine.GAME_WIDTH + 50) {			
				removeEventListener(Event.ENTER_FRAME, move);				
				remove();
			}
		}
		
		
		
		private function remove():void
		{
			engineRef.removeIcon(this);
		}		

	}	
}