//collection of oscillating sine wave lines in the analyzer bg

package com.gmrmarketing.wrigley.gumergency
{
	import adobe.utils.CustomActions;
	import flash.display.*
	import flash.events.Event;

	public class VLines
	{		
		private var container:DisplayObjectContainer;				
		private var lines:Array;
		
		public function VLines(){}		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;			
			container.blendMode = BlendMode.OVERLAY;
		}		
		
		public function show():void
		{		
			lines = new Array();
			var curX:int = 0;
			var ang:Number = 0;
			while (curX < 1920) {
				var m:VLine = new VLine();
				lines.push(m);
				m.add(container, curX, 250, ang);	
				curX += 40;	
				//6.28 / 15 = .4186 - there are 60 total vLines - so this makes 4 sets of waves
				ang += .4186; 
				if (ang > 6.28) {
					ang = 0;
				}
			}
		}
		
		public function start():void
		{			
			for (var i:int = 0; i < lines.length; i++) {
				lines[i].start();
			}
		}
		
		public function stop():void
		{
			for (var i:int = 0; i < lines.length; i++) {
				lines[i].stop();
			}
		}
	}	
}