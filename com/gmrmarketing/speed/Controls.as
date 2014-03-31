//linked to controlInterface movieClip in library
//0,458
package com.gmrmarketing.speed
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;

	public class Controls extends MovieClip
	{
		private var stickerList:Array;
		private var currentControl:MovieClip; //reference to the control clip currently being shown
		private var border:MovieClip;
		
		private var baseRef:Stage; //main card in the interface - the preview in the middle
		
	
		public function Controls($baseRef:Stage) 
		{			
			baseRef = $baseRef;
			
			stickerList = new Array(stickerBox.s1, stickerBox.s2, stickerBox.s3, stickerBox.s4, stickerBox.s5, stickerBox.s6, stickerBox.s7);			
			
			var sinst:Array = new Array();
			for (var i:int = 0; i < stickerList.length; i++) {
				stickerList[i].oScale = stickerList[i].scaleX;
			}			
			
			colorBox.c1.myColor = 0x181818;
			colorBox.c1.alpha = 0;
			colorBox.c1.buttonMode = true;
			
			colorBox.c2.myColor = 0x6b6b6b;
			colorBox.c2.alpha = 0;
			colorBox.c2.buttonMode = true;
			
			colorBox.c3.myColor = 0xab2627;
			colorBox.c3.alpha = 0;
			colorBox.c3.buttonMode = true;
			
			colorBox.c4.myColor = 0x153f67;
			colorBox.c4.alpha = 0;
			colorBox.c4.buttonMode = true;
			
			tabColor.addEventListener(MouseEvent.CLICK, showColors, false, 0, true);
			tabTheme.addEventListener(MouseEvent.CLICK, showThemes, false, 0, true);
			
			currentControl = null;
		}
		
		
		public function swapBorder(whichBorder:int):void
		{
			if(border){
				if(baseRef.theCard.contains(border)){
					baseRef.theCard.removeChild(border);
				}
			}
			
			switch(whichBorder) {
				case 1:
					border = new border1(); //lib clip					
					break;
				case 2:
					border = new border2();
					break;
				case 3:
					border = new border3();
					break;
			}
			
			border.x = 10;
			border.y = 90;
			
			border.theMask.alpha = 0;
			baseRef.carContainer.mask = border.theMask;
			
			baseRef.theCard.addChild(border);
		}
		
		
		private function showColors(e:MouseEvent):void
		{
			removeLastControl();
			colorBox.alpha = 0;
			TweenLite.to(colorBox, .5, { alpha:1 } );
			colorBox.y = 60;
			currentControl = colorBox;
		}
		
		private function showThemes(e:MouseEvent):void
		{
			removeLastControl();
			templateBox.alpha = 0;
			TweenLite.to(templateBox, .5, { alpha:1 } );
			templateBox.y = 60;
			currentControl = templateBox;
		}
		
		private function removeLastControl():void
		{
			if (currentControl != null) {
				currentControl.y = 450;
			}
		}
		
		
		private function addStickerHandlers():void
		{
			for (var i:int = 0; i < stickerList.length; i++) {
				stickerList[i].addEventListener(MouseEvent.CLICK, stickerPick, false, 0, true);
				stickerList[i].addEventListener(MouseEvent.MOUSE_OVER, expandSticker, false, 0, true);
				stickerList[i].addEventListener(MouseEvent.MOUSE_OUT, contractSticker, false, 0, true);
				stickerList[i].buttonMode = true;
			}
		}
		
		
		private function removeStickerHandlers():void
		{			
			for (var i:int = 0; i < stickerList.length; i++) {
				stickerList[i].removeEventListener(MouseEvent.CLICK, stickerPick);
				stickerList[i].removeEventListener(MouseEvent.MOUSE_OVER, expandSticker);
				stickerList[i].removeEventListener(MouseEvent.MOUSE_OUT, contractSticker);
			}
		}
		
		
		private function openStickers(e:MouseEvent):void
		{
			TweenLite.to(stickerBox, .5, { y:88, ease:Bounce.easeOut, onComplete:addStickerHandlers } );
		}
		
		
		private function closeStickers(e:MouseEvent):void
		{
			TweenLite.to(stickerBox, .5, { y:711, onComplete:removeStickerHandlers } );
		}
		
		
		
		
		
		private function stickerPick(e:MouseEvent):void
		{
			
		}
		
		private function expandSticker(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { scaleX:1, scaleY:1 } );
		}
		private function contractSticker(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { scaleX:e.currentTarget.oScale, scaleY:e.currentTarget.oScale } );
		}
		
	
	}
	
}