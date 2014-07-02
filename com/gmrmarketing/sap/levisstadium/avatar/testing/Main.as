package com.gmrmarketing.sap.levisstadium.avatar.testing
{	
	import com.tastenkunst.as3.brf.simpleapps.*;	
	import com.tastenkunst.as3.brf.shapemasks.*;	
	import flash.display.*;
	import flash.events.*;
	
	public class Main extends MovieClip
	{
		private var clip:Sprite;
		
		public function Main()
		{
			if(stage == null) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			} else {
				init();
			}
		}
		
		
		public function onAddedToStage(e:Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
		
		public function init() : void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 36;
			
			clip = new ExampleWebcamFaceDetection_manualMove();
			if(clip != null) {
				addChild(clip);
			}
		}
		
	}
	
}