package  com.gmrmarketing.sap.levisstadium.didyouknow
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		public static const ERROR:String = "error";
		private var degToRad:Number = 0.0174532925; //PI / 180
		private var json:Object;
		private var dyk:MovieClip;
		private var myTime:int;
		private var tweenOb:Object;
		private var animRing:Sprite;
		private var tMask:MovieClip;
		private var localCache:Object;
		
		
		public function Main()
		{
			dyk = new mcRing();//lib clip
			
			animRing = new Sprite();
			tMask = new textMask();//lib clip
			tMask.x = -211;
			tMask.y = -706;
			//tMask.alpha = 0;
			dyk.addChild(tMask);
			dyk.addChild(animRing);
			
			dyk.textGroup.cacheAsBitmap = true;
			tMask.cacheAsBitmap = true;
			
			dyk.textGroup.mask = tMask;
			
			tweenOb = { angle:0 };
			
			
			//setConfig("15");
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function init(initValue:String = ""):void
		{
			myTime = parseInt(initValue);
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/getdidyouknow" + "?abc="+String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		private function dataLoaded(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			localCache = json;
			//show();//TESTING
			dispatchEvent(new Event(READY));
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				json = localCache;
				dispatchEvent(new Event(READY));
			}else{
				dispatchEvent(new Event(ERROR));
			}
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
		{
			tMask.y = -706;
			dyk.textGroup.theTitle.text = "";
			dyk.textGroup.theText.text = "";
			animRing.graphics.clear();
			dyk.scaleX = dyk.scaleY = 0;
		}
		
		/**
		 * ISChedulerMethods
		 * Called once scheduler receives READY event
		 */
		public function show():void
		{
			if (!contains(dyk)) {
				addChild(dyk);
			}
			
			dyk.textGroup.theTitle.text = json.Subhead.replace(/\\n/g, '\n');
			dyk.textGroup.theTitle.autoSize = TextFieldAutoSize.CENTER;
			dyk.textGroup.theText.text = json.Body.replace(/\\n/g, '\n');
			
			var titleSize:Object = getTextBounds(dyk.textGroup.theTitle);
			var bodySize:Object = getTextBounds(dyk.textGroup.theText);
			var fullSize:int = titleSize.height + 15 + bodySize.height;
			var range:int = 229;//172 is bottom, -67 is top - 172 + 67 = 239
			var delta:int = range - fullSize;
			
			if(-57 + delta / 2 < -57){
				dyk.theTitle.y = -57 + delta / 2;
			}
			
			dyk.textGroup.theText.y = dyk.textGroup.theTitle.y + titleSize.height + 15;
			dyk.scaleX = dyk.scaleY = 0;
			dyk.x = 400;
			dyk.y = 244;
			
			tweenOb.angle = 0;
			
			TweenMax.to(dyk, 1, { scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:showText } );
		}
		
		
		private function showText():void
		{
			TweenMax.to(tMask, 10, {y:-249} );
			TweenMax.to(tweenOb, myTime, { angle:360, ease:Linear.easeNone, onUpdate:drawcircleTween } );
		}
		
		
		private function drawcircleTween():void
		{
			draw_arc(animRing.graphics, 0, 0, 213, 0, tweenOb.angle, 11, 0xedb01a, 1 );
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			
		}
		
		private function getTextBounds(textField:TextField):Object
		{
			// Create a completely transparent BitmapData:
			var bmd:BitmapData = new BitmapData(textField.width, textField.height, true, 0x00ffffff);

			// Note that some cases may require you to render a Sprite/MovieClip
			// CONTAINING the TextField for anything to get drawn.
			// For example, AntiAliasType.ADVANCED (antialias for readability) is known to 
			// not be renderable in some cases - other settings may cause nothing to be
			// rendered too. In that case, simply wrap add the TextField as a child of an 
			// otherwise empty Sprite/MovieClip, and pass that to draw() instead:
			bmd.draw(textField);

			// This gets the bounds of pixels that are not completely transparent.
			// Param 1: mask  = specifies which color components to check (0xAARRGGBB)
			// Param 2: color = is the color to check for.
			// Param 3: findColor = whether to bound pixels OF the specified color (true),
			//                      or NOT OF the specified color (false)
			//
			// In this case, we're interested in:
			// 1: the alpha channel (0xff000000)
			// 2: being 00 (0x00......)
			// 3: and want the bounding box of pixels that DON'T meet that criterium (false)
			var rect:Rectangle = bmd.getColorBoundsRect(0xff000000, 0x00000000, false);

			// Do remember to dispose BitmapData when done with it:
			bmd.dispose();

			return { width:rect.width, height:rect.height };
		}
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number, alph:Number = 1):void
		{
			g.clear();
			//g.lineStyle(1, lineColor, alph, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			if(angle_diff > 0){
				g.beginFill(lineColor, alph);
				g.moveTo(px_inner, py_inner);
				
				var i:int;
			
				// drawing the inner arc
				for (i = 1; i <= steps; i++) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
				}
				
				// drawing the outer arc
				for (i = steps; i >= 0; i--) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
				}
				
				g.lineTo(px_inner, py_inner);
				g.endFill();
			}
		}
		
		private function getX(angle:Number, radius:Number, center_x:Number):Number
		{
			return Math.cos((angle-90) * degToRad) * radius + center_x;
		}
		
		
		private function getY(angle:Number, radius:Number, center_y:Number):Number
		{
			return Math.sin((angle-90) * degToRad) * radius + center_y;
		}
	}
	
}