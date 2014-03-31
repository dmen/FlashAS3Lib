package com.gmrmarketing.comcast.scratchoff
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import com.greensock.TweenLite;
	import com.gmrmarketing.utilities.LocalFile;
	import flash.utils.Timer;
	
	
	
	public class Main extends MovieClip
	{
		private var btnAdmin:btnadmin; //lib clip
		
		private var admin:Admin;
		private var scratch:Scratch;
		private var punch:PunchOut;
		private var spinner:PrizeWheel;
		
		private var adminShowing:Boolean;
		
		//lib clips
		private var scratchIntro:scratchIntroDialog;
		private var punchIntro:punchIntroDialog;
		
		private var lf:LocalFile;
		private var adminData:Object; //file data from the LocalFile class
		private var reporting:Reporting; //file class		
		
		//basketball or hockey image dependent on game theme in admin
		private var theBackgroundBMD:BitmapData;
		private var theBackground:Bitmap;
		
		private var winLose:winLoseDialog; //lib clips
		private var introDialog:dialogIntro;
		
		private var endGame:endGameDialog;
		private var endGameClicks:int;
		
		private var channel:SoundChannel;
		private var sound:Sound;
		
		private var titles:theTitles; //lib clip
		
		//used to delay the win/lose dialog at the end of the punch game
		private var delayTimer:Timer;
		
		
		public function Main()
		{
			//uses AIR file classes
			lf = LocalFile.getInstance();
			reporting = new Reporting();
			
			btnAdmin = new btnadmin();
			btnAdmin.x = 976;
			btnAdmin.y = 731;
			
			delayTimer = new Timer(1000, 1);
			delayTimer.addEventListener(TimerEvent.TIMER, showDelayedDialog, false, 0, true);
			
			var t:Timer = new Timer(500,1);
			t.addEventListener(TimerEvent.TIMER, startInit);
			t.start();
		}
		
		private function startInit(e:TimerEvent):void
		{
			init();
		}
		
		
		private function init():void
		{
			
			if (punchIntro) {
				if (contains(punchIntro)) {
					removeChild(punchIntro);
					punchIntro = null;
				}
			}
			if (scratchIntro) {
				if (contains(scratchIntro)) {
					removeChild(scratchIntro);
					scratchIntro = null;
				}
			}
			if (punch) {
				if (contains(punch)) {
					removeChild(punch);
					punch = null;
				}
			}
			if (scratch) {
				if (contains(scratch)) {
					removeChild(scratch);
					scratch = null;					
				}
			}
			if (theBackground) {
				if (contains(theBackground)) {
					removeChild(theBackground);
				}
			}
			if (winLose) {
				if (contains(winLose)) {
					removeChild(winLose);
				}
			}
			if (endGame) {
				if (contains(endGame)) {
					removeChild(endGame);
				}
			}
			if (introDialog) {
				if (contains(introDialog)) {
					removeChild(introDialog);
				}
			}
			if (spinner) {
				if (contains(spinner)) {
					removeChild(spinner);
					spinner.removeEventListener("doneSpinning", doneSpinning);
					spinner = null;
				}
			}
			if (btnAdmin) {
				if (contains(btnAdmin)) {
					removeChild(btnAdmin);
				}
			}
			if (titles) {
				if (contains(titles)) {
					removeChild(titles);
				}
			}
			
			//loads the data object from the local file
			adminData = lf.load();			
			
			if (adminData.gameTheme == "sixers") {
				theBackgroundBMD = new basketballBG(1024, 768);
			}else if(adminData.gameTheme == "flyers"){
				theBackgroundBMD = new hockeyBG(1024, 768);
			}else {
				theBackgroundBMD = new genericBG(1024, 768);
			}
			theBackground = new Bitmap(theBackgroundBMD);
			addChildAt(theBackground, 0);
			
			titles = new theTitles();
			titles.x = 606;
			titles.y = 95;
			addChild(titles);
			
			//trace("init:", adminData.gameType);
			//trace("init:", adminData.gameTheme);
			
			if (adminData.gameType == "scratch")
			{
				titles.gotoAndStop(1);
				//scratch = new Scratch(adminData.gameTheme);				
				//showScratchIntro(adminData.gameTheme); //sixers flyers...none				
				
			}else {
				//punch
				titles.gotoAndStop(2);
				//punch = new PunchOut();
				//showPunchIntro();					
			}			
			
			//shows the i button at lower right
			showAdminButton();
			
			showIntroDialog();
		}
		
		private function showIntroDialog():void
		{
			introDialog = new dialogIntro(); //lib clip
			introDialog.x = 55;
			introDialog.y = 204;
			
			//change bg color depending on theme
			if (adminData.gameTheme == "sixers") {
				introDialog.bg.gotoAndStop(3);
			}else if (adminData.gameTheme == "flyers"){
				introDialog.bg.gotoAndStop(2);
			}else {
				//generic
				introDialog.bg.gotoAndStop(1);
			}
			
			addChild(introDialog);
			var introText:String;
			if (adminData.gameType == "scratch") {
				
				if (adminData.gameTheme == "sixers") {
					introText = "Xfinity® is the Official HD Provider of your Philadelphia 76ers";					
					introText += "\n\nWith XFINITY®, you can watch the Sixers anywhere and any way you want. ";
					introText += "Catch the action live in HD or online with xfinity.com/espn3.\n"; 
					introText += "When it comes to the Sixers, XFINITY has you covered.";
					introText += "\n\nXFINITY – Home of the Most Live Sports.";
					
				}else if(adminData.gameTheme == "flyers") {
					introText = "Xfinity® is the Official HD Provider of your Philadelphia Flyers";					
					introText += "\n\nWith XFINITY®, you can watch the Flyers anywhere and any way you want. ";
					introText += "Catch the action live in HD or online with xfinity.com/espn3.\n"; 
					introText += "When it comes to the Flyers, XFINITY has you covered.";
					introText += "\n\nXFINITY – Home of the Most Live Sports.";
					
				}else {
					//generic
					introText = "Xfinity® gives you more of what you love, more speed and more\neye popping HD. ";
					introText += "Experience 3D TV in a whole new dimension and learn more about Xfinity TV, the world’s greatest collection of shows and movies on TV and online.";
					introText += "\n\nXfinity reinvents entertainment so you can enjoy it your way!";
				}
				
			}else {
				
				//punch game
				
				if (adminData.gameTheme == "sixers") {
					introText = "Xfinity® is the Official HD Provider of your Philadelphia 76ers";					
					introText += "\n\nWith XFINITY®, you can watch the Sixers anywhere and any way you want. ";
					introText += "Catch the action live in HD or online with xfinity.com/espn3.\n"; 
					introText += "When it comes to the Sixers, XFINITY has you covered.";
					introText += "\n\nXFINITY – Home of the Most Live Sports.";
					
				}else if(adminData.gameTheme == "flyers") {
					introText = "Xfinity® is the Official HD Provider of your Philadelphia Flyers";					
					introText += "\n\nWith XFINITY®, you can watch the Flyers anywhere and any way you want. ";
					introText += "Catch the action live in HD or online with xfinity.com/espn3.\n"; 
					introText += "When it comes to the Flyers, XFINITY has you covered.";
					introText += "\n\nXFINITY – Home of the Most Live Sports.";
					
				}else {
					//generic
					introText = "Xfinity ® gives you more of what you love, more speed and more eye-popping HD. ";
					introText += "Learn more about Xfinity TV, the world’s greatest collection of shows and movies on TV and online, and ask about all the latest and greatest features that Xfinity offers!";
					introText += "\n\nXfinity reinvents entertainment so you can enjoy it your way!";
				}
				
			}
			
			introDialog.theText.text = introText;
			introDialog.btnContinue.theText.text = "LET'S PLAY!";
			introDialog.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, removeIntroDialog, false, 0, true);
		}
		
		private function removeIntroDialog(e:MouseEvent):void
		{
			introDialog.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, removeIntroDialog);		
			TweenLite.to(introDialog, .5, { y:768, onComplete:killIntroDialog } );
		}
		
		private function killIntroDialog():void
		{
			removeChild(introDialog);
			introDialog = null;
			
			if (adminData.gameType == "scratch")
			{
				scratch = new Scratch(stage, adminData.gameTheme);				
				showScratchIntro(adminData.gameTheme); //sixers, flyers, generic				
				
			}else {
				//punch				
				punch = new PunchOut();
				showPunchIntro();					
			}	
		}
		
		
		//theme will be either sixers or flyers
		private function showScratchIntro(theme:String):void
		{			
			scratchIntro = new scratchIntroDialog(); //lib clip
			scratchIntro.x = 55;
			scratchIntro.y = 236;
			
			if (theme == "sixers") {
				scratchIntro.theText.text = "Scratch off any three basketballs to reveal the Xfinity® Triple Play bundle!";
			}else if(theme == "flyers"){
				scratchIntro.theText.text = "Scratch off any three hockey pucks to reveal the Xfinity® Triple Play bundle!";
			}else {
				//generic
				scratchIntro.theText.text = "Scratch off any three circles to reveal the Xfinity® Triple Play bundle!";
			}
			
			scratchIntro.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, removeScratchIntro, false, 0, true);
			addChild(scratchIntro);
		}
		
		
		private function removeScratchIntro(e:MouseEvent):void
		{
			scratchIntro.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, removeScratchIntro);			
			TweenLite.to(scratchIntro, .5, { y:768, onComplete:killScratchIntro } );		
		}
		
		
		private function killScratchIntro():void
		{
			removeChild(scratchIntro);
			scratchIntro = null;
			//show the game
			addChild(scratch);
			reporting.scratchStarted();
			scratch.addEventListener("win", playerWon, false, 0, true);
			scratch.addEventListener("lose", playerLost, false, 0, true);
			showAdminButton();
		}
		
		
		private function showPunchIntro():void
		{	
			punchIntro = new punchIntroDialog(); //lib clip
			punchIntro.x = 55;
			punchIntro.y = 236;
			
			punchIntro.theText.text = "Punch out up to five holes on the game board to\nreveal the Xfinity® Triple Play bundle!";
			
			punchIntro.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, removePunchIntro, false, 0, true);
			addChild(punchIntro);
		}
		
		
		private function removePunchIntro(e:MouseEvent):void
		{
			punchIntro.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, removePunchIntro);			
			TweenLite.to(punchIntro, .5, { y:768, onComplete:killPunchIntro } );	
		}
		
		
		private function killPunchIntro():void
		{
			removeChild(punchIntro);
			punchIntro = null;
			//show the game
			addChild(punch);
			reporting.punchStarted();
			punch.addEventListener("win", playerWon, false, 0, true);
			punch.addEventListener("lose", playerLost, false, 0, true);
			
			//call to insure button is on top
			showAdminButton();
		}
		
		
		private function playerWon(e:Event):void
		{
			if (adminData.gameType == "scratch") {
				reporting.scratchWon();
			}else {
				reporting.punchWon();
			}
			
			winLose = new winLoseDialog(); //lib clip
			winLose.x = 55;
			winLose.y = 236;
			winLose.theTitle.text = "CONGRATULATIONS!";
			
			var wl:String = "You have successfully revealed the Xfinity® Triple Play Bundle"
			wl += "\nTV, Internet and Voice.";
			wl += "\n\nNow spin the wheel to win a prize!";
			winLose.theText.text = wl;
			
			winLose.btnContinue.theText.text = "SPIN NOW TO WIN!";
			winLose.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, showPrizeWheel, false, 0, true);
			
			if (adminData.gameType == "scratch") {
				addChild(winLose);
			}else {
				delayTimer.start();
			}
			
			var aSound:cheer = new cheer();
			channel = aSound.play();
		}
		
		private function showDelayedDialog(e:TimerEvent):void
		{
			addChild(winLose);
			delayTimer.reset();
		}
		
		private function playerLost(e:Event):void
		{			
			if (adminData.gameType == "scratch") {
				reporting.scratchLost();
			}else {
				reporting.punchLost();
			}
			
			winLose = new winLoseDialog(); //lib clip
			winLose.x = 55;
			winLose.y = 236;
			winLose.theTitle.text = "SORRY!";
			winLose.theText.text = "You did not successfully reveal each of the Xfinity® Triple Play products.\n\nThanks for playing – better luck next time!";
			winLose.btnContinue.theText.text = "CONTINUE";
			winLose.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, resetGame, false, 0, true);
			
			if (adminData.gameType == "scratch") {
				addChild(winLose);
			}else {
				delayTimer.start();
			}
			
			var aSound:trombone = new trombone();
			channel = aSound.play();
		}
		
		
		private function resetGame(e:MouseEvent):void
		{
			TweenLite.to(winLose, .5, { y:768, onComplete:killWinLose } );
		}
		
		
		private function endGameCounter(e:MouseEvent):void
		{
			endGameClicks++;
			if(endGameClicks == 3){
				resetEndGame();
			}
		}
		
		
		private function resetEndGame():void
		{
			TweenLite.to(endGame, .5, { y:768, onComplete:killEndGame } );
		}
		
		
		private function killWinLose():void
		{
			removeChild(winLose);
			winLose.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, resetGame);
			winLose = null;
			
			init();
		}
		
		private function killEndGame():void
		{
			removeChild(endGame);
			endGame.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, resetGame);
			endGame = null;
			
			init();
		}
		
		
		private function showPrizeWheel(e:MouseEvent):void
		{
			TweenLite.to(winLose, .5, { y:768, onComplete:showWheel } );
		}
		
		
		private function showWheel():void
		{
			removeChild(winLose);
			winLose.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, showPrizeWheel);
			winLose = null;
			
			if (punch) {
				if (contains(punch)) {
					removeChild(punch);
				}
			}
			if (scratch) {
				if (contains(scratch)) {
					removeChild(scratch);
				}
			}
			
			//show the single line titles for the spinner
			titles.x = 40;// 300;// 40;
			titles.y = 25;// 28; // 25; with single lines...
			if(adminData.gameType == "scratch"){
				titles.gotoAndStop(3); //3 or 4 for single line, 1 or 2 for double line
			}else {
				titles.gotoAndStop(4);
			}
			
			//change background to all red
			removeChild(theBackground);
			theBackgroundBMD = new redBG(1024, 768);
			theBackground = new Bitmap(theBackgroundBMD);
			addChildAt(theBackground, 0);
			
			spinner = new PrizeWheel(stage);
			spinner.addEventListener("doneSpinning", doneSpinning, false, 0, true);
			addChild(spinner);
			
			//call to insure button is on top of spinner
			showAdminButton();
		}
		
		
		private function doneSpinning(e:Event):void
		{
			spinner.removeEventListener("doneSpinning", doneSpinning);
			var whichPrize:Array = spinner.getPrize();
			
			reporting.addPrize(whichPrize[0]);
			
			endGameClicks = 0;
			endGame = new endGameDialog(); //lib clip
			endGame.x = 55;
			endGame.y = 190;
			endGame.theTitle.text = "You've won a " + whichPrize[0];
			endGame.theText.text = whichPrize[1] + "\n\nThanks for playing!\n\n1-800-XFINITY | xfinity.com";
			endGame.btnContinue.alpha = 0;
			endGame.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, endGameCounter, false, 0, true);
			if(adminShowing){
				addChildAt(endGame, numChildren - 2);
			}else {
				addChild(endGame);
			}
		}
		
		
		private function showAdminButton():void
		{
			if (btnAdmin) {
				if (contains(btnAdmin)) {
					removeChild(btnAdmin);
				}
			}
			addChild(btnAdmin);
			btnAdmin.addEventListener(MouseEvent.MOUSE_DOWN, showAdmin, false, 0, true);
		}
		
		
		private function showAdmin(e:MouseEvent = null):void
		{			
			admin = new Admin(reporting.getData());
			adminShowing = true;
			
			//admin.x = Math.round((stage.stageWidth - admin.width) * .5);
			//admin.y = Math.round((stage.stageHeight - admin.height) * .5);
			
			addChild(admin);
			admin.addEventListener("closeAdmin", closeAdmin, false, 0, true);
			admin.addEventListener("resetReporting", resetReporting, false, 0, true);			
		}
		
		
		private function closeAdmin(e:Event):void
		{			
			admin.removeEventListener("closeAdmin", closeAdmin);
			admin.removeEventListener("resetReporting", resetReporting);
			//TweenLite.to(admin, .5, { x:0 - admin.width, onComplete:killAdmin } );
			killAdmin();
		}
		
		
		private function resetReporting(e:Event):void
		{
			reporting.reset();
			admin.setReportingObject(reporting.getData());
			admin.reportingClicked();
		}
		
		
		private function killAdmin():void
		{
			adminShowing = false;
			removeChild(admin);
			admin = null;
			
			//reload 
			init();
		}
		
	}
	
}