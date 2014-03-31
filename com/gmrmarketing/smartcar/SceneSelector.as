/**
 * Instantiated from Main by menuClick()
 * 
 * Scene Tool - placed inside of Main movies toolContainer
 * 
 * Scene names are derived from the clip names of the buttons in the tool
 */
package com.gmrmarketing.smartcar
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	//bitmaps from library
	import scenePreview_city;
	import scenePreview_suburbs;	
	import scenePreview_beach;
	import scenePreview_nightlife;
	
	
	public class SceneSelector extends MovieClip
	{		
		private var theScene:String = "city";
		
		
		public function SceneSelector(){}
		
		public function init(scene:String = "city"):void
		{
			//scene names derived from clip names
			city.addEventListener(MouseEvent.CLICK, sceneSelected, false, 0, true);
			suburbs.addEventListener(MouseEvent.CLICK, sceneSelected, false, 0, true);
			beach.addEventListener(MouseEvent.CLICK, sceneSelected, false, 0, true);
			nightlife.addEventListener(MouseEvent.CLICK, sceneSelected, false, 0, true);
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
			
			sceneSelected(null, scene);
		}
		
		public function getScene():String
		{
			return theScene;
		}
		
		public function sceneSelected(e:MouseEvent = null, sc:String = "city"):void
		{
			var s:String;
			if (e == null) {
				s = sc;
			}else{
				s = e.currentTarget.name;
			}
			
			TweenMax.killAll();
			
			city.theMask.rotation = 0;
			city.outline.rotation = 0;
			suburbs.theMask.rotation = 0;
			suburbs.outline.rotation = 0;
			beach.theMask.rotation = 0;
			beach.outline.rotation = 0;
			nightlife.theMask.rotation = 0;
			nightlife.outline.rotation = 0;
			
			theScene = s;
			TweenMax.to(this[s].theMask, .5, { rotation:180 } );
			TweenMax.to(this[s].outline, .5, { rotation:180 } );
			
			dispatchEvent(new Event("toolChange"));
		}
		
		
		public function getSceneImage():BitmapData
		{
			var bg:BitmapData;
			switch(theScene) {
				case "city":
					bg = new scenePreview_city();
					break;
				case "suburbs":
					bg = new scenePreview_suburbs();
					break;
				case "beach":
					bg = new scenePreview_beach();
					break;
				case "nightlife":
					bg = new scenePreview_nightlife();
					break;
			}
			return bg;
		}
		
		
		/**
		 * Called when this tool is removed from the stage
		 * @param	e
		 */
		private function cleanUp(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			
			city.removeEventListener(MouseEvent.CLICK, sceneSelected);
			suburbs.removeEventListener(MouseEvent.CLICK, sceneSelected);
			beach.removeEventListener(MouseEvent.CLICK, sceneSelected);
			nightlife.removeEventListener(MouseEvent.CLICK, sceneSelected);
			
		}
	}
	
}