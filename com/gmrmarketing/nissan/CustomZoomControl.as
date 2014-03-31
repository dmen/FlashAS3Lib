package com.gmrmarketing.nissan 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import com.google.maps.MapEvent;
	import com.google.maps.Map;
	import com.google.maps.MapType;
	import com.google.maps.LatLng;
	import com.google.maps.LatLngBounds;
	import com.google.maps.ProjectionBase;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.controls.PositionControl;
	import com.google.maps.controls.ControlPosition;
	import com.google.maps.controls.ControlBase;
	import com.google.maps.interfaces.IMap;

	public class CustomZoomControl extends ControlBase 
	{
		public static const DID_ZOOM:String = "mapWasZoomed";
		
		public function CustomZoomControl() 
		{	
			super(new ControlPosition(ControlPosition.ANCHOR_BOTTOM_RIGHT, 7, 7));
		}


		public override function initControlWithMap(map:IMap):void 
		{
			createButton("+", 0, 0, function(event:Event):void { map.zoomIn(null,false,true); dispatchEvent(new Event(DID_ZOOM)); } );
			createButton("-", 0, 40, function(event:Event):void{ map.zoomOut(null,true); dispatchEvent(new Event(DID_ZOOM)); } );
		}
		
		
		private function createButton(text:String, x:Number, y:Number, callback:Function):void 
		{			
			var colors:Array = [ 0x031927, 0x042f49, 0x031927 ];
			var alphas:Array = [ 1, 1, 1 ];
			var ratios:Array = [ 0, 128, 255 ];

			var matr:Matrix = new Matrix();
			matr.createGradientBox( 24, 15, Math.PI / 2, 0, 0 );
			
			var sprite:Sprite = new Sprite();			
			sprite.graphics.beginGradientFill( GradientType.LINEAR, colors, alphas, ratios, matr, SpreadMethod.PAD );
			sprite.graphics.drawRoundRect( 0, 0, 24, 20, 4, 4 );		
		
			var label:TextField = new TextField();
			label.text = text;			
			label.width = 24;
			label.x = 1;
			label.y = -8;
			label.selectable = false;
			label.autoSize = TextFieldAutoSize.CENTER;
			var format:TextFormat = new TextFormat("Arial");
			format.color = 0xFFFFFF;
			format.size = 24;
			format.bold = true;
			label.setTextFormat(format);		
			
			sprite.addChild(label);			
			sprite.addEventListener(MouseEvent.CLICK, callback);
			
			//web only
			sprite.buttonMode = true;
			sprite.mouseChildren = false;
			
			sprite.x = x;
			sprite.y = y;
			
			addChild(sprite);
		}
	}
}
