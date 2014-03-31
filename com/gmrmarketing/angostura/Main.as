package com.gmrmarketing.angostura
{	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	
	import com.greensock.TweenLite;
	
	import com.gmrmarketing.angostura.PourLiquid;
	import com.gmrmarketing.angostura.DashLiquid;
	import com.gmrmarketing.angostura.RateIndicator;
	
	
	
	public class Main extends MovieClip
	{
		//Bottles
		private var vodBot:BottleVodka;
		private var etBottle:BottleET; //early times
		private var bit:BottleBitters;
		
		private var liquid:PourLiquid;
		private var dash:DashLiquid;
		private var rateMeter:RateIndicator;
		
		
		public function Main() 
		{
			liquid = new PourLiquid(this);
			//dash = new DashLiquid(this);
			rateMeter = new RateIndicator(this);
			
			var loc:Point;
			vodBot = new BottleVodka(glass);
			vodBot.addEventListener(BaseBottle.START_POURING, pourStart);
			vodBot.addEventListener(BaseBottle.STOP_POURING, pourEnd);
			vodBot.addEventListener(BaseBottle.STOP_DRAGGING, dragEnd);
			addChild(vodBot);
			loc = vodBot.getStartLoc();
			vodBot.x = loc.x;
			vodBot.y = loc.y;

			bit = new BottleBitters(glass);
			bit.addEventListener(BaseBottle.START_POURING, pourStart);
			bit.addEventListener(BaseBottle.STOP_POURING, pourEnd);
			bit.addEventListener(BaseBottle.STOP_DRAGGING, dragEnd);
			addChild(bit);
			loc = bit.getStartLoc();
			bit.x = loc.x;
			bit.y = loc.y;
			
			etBottle = new BottleET(glass);
			etBottle.addEventListener(BaseBottle.START_POURING, pourStart);
			etBottle.addEventListener(BaseBottle.STOP_POURING, pourEnd);
			etBottle.addEventListener(BaseBottle.STOP_DRAGGING, dragEnd);
			addChild(etBottle);
			loc = etBottle.getStartLoc();
			etBottle.x = loc.x;
			etBottle.y = loc.y;
		}
		
		
		
		/**
		 * Called by START_POURING listener on all bottles
		 * @param	e
		 */	
		private function pourStart(e:Event):void
		{
			var bottle:IBottle = IBottle(e.currentTarget);
			
			if (bottle.getLabel() == "Angostura Bitters") {
				//dash.pour(glass, bottle);
			}else{
				liquid.pour(glass, bottle); //glass is on stage already				
			}
			rateMeter.indicate(bottle);
		}
		
		
		
		/**
		 * Called by STOP_DRAGGING event
		 * this event is dispatched when the bottle is relased by the user
		 * Stops pouring and returns the bottle to it's start loc
		 * @param	e
		 */
		private function dragEnd(e:Event):void
		{
			liquid.stopPour();
			//dash.stopPour();
			rateMeter.stopIndicating();
			var bottle:IBottle = IBottle(e.currentTarget);
			var loc:Point = bottle.getStartLoc();
			TweenLite.to(bottle, .5, { x:loc.x, y:loc.y, overwrite:0 } );
		}
		
		
		/**
		 * Called by STOP_POURING event
		 * dispatched when the bottle is moved away from the glass		 * 
		 * @param	e
		 */
		private function pourEnd(e:Event):void
		{
			liquid.stopPour();
			rateMeter.stopIndicating();
		}
	}
	
}