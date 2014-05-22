package com.gmrmarketing.reeses.scratchgame
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.reeses.scratchgame.Scratch;
	import com.gmrmarketing.reeses.scratchgame.Admin_NewAdmin;
	import com.gmrmarketing.reeses.scratchgame.Dialog;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.greensock.TweenLite;
	import flash.media.Sound;
	//import flash.desktop.NativeApplication;
	
	
	public class Main extends MovieClip
	{
		private var scratch:Scratch;
		private var dialog:MovieClip;
		private var cq:CornerQuit;
		private var admin:Admin_NewAdmin;
		private var spinner:PrizeWheel;
		
		private var scratchContainer:Sprite;
		private var spinContainer:Sprite;		
		private var spinBG:MovieClip;
		
		private var winSound:Sound;
		private var loseSound:Sound;
		private var prizeSound:Sound;
		
		//private var report:AdminFile;
		
		
		public function Main()
		{			
			//NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
			
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			admin = new Admin_NewAdmin();
			scratch = new Scratch();
			dialog = new winLose();//lib clip
			
			scratch.addEventListener(Scratch.STARTED, incStarted, false, 0, true);
			scratch.addEventListener(Scratch.LOSER, playerLost, false, 0, true);
			scratch.addEventListener(Scratch.WINNER, playerWon, false, 0, true);
			
			scratchContainer = new Sprite();
			spinContainer = new Sprite();
			spinBG = new spinBackground(); //lib clip
			
			spinner = new PrizeWheel(spinContainer);
			loseSound = new soundLose();//lib sounds
			winSound = new soundWin();
			prizeSound = new soundPrize();
			
			addChild(scratchContainer);
			addChild(spinContainer);			
			
			scratch.show(scratchContainer, admin.getPercent());
			cq.moveToTop();
		}
		
		private function incStarted(e:Event):void
		{
			//report.scratchStarted();
		}
		
		private function playerLost(e:Event):void
		{
			//report.scratchLost();
			scratch.addEventListener(Scratch.DONE_FADING, showSorry, false, 0, true);
			scratch.hide();//fades out and removes scratch
		}
		
		
		private function showSorry(e:Event):void
		{
			loseSound.play();
			scratch.removeEventListener(Scratch.DONE_FADING, showSorry);
			
			if (!contains(dialog)) {
				addChild(dialog);
			}
			
			dialog.x = 0;
			dialog.y = 753;	
			dialog.gotoAndStop(1);
		
			dialog.addEventListener(MouseEvent.MOUSE_DOWN, playAgain, false, 0, true);
			
			TweenLite.to(dialog, .5, { y:0 } );
		}
		
		
		private function playAgain(e:MouseEvent):void
		{
			dialog.removeEventListener(MouseEvent.MOUSE_DOWN, playAgain);
			TweenLite.to(dialog, .5, { y:800, onComplete:removeDialog } );
		}
		
		
		private function removeDialog():void
		{
			removeChild(dialog);			
			scratch.show(scratchContainer, admin.getPercent());// admin.getData().winPercent);
		}
		
		
		private function playerWon(e:Event):void
		{
			//report.scratchWon();
			scratch.addEventListener(Scratch.DONE_FADING, showWon, false, 0, true);
			scratch.hide();//fades out and removes scratch
		}
		
		private function showWon(e:Event):void
		{
			winSound.play();
			scratch.removeEventListener(Scratch.DONE_FADING, showWon);
			
			if (!contains(dialog)) {
				addChild(dialog);
			}			
			
			dialog.x = 0;
			dialog.y = 753;
			dialog.gotoAndStop(2);
			
			//dialog.addEventListener(MouseEvent.MOUSE_DOWN, spin, false, 0, true);
			dialog.addEventListener(MouseEvent.MOUSE_DOWN, playAgain, false, 0, true);
			
			TweenLite.to(dialog, .5, { y:0 } );
			
		}
		
		
		private function spin(e:MouseEvent):void
		{
			dialog.removeEventListener(MouseEvent.MOUSE_DOWN, spin);
			
			if (!contains(spinBG)) {
				addChildAt(spinBG, 1);
			}
			spinBG.alpha = 0;
			
			TweenLite.to(spinBG, .5, { alpha:1 } );
			TweenLite.to(dialog, .5, { y:800, onComplete:showSpin } );
		}
		
		
		private function showSpin():void
		{
			removeChild(dialog);		
			
			//NEW - AARON - WEB DEMO
			var data:Object = new Object();
			data.scratch = new Array(0, 0, 0); //started, won, lost			
			data.prizes = new Array("Prize A", "Prize B", "Prize C");
			data.prizeCounts = new Object();
			data.descriptions = new Array("Prize A", "Prize B", "Prize C");
			data.winPercent = 50;
			//========================================
			
			//spinner.show(admin.getData());
			spinner.show(data);
			
			//spinner.show(admin.getData());
			spinner.addEventListener(PrizeWheel.DONE_SPINNING, spinComplete, false, 0, true);
		}
		
		
		private function spinComplete(e:Event):void
		{
			spinner.hide();
			spinner.removeEventListener(PrizeWheel.DONE_SPINNING, spinComplete);			
			
			if (!contains(dialog)) {
				addChild(dialog);
			}
			
			if (contains(spinBG)) {
				TweenLite.to(spinBG, 1, { alpha:0, onComplete:killSkinBG } );
			}
			
			dialog.x = 0;
			dialog.y = 753;
			dialog.gotoAndStop(3);
			
			var prize:Array = spinner.getPrize();
			if(prize[0] != null){
				//report.addPrize(prize[0]);//prize
			}else {
				//null prize
				//report.addPrize("Error: peg: " + prize[2] + " dir: " + prize[3]);//last peg number and direction
			}
			dialog.theText.text = "You won " + prize[1];//prize description			
			dialog.addEventListener(MouseEvent.MOUSE_DOWN, gameOver, false, 0, true);
			prizeSound.play();
			TweenLite.to(dialog, .5, { y:0 } );
		}
		
		
		private function killSkinBG():void
		{
			if (contains(spinBG)) {
				removeChild(spinBG);
			}
		}
		
		
		private function gameOver(e:MouseEvent):void
		{
			dialog.removeEventListener(MouseEvent.MOUSE_DOWN, gameOver);
			TweenLite.to(dialog, .5, { y:753, onComplete:removeDialog } );
		}
		
		
		private function showAdmin(e:Event):void
		{
			admin.show(this);
			admin.addEventListener(Admin.ADMIN_CLOSED, closeAdmin, false, 0, true);
			//admin.addEventListener(Admin.RESET, adminReset, false, 0, true);
		}
		
		
		private function closeAdmin(e:Event):void
		{			
			scratch.updateWinPercent(admin.getPercent());
			admin.removeEventListener(Admin.ADMIN_CLOSED, closeAdmin);
			//admin.removeEventListener(Admin.RESET, adminReset);
			admin.hide();			
		}
		
		
		private function adminReset(e:Event):void
		{
			//admin.doReset();
		}
		
		
		private function handleDeactivate(event:Event):void 
		{
			//NativeApplication.nativeApplication.exit();	 
		}
		
	}
	
}