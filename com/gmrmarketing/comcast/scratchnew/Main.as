package com.gmrmarketing.comcast.scratchnew
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.comcast.scratchnew.Scratch;
	import com.gmrmarketing.comcast.scratchnew.Admin;
	import com.gmrmarketing.comcast.scratchnew.Dialog;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.greensock.TweenLite;
	
	public class Main extends MovieClip
	{
		private var scratch:Scratch;
		private var dialog:MovieClip;
		private var cq:CornerQuit;
		private var admin:Admin;
		private var spinner:PrizeWheel;
		
		private var scratchContainer:Sprite;
		private var spinContainer:Sprite;		
		
		
		public function Main()
		{
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			admin = new Admin();
			scratch = new Scratch();
			dialog = new winLose();//lib clip
			
			scratch.addEventListener(Scratch.LOSER, playerLost, false, 0, true);
			scratch.addEventListener(Scratch.WINNER, playerWon, false, 0, true);
			
			scratchContainer = new Sprite();
			spinContainer = new Sprite();			
			
			spinner = new PrizeWheel(spinContainer);
			
			addChild(scratchContainer);
			addChild(spinContainer);			
			
			scratch.show(scratchContainer, admin.getData().winPercent);
			cq.moveToTop();
		}
		
		
		private function playerLost(e:Event):void
		{
			scratch.addEventListener(Scratch.DONE_FADING, showSorry, false, 0, true);
			scratch.hide();//fades out and removes scratch
		}
		
		
		private function showSorry(e:Event):void
		{
			scratch.removeEventListener(Scratch.DONE_FADING, showSorry);
			
			if (!contains(dialog)) {
				addChild(dialog);
			}
			
			dialog.x = 55;
			dialog.y = 800;
			
			dialog.theTitle.text = "SORRY!";
			dialog.theText.text = "You didn't win this time,\nThanks for playing.";			
			dialog.btnPlay.theText.text = "NEW GAME";
			dialog.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, playAgain, false, 0, true);
			
			TweenLite.to(dialog, .5, { y:165 } );
		}
		
		
		private function playAgain(e:MouseEvent):void
		{
			dialog.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, playAgain);
			TweenLite.to(dialog, .5, { y:800, onComplete:removeDialog } );
		}
		
		
		private function removeDialog():void
		{
			removeChild(dialog);
			scratch.show(scratchContainer, admin.getData().winPercent);
		}
		
		
		private function playerWon(e:Event):void
		{
			scratch.addEventListener(Scratch.DONE_FADING, showWon, false, 0, true);
			scratch.hide();//fades out and removes scratch
		}
		
		private function showWon(e:Event):void
		{
			scratch.removeEventListener(Scratch.DONE_FADING, showWon);
			
			if (!contains(dialog)) {
				addChild(dialog);
			}
			
			dialog.x = 55;
			dialog.y = 800;
			
			dialog.theTitle.text = "YOU WON!";
			dialog.theText.text = "Great job,\nspin the prize wheel for your chance to win.";			
			dialog.btnPlay.theText.text = "SPIN!";
			dialog.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, spin, false, 0, true);
			
			TweenLite.to(dialog, .5, { y:165 } );
		}
		
		
		private function spin(e:MouseEvent):void
		{
			dialog.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, spin);
			TweenLite.to(dialog, .5, { y:800, onComplete:showSpin } );
		}
		
		
		private function showSpin():void
		{
			removeChild(dialog);
			spinner.show(admin.getData());
			spinner.addEventListener(PrizeWheel.DONE_SPINNING, spinComplete, false, 0, true);
		}
		
		
		private function spinComplete(e:Event):void
		{
			spinner.hide();
			spinner.removeEventListener(PrizeWheel.DONE_SPINNING, spinComplete);			
			
			if (!contains(dialog)) {
				addChild(dialog);
			}
			
			dialog.x = 55;
			dialog.y = 800;
			
			dialog.theTitle.text = "WINNER!";
			dialog.theText.text = "You won a\n" + spinner.getPrize()[1];			
			dialog.btnPlay.theText.text = "DONE";
			dialog.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, gameOver, false, 0, true);
			
			TweenLite.to(dialog, .5, { y:165 } );
		}
		private function gameOver(e:MouseEvent):void
		{
			dialog.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, gameOver);
			TweenLite.to(dialog, .5, { y:800, onComplete:removeDialog } );
		}
		
		private function showAdmin(e:Event):void
		{
			admin.show(this);
			admin.addEventListener(Admin.ADMIN_CLOSED, closeAdmin, false, 0, true);
			admin.addEventListener(Admin.RESET, adminReset, false, 0, true);
		}
		
		
		private function closeAdmin(e:Event):void
		{
			admin.removeEventListener(Admin.ADMIN_CLOSED, closeAdmin);
			admin.removeEventListener(Admin.RESET, adminReset);
			admin.hide();
		}
		
		
		private function adminReset(e:Event):void
		{
			admin.doReset();
		}
		
	}
	
}