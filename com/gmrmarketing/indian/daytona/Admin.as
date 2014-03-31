/**
 * Document class for Admin.fla
 * 
 */
package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import com.gmrmarketing.indian.daytona.*;
	import flash.events.Event;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.utils.Timer;
	import flash.text.*;
	
	
	public class Admin extends MovieClip
	{
		private var countDown:MovieClip;
		private var winner:MovieClip;
		private var secTimer:Timer;
		private var database:Database;
		private var pwdDialog:PasswordDialog;
		
		private var xmlLoader:URLLoader;
		private var xmlPassword:String;
		
		private var dialog:Dialog;
		private var countFormatter:TextFormat;
		
		private var currentWinner:Object;
		
		//name animation
		private var names:Array; //array of object from Database - only used to animate the names when waiting for a winner selection
		private var animTimer:Timer;
		private var nameIndex:int;
		
		private var rules:Rules;
		
		private var timeToPick:TimeToPick;
		private var cq:CornerQuit;
		
		
		public function Admin()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			countFormatter = new TextFormat();
			countFormatter.letterSpacing = -6;
			
			countDown = new mainScreen(); //lib clips
			
			winner = new winnerScreen();
			
			secTimer = new Timer(1000);
			secTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			
			animTimer = new Timer(40);
			animTimer.addEventListener(TimerEvent.TIMER, animate, false, 0, true);
			
			database = Database.getInstance();
			
			dialog = new Dialog();
			
			rules = new Rules();
			rules.setContainer(this);
			
			timeToPick = new TimeToPick();
			
			//load the password for the winners screen
			xmlLoader = new URLLoader(new URLRequest("pwd.xml"));
			xmlLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			
			cq = new CornerQuit();
			cq.init(this, "ul");			
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);
			
			currentWinner = { fname:"", lname:"" };
			
			showCountScreen();
			beginCount();
		}
		
		
		private function configLoaded(e:Event):void
		{
			var c:XML = new XML(e.currentTarget.data);			
			
			xmlLoader.removeEventListener(Event.COMPLETE, configLoaded);
			
			pwdDialog = new PasswordDialog(c.pwd);
			pwdDialog.setContainer(this);			
		}
				
		
		private function showCountScreen(e:MouseEvent = void):void
		{		
			winner.btnAdmin.removeEventListener(MouseEvent.MOUSE_DOWN, showCountScreen);			
			winner.btnPick.removeEventListener(MouseEvent.MOUSE_DOWN, pickWinner);
			winner.btnClaim.removeEventListener(MouseEvent.MOUSE_DOWN, claim);
			winner.btnNoShow.removeEventListener(MouseEvent.MOUSE_DOWN, noShow);
			winner.btnPolicy.removeEventListener(MouseEvent.MOUSE_DOWN, showPolicy);
			winner.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);
			
			if(!contains(countDown)){
				addChild(countDown);
			}
			
			//winner is the winner screen
			if (contains(winner)) {
				TweenMax.to(winner, .5, { alpha:0, onComplete:killWinner } );
			}
			
			currentWinner = { fname:"", lname:"" };
			
			if(pwdDialog){
				pwdDialog.kill();
			}
			
			cq.moveToTop();
			
			countDown.btnAdmin.addEventListener(MouseEvent.MOUSE_DOWN, showPasswordDialog, false, 0, true);
			countDown.btnPolicy.addEventListener(MouseEvent.MOUSE_DOWN, showPolicy, false, 0, true);
			countDown.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
		}
		
		
		/**
		 * Called by clicking the admin button at upper right in the countdown screen
		 * @param	e
		 */
		private function showPasswordDialog(e:MouseEvent):void
		{			
			pwdDialog.show();
			pwdDialog.addEventListener(PasswordDialog.ACCEPTED, showWinnerScreen, false, 0, true);
		}
		
		private function showPolicy(e:MouseEvent):void
		{			
			rules.show(1);
		}
		
		private function showRules(e:MouseEvent):void
		{			
			rules.show(2);
		}
		
		/**
		 * Called by clicking admin button at top right of countdown screen
		 * and entering the proper password in the dialog
		 * 
		 * @param	e
		 */
		private function showWinnerScreen(e:Event):void
		{		
			timeToPick.hide();
			
			pwdDialog.removeEventListener(PasswordDialog.ACCEPTED, showWinnerScreen);
			
			countDown.btnAdmin.removeEventListener(MouseEvent.MOUSE_DOWN, showWinnerScreen);
			countDown.btnPolicy.removeEventListener(MouseEvent.MOUSE_DOWN, showPolicy);
			countDown.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);
			
			if (!contains(winner)) {
				addChild(winner);
			}
			
			winner.alpha = 0;			
			TweenMax.to(winner, .5, { alpha:1 } );
			
			winner.btnAdmin.addEventListener(MouseEvent.MOUSE_DOWN, showCountScreen, false, 0, true);
			
			
			//gets the list of users entered in the last hour
			database.addEventListener(Database.WINNERS_SELECTED, winnersSelected, false, 0, true);
			database.addEventListener(Database.NO_WINNERS, noWinners, false, 0, true);			
			
			cq.moveToTop();
			
			database.selectWinners();
		}
		
		
		/**
		 * Called once the database call to selectWinners() has returned a list of possible winners
		 * enables the pick/claim/no show buttons
		 * @param	e
		 */
		private function winnersSelected(e:Event):void
		{			
			database.removeEventListener(Database.WINNERS_SELECTED, winnersSelected);
			database.removeEventListener(Database.NO_WINNERS, noWinners);
			
			//normal buttons
			winner.btnClaim.alpha = 0;
			winner.btnNoShow.alpha = 0;
			winner.btnPick.alpha = 0;
			
			winner.btnClaim.addEventListener(MouseEvent.MOUSE_DOWN, claim, false, 0, true);
			winner.btnNoShow.addEventListener(MouseEvent.MOUSE_DOWN, noShow, false, 0, true);
			winner.btnPick.addEventListener(MouseEvent.MOUSE_DOWN, pickWinner, false, 0, true);
			winner.btnPolicy.addEventListener(MouseEvent.MOUSE_DOWN, showPolicy, false, 0, true);
			winner.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			
			updateNumWinners();
			
			//get names from the database - first and last names only for the animation
			database.addEventListener(Database.GOT_NAMES, startAnimation, false, 0, true);			
			database.selectNames();
		}
		
		
		/**
		 * Called from clicking the No Show button on the winners screen
		 * this button is only enabled if winnerSelected has been called
		 * Marks the currentWinner as claimed and possibly unmarks noShow
		 * @param	e
		 */
		private function claim(e:MouseEvent):void
		{			
			if (currentWinner.fname != "") {
				animTimer.stop();
				database.claimWinner(currentWinner);
				updateNumWinners();
				removeFromAnim(currentWinner);
				if(database.getNumWinners() > 0 && names.length){
					animTimer.start();
				}
			}
		}
		
		
		/**
		 * Called from clicking the No Show button on the winners screen
		 * this button is only enabled if winnerSelected has been called
		 * Marks the currentWinner as noShow and possibly unmarks claimed
		 * @param	e
		 */
		private function noShow(e:MouseEvent):void
		{
			if (currentWinner.fname != "") {
				animTimer.stop();
				database.noShow(currentWinner);
				updateNumWinners();
				removeFromAnim(currentWinner);
				if(database.getNumWinners() > 0 && names.length){
					animTimer.start();
				}
			}
		}		
		
		
		/**
		 * Called from claim() and noShow() removes the picked winner from the animation
		 * list of names - just to prevent any confusion
		 * 
		 * @param	curWin
		 */
		private function removeFromAnim(curWin:Object):void
		{				
			for (var i:int = 0; i < names.length; i++) {
				if (names[i].lname == currentWinner.lname && names[i].fname == currentWinner.fname) {
					//trace(names[i].lname, currentWinner.lname, names[i].fname, currentWinner.fname);					
					names.splice(i, 1);					
					break;
				}
			}
			nameIndex = 0;
		}
		
		
		/**
		 * Called if the database call to selectWinners() returns an empty set
		 * grays out and disables the pick/claim/no show buttons
		 * @param	e
		 */
		private function noWinners(e:Event):void
		{
			database.removeEventListener(Database.WINNERS_SELECTED, winnersSelected);
			database.removeEventListener(Database.NO_WINNERS, noWinners);
			
			//gray out the buttons
			winner.btnClaim.alpha = .8;
			winner.btnNoShow.alpha = .8;
			winner.btnPick.alpha = .8;
			
			winner.btnPick.removeEventListener(MouseEvent.MOUSE_DOWN, pickWinner);
			winner.btnClaim.removeEventListener(MouseEvent.MOUSE_DOWN, claim);
			winner.btnNoShow.removeEventListener(MouseEvent.MOUSE_DOWN, noShow);
			winner.btnPolicy.removeEventListener(MouseEvent.MOUSE_DOWN, showPolicy);
			winner.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);
			
			dialog.show("NO ENTRIES IN THE PAST HOUR", this);
			winner.possibleWinners.text = "0 possible winners";
			
			//get names, for animation, from the database
			database.addEventListener(Database.GOT_NAMES, startAnimation, false, 0, true);			
			database.selectNames();
		}
		
		
		/**
		 * Callback from database call to selectNames in winnersSelected
		 * @param	e
		 */
		private function startAnimation(e:Event):void
		{
			database.removeEventListener(Database.GOT_NAMES, startAnimation);			
			names = database.getNames();			
			nameIndex = 0;
			animTimer.start();
		}
		
		
		/**
		 * Called when animTimer is running
		 * @param	e
		 */
		private function animate(e:TimerEvent):void
		{
			var fName:TextField = winner.theName.fname as TextField;
			var lName:TextField = winner.theName.lname as TextField;
			
			fName.autoSize = TextFieldAutoSize.LEFT;
			lName.autoSize = TextFieldAutoSize.LEFT;
			
			//get first name with upper cased first letter - last name field uses Liberator font - which is only uppercase
			var f:String = " " + String(names[nameIndex].fname).substr(0, 1).toUpperCase() + String(names[nameIndex].fname).substr(1).toLowerCase() + " ";
			
			fName.text = f;
			lName.text = String(names[nameIndex].lname).substr(0, 6);
			
			var maxWide:int = 830;
			var maxHeight:int = 300;
			
			//winner.theName.width = maxWide;
			//winner.theName.scaleY = winner.theName.scaleX;
			
			//if (winner.theName.height > maxHeight) {
				winner.theName.height = maxHeight;
				winner.theName.scaleX = winner.theName.scaleY;
			//}			
			
			nameIndex++;
			if (nameIndex >= names.length) {
				nameIndex = 0;
			}
		}
		
		
		/**
		 * Called from winnersSelected(), claim() and noShow()
		 * 
		 */
		private function updateNumWinners():void
		{
			var num:int = database.getNumWinners();
			winner.possibleWinners.text = num + " possible winners";
			
			if (num == 0) {
				dialog.show("There are no more entries\nto choose from", this);
				animTimer.stop();
				winner.theName.fname.text = "";
				winner.theName.lname.text = "";
				
				//gray out the buttons
				winner.btnClaim.alpha = .8;
				winner.btnNoShow.alpha = .8;
				winner.btnPick.alpha = .8;
				
				winner.btnPick.removeEventListener(MouseEvent.MOUSE_DOWN, pickWinner);
				winner.btnClaim.removeEventListener(MouseEvent.MOUSE_DOWN, claim);
				winner.btnNoShow.removeEventListener(MouseEvent.MOUSE_DOWN, noShow);
			}
		}
		
		/**
		 * Called by clicking the 'pick another winner' button
		 * 
		 * Button is not enabled unless winnersSelected has been called
		 * stops the animTimer
		 * @param	e
		 */
		private function pickWinner(e:MouseEvent):void
		{
			animTimer.stop();			
			
			//get random winner from the database list of possible winners (ie the registrants in the past hour)
			currentWinner = database.getWinner();
			
			if (currentWinner.fname == "") {
				//empty winner returned - no more winners in the array
				dialog.show("There are no more entries\nto choose from", this);
				
				//these lines moved to updateNumWinners()
				//animTimer.stop();
				//winner.theName.fname.text = "";
				//winner.theName.lname.text = "";
				 
			}else{
				
				var fName:TextField = winner.theName.fname as TextField;
				var lName:TextField = winner.theName.lname as TextField;
				
				fName.autoSize = TextFieldAutoSize.LEFT;
				lName.autoSize = TextFieldAutoSize.LEFT;
				
				//get first name with upper cased first letter
				var f:String = " " + String(currentWinner.fname).substr(0, 1).toUpperCase() + String(currentWinner.fname).substr(1).toLowerCase() + " ";
				
				fName.text = f;
				lName.text = currentWinner.lname;
				
				var maxWide:int = 830;
				var maxHeight:int = 350;
				
				winner.theName.width = maxWide;
				winner.theName.scaleY = winner.theName.scaleX;
				
				if (winner.theName.height > maxHeight) {
					winner.theName.height = maxHeight;
					winner.theName.scaleX = winner.theName.scaleY;
				}
			}			
		}
		
		
		
		/**
		 * Called each second by secTimer
		 * Displays the on-scren time remaining on both the countdown and winner screens
		 * 
		 * 
		 * @param	e
		 */
		private function update(e:TimerEvent):void
		{
			var d:Date = new Date(); //now
			
			//drawings on the :48
			var remaining:int = 48 - d.getMinutes();
			if (remaining < 0) {
				remaining += 60;
			}
			var rem:String = String(remaining);
			
			var secRem:String = String(60 - d.getSeconds());
			
			if (rem.length < 2) {
				rem = "0" + rem;
			}
			
			if (secRem.length < 2) {
				secRem = "0" + secRem;
			}
			
			countDown.count.theText.text = rem;
			countDown.theSec.text = secRem;
			
			countDown.count.theText.setTextFormat(countFormatter);
			countDown.theSec.setTextFormat(countFormatter);
			
			winner.theCount.text = rem;
			winner.theCount.setTextFormat(countFormatter);
			
			if (rem == "00" && secRem == "01") {				
				timeToPick.show(this);
				//if pwd dialog is showing make sure it's over the time to pick text
				pwdDialog.moveToTop();
			}
		}

		
		private function beginCount():void
		{
			secTimer.start();
		}
		
		
		private function stopCount():void
		{
			secTimer.stop();
		}
		
		
		
		
		
		private function killWinner():void
		{
			removeChild(winner);
		}
		
		
		private function quit(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}