package com.gmrmarketing.empirestate.ilny
{
	import flash.geom.*;
	import flash.ui.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{
		private var bgContainer:Sprite;
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var bg:Background;
		private var intro:Intro;
		private var map:Map;
		private var detail:DetailDialog;
		private var email:EmailForm;
		private var thanks:Thanks;
		private var interests:InterestsManager;
		private var zipDialog:ZipDialog;
		private var queue:Queue;
		private var cq:CornerQuit;
		private var zq:CornerQuit;//zip dialog opener
		private var tim:TimeoutHelper;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			cq = new CornerQuit();
			zq = new CornerQuit();
			
			tim = TimeoutHelper.getInstance();
			tim.init(120000);
			tim.addEventListener(TimeoutHelper.TIMED_OUT, resetApp);			
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			bgContainer = new Sprite();
			addChild(bgContainer);
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
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
			
			email = new EmailForm();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			interests = InterestsManager.getInstance();
			interests.addEventListener(InterestsManager.CHANGED, interestsChanged);
			
			zipDialog = new ZipDialog();
			zipDialog.container = mainContainer;
			
			queue = new Queue();
			
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			zq.init(cornerContainer, "ur");
			zq.addEventListener(CornerQuit.CORNER_QUIT, openZipDialog, false, 0, true);
			
			//intro.addEventListener(Intro.COMPLETE, 
			bg.show();
			intro.show();
			
			//wait 1 sec before adding listener to allow bg/ken burns to fully start
			var a:Timer = new Timer(1000, 1);
			a.addEventListener(TimerEvent.TIMER, addMapListener, false, 0, true);
			a.start();
		}
		
		
		private function addMapListener(e:TimerEvent):void
		{
			intro.addEventListener(Intro.COMPLETE, showMap);
		}
		
		
		private function showMap(e:Event = null):void
		{
			intro.removeEventListener(Intro.COMPLETE, showMap);
			tim.startMonitoring();
			
			map.show(zipDialog.getPosition());
			map.addEventListener(Map.INTEREST_SELECTED, showInterestDialog);
			map.addEventListener(Map.NEXT, mapComplete);
			
			intro.hide();
			zq.hide();
			cq.hide();
			
			bg.stop();
		}
		
		
		/**
		 * callback for selecting an interest on the map
		 * displays the detail dialog
		 * @param	e
		 */
		private function showInterestDialog(e:Event):void
		{
			var interest:Object = map.interestData;
			var inList:Boolean = interests.hasInterest(interest);
			detail.show(interest, inList, new Point(mouseX, mouseY));
		}
		
		
		/**
		 * callback for listener on the detailDialog
		 * Called whenever users presses add interest button
		 */
		private function addNewInterest(e:Event):void
		{
			if(!interests.hasInterest(detail.interest)){
				interests.add(detail.interest);
				map.updateInterests();
			}
		}
		
		
		private function interestsChanged(e:Event):void
		{
			map.updateInterests();//will turn off red icon and remove from bucketList
		}
		
		
		private function mapComplete(e:Event):void
		{
			map.removeEventListener(Map.INTEREST_SELECTED, showInterestDialog);
			map.removeEventListener(Map.NEXT, mapComplete);
			map.hide();
			
			detail.hide();
			
			email.show();
			email.addEventListener(EmailForm.COMPLETE, formComplete);
			email.addEventListener(EmailForm.BACK, backToMap);
			bg.show();
			//bg.tField = null;
		}
		
		
		private function backToMap(e:Event):void
		{
			email.removeEventListener(EmailForm.COMPLETE, formComplete);
			email.removeEventListener(EmailForm.BACK, backToMap);
			email.hide();
			showMap();
		}
		
		
		private function formComplete(e:Event):void
		{
			email.removeEventListener(EmailForm.COMPLETE, formComplete);
			email.removeEventListener(EmailForm.BACK, backToMap);
			
			var data:Object = email.data;
			data.interests = interests.interests.concat();//array of interest objects
			//trace("form Complete", data.interests.length);
			queue.add(data);
			
			//thanks.addEventListener(Thanks.SHOWING, hideForm);
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete);
			email.hide();
			thanks.show();
		}
		
		
		private function hideForm(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, hideForm);
			
		}
		
		
		private function thanksComplete(e:Event):void
		{
			interests.clear();
			detail.resetMove();
			tim.stopMonitoring();//don't monitor on intro
			
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);
			intro.show();
			intro.addEventListener(Intro.COMPLETE, showMap);
			zq.moveToTop();
			cq.moveToTop();
			thanks.hide();
		}
		
		
		/**
		 * called by listener on timeoutHelper
		 * @param	e
		 */
		private function resetApp(e:Event):void
		{
			tim.stopMonitoring();//don't monitor on intro
			email.hide();
			thanks.hide();
			detail.hide();
			detail.resetMove();
			map.hide();
			interests.clear();
			bg.show();			
			intro.show();
			zq.moveToTop();
			cq.moveToTop();
			intro.addEventListener(Intro.COMPLETE, showMap);
		}
			
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function openZipDialog(e:Event):void
		{
			zipDialog.addEventListener(ZipDialog.CANCEL, cancelZip);
			zipDialog.addEventListener(ZipDialog.OK, OKZip);
			zipDialog.show();
		}
		
		
		private function cancelZip(e:Event):void
		{
			zipDialog.removeEventListener(ZipDialog.CANCEL, cancelZip);
			zipDialog.removeEventListener(ZipDialog.OK, OKZip);
			zipDialog.hide();
		}
		
		private function OKZip(e:Event):void
		{
			zipDialog.removeEventListener(ZipDialog.CANCEL, cancelZip);
			zipDialog.removeEventListener(ZipDialog.OK, OKZip);
			zipDialog.hide();
		}
	}
	
}