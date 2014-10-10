package com.gmrmarketing.sap.metlife.player
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.*;
	
	
	public class LensFlares
	{		
		private var container:DisplayObjectContainer;
		
		
		public function LensFlares()
		{			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * 
		 * @param	flares Array of flare arrays - flare arrays contain x, y, to x, type, delay
		 */
		public function show(flares:Array):void
		{
			for (var i:int = 0; i < flares.length; i++) {
				var theFlare:Bitmap;
				var f:Array = flares[i]; //one flare
				switch(f[3]) {
					case "point":
						theFlare = new Bitmap(new flarePointBMD());
						break;
					case "line":
						theFlare = new Bitmap(new flareLineBMD());
						break;
				}
				
				theFlare.x = f[0] - (theFlare.width * .5);
				theFlare.y = f[1] - (theFlare.height * .5);
				theFlare.alpha = 0;
				container.addChild(theFlare);
				
				var delta:int = (f[2] - f[0]) / 150;				
			
				TweenMax.to(theFlare, .75, { alpha:1, delay:f[4] } );
				TweenMax.to(theFlare, delta, { x:f[2]-(theFlare.width * .5), delay:f[4], ease:Linear.easeNone } );
				TweenMax.to(theFlare, .75, { alpha:0, delay:f[4] + (delta - .75), onComplete:kill, onCompleteParams:[theFlare] } );
			}
		}
		
		private function kill(theFlare:Bitmap):void
		{
			if (container.contains(theFlare)) {
				container.removeChild(theFlare);
			}			
			theFlare = null;
		}
		
	}
	
}