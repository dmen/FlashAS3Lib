package com.gmrmarketing.sap.metlife.eventsTicker
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.sap.metlife.player.LensFlares;
	import fl.video.MetadataEvent;
	import flash.text.TextFormat;
	
	public class Main extends MovieClip
	{		
		private var fanCache:Object;//last good pull of FOTD JSON from the web service
		private var eventsCache:Object;//last good pull of events JSON from the web service
		private var fanImages:Array;
		private var fanIndex:int; //current index in fanCache - reset in dataLoaded()
		private var slideIndex:int; //current showing slide in the slider
		private var totalSlides:int; //total number of slides - starts at 3
		private var flares:LensFlares;
		
		public function Main()
		{
			flares = new LensFlares();
			flares.setContainer(this);
			totalSlides = 3; //two logos and fotd
			theVideo.addEventListener(MetadataEvent.CUE_POINT, loop);
			fanImages = new Array();
			refreshFOTD();
		}
		
		private function loop(e:Event):void
		{
			theVideo.seek(0);
			theVideo.play();
		}
		
		/**
		 * refreshes FOTD data from the web service
		 */
		private function refreshFOTD():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://wall.thesocialtab.net/SocialPosts/GetPosts?ProgramID=52&Count=5&Grouping=SAPJets" + "&abc=" + String(new Date().valueOf()));
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
			fanIndex = 0; //first person in the list
			fanCache = JSON.parse(e.currentTarget.data);			
			loadFOTDImage();
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (fanCache) {
				fanIndex = 0;
				loadFOTDImage();
			}			
		}
		
		
		private function loadFOTDImage():void
		{			
			var imageURL:String = fanCache.SocialPosts[fanIndex].MediumResURL;			
			if(imageURL){
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imLoaded, false, 0, true);			
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imError, false, 0, true);			
				l.load(new URLRequest(imageURL));
			}
		}
		
		
		/**
		 * Called once FOTD data and image have successfully loaded
		 * refreshes the data in the slider.fotd clip
		 * @param	e
		 */
		private function imLoaded(e:Event):void
		{
			//remove old image from clip
			if(fanImages[fanIndex]){
				if (slider.fotd.contains(fanImages[fanIndex])) {
					slider.fotd.removeChild(fanImages[fanIndex]);
				}				
			}
			
			var im:Bitmap =  Bitmap(e.target.content);
			im.smoothing = true;			
			
			var r:Number;
			if (144 / im.width > 145 / im.height) {
				//height is greater than width
				r = 144 / im.width;
			}else {
				r = 145 / im.height;
			}
			im.width = im.width * r;
			im.height = im.height * r;
			
			fanImages[fanIndex] = im;
			
			slider.fotd.addChild(fanImages[fanIndex]);
			fanImages[fanIndex].x = 43;//TODO: Center if too big still?
			fanImages[fanIndex].y = 78;
			fanImages[fanIndex].mask = slider.fotd.picMask;
			
			slider.fotd.userName.text = fanCache.SocialPosts[fanIndex].AuthorName;
			slider.fotd.theText.text = fanCache.SocialPosts[fanIndex].Text;	
			
			refreshEvents();
		}
		
		
		private function imError(e:IOErrorEvent):void
		{
			if(fanImages[fanIndex]){
				if (slider.fotd.contains(fanImages[fanIndex])) {
					slider.fotd.removeChild(fanImages[fanIndex]);
				}				
			}	
			
			slider.fotd.addChild(fanImages[fanIndex]);
			fanImages[fanIndex].x = 43;//TODO: Center if too big still?
			fanImages[fanIndex].y = 78;
			fanImages[fanIndex].mask = slider.fotd.picMask;
			
			refreshEvents();
		}
		
		
		//TODO: Date has to come from config file...
		private function refreshEvents():void
		{			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetGameDayEvents?gamedate=10/12/14" + "&abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, eventsLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, eventsError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function eventsLoaded(e:Event):void
		{
			while (slider.numChildren > 3) {
				slider.removeChildAt(3);				
			}
			totalSlides = 3;
			eventsCache = JSON.parse(e.currentTarget.data);
			//for each event add an events clip t the end of the slider
			for (var i:int = 0; i < eventsCache.length; i++) {
				var ev:MovieClip = new event(); //lib clip
				ev.x = slider.width;
				slider.addChild(ev);
				ev.headline.text = eventsCache[i].Headline;
				ev.displayTime.text = eventsCache[i].DisplayTime;
				ev.title.text = eventsCache[i].Title;
				
				//change font size so that authorName fits fully in the field
				var fSize:int = 60;//default font size
				var tf:TextFormat = new TextFormat();

				while(ev.title.textWidth > ev.title.width){
					fSize--;
					tf.size = fSize;
					ev.title.setTextFormat(tf);
				}
				ev.title.y = 147 + ((76 - ev.title.textHeight) * .5);
					
				ev.hashtag.text = eventsCache[i].Hashtag;
				totalSlides++;
			}
			
			//add sap logo to end
			var l:MovieClip = new logoLockup();
			l.x = slider.width;
			slider.addChild(l);
			totalSlides++;
			resetSlide();
		}
		
		
		private function eventsError(e:IOErrorEvent):void
		{
			//do nothing if error...	
			resetSlide();
		}
		
		
		private function resetSlide():void
		{
			slider.x = 0;
			slideIndex = 0;
			slideNext();
		}
		
		
		private function slideNext():void
		{
			slideIndex++;
			if (slideIndex == 1) {
				//fotd will be showing next
				slider.fotd.theMask.x = -619;
			}
			TweenMax.to(slider, .75, { x:"-1008", delay:10, onStart:checkFOTD, onComplete:checkForEnd } );
		}		
		
		private function checkFOTD():void
		{
			if (slideIndex == 1) {
				TweenMax.to(slider.fotd.theMask, .5, { x:191, delay:.5 } );
				flares.show([[192, 86, 530, "point", 1.5], [192,133,973,"line",1.7],[45,242,963,"line",4],[57,284,952,"point",4.2]]);
			}
			//events flares
			if (slideIndex > 2 && slideIndex < totalSlides-1) {
				flares.show([[252, 16, 754, "line", 1.5], [268,60,739,"point",1.7],[94,75,914,"line",4],[138,228,868,"point",4.2],[417,246,590,"point",5]]);
			}
		}
		
		private function checkForEnd():void
		{
			if (slider.x <= -slider.width + 1008) {
				fanIndex++;
				if (fanIndex >= fanCache.SocialPosts.length) {
					fanIndex = 0;
				}
				loadFOTDImage();
			}else {
				slideNext();
			}
		}
		
	}
	
}