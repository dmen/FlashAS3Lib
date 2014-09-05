package com.gmrmarketing.sap.metlife.tagcloud
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import com.gmrmarketing.sap.metlife.FlareManager;
	import flash.display.*;
	import com.gmrmarketing.sap.metlife.tagcloud.RectFinder;	
	import com.gmrmarketing.sap.metlife.tagcloud.TagCloud;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready"; //scheduler requires the READY event to be the string "ready"
		
		private const WIDTH:int = 1008;
		private const HEIGHT:int = 567;
		
		private var dict:TagCloud;//tags from the service
		private var ra:RectFinder;
		private var bmp:Bitmap;
		private var tagName:String; //set in setConfig, one of: levis,offense,defense
		private var flares:FlareManager;
		
		
		public function Main()
		{	
			dict = new TagCloud(3, 56, 12);
			dict.addEventListener(TagCloud.TAGS_READY, tagsLoaded, false, 0, true);
			
			//TESTING
			//init("levis,0xda2c45,0xc7283f,0xa92236");
			
			flares = new FlareManager();//will be part of scheduler
			flares.setContainer(this);
			
			init("levis,0xc92845");
		}
		
		
		/**
		 * ISChedulerMethods
		 * initValue is tagName, array of colors: levis,0xffffff,0xcccccc,0x678900,etc
		 */
		public function init(initValue:String = ""):void
		{
			var i:int = initValue.indexOf(",");//first occurence of comma
			tagName = initValue.substring(0, i);
			var cols:String = initValue.substr(i + 1);
			var colors:Array = cols.split(",");
			
			ra = new RectFinder(3);
			
			dict.refreshTags(tagName, colors);//calls tagsLoaded when ready
		}
		
		
		/**
		 * ISChedulerMethods
		 * show will be called once ready event is received
		 */
		public function show():void
		{		
			flares.newFlare(360, 40, 640,2);	//x,y,toX,delay		
			flares.newFlare(290, 470, 720, 2);
			flares.newFlare(300, 93, 710, 1);
			flares.newFlare(320, 173, 690, 1);
			
			var bmd:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
			bmp = new Bitmap(bmd);
			//TweenMax.to(bmp, 0, { dropShadowFilter: { color:0x000000, alpha:.8, blurX:5, blurY:5, distance:4 }} );
			addChild(bmp);	
			
			var tagImage:BitmapData = new cloud();//image to create with word cloud
			
			ra.create(this, tagImage, dict.getTags(), this.stage);
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			if (contains(bmp)) {
				removeChild(bmp);
			}
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			ra.stop();
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
		{
			dict.kill();
			ra.kill();
			//dict = null;
			ra = null;
		}
		
		/**
		 * callback from setConfig()
		 * @param	e
		 */
		private function tagsLoaded(e:Event):void
		{
			show();//TESTING
			dispatchEvent(new Event(READY));
		}
	}
	
}