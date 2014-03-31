package com.sagecollective.corona.atp
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import flash.events.*;	
	import flash.utils.Timer;
	import com.sagecollective.utilities.TimeoutHelper;
	
	
	public class Dialog extends MovieClip
	{
		private var container:DisplayObjectContainer;
		private var funcToCall:Function;
		private var theDialog:MovieClip;
		private var showTimer:Timer;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Dialog($container:DisplayObjectContainer)
		{
			container = $container;
			timeoutHelper = TimeoutHelper.getInstance();
			theDialog = new dialogBox(); //lib clip
		}
		
		
		public function show(mess:String, func:Function = null, showContinue:Boolean = true, showFor:int = 0, showRotator:Boolean = false):void
		{
			funcToCall = func;
			
			container.addChild(theDialog);
			theDialog.x = 754;
			theDialog.y = 337;
			
			theDialog.theText.text = mess;
			theDialog.theText.y = (250 - theDialog.theText.textHeight) * .5;
			
			theDialog.alpha = 1;
			
			if (showContinue) {
				theDialog.btnContinue.alpha = 1;
				theDialog.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			}else {
				theDialog.btnContinue.alpha = 0;
				theDialog.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			}
			
			if (showFor > 0) {
				showTimer = new Timer(showFor, 1);
				showTimer.addEventListener(TimerEvent.TIMER, timerHide, false, 0, true);
				showTimer.start();
			}
			
			if (showRotator) {
				theDialog.rotator.alpha = 1;
				theDialog.rotator.addEventListener(Event.ENTER_FRAME, spinRotator, false, 0, true);
			}else {
				theDialog.rotator.alpha = 0;
				theDialog.rotator.removeEventListener(Event.ENTER_FRAME, spinRotator);
			}
		}
		
		private function spinRotator(e:Event):void
		{
			theDialog.rotator.rotation += 2;
		}
		
		private function timerHide(e:TimerEvent):void
		{
			hide();
		}
		
		
		public function hide(e:MouseEvent = null):void
		{
			timeoutHelper.buttonClicked();
			theDialog.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			theDialog.rotator.alpha = 0;
			theDialog.rotator.removeEventListener(Event.ENTER_FRAME, spinRotator);
			TweenMax.to(theDialog, 1, { alpha:0, onComplete:killMe } );
		}
		
		
		private function killMe():void
		{
			theDialog.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			if(container.contains(theDialog)){
				container.removeChild(theDialog);
				if(funcToCall != null){
					funcToCall();
				}
			}
		}
	}
	
}