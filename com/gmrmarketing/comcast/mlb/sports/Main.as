package com.gmrmarketing.comcast.sports
{
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.display.Loader;
	import com.gmrmarketing.comcast.sports.*;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getDefinitionByName;
	import flash.events.*;
	
	NFL; //references to the sport classes so getDefinitionByName works
	
	
	
	public class Main extends MovieClip
	{		
		private var player:VPlayer;
		private var theSport:Object;
		private var imLoader:Loader;
		
		private var rep:Object; //replay object got from sport class when video is done playing
		private var replay:replayButton; //library clip
		
		
		
		public function Main() 
		{
			//FLASHVAR
			var theType:String = loaderInfo.parameters.type; //comcastEN, comcastSP, xfinityEN, xfinitySP
			var whichSport:String = loaderInfo.parameters.sport; //NFL, NHL, etc.
			
			//for testing prior to FlashVars being used
			theType = "comcastEN";
			whichSport = "NFL";
			
			var cRef:Class = getDefinitionByName("com.gmrmarketing.comcast.sports." + whichSport) as Class;
			theSport = new cRef(theType);
			
			sideText.htmlText = theSport.getSideText();			
			
			var media:Object = theSport.getMedia();
			
			if (media.type == "flv") {
				player = new VPlayer();
				player.autoSizeOff();
				player.setSmoothing(true);
				player.setVidSize( { width:754, height:325 } );
				player.showVideo(this);			
				player.playVideo(media.url);
				player.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);
				
			}else if(media.type == "img" || media.type == "swf") {
				//load image
				imLoader = new Loader();
				imLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, showImage, false, 0, true);
				imLoader.load(new URLRequest(media.url));				
			
			}else {
				throw new Error("Undefined media type in sport class");
			}
			
		}
		
		
		
		private function showImage(e:Event):void
		{
			addChild(imLoader);
		}
		
		
		
		private function vidStatus(e:Event):void
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				
				rep = theSport.getReplay();
				if (rep.text != "") {
					//text is defined - show the button
					if(replay == null){
						replay = new replayButton();
					}
					replay.x = 635;
					replay.y = 285;
					addChild(replay);
					replay.addEventListener(MouseEvent.CLICK, replayClicked, false, 0, true);
				}
			}
		}
		
		
		
		private function replayClicked(e:MouseEvent):void
		{
			if (rep.url != "") {
				navigateToURL(new URLRequest(rep.url), "_blank");
			}else {
				//url is blank - replay button replays the video
				player.playVideo(theSport.getMedia().url);
				removeChild(replay);
			}
		}
		
		
	}
	
}