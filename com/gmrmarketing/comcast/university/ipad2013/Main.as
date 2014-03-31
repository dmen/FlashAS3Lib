package com.gmrmarketing.comcast.university.ipad2013
{
	import com.gmrmarketing.comcast.university.ipad2013.*;
	import flash.display.*;	
	import flash.events.*;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.media.*;
	import flash.net.*;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var optin:OptIn;
		private var howto:HowTo;
		private var scratch:Scratch;
		private var popup:PopUp;
		private var congrats:Congrats;
		private var sorry:Sorry;
		private var form:Form;
		private var thanks:ThankYou;
		private var admin:Admin;
		
		private var cq:CornerQuit;
		
		private var gameContainer:Sprite;
		private var adminContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var bgSound:Sound;
		private var bgChannel:SoundChannel;
		private var vol:SoundTransform;
		
		private var rulesButton:MovieClip;
		
		
		public function Main()
		{
			gameContainer = new Sprite();
			adminContainer = new Sprite();
			cornerContainer = new Sprite();
			addChild(gameContainer);
			addChild(adminContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.setContainer(gameContainer);
			
			optin = new OptIn();
			optin.setContainer(gameContainer);
			
			howto = new HowTo();
			howto.setContainer(gameContainer);
			
			scratch = new Scratch();
			scratch.setContainer(gameContainer);
			
			popup = new PopUp();
			popup.setContainer(gameContainer);
			
			congrats = new Congrats();
			congrats.setContainer(gameContainer);
			
			sorry = new Sorry();
			sorry.setContainer(gameContainer);
			
			form = new Form();
			form.setContainer(gameContainer);
			
			thanks = new ThankYou();
			thanks.setContainer(gameContainer);
			
			admin = new Admin();
			admin.setContainer(adminContainer);			
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			//cq.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			rulesButton = new btnRules();//lib clip
			rulesButton.x = 377;
			rulesButton.y = 724;
			rulesButton.alpha = 0;
			rulesButton.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			
			bgSound = new audBG();
			vol = new SoundTransform(.3);
			
			showIntro();
		}
		
		private function showRules(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://therulespage.com/FALL2013SPINTOWIN"), "_blank");
		}
		
		private function showAdmin(e:Event):void
		{
			admin.show();
		}
		
		
		private function showIntro():void
		{	
			intro.addEventListener(Intro.PLAY_PRESSED, showOptIn, false, 0, true);
			intro.addEventListener(Intro.INTRO_SHOWING, removeThanks, false, 0, true);
			if (cornerContainer.contains(rulesButton)) {
				cornerContainer.removeChild(rulesButton);
			}
			intro.show();
		}
		
		
		private function removeThanks(e:Event):void
		{
			intro.removeEventListener(Intro.INTRO_SHOWING, removeThanks);
			thanks.hide();
			sorry.hide();
		}
		
		
		private function showOptIn(e:Event):void
		{
			restartBGSound();
			
			intro.removeEventListener(Intro.PLAY_PRESSED, showOptIn);
			optin.addEventListener(OptIn.OPTIN_SHOWING, removeIntro, false, 0, true);
			optin.addEventListener(OptIn.OPTIN_COMPLETE, showHowTo, false, 0, true);
			optin.show();			
		}
		
		
		private function restartBGSound(e:Event = null):void
		{
			bgChannel = bgSound.play();
			bgChannel.soundTransform = vol;
			bgChannel.addEventListener(Event.SOUND_COMPLETE, restartBGSound, false, 0, true);
		}
		
		
		private function removeIntro(e:Event):void
		{
			if (!cornerContainer.contains(rulesButton)) {
				cornerContainer.addChild(rulesButton);
			}
			optin.removeEventListener(OptIn.OPTIN_SHOWING, removeIntro);
			intro.hide();
		}
		
		/**
		 * Called when OPTIN_COMPLETE is received from OptIn
		 * @param	e
		 */
		private function showHowTo(e:Event):void
		{
			if (admin.emailAlreadyUsed(optin.getEmail())) {
				optin.showError("That email address has already been used");
			}else{
				admin.registerUser(optin.getRegData());
				optin.removeEventListener(OptIn.OPTIN_COMPLETE, showHowTo);
				howto.addEventListener(HowTo.HOWTO_SHOWING, removeOptin, false, 0, true);
				howto.addEventListener(HowTo.HOWTO_COMPLETE, showGame, false, 0, true);
				howto.show();
			}
		}
		
		
		private function removeOptin(e:Event):void
		{
			howto.addEventListener(HowTo.HOWTO_SHOWING, removeOptin);
			optin.hide();
		}
		
		
		private function showGame(e:Event):void
		{
			howto.removeEventListener(HowTo.HOWTO_COMPLETE, showGame);
			scratch.addEventListener(Scratch.SCRATCH_SHOWING, removeHowTo, false, 0, true);
			scratch.addEventListener(Scratch.NEW_ICON, newIconRevealed, false, 0, true);
			scratch.addEventListener(Scratch.SCRATCH_COMPLETE, scratchComplete, false, 0, true);
			
			scratch.show(admin.getDisabled());
		}
		
		
		private function removeHowTo(e:Event):void
		{
			scratch.removeEventListener(Scratch.SCRATCH_SHOWING, removeHowTo);
			howto.hide();
		}
		
		
		private function newIconRevealed(e:Event):void
		{			
			popup.show(scratch.getIconName());
		}
		
		
		private function scratchComplete(e:Event):void
		{			
			if((scratch.getNumScratched() == 2 && popup.getShown() == 1) || scratch.getNumScratched() == 3 && popup.getShown() >= 2){
			
				scratch.removeEventListener(Scratch.NEW_ICON, newIconRevealed);
				scratch.removeEventListener(Scratch.SCRATCH_COMPLETE, scratchComplete);
			
				if (popup.isShowing()) {
					popup.addEventListener(PopUp.POPUP_COMPLETE, showResults, false, 0, true);
				}else {
					showResults();
				}
			}
		}
		
		private function showResults(e:Event = null):void
		{
			popup.removeEventListener(PopUp.POPUP_COMPLETE, showResults);
			if (popup.getShown() == 2 || popup.getShown() == 1) {
				//winner
				congrats.addEventListener(Congrats.CONGRATS_SHOWING, removeScratch, false, 0, true);
				congrats.addEventListener(Congrats.CONGRATS_COMPLETE, showForm, false, 0, true);
				congrats.show(admin.getPrize());
			}else {
				//no bueno
				sorry.addEventListener(Sorry.SORRY_SHOWING, removeScratch, false, 0, true);
				sorry.addEventListener(Sorry.SORRY_COMPLETE, replay, false, 0, true);
				sorry.show();
			}						
		}
		
		
		private function removeScratch(e:Event):void
		{
			sorry.removeEventListener(Sorry.SORRY_SHOWING, removeScratch);
			congrats.removeEventListener(Congrats.CONGRATS_SHOWING, removeScratch);
			scratch.hide();
		}
		
		
		private function showForm(e:Event):void
		{
			congrats.removeEventListener(Congrats.CONGRATS_COMPLETE, showForm);
			form.addEventListener(Form.FORM_SHOWING, removeCongrats, false, 0, true);
			form.addEventListener(Form.FORM_COMPLETE, formComplete, false, 0, true);
			form.show(optin.getEmail());
		}
		
		
		private function removeCongrats(e:Event):void
		{
			form.removeEventListener(Form.FORM_SHOWING, removeCongrats);
			congrats.hide();
		}
		
		
		private function formComplete(e:Event):void
		{
			form.removeEventListener(Form.FORM_COMPLETE, formComplete);
			
			var tform:Object = form.getFormData();
			tform.prize = congrats.getPrize();
			admin.saveWinner(tform);
			
			thanks.addEventListener(ThankYou.THANKYOU_SHOWING, removeForm, false, 0, true);
			thanks.addEventListener(ThankYou.THANKYOU_COMPLETE, replay, false, 0, true);
			thanks.show();			
		}
		
		
		private function removeForm(e:Event):void
		{
			thanks.removeEventListener(ThankYou.THANKYOU_SHOWING, removeForm);
			form.hide();
		}
		
		
		private function replay(e:Event):void
		{			
			bgChannel.stop();
			
			thanks.removeEventListener(ThankYou.THANKYOU_COMPLETE, replay);
			sorry.removeEventListener(Sorry.SORRY_COMPLETE, replay);				
			popup.reset();
			showIntro();
		}
		
	}
	
}