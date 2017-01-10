 package com.gmrmarketing.goldenOne.cheerBooth2016
 {
    import flash.display.*;
    import flash.events.*;
    import flash.media.Video;
    import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	

    public class Review extends EventDispatcher 
	{
		public static const COMPLETE:String = "reviewComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
        private var video:Video;		
        private var connection:NetConnection;
        private var stream:NetStream;

		private var videoFile:String; //full path to the video file - created in show()
		
		
        public function Review() 
		{
			clip = new mcReview();
			
			video = new Video(960, 540);
			video.x = 156;
			video.y = 370;
			clip.addChild(video);			
			
            connection = new NetConnection();
            connection.addEventListener(NetStatusEvent.NET_STATUS, connectionStatusHandler);
            connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);            
        }

		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			videoFile = "C:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\goldenOne\\streams\\_definst_\\user.flv";
			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			connection.connect(null);
			
			clip.title.x = 1920;
			clip.subTitle.text = 1920;
			
			video.addEventListener(MouseEvent.MOUSE_DOWN, replayVideo, false, 0, true);
			
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut});
			TweenMax.to(clip.subTitle, .5, {x:150, ease:Expo.easeOut, delay:.1});
		}
		
		
		public function hide():void
		{
			stream.dispose();
			video.attachNetStream(null);
			
			video.removeEventListener(MouseEvent.MOUSE_DOWN, replayVideo);
			
			TweenMax.to(clip.title, .5, {x:-1500, ease:Expo.easeIn});
			TweenMax.to(clip.subTitle, .5, {x:-1500, ease:Expo.easeIn, delay:.1, onComplete:kill});
		}
		
		
		public function replayVideo():void
		{
			stream.seek(0);
			stream.play(videoFile);
		}
		
		
		public function kill():void
		{
			if(stream){
				stream.dispose();
			}
			video.attachNetStream(null);
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
		}
		
		
        private function connectionStatusHandler(e:NetStatusEvent):void 
		{			
            switch (e.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    trace("Unable to locate video: " + videoFile);
                    break;		
            }
        }

		
        private function connectStream():void
		{
            stream = new NetStream(connection);
			stream.client = {onMetaData:metaDataHandler, onPlayStatus:streamStatusHandler};           
            video.attachNetStream(stream);
            stream.play(videoFile);
			video.alpha = 0;
			TweenMax.to(video, .3, {alpha:1});
        }
		
		
		private function streamStatusHandler(infoObject:Object):void
		{
			var status:String = infoObject.code;
			if (status == "NetStream.Play.Complete") {				
				dispatchEvent(new Event(COMPLETE));
			}
		}
		

		private function metaDataHandler(infoObject:Object):void 
		{
		}
		
		
        private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
            trace("securityErrorHandler: " + event);
        }
        
		
        private function asyncErrorHandler(event:AsyncErrorEvent):void 
		{
            // ignore AsyncErrorEvent events.
        }
    }
 }