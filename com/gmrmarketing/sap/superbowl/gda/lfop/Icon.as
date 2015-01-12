package com.gmrmarketing.sap.superbowl.gda.lfop
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Icon
	{
		private var myContainer:DisplayObjectContainer;
		private var myIcon:MovieClip;
		private var animOb:Object;
		
		
		public function Icon()
		{
			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function set icon(mc:MovieClip):void
		{
			myIcon = mc;			
		}
		
		
		public function show(tx:int, ty:int, percent:Number, label:String, del:Number = 0):void
		{
			if (!myContainer.contains(myIcon)) {
				myContainer.addChild(myIcon);
			}
			myIcon.x = tx;
			myIcon.y = ty;
			myIcon.theMask.cacheAsBitmap = true;
			myIcon.theRect.cacheAsBitmap = true;
			myIcon.theRect.mask = myIcon.theMask;
			myIcon.theRect.scaleY = 0;
			
			myIcon.thePercent.text = "0%";
			//myIcon.theLabel.text = label;
			animOb = { percent:0 };
			
			myIcon.scaleY = 0;
			TweenMax.to(myIcon, .75, { scaleY:1, delay:del, ease:Back.easeOut } );
			TweenMax.to(myIcon.theRect, 3, { scaleY:percent, delay:.75 + del } );//yellow bar
			TweenMax.to(animOb, 3, { percent:percent * 100, onUpdate:drawPercent, delay:del } );
		}
		
		
		private function drawPercent():void
		{
			myIcon.thePercent.text = String(Math.round(animOb.percent)) + "%";
		}
		
		
	}
	
}