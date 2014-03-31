/**
 * Preloader / container for PlayerWeb
 */

package com.gmrmarketing.smartcar
{
	import flash.display.Loader;
	import flash.display.MovieClip;	
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LoaderInfo;
	import com.greensock.TweenLite;
	import flash.system.LoaderContext;
	
	
	public class WebPlayer extends MovieClip 
	{
		private var vLoader:Loader;
		private var scenePreviewData:BitmapData;
		private var scenePreview:Bitmap;
		private var scaler:Matrix;
		private var replay:MovieClip; //lib clip
		
		private var videoID:String = loaderInfo.parameters.id;
		
		
		
		public function WebPlayer()
		{			
			//videoID = "E31466F4-70F7-4802-BECE-D8F2E2B6E767";
			
			prog.bar.scaleX = 0;
			
			replay = new btnReplay();
			replay.x = 745;
			replay.y = 455;
			
			scenePreviewData = new BitmapData(900, 506, false, 0xffffffff);
			scenePreview = new Bitmap(scenePreviewData);
			
			scaler = new Matrix();
			scaler.scale(900 / 1280, 506 / 720);
			
			vLoader = new Loader();
			init();
		}
		
		private function init():void
		{			
			vLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, playerLoaded, false, 0, true);
			vLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, initialLoadProgress, false, 0, true);
			
			var lc:LoaderContext = new LoaderContext(true);
			lc.checkPolicyFile = true;
			vLoader.load(new URLRequest("PlayerWeb.swf"), lc);
		}
		
		private function doReplay(e:MouseEvent):void
		{
			removeChild(replay);
			replay.removeEventListener(MouseEvent.CLICK, doReplay);
			vLoader.unload();
			
			init();
		}
		
		private function initialLoadProgress(e:ProgressEvent):void
		{
			prog.bar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
		
		private function playerLoaded(e:Event):void
		{
			vLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, playerLoaded);
			vLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, initialLoadProgress);			
			
			MovieClip(vLoader.content).init(videoID);
			MovieClip(vLoader.content).addEventListener("allDataLoaded", videoReadyToPlay, false, 0, true);
			MovieClip(vLoader.content).addEventListener("modelLoadingProgress", modelLoading, false, 0, true);
			MovieClip(vLoader.content).addEventListener("textureLoadingProgress", textureLoading, false, 0, true);
			MovieClip(vLoader.content).addEventListener("videoCompleted", showReplay, false, 0, true);
		}
		
		private function modelLoading(e:Event):void
		{
			prog.theText.text = "Model Loading";
			prog.bar.scaleX = MovieClip(vLoader.content).getMeshPercentLoaded();
		}
		
		private function textureLoading(e:Event):void
		{			
			prog.theText.text = "Wrap Loading";
			prog.bar.scaleX = MovieClip(vLoader.content).getTexturePercentLoaded();
		}
		
		
		private function videoReadyToPlay(e:Event):void
		{
			MovieClip(vLoader.content).removeEventListener("allDataLoaded", videoReadyToPlay);
			MovieClip(vLoader.content).removeEventListener("modelLoadingProgress", modelLoading);
			MovieClip(vLoader.content).removeEventListener("textureLoadingProgress", textureLoading);			
			
			if(contains(prog)){
				removeChild(prog);	
			}
			
			addChild(scenePreview);	
			addEventListener(Event.ENTER_FRAME, updatePreview, false, 0, true);
		}
		
		
		private function updatePreview(e:Event):void
		{
			scenePreviewData.draw(vLoader, scaler);
		}
		
		private function showReplay(e:Event):void
		{
			MovieClip(vLoader.content).removeEventListener("videoCompleted", showReplay);
			
			replay.alpha = 0;
			addChild(replay);
			TweenLite.to(replay, 1, { alpha:1 } );
			replay.addEventListener(MouseEvent.CLICK, doReplay, false, 0, true);			
		}
	}
	
}