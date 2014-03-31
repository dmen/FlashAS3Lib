package com.gmrmarketing.preloaders
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.*;
	
	
	public class SimpleCircle
	{
		private var ang:int = 0;
		private var inc:int = 4;
		private var cx:int = 0;
		private var cy:int = 0;
		private var rad:int = 12;
		private var lineWidth:int = 8;
		private var ix:Number;
		private var iy:Number;
		private var ex:Number;
		private var ey:Number;
		private var pContainer:Sprite;
		private var circContainer:DisplayObjectContainer;
		
		
		public function SimpleCircle($circContainer:DisplayObjectContainer)
		{
			circContainer = $circContainer;
			pContainer = new Sprite();
			pContainer.x = 365;
			pContainer.y = 150;
		}

		
		public function addPreloaderCircle()
		{
			circContainer.addChild(pContainer);	
			
			pContainer.graphics.clear();
			pContainer.graphics.lineStyle(1, 0xAAAAAA);
			pContainer.graphics.drawCircle(cx, cy, rad + lineWidth + 10);
			pContainer.graphics.lineStyle(lineWidth + 2, 0xAAAAAA);
			pContainer.graphics.drawCircle(cx, cy, rad + lineWidth / 2);
			pContainer.graphics.lineStyle(3, 0x990000);
			
			circContainer.addEventListener(Event.ENTER_FRAME, updatePreloader, false, 0, true);
		}

		
		public function removePreloaderCircle()
		{
			circContainer.removeEventListener(Event.ENTER_FRAME, updatePreloader);
			pContainer.graphics.clear();
			if(circContainer.contains(pContainer)){
				circContainer.removeChild(pContainer);
			}
		}
		

		private function updatePreloader(e:Event)
		{			
			if(ang < 360){
				
				ix = cx + (Math.cos(ang / (180 / Math.PI)) * rad);
				iy = cy + (Math.sin(ang / (180 / Math.PI)) * rad);
				ex = cx + (Math.cos(ang / (180 / Math.PI)) * (rad + lineWidth));
				ey = cy + (Math.sin(ang / (180 / Math.PI)) * (rad + lineWidth));
				
				pContainer.graphics.moveTo(ix, iy);
				pContainer.graphics.lineTo(ex, ey);
				
				ang += inc;
				
			}else{
				
				pContainer.graphics.clear();
				pContainer.graphics.lineStyle(1, 0xAAAAAA);
				pContainer.graphics.drawCircle(cx, cy, rad + lineWidth + 10);
				pContainer.graphics.lineStyle(lineWidth + 2, 0xAAAAAA);
				pContainer.graphics.drawCircle(cx, cy, rad + lineWidth / 2);
				pContainer.graphics.lineStyle(3, 0x990000);
				ang = 0;				
			}	
		}
	}
	
}