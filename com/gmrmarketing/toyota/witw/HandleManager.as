package com.gmrmarketing.toyota.witw
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import com.gmrmarketing.utilities.Utility;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class HandleManager 
	{
		private var myContainer:DisplayObjectContainer;//holds the Handle sprites
		private var myHandles:Array;
		private var handleIndex:int;//current index in myHandles
		private var locs:Array; //array of six points and bgColors
		
		
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
			myHandles = [["@WomenintheWorld","twitter"],["@WomenintheWorld","instagram"],["@tinabrownlm","twitter"],["@toyota","twitter"],["@toyotausa","instagram"],["@randomkid","twitter"],["@uplayco","twitter"],["@schoollady1","twitter"],["@KavitaFresh","twitter"],["@fenugreen","twitter"],["@MorganEONeill","twitter"],["@recovers_org","twitter"],["@girltankorg","twitter"],["@DayOneResponse","twitter"],["@dc_greens","twitter"],["@LuminAIDLab","twitter"],["@Luminaid","instagram"],["@EnglishAtWork","twitter"],["@TingAtClick","twitter"],["@ClickMedix","twitter"],["@LavaMae","twitter"],["@LavaMae","instagram"],["@TinaHovsepian","twitter"],["@Cardborigami","twitter"]];
		}
		
		
		/**
		 * Fill all slots with the first six handles
		 */
		public function show():void
		{
			myHandles = Utility.randomizeArray(myHandles);
			handleIndex = 0;
			
			while (myContainer.numChildren) {
				myContainer.removeChildAt(0);
			}
			
			for (var i:int = 0; i < locs.length; i++) {
				var h:Handle = new Handle(myHandles[i][0], myHandles[i][1], locs[i][1], i);
				h.x = 122 + locs[i][0].x;
				h.y = 30 + locs[i][0].y;
				h.addEventListener(Handle.COMPLETE, nextHandle, false, 0, true);
				myContainer.addChild(h);
				h.scaleX = h.scaleY = 0;
				TweenMax.to(h, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, delay:i * .1 } );
				handleIndex++;
			}
		}
		
		
		public function hide():void
		{
			var n:int = myContainer.numChildren;
			for (var i:int = 0; i < n; i++){
				var handle:Handle = Handle(myContainer.getChildAt(i));
				handle.removeEventListener(Handle.COMPLETE, nextHandle);
				TweenMax.to(handle, .5, { alpha:0 } );
			}
		}
		
		
		/**
		 * called when a handle finishes displaying itself
		 * @param	e
		 */
		private function nextHandle(e:Event):void
		{
			var handle:Handle = Handle(e.currentTarget);
			var locIndex:int = handle.locIndex;
			if (myContainer.contains(handle)) {
				handle.killBitmap();
				myContainer.removeChild(handle);
			}
			var h:Handle = new Handle(myHandles[handleIndex][0], myHandles[handleIndex][1], locs[locIndex][1], locIndex);
			h.x = 122 + locs[locIndex][0].x;
			h.y = 30 + locs[locIndex][0].y;
			h.addEventListener(Handle.COMPLETE, nextHandle, false, 0, true);
			myContainer.addChild(h);
			h.scaleX = h.scaleY = 0;
			TweenMax.to(h, .5, { scaleX:1, scaleY:1, ease:Back.easeOut} );
			handleIndex++;
			if (handleIndex >= myHandles.length) {
				handleIndex = 0;
			}
		}
		
	}
	
}