package com.gmrmarketing.sap.levisstadium.fotd
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Utility;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		public static const ERROR:String = "error";
		
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
		
		private var json:Object;
		private var localCache:Object;
		private var imagesLoaded:Array; //array of booleans
		private var tweenObject:Object;//for tweening arc
		
		private var delayTime:int; //seconds between pic changes - set in init
		
		
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
			
			//init("20");//TESTING
		}
		
		
		/**
		 * ISchedulerMethods
		 * initValue is the total time (in seconds) this task will be displayed for
		 */
		public function init(initValue:String = ""):void
		{
			delayTime = (parseInt(initValue) - 1.25) / 3;//subtract 1.25 first to compensate for intro animation in show
			
			tweenObject = new Object();
			imagesLoaded = new Array();
			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=48&Grouping=FOTD49ers&Count=3&SwearRating=7" + "&abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
			
		}
		
		/**
		 * ISchedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		/**
		 * ISchedulerMethods
		 */
		public function doStop():void
		{
			
		}
		
		/**
		 * ISchedulerMethods
		 */
		public function kill():void
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
		}
		
		
		private function dataLoaded(e:Event):void
		{
			json = JSON.parse(e.currentTarget.data);
			localCache = json;
			
			if(json.SocialPosts.length > 2){
				var im1URL:String = json.SocialPosts[0].MediumResURL;
				var im2URL:String = json.SocialPosts[1].MediumResURL;
				var im3URL:String = json.SocialPosts[2].MediumResURL;			
				
				if(im1URL){
					var im1Loader:Loader = new Loader();
					im1Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im1Loaded, false, 0, true);			
					im1Loader.load(new URLRequest(im1URL));
				}
				
				if(im2URL){
					var im2Loader:Loader = new Loader();
					im2Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im2Loaded, false, 0, true);			
					im2Loader.load(new URLRequest(im2URL));
				}
				
				if(im3URL){
					var im3Loader:Loader = new Loader();
					im3Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, im3Loaded, false, 0, true);			
					im3Loader.load(new URLRequest(im3URL));
				}
				
				//show();//TESTING
			}else {
				//social posts is empty
				dispatchEvent(new Event(ERROR));
			}
		}
		
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				json = localCache;	
				tweenObject.f1 = 0;	//reset for arc drawing
				tweenObject.f2 = 0;	
				tweenObject.f3 = 0;	
				dispatchEvent(new Event(READY));//will call show()
			}else{
				dispatchEvent(new Event(ERROR));
			}
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
			
			addFan(0, fan1Image); //adds image to the fan clip
			
			imagesLoaded[0] = true;
			checkImages();
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
			
			addFan(1, fan2Image);			
			
			imagesLoaded[1] = true;
			checkImages();
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
			
			addFan(2, fan3Image);			
			
			imagesLoaded[2] = true;
			checkImages();
		}
		
		
		/**
		 * Called by im(n)Loaded methods
		 * checks to see if all three images are loaded and then dispatches READY event
		 */
		private function checkImages():void
		{
			if (imagesLoaded[0] == true && imagesLoaded[1] == true && imagesLoaded[2] == true) {
				//show();//TESTING
				dispatchEvent(new Event(READY));//will call show()
			}
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
			var data:Object = json.SocialPosts[index];
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
			
			switch(index) {
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
			
			f.userName.text = data.AuthorName;
			
			//change font size so that authorName fits fully in the field
			var fSize:int = 22;//default font size in userName field
			var tf:TextFormat = new TextFormat();

			while(f.userName.textWidth > f.userName.width){
				fSize--;
				tf.size = fSize;
				f.userName.setTextFormat(tf);
			}
			
			var ft:String = data.Text;
			
			var t:Array = ft.split(" ");
			for(var i:int = t.length -1; i >= 0; i--){
				if(t[i].indexOf("fuck") != -1 || t[i].indexOf("bitch") != -1 || t[i].indexOf("shit") != -1){
					t.splice(i,1);		
				}
			}

			var m:String = t.join(" ");

			m = m.replace(/fuck/g, "");
			m = m.replace(/bitch/g, "");
			m = m.replace(/shit/g, "");
			
			f.theMessage.autoSize = TextFieldAutoSize.LEFT;
			f.theMessage.text = m;
			
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
		
		
		/**
		 * ISChedulerMethods
		 * Called once scheduler receives READY event
		 */
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
			
			//TweenMax.to(tweenObject, 5, { f2:360, onUpdate:drawArc2 } );
			//TweenMax.to(tweenObject, 5, { f3:360, onUpdate:drawArc3 } );
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
			TweenMax.to(tweenObject, delayTime, { f1:360, onUpdate:drawArc1, ease:Linear.easeNone } );
			
			//scroll fan1 text if necessary
			var mh:Number = fan1.theMask.height;
			var delt:Number = fan1.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan1.theMessage, delayTime - 1, {y:fan1.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
			
			TweenMax.to(fan1, 1, { x:450, y:100, scaleX:.75, scaleY:.75, ease:Back.easeOut, delay:delayTime});
			TweenMax.to(fan2, 1, { x:30, y:133, scaleX:1, scaleY:1, ease:Back.easeOut, delay:delayTime, onComplete:nextCycle});
		}
		
		
		private function nextCycle():void
		{
			//draw the orange arc for delayTime and then move fan2 to fan3 spot and fan3 to fan1 spot
			TweenMax.to(tweenObject, delayTime, { f2:360, onUpdate:drawArc2, ease:Linear.easeNone } );
			
			//scroll fan2 text if necessary
			var mh:Number = fan2.theMask.height;
			var delt:Number = fan2.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan2.theMessage, delayTime - 1, {y:fan2.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
			
			TweenMax.to(fan2, 1, { x:450, y:270, scaleX:.75, scaleY:.75, ease:Back.easeOut, delay:delayTime});
			TweenMax.to(fan3, 1, { x:30, y:133, scaleX:1, scaleY:1, ease:Back.easeOut, delay:delayTime, onComplete:lastCycle});
		}
		
		
		private function lastCycle():void
		{
			//draw the orange arc for delayTime
			TweenMax.to(tweenObject, delayTime, { f3:360, onUpdate:drawArc3, ease:Linear.easeNone } );
			
			//scroll fan3 text if necessary
			var mh:Number = fan3.theMask.height;
			var delt:Number = fan3.theMessage.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(fan3.theMessage, delayTime - 1, {y:fan3.theMask.y - delt - 5, ease:Linear.easeNone, delay:.5});
			}
		}
		
	}
	
	
}