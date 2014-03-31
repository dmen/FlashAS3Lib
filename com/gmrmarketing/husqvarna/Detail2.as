package com.gmrmarketing.husqvarna
{
	import flash.display.DisplayObjectContainer;
	import com.gmrmarketing.utilities.Strings;
	import flash.display.Sprite;
	import flash.events.*;
	
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	
	public class Detail2 extends EventDispatcher
	{
		public static const DETAIL_CLOSE:String = "detailCloseTabClicked";
		public static const MUSIC_CLICK:String = "musicTabClicked";
		
		private var detail:theDetail; //library clip
		private var container:DisplayObjectContainer;		
				
		private var featureData:Object;
		
		//private var callout:theCallout; //library clip
		
		 //y position of the detail clip - used by the callout as it uses stage coords
		private var yOffset:int = 119;
		
		//height of the small h logo - used for animating the mask
		private var lHeight:int;
		private var lInitY:int;
		
		//video		
		private var cueName:String;
		private var vidWidth:int;
		private var vidHeight:int;		
		private var statusCode:String;
		private var preloader:logoSmall; //lib
		private var preloaderMask:logoSmallMask;
		private var preloaderShowing:Boolean = false;
		private var vm:int = 125; //vertical motion the mask travels to reveal the logo - used in updatePreloader()
		
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;
		private var theVideo:Video;
		
		
		public function Detail2($container:DisplayObjectContainer)
		{
			TweenPlugin.activate([TintPlugin]);
			
			container = $container;
			
			detail = new theDetail();
			detail.x = 0;
			detail.y = yOffset;			
			
			preloader = new logoSmall();
			preloader.x = 420;
			preloader.y = 120;
			preloader.alpha = .5;			
			
			preloaderMask = new logoSmallMask();			
			preloaderMask.x = 418;
			lHeight = preloaderMask.height;
			lInitY = 120 + lHeight + 2;
			preloaderMask.y = lInitY;
			
			//video
			vidConnection = new NetConnection();
			vidConnection.connect(null);
			trace("connec", vidConnection);
			
			vidStream = new NetStream(vidConnection);			
			vidStream.bufferTime = 3;
			vidStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			vidStream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);			
			vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };
			trace("stream",vidStream);
			
			theVideo = new Video();
			theVideo.attachNetStream(vidStream);
			
			theVideo.width = 940;
			theVideo.height = 444;
			trace("vid", theVideo);
			
			container.addChild(theVideo);
			trace("vid x,y", theVideo.x, theVideo.y, container.contains(theVideo));
		}
		
		
		/**
		 * Removes the detail container from the view
		 */
		public function hide():void
		{			
			container.removeChild(detail);
		}
		
		
		/**
		 * Data object contains description, video, feature, callout, calloutLoc properties
		 * adds an event listener to detail that calls checkVid on enter_frame, after playing the video
		 * @param	data
		 */
		public function show(data:Object, showMusicTab:Boolean):void
		{
			vidStream.play(data.video);
			trace("playing", data.video);
			
			detail.tabMusic.visible = showMusicTab;
			detail.tabMusic.addEventListener(MouseEvent.CLICK, musicTabClicked, false, 0, true);
			detail.tabMusic.addEventListener(MouseEvent.MOUSE_OVER, hiliteMusic, false, 0, true);
			detail.tabMusic.addEventListener(MouseEvent.MOUSE_OUT, unhiliteMusic, false, 0, true);
			detail.tabMusic.mouseChildren = false;
			detail.tabMusic.buttonMode = true;
			
			//detail.tabModels.addEventListener(MouseEvent.CLICK, showModels, false, 0, true);
			detail.tabModels.addEventListener(MouseEvent.MOUSE_OVER, hiliteModels, false, 0, true);
			detail.tabModels.addEventListener(MouseEvent.MOUSE_OUT, unhiliteModels, false, 0, true);
			detail.tabModels.mouseChildren = false;
			detail.tabModels.buttonMode = true;
			
			detail.tabClose.addEventListener(MouseEvent.MOUSE_OVER, hiliteClose, false, 0, true);
			detail.tabClose.addEventListener(MouseEvent.MOUSE_OUT, unhiliteClose, false, 0, true);
			detail.tabClose.addEventListener(MouseEvent.CLICK, closeClicked, false, 0, true);
			detail.tabClose.mouseChildren = false;
			detail.tabClose.buttonMode = true;
			
			//set local data for use in vPlayerStatus()
			featureData = data;
			
			detail.theText.htmlText = featureData.description;
			detail.theText.y = 450 + ((103 - detail.theText.textHeight) * .5);
			
			//name in the black feature tab
			detail.tabFeature.theText.text = Strings.upperCaseFirst(data.feature);			
			//center text vertically in the tab
			detail.tabFeature.theText.y = Math.floor((38 - detail.tabFeature.theText.textHeight) * .5) - 2;			
			
			if(!container.contains(detail)){
				container.addChild(detail);
			}
			
			
		}
		
		
		
		private function hiliteClose(e:MouseEvent):void
		{
			TweenLite.to(detail.tabClose.bg, .3, { tint:0x74320A } );
		}
		private function unhiliteClose(e:MouseEvent):void
		{
			TweenLite.to(detail.tabClose.bg, .3, { tint:0x000000 } );
		}
		private function hiliteMusic(e:MouseEvent):void
		{
			TweenLite.to(detail.tabMusic.bg, .3, { tint:0x74320A } );
		}
		private function unhiliteMusic(e:MouseEvent):void
		{
			TweenLite.to(detail.tabMusic.bg, .3, { tint:0x333333 } );
		}
		
		
		/**
		 * Called by rolling into the show models tab
		 * @param	e
		 */
		private function hiliteModels(e:MouseEvent):void
		{
			TweenLite.to(detail.tabModels.bg, .3, { tint:0x74320A } );
			showModels();
		}
		private function unhiliteModels(e:MouseEvent):void
		{
			TweenLite.to(detail.tabModels.bg, .3, { tint:0x333333 } );
		}
		
		/**
		 * Tweens the models container up or down depending on modelsShowing
		 * Called from hiliteModels() when the models tab is moused over	
		 */
		private function showModels():void
		{			
			TweenLite.to(detail.models, .5, { y:242, onComplete:startModelMouseChecking } );
			
			detail.models.p4822.mouseEnabled = false;
			detail.models.p6126.mouseEnabled = false;
			detail.models.p6128.mouseEnabled = false;
			detail.models.p5224.mouseEnabled = false;
			
			detail.models.btn4822.buttonMode = true;
			detail.models.btn6126.buttonMode = true;
			detail.models.btn6128.buttonMode = true;
			detail.models.btn5224.buttonMode = true;
			
			detail.models.btn4822.addEventListener(MouseEvent.MOUSE_OVER, hiliteModel, false, 0, true);
			detail.models.btn6126.addEventListener(MouseEvent.MOUSE_OVER, hiliteModel, false, 0, true);
			detail.models.btn6128.addEventListener(MouseEvent.MOUSE_OVER, hiliteModel, false, 0, true);
			detail.models.btn5224.addEventListener(MouseEvent.MOUSE_OVER, hiliteModel, false, 0, true);
			
			detail.models.btn4822.addEventListener(MouseEvent.MOUSE_OUT, unhiliteModel, false, 0, true);
			detail.models.btn6126.addEventListener(MouseEvent.MOUSE_OUT, unhiliteModel, false, 0, true);
			detail.models.btn6128.addEventListener(MouseEvent.MOUSE_OUT, unhiliteModel, false, 0, true);
			detail.models.btn5224.addEventListener(MouseEvent.MOUSE_OUT, unhiliteModel, false, 0, true);
			
			detail.models.btn4822.addEventListener(MouseEvent.CLICK, modelClicked, false, 0, true);
			detail.models.btn6126.addEventListener(MouseEvent.CLICK, modelClicked, false, 0, true);
			detail.models.btn6128.addEventListener(MouseEvent.CLICK, modelClicked, false, 0, true);
			detail.models.btn5224.addEventListener(MouseEvent.CLICK, modelClicked, false, 0, true);				
		}
		
		private function startModelMouseChecking():void
		{
			detail.addEventListener(Event.ENTER_FRAME, modelsOut, false, 0, true);	
		}
		
		private function modelsOut(e:Event):void
		{
			
			if (detail.mouseX < detail.models.x || detail.mouseX > detail.models.x + detail.models.width || detail.mouseY < detail.models.y || detail.mouseY > detail.models.y + detail.models.height + 30) {
				TweenLite.to(detail.models, .5, { y:450 } );
				detail.removeEventListener(Event.ENTER_FRAME, modelsOut);
			}			
		}
		
		private function hiliteModel(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .5, { alpha:1 } );
		}
		
		private function unhiliteModel(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .5, { alpha:.24 } );
		}
		
		private function modelClicked(e:MouseEvent):void
		{
			var baseURL:String = "http://www.husqvarna.com/us/landscape-and-groundcare/products/zero-turn-mowers/";
			var fullURL:String;
			
			switch(e.currentTarget.name) {
				case "btn4822":
					fullURL = baseURL + "p-zt4822/";
					break;
				case "btn5224":
					fullURL = baseURL + "p-zt5224/";
					break;
				case "btn6126":
					fullURL = baseURL + "p-zt6126/";
					break;
				case "btn6128":
					fullURL = baseURL + "p-zt6128/";
					break;
			}
			
			navigateToURL(new URLRequest(fullURL), "_blank");
		}
		
		/**
		 * Called when the close tab is clicked
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function closeClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(DETAIL_CLOSE));
		}
		
		
		private function musicTabClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(MUSIC_CLICK));
		}
		

		
		
		//VIDEO
		/**
		 * Called from statusHandler() when a NetStream.Play.Start is received
		 * play.start signals a video has begun to queue
		 */
		private function addPreloader(){
			preloaderShowing = true;
			if(!detail.contains(preloader)){
				detail.addChild(preloader);
				detail.addChild(preloaderMask);
			}
			preloaderMask.y = lInitY;
			preloader.mask = preloaderMask;
			
			detail.addEventListener(Event.ENTER_FRAME, updatePreloader);
		}
		
		/**
		 * Called from statusHandler() when NetStream.Buffer.Full is received, which
		 * signals the beginning of playback
		 */
		private function removePreloader(){
			preloaderShowing = false;
			if(detail.contains(preloader)){
				detail.removeChild(preloader);
				detail.removeChild(preloaderMask);
			}
			detail.removeEventListener(Event.ENTER_FRAME, updatePreloader);
		}
		
		
		/**
		 * Called by enter frame listener on detail when the preloader is showing
		 * updates the position of the mask based on the seconds buffered
		 * 
		 * @param	e
		 */
		private function updatePreloader(e:Event){
			var r:Number = vidStream.bufferLength / vidStream.bufferTime; //0-1	
			preloaderMask.y = lInitY - (r * vm);
		}
		
		
		private function metaDataHandler(infoObject:Object):void 
		{					
			trace("meta");
			vidWidth = infoObject.width;
			vidHeight = infoObject.height;			
		}


		private function cuePointHandler(infoObject:Object):void 
		{
			cueName = infoObject.name;				
		}


		private function statusHandler(e:NetStatusEvent):void 
		{ 			
			trace("status", e.info.code);
			statusCode = e.info.code;			
			if(statusCode == "NetStream.Play.Start" && !preloaderShowing){
				addPreloader();
			}
			if(statusCode == "NetStream.Buffer.Full"){
				removePreloader();
			}			
		}
		
			
		private function asyncErrorHandler(e:AsyncErrorEvent):void 	
		{
			trace("asynch:", e); 
		}
	}
	
}