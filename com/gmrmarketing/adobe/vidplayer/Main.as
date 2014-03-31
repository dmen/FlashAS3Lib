package com.gmrmarketing.adobe.vidplayer
{	
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import com.greensock.TweenLite;
	import flash.events.*;
	
	public class Main extends MovieClip
	{
		private var vidURL:String;
		private var vidAutoPlay:Boolean;
		
		
		public function Main()
		{
			cover.btnReplay.alpha = 0;
			cover.btnPausePlay.alpha = 0;
				
			vidURL = loaderInfo.parameters.vidurl;
			if (vidURL != null) {
				
				vidAutoPlay = (loaderInfo.parameters.autoplay == "true" || loaderInfo.parameters.autoplay == undefined) ? true : false;			
				vid.source = vidURL;
				
				if (vidAutoPlay) {
					vid.play();				
				}else {
					showPausePlay();
				}			
				
				vid.addEventListener(Event.COMPLETE, showReplay, false, 0, true);
				
				cover.addEventListener(MouseEvent.MOUSE_OVER, showPausePlay, false, 0, true);
				cover.addEventListener(MouseEvent.MOUSE_OUT, hidePausePlay, false, 0, true);
			}
		}
		
		
		private function showPausePlay(e:MouseEvent = null):void
		{
			if(cover.btnReplay.alpha == 0){
				if (vid.state == "paused") {
					cover.btnPausePlay.gotoAndStop(1);
				}else {
					cover.btnPausePlay.gotoAndStop(2);
				}
				
				TweenLite.to(cover.btnPausePlay, 1, { alpha:1 } );
				cover.btnPausePlay.buttonMode = true;
				cover.btnPausePlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);
			}
		}
		
		
		private function playPause(e:MouseEvent = null):void
		{
			if (vid.state == "paused") {
				vid.play();
			}else {				
				vid.pause();
			}
			showPausePlay();
		}
		
		
		private function hidePausePlay(e:MouseEvent):void
		{
			cover.btnPausePlay.removeEventListener(MouseEvent.CLICK, playPause);
			TweenLite.to(cover.btnPausePlay, .5, { alpha:0 } );
		}
		
		
		/**
		 * Called on Video COMPLETE event
		 * @param	e
		 */
		private function showReplay(e:Event):void
		{
			cover.btnPausePlay.visible = false;
			cover.btnPausePlay.alpha = 0;
			cover.btnPausePlay.removeEventListener(MouseEvent.CLICK, playPause);			
			
			cover.btnReplay.buttonMode = true;
			TweenLite.to(cover.btnReplay, 1, { alpha:1 } );
			cover.btnReplay.addEventListener(MouseEvent.CLICK, replay, false, 0, true);
		}
		
		
		private function replay(e:MouseEvent):void
		{			
			vid.seek(0);
			vid.play();
			cover.btnPausePlay.visible = true;
			TweenLite.to(cover.btnReplay, .5, { alpha:0 } );
			cover.btnReplay.removeEventListener(MouseEvent.CLICK, replay);
		}
		
	}
	
}