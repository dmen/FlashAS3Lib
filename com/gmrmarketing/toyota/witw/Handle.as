package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.text.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Handle extends Sprite
	{
		public static const COMPLETE:String = "handleComplete";
		private var myLoc:int;
		private var icon:Bitmap;
		
		public function Handle(handle:String, type:String, color:Number, locIndex:int)
		{
			myLoc = locIndex;//this handles index in the locs array within HandleManager
			
			graphics.beginFill(color, 1);
			graphics.drawRect(-122, -30, 244, 60);
			graphics.endFill();
			
			var bmd:BitmapData;
			var scaledBMD:BitmapData;
			var m:Matrix = new Matrix();
			if (type == "twitter") {
				bmd = new iconTwitter();
				scaledBMD = new BitmapData(16, 12, true, 0x00000000);
				m.scale(16 / bmd.width, 12 / bmd.height);
				scaledBMD.draw(bmd, m, null, null, null, true);
			}else {
				bmd = new iconInstagram();
				scaledBMD = new BitmapData(14, 13, true, 0x00000000);
				m.scale(14 / bmd.width, 13 / bmd.height);
				scaledBMD.draw(bmd, m, null, null, null, true);
			}
			icon = new Bitmap(scaledBMD);
			icon.x = 102;
			icon.y = 13;
			addChild(icon);
			
			var userFont:Font = new helvNeueBold();
			
			var userFormat:TextFormat = new TextFormat();						
			userFormat.font = userFont.fontName;
			userFormat.color = 0xFFFFFF;			
			
			var userField:TextField = new TextField();
			userField.defaultTextFormat = userFormat;
			userField.embedFonts = true;
			userField.antiAliasType = AntiAliasType.ADVANCED;
			userField.x = -122;
			userField.width = 244;
			userField.height = 60;
			userField.autoSize = TextFieldAutoSize.CENTER;
			addChild(userField);
			
			//reduce font size so it fits - one line only
			userField.text = handle;
			userFormat.size = 22;
			userField.setTextFormat(userFormat);
			while (userField.textWidth > width - 15) {				
				 userFormat.size = int(userFormat.size) - 1;
				 userField.setTextFormat(userFormat);
			}
			
			userField.y = -32 + Math.floor((60 - userField.textHeight) * .5);
			TweenMax.delayedCall(4 + Math.random() * 3, finished);
		}
		
		
		public function get locIndex():int
		{
			return myLoc;
		}
		
		
		private function finished():void
		{
			TweenMax.to(this, .5, { scaleX:0, scaleY:0, ease:Back.easeIn, onComplete:kill } );
		}
		
		public function killBitmap():void
		{
			icon.bitmapData.dispose();
			icon = null;
		}
		private function kill():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}