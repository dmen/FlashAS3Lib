package com.gmrmarketing.empirestate.ilny
{
	import flash.geom.*;
	import flash.ui.*;
	import flash.display.*;
	import flash.events.*;
	
	public class Main extends MovieClip
	{
		private var bgContainer:Sprite;
		private var mainContainer:Sprite;
		private var bg:Background;
		private var intro:Intro;
		private var map:Map;
		private var detail:DetailDialog;
		
		private var interests:InterestsManager;
		
		
		public function Main()
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			bgContainer = new Sprite();
			addChild(bgContainer);
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			bg = new Background();
			bg.container = bgContainer;
			bg.tField = intro.clip.theText;
			
			map = new Map();
			map.container = mainContainer;
			
			detail = new DetailDialog();
			detail.addEventListener(DetailDialog.ADD_INTEREST, addNewInterest);
			detail.container = mainContainer;
			
			interests = InterestsManager.getInstance();
			
			//intro.addEventListener(Intro.COMPLETE, 
			bg.show();
			intro.show();
			intro.addEventListener(Intro.COMPLETE, showMap);
		}
		
		
		private function showMap(e:Event):void
		{
			map.show();
			map.addEventListener(Map.INTEREST_SELECTED, showInterestDialog, false, 0, true);
			
			intro.hide();
			bg.stop();
		}
		
		
		private function showInterestDialog(e:Event):void
		{
			var interest:Object = map.interestData;
			var inList:Boolean = interests.hasInterest(interest);
			detail.show(interest, inList, mouseY);
		}
		
		
		/**
		 * callback for listener on the detailDialog
		 * Called whenever users presses add interest button
		 */
		private function addNewInterest(e:Event):void
		{
			interests.add(detail.interest);
			map.updateInterests();
		}
	}
	
}