package com.gmrmarketing.sap.nhl2015.gda.fotd
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.utilities.SwearFilter;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		public static const FINISHED:String = "finished";
		private const ARC_TIME:int = 10;
		
		private var fan1:MovieClip;
		private var fan2:MovieClip;
		private var fan3:MovieClip;
		private var f1Arc:Sprite;//for gray arcs
		private var f2Arc:Sprite;
		private var f3Arc:Sprite;
		private var f1Arc2:Sprite;//for orange arcs
		private var f2Arc2:Sprite;
		private var f3Arc2:Sprite;
		
		private var fan1Image:Bitmap;
		private var fan2Image:Bitmap;
		private var fan3Image:Bitmap;
		
		private var fanIndex:int;//index in localCache
		
		private var localCache:Object;
		private var imagesLoaded:Array; //array of booleans
		private var tweenObject:Object;//for tweening arc
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{			
			fan1 = new fan();//lib clip
			fan2 = new fan();//lib clip
			fan3 = new fan();//lib clip
			
			f1Arc = new Sprite();
			f2Arc = new Sprite();
			f3Arc = new Sprite();
			
			f1Arc2 = new Sprite();
			f2Arc2 = new Sprite();
			f3Arc2 = new Sprite();
			
			fan1.addChild(f1Arc);//gray arcs
			fan2.addChild(f2Arc);
			fan3.addChild(f3Arc);
			
			fan1.addChild(f1Arc2);//orange arcs
			fan2.addChild(f2Arc2);
			fan3.addChild(f3Arc2);
			
			bottomBar.y = 512; //off screen bottom
			
			if (TESTING){
				init();
			}
		}
		
		
		public function init(initValue:String = ""):void
		{
			tweenObject = new Object();
			imagesLoaded = new Array();
			fanIndex = 0;
			refreshData();
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/NHL/GetCachedFeed?feed=NHLFanOfTheDay");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function dataLoaded(e:Event = null):void
		{
			if(e != null){
				localCache = JSON.parse(e.currentTarget.data);//array of objects
			}
			
			if(localCache.length > 2){
				var im1URL:String = localCache[fanIndex].mediumresURL;
				var im2URL:String = localCache[fanIndex + 1].mediumresURL;
				var im3URL:String = localCache[fanIndex + 2].mediumresURL;
				
				if(im1URL){
					var im1Loader:Loader = new Loader();
					im1Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im1Loaded, false, 0, true);			
					im1Loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, im1Error, false, 0, true);			
					im1Loader.load(new URLRequest(im1URL));
				}else {
					im1Error();
				}
				
				if(im2URL){
					var im2Loader:Loader = new Loader();
					im2Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im2Loaded, false, 0, true);
					im2Loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, im2Error, false, 0, true);
					im2Loader.load(new URLRequest(im2URL));
				}else {
					im2Error();
				}
				
				if(im3URL){
					var im3Loader:Loader = new Loader();
					im3Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im3Loaded, false, 0, true);
					im3Loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, im3Error, false, 0, true);
					im3Loader.load(new URLRequest(im3URL));
				}else {
					im3Error();
				}
				
				if (TESTING) {
					show();
				}
			}
		}
		
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		private function im1Error(e:IOErrorEvent = null):void
		{
			//remove old image from clip
			if(fan1Image){
				if (fan1.contains(fan1Image)) {
					fan1.removeChild(fan1Image);
				}
			}
			
			fan1Image = new Bitmap(new noPic());
			fan1Image.smoothing = true;		
			addFan(fanIndex, fan1Image); //adds image to the fan clip			
			imagesLoaded[0] = true;
		}
		
		private function im2Error(e:IOErrorEvent = null):void
		{
			//remove old image from clip
			if(fan2Image){
				if (fan2.contains(fan2Image)) {
					fan2.removeChild(fan2Image);
				}
			}
			
			fan2Image = new Bitmap(new noPic());
			fan2Image.smoothing = true;		
			addFan(fanIndex + 1, fan2Image); //adds image to the fan clip			
			imagesLoaded[1] = true;
		}
		
		private function im3Error(e:IOErrorEvent = null):void
		{
			//remove old image from clip
			if(fan3Image){
				if (fan3.contains(fan3Image)) {
					fan3.removeChild(fan3Image);
				}
			}
			
			fan3Image = new Bitmap(new noPic());
			fan3Image.smoothing = true;			
			
			addFan(fanIndex + 2, fan3Image);			
			imagesLoaded[2] = true;
		}
		
		
		private function im1Loaded(e:Event):void
		{	
			//remove old image from clip
			if(fan1Image){
				if (fan1.contains(fan1Image)) {
					fan1.removeChild(fan1Image);
				}
			}
			
			fan1Image = Bitmap(e.target.content);
			fan1Image.smoothing = true;			
			
			addFan(fanIndex, fan1Image); //adds image to the fan clip			
			imagesLoaded[0] = true;
		}
		
		
		private function im2Loaded(e:Event):void
		{	
			//remove old image from clip
			if(fan2Image){
				if (fan2.contains(fan2Image)) {
					fan2.removeChild(fan2Image);
				}
			}
			
			fan2Image = Bitmap(e.target.content);
			fan2Image.smoothing = true;			
			
			addFan(fanIndex + 1, fan2Image);			
			imagesLoaded[1] = true;
		}
		
		
		private function im3Loaded(e:Event):void
		{	
			//remove old image from clip
			if(fan3Image){
				if (fan3.contains(fan3Image)) {
					fan3.removeChild(fan3Image);
				}
			}
			
			fan3Image = Bitmap(e.target.content);
			fan3Image.smoothing = true;			
			
			addFan(fanIndex + 2, fan3Image);			
			imagesLoaded[2] = true;
		}
		
		
		
		public function isReady():Boolean
		{
			return imagesLoaded[0] && imagesLoaded[1] && imagesLoaded[2];
		}
		
		
		/**
		 * called from im(n)Loaded methods
		 * sets userName and message text in the fan clip specified by index
		 * adds the image to the fan clip
		 * @param	index
		 * @param	im
		 */
		private function addFan(index:int, im:Bitmap):void
		{
			var data:Object = localCache[index];
			var f:MovieClip;
			
			var r:Number;
			if (200 / im.width > 200 / im.height) {
				//height is greater than width
				r = 200 / im.width;
			}else {
				r = 200 / im.height;
			}
			im.width = im.width * r;
			im.height = im.height * r;
			
			switch(index % 3) {
				case 0:
					f = fan1;					
					break;
				case 1:
					f = fan2;
					break;
				case 2:
					f = fan3;
					break;
			}
			
			
			f.userName.autoSize = TextFieldAutoSize.LEFT;
			f.userName.text = "@" + data.authorname;
			//change font size so that authorName fits fully in the field
			var fSize:int = 22;//default font size in userName field
			var tf:TextFormat = new TextFormat();

			while(f.userName.textWidth > 165){
				fSize--;
				tf.size = fSize;
				f.userName.setTextFormat(tf);
			}
			
			var ft:String = data.text;
			
			while (ft.indexOf("http://") != -1){
				ft = Strings.removeChunk(ft, "http://");
			}
			while (ft.indexOf("https://") != -1){
				ft = Strings.removeChunk(ft, "https://");
			}
			ft = SwearFilter.cleanString(ft);
			
			f.theMessage.autoSize = TextFieldAutoSize.LEFT;
			f.theMessage.text = ft;
			
			if (f.theMessage.text == "") {
				f.theMask.visible = false;
				f.theMessage.visible = false;
				f.textBG.visible = false;
				f.whiteBG.height = 49;
			}else {
				f.theMask.visible = true;
				f.theMessage.visible = true;
				f.textBG.visible = true;
				f.whiteBG.height = 157;
			}
			
			f.addChildAt(im, 1); //place image into fan clip
			im.mask = f.circle;
		}
		
		
		
		public function show():void
		{
			fan1.x = 30;
			fan1.y = 133;
			fan1.alpha = 0;
			fan1.scaleX = fan1.scaleY = 1;
			tweenObject.f1 = 0;	
			
			fan2.x = 450;
			fan2.y = 100;
			fan2.alpha = 0;
			fan2.scaleX = fan2.scaleY = .75;
			tweenObject.f2 = 0;	
			
			fan3.x = 450;
			fan3.y = 270;
			fan3.alpha = 0;
			fan3.scaleX = fan3.scaleY = .75;
			tweenObject.f3 = 0;
			
			addChild(fan1);
			addChild(fan2);
			addChild(fan3);			
			
			fan1.x -= 150;
			fan2.x += 150;
			fan3.x += 150;
			
			//draw gray arcs
			Utility.drawArc(f1Arc.graphics, 100, 100, 98, 0, 360, 12, 0xCECECE, 1);		
			Utility.drawArc(f2Arc.graphics, 100, 100, 98, 0, 360, 12, 0xCECECE, 1);		
			Utility.drawArc(f3Arc.graphics, 100, 100, 98, 0, 360, 12, 0xCECECE, 1);
			
			TweenMax.to(fan1, .75, { x:"+150", alpha:1, ease:Back.easeOut } );
			TweenMax.to(fan2, .75, { x:"-150", alpha:1, delay:.25, ease:Back.easeOut } );
			TweenMax.to(fan3, .75, { x:"-150", alpha:1, delay:.5, ease:Back.easeOut, onComplete:startCycle } );
			
			TweenMax.to(bottomBar, .5, { y:449, ease:Back.easeOut, delay:1 } );
		}
		
		
		private function drawArc1():void
		{
			Utility.drawArc(f1Arc2.graphics, 100, 100, 98, 0, tweenObject.f1, 12, 0xedb01a, 1);
		}
		
		
		private function drawArc2():void
		{
			Utility.drawArc(f2Arc2.graphics, 100, 100, 98, 0, tweenObject.f2, 12, 0xedb01a, 1);
		}
		
		
		private function drawArc3():void
		{
			Utility.drawArc(f3Arc2.graphics, 100, 100, 98, 0, tweenObject.f3, 12, 0xedb01a, 1);
		}
		
		
		private function startCycle():void
		{			
			//draw the orange arc for delayTime and then move fan1 to fan2 spot and fan2 to fan1 spot
			TweenMax.to(tweenObject, ARC_TIME, { f1:360, onUpdate:drawArc1, ease:Linear.easeNone } );
			
			//scroll fan1 text if necessary
			var mh:Number = fan1.theMask.height;
			var delt:Number = fan1.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan1.theMessage, ARC_TIME - 1, {y:fan1.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
			
			TweenMax.to(fan1, 1, { x:450, y:100, scaleX:.75, scaleY:.75, ease:Back.easeOut, delay:ARC_TIME});
			TweenMax.to(fan2, 1, { x:30, y:133, scaleX:1, scaleY:1, ease:Back.easeOut, delay:ARC_TIME, onComplete:nextCycle});
		}
		
		
		private function nextCycle():void
		{
			//draw the orange arc for delayTime and then move fan2 to fan3 spot and fan3 to fan1 spot
			TweenMax.to(tweenObject, ARC_TIME, { f2:360, onUpdate:drawArc2, ease:Linear.easeNone } );
			
			//scroll fan2 text if necessary
			var mh:Number = fan2.theMask.height;
			var delt:Number = fan2.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan2.theMessage, ARC_TIME - 1, {y:fan2.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
			
			TweenMax.to(fan2, 1, { x:450, y:270, scaleX:.75, scaleY:.75, ease:Back.easeOut, delay:ARC_TIME});
			TweenMax.to(fan3, 1, { x:30, y:133, scaleX:1, scaleY:1, ease:Back.easeOut, delay:ARC_TIME, onComplete:lastCycle});
		}
		
		
		private function lastCycle():void
		{
			//draw the orange arc for delayTime
			TweenMax.to(tweenObject, ARC_TIME, { f3:360, onUpdate:drawArc3, ease:Linear.easeNone, onComplete:done } );
			
			//scroll fan3 text if necessary
			var mh:Number = fan3.theMask.height;
			var delt:Number = fan3.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan3.theMessage, ARC_TIME - 1, {y:fan3.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
		}
		
		
		private function done():void
		{
			dispatchEvent(new Event(FINISHED));//will call cleanup
		}
		
		
		public function cleanup():void
		{
			if (contains(fan1)) {
				removeChild(fan1);
			}
			if (contains(fan2)) {
				removeChild(fan2);
			}
			if (contains(fan3)) {
				removeChild(fan3);
			}
			fan1.theMessage.y = fan1.theMask.y;
			fan2.theMessage.y = fan2.theMask.y;
			fan3.theMessage.y = fan3.theMask.y;
			bottomBar.y = 512; //off screen bottom
			
			f1Arc2.graphics.clear();
			f2Arc2.graphics.clear();
			f3Arc2.graphics.clear();
			
			fanIndex += 3;
			if (fanIndex <= localCache.length - 3) {
				dataLoaded();
			}else {
				fanIndex = 0;
				refreshData();				
			}
			
		}
		
	}	
	
}