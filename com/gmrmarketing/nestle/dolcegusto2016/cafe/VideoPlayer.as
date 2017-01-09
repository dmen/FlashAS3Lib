package com.gmrmarketing.nestle.dolcegusto2016.cafe
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	

	public class VideoPlayer extends EventDispatcher
	{
		public static const COMPLETE:String = "videoComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var videoPlayer:MovieClip;
		
		private var loader:URLLoader;
		private var videos:Object;
		private var currentVideos:Array; //the product or william videos - set in setSection()
		
		private var section:int; //0 products, 1 william - defaults to 0 in show()
		private var vidNum:int;//index of currentVideos within section
		
		private var indicatorContainer:Sprite;//holds the circle indicators for the number of videos
		
		
		public function VideoPlayer()
		{
			clip = new mcVideoPlayer();
			
			indicatorContainer = new Sprite();//contains instances of mcFlavorIndicator (24x24 gray circle)
			clip.addChild(indicatorContainer);
			indicatorContainer.y = 1721;//top of the circles
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("videos.json"));
		}
		
		
		private function parseJSON(e:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, parseJSON);
			var js:Object = JSON.parse(loader.data);
			videos = js.videos;//object with product and william properties (arrays of objects with video, title properties)
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			section = 0;
			vidNum = 0;			
			setSection(0);//set to products
			
			clip.btnLeft.alpha = .2;
			clip.btnRight.alpha = 1;
			
			//TODO:Animate Build
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeVideoPlayer, false, 0, true);
			clip.btnProducts.addEventListener(MouseEvent.MOUSE_DOWN, showProducts, false, 0, true);
			clip.btnWilliam.addEventListener(MouseEvent.MOUSE_DOWN, showWilliam, false, 0, true);			
		}
		
		
		public function hide():void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeVideoPlayer);
			clip.btnProducts.removeEventListener(MouseEvent.MOUSE_DOWN, showProducts);
			clip.btnWilliam.removeEventListener(MouseEvent.MOUSE_DOWN, showWilliam);
			clip.btnLeft.removeEventListener(MouseEvent.MOUSE_DOWN, leftClicked);
			clip.btnRight.removeEventListener(MouseEvent.MOUSE_DOWN, rightClicked);
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			clip.player.stop();
		}
		
		
		private function closeVideoPlayer(e:MouseEvent):void
		{
			clip.player.stop();
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function showProducts(e:MouseEvent):void
		{
			setSection(0);
		}
		
		private function showWilliam(e:MouseEvent):void
		{
			setSection(1);
		}
		
		/**
		 * populates currentVideos from the JSON
		 * plays the first video avaiable
		 * @param	newSection
		 */
		private function setSection(newSection:int):void
		{
			if(newSection == 0){
				currentVideos = videos.product;//array of {"video":"","title":""}
				clip.btnProducts.gotoAndStop(1);
				clip.btnWilliam.gotoAndStop(2);
			}else{
				currentVideos = videos.william;
				clip.btnProducts.gotoAndStop(2);
				clip.btnWilliam.gotoAndStop(1);
			}
			
			vidNum = 0;//first video in the section
			
			//re-build the indicator
			while (indicatorContainer.numChildren){
				indicatorContainer.removeChildAt(0);
			}
			for (var i:int = 0; i < currentVideos.length; i++){
				var indic:MovieClip = new mcFlavorIndicator();
				indic.x = i * (indic.width + 25);
				indicatorContainer.addChild(indic);
			}
			indicatorContainer.x = 1368 - (indicatorContainer.width * .5);
			showPageNum();
			
			if (currentVideos.length == 1){
				clip.btnLeft.alpha = .2;
				clip.btnRight.alpha = .2;
				clip.btnLeft.removeEventListener(MouseEvent.MOUSE_DOWN, leftClicked);
				clip.btnRight.removeEventListener(MouseEvent.MOUSE_DOWN, rightClicked);
			}else{
				clip.btnLeft.alpha = .2;
				clip.btnRight.alpha = 1;
				clip.btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, leftClicked, false, 0, true);
				clip.btnRight.addEventListener(MouseEvent.MOUSE_DOWN, rightClicked, false, 0, true);
			}
			
			playCurrentVideo();
		}
		
		
		private function playCurrentVideo():void
		{
			clip.title.text = currentVideos[vidNum].title;
			clip.player.source = "assets/" + currentVideos[vidNum].video;
			clip.player.seek(0);
			clip.player.play();
		}
		
		
		/**
		 * shows the vid number in little circles at the bottom
		 */
		private function showPageNum():void
		{
			var n:int = indicatorContainer.numChildren;
			for (var i:int = 0; i < n; i++){
				if (i == vidNum){
					TweenMax.to(indicatorContainer.getChildAt(i), .75, {tint:0x930053});
				}else{
					TweenMax.to(indicatorContainer.getChildAt(i), 0, {tint:0xc0c0c0});
				}
			}
		}
		
		
		private function leftClicked(e:MouseEvent):void
		{
			if(vidNum > 0){				
				vidNum--;
				showPageNum();
				playCurrentVideo();
			}
			if (vidNum <= 0){
				TweenMax.to(clip.btnLeft, .5, {alpha:.1});				
			}
			TweenMax.to(clip.btnRight, .5, {alpha:1});
		}
		
		
		private function rightClicked(e:MouseEvent):void
		{
			if((vidNum + 1) < currentVideos.length){				
				vidNum++;
				showPageNum();
				playCurrentVideo();
			}
			if ((vidNum + 1) >= currentVideos.length){
				TweenMax.to(clip.btnRight, .5, {alpha:.1});				
			}
			TweenMax.to(clip.btnLeft, .5, {alpha:1});
		}
		
	}
	
}