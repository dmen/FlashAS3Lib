package com.gmrmarketing.toyota.witw
{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class HandleManager 
	{
		private var myContainer:DisplayObjectContainer;//holds the Handle sprites
		private var myHandles:Array;
		private var handleIndex:int;//current index in myHandles
		private var locs:Array; //array of six points and bgColors
		private var locIndex:int;//current index in the locs array
		
		
		public function HandleManager()
		{
			locs = [[new Point(573, 474), 0xD71B23], [new Point(573, 546), 0x58595B], [new Point(573, 618), 0xD71B23], [new Point(840, 474), 0x58595B], [new Point(840, 546), 0xD71B23], [new Point(840, 618), 0x58595B]];
		}
		
		
		public function set handles(h:Array):void
		{
			myHandles = h;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function defaults():void
		{
			myHandles = ["@mariaShiznet", "@hoboLizard", "@theLizard", "@phoenixWings", "@teboSux", "@cutlerSuxMore", "@packers", "@sixtyNineIsFine", "@maxwellHouse", "@eatShitISIS", "@taxTampons", "@eatMoreSquirrel", "@IronMan", "@belowTheBelt", "@vaJayJay", "@justBeatIt"];
		}
		
		
		/**
		 * Fill all six slots initially
		 */
		public function show():void
		{
			myHandles = Utility.randomizeArray(myHandles);
			handleIndex = 0;
			locIndex = 0;
			
			for (var i:int = 0; i < locs.length; i++) {
				var h:Handle = new Handle(myHandles[i], locs[i][1]);
				h.x = locs[i][0].x;
				h.y = locs[i][0].y;
				myContainer.addChild(h);
			}
		}
		
	}
	
}