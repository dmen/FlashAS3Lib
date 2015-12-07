package com.gmrmarketing.holiday2015
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.particles.Snow;
	import com.greensock.TweenMax;
	
	
	public class Background
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var dustContainer:Sprite;
		private var flakes:Array;
		private var g:Graphics;
		private var c:Snow;
		private var d:Snow;
		private var dist:Number;
		
		
		public function Background()
		{
			dustContainer = new Sprite();
			
			clip = new mcBackground();
			clip.addChild(dustContainer);
			g = dustContainer.graphics;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			
			
			while (dustContainer.numChildren) {
				dustContainer.removeChildAt(0);
			}
			
			flakes = [];
			for (var i:int = 0; i < 100; i++) {
				var d:Snow = new Snow();
				d.x = Math.floor(Math.random() * 1920);
				d.y = Math.floor(Math.random() * 1080);
				flakes.push(d);
				dustContainer.addChild(d);
			}
			myContainer.addEventListener(Event.ENTER_FRAME, updateBG);
		}		
		
		public function showBlack():void
		{
			TweenMax.to(clip.blackBox, 3, { alpha:.79 } );
		}
		
		public function hideBlack():void
		{
			TweenMax.to(clip.blackBox, 3, { alpha:0 } );
		}

		private function updateBG(e:Event):void
		{
			g.clear();
			
			
			for(var i:int = 0; i < 100; i++){
				c = flakes[i];
				for(var j:int = 0; j< 100; j++){
					d = flakes[j];
					dist = ((c.x - d.x)*(c.x - d.x)) + ((c.y - d.y)*(c.y - d.y));	//distance squared - remove Math.sqrt() for speed ~20% faster
								
					if(dist < 30000){
						g.lineStyle(1, 0xA38946, (30000 - dist)/300000);
						g.moveTo(c.x, c.y);
						g.lineTo(d.x, d.y);
					}					
				}
			}
		}
		
	}
	
}