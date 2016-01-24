package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.queue.Queue;
	import com.gmrmarketing.utilities.queue.FormService;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var dialogContainer:Sprite;
		
		private var bg:MovieClip; //lib clip background
		
		private var home:Home;//home screen - novice/seasoned/sommelier selection
		private var selectPreference:SelectPreference; //white/red selection
		private var rankWine:RankWine; //like it, love it, favorite
		private var challenge:Challenge; //blind taste challenge based on level selection
		private var results:Results;
		private var email:Email; //email screen with keyboard
		private var didEmail:Boolean; //used by thanks screen
		private var thanks:Thanks;
		
		private var configDialog:ConfigDialog; //for configuring the wines used
		
		private var wineData:WineData;//reads JSON file
		
		private var dialogCorner:CornerQuit;
		private var quitCorner:CornerQuit;
		
		private var q:Queue;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			dialogContainer = new Sprite();
			addChild(dialogContainer);
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
			dialogCorner = new CornerQuit();
			dialogCorner.init(cornerContainer, "ur");
			dialogCorner.addEventListener(CornerQuit.CORNER_QUIT, showWineConfig);
			
			quitCorner = new CornerQuit();
			quitCorner.init(cornerContainer, "ul");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, closeApp);
			
			bg = new mcBackground();
			mainContainer.addChild(bg);
			
			configDialog = new ConfigDialog();
			configDialog.container = dialogContainer;
			
			wineData = new WineData();
			wineData.addEventListener(WineData.READY, pushDataToConfig);
			
			home = new Home();
			home.container = mainContainer;
			
			selectPreference = new SelectPreference();
			selectPreference.container = mainContainer;
			
			rankWine = new RankWine();
			rankWine.container = mainContainer;
			
			challenge = new Challenge();
			challenge.container = mainContainer;
			
			results = new Results();
			results.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			q = new Queue();
			q.fileName = "nflHouseWine";
			q.service = new FormService("http://someWebPlace");
			
			init();
		}
		
		
		private function init():void
		{
			home.show();
			home.addEventListener(Home.COMPLETE, hideHome, false, 0, true);
		}
		
		
		/**
		 * Called by listener on wineData once the JSON is read and parsed
		 * Sets the white and red wine list in the config dialog
		 * @param	e
		 */
		private function pushDataToConfig(e:Event):void
		{
			wineData.removeEventListener(WineData.READY, pushDataToConfig);
			configDialog.setData(wineData.whites, wineData.reds);
		}
		
		
		/**
		 * Called by four taps on config corner at upper right
		 * @param	e
		 */
		private function showWineConfig(e:Event):void
		{
			configDialog.show();
		}
		
		
		/**
		 * Shows the select red or white wine screen
		 * @param	e
		 */
		private function hideHome(e:Event):void
		{
			home.removeEventListener(Home.COMPLETE, showSelectPreference);
			home.addEventListener(Home.HIDDEN, showSelectPreference, false, 0, true);
			home.hide();
		}
		
		
		private function showSelectPreference(e:Event):void
		{
			home.removeEventListener(Home.HIDDEN, showSelectPreference);
			
			selectPreference.show(home.selection);
			selectPreference.addEventListener(SelectPreference.COMPLETE, hidePreference, false, 0, true);
		}
		
		
		private function hidePreference(e:Event):void
		{
			selectPreference.removeEventListener(SelectPreference.COMPLETE, hidePreference);
			selectPreference.addEventListener(SelectPreference.HIDDEN, showRankWine, false, 0, true);
			selectPreference.hide();
		}
		
		
		private function showRankWine(e:Event):void
		{
			selectPreference.removeEventListener(SelectPreference.HIDDEN, showRankWine);

			rankWine.addEventListener(RankWine.COMPLETE, hideRankWine, false, 0, true);
			rankWine.show();
		}
		
		
		private function hideRankWine(e:Event):void
		{
			rankWine.removeEventListener(RankWine.COMPLETE, hideRankWine);
			rankWine.addEventListener(RankWine.HIDDEN, showChallenge, false, 0, true);
			rankWine.hide();
		}
		
		
		private function showChallenge(e:Event):void
		{
			rankWine.removeEventListener(RankWine.HIDDEN, showChallenge);
			
			challenge.addEventListener(Challenge.COMPLETE, hideChallenge, false, 0, true);
			challenge.show(home.selection, wineData.getWineDataFromSelections(configDialog.selectedWines(selectPreference.selection)), wineData.questionData);
		}
		
		
		private function hideChallenge(e:Event):void
		{
			challenge.removeEventListener(Challenge.COMPLETE, hideChallenge);
			
			trace(challenge.selection);
			challenge.addEventListener(Challenge.HIDDEN, showResults, false, 0, true);
			challenge.hide();
		}
		
		
		private function showResults(e:Event):void
		{
			email.addEventListener(Email.HIDDEN, showResults);
			challenge.removeEventListener(Challenge.HIDDEN, showResults);
			
			results.addEventListener(Results.COMPLETE, hideResults, false, 0, true);
			results.addEventListener(Results.SKIP, hideResultsSkip, false, 0, true);
			results.show(challenge.selection, challenge.answersText, wineData.getWineDataFromSelections(configDialog.selectedWines(selectPreference.selection)), rankWine.selection);
		}
		
		
		/**
		 * called if user presses send email button in results
		 * @param	e
		 */
		private function hideResults(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.removeEventListener(Results.SKIP, hideResultsSkip);
			
			results.addEventListener(Results.HIDDEN, showEmail, false, 0, true);
			results.hide();
		}
		
		
		/**
		 * called if user presses skip button in results
		 * @param	e
		 */
		private function hideResultsSkip(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.removeEventListener(Results.SKIP, hideResultsSkip);
			didEmail = false;
			results.addEventListener(Results.HIDDEN, showThanks, false, 0, true);
			results.hide();
		}
		
		
		private function showEmail(e:Event):void
		{
			results.removeEventListener(Results.HIDDEN, showEmail);
			
			email.addEventListener(Email.COMPLETE, hideEmail, false, 0, true);
			email.addEventListener(Email.CANCEL, cancelEmail, false, 0, true);
			email.show();
		}
		
		
		private function hideEmail(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.CANCEL, cancelEmail);
			didEmail = true;
			email.addEventListener(Email.HIDDEN, showThanks, false, 0, true);
			email.hide();
		}
		
		
		private function cancelEmail(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.CANCEL, cancelEmail);
			email.addEventListener(Email.HIDDEN, showResults, false, 0, true);
			email.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			email.removeEventListener(Email.HIDDEN, showThanks);
			results.removeEventListener(Results.HIDDEN, showThanks);
			
			if (didEmail) {
				//send data to web service
				var o:Object = email.data; //object with name and email properties
				
				//the users ranking order - so we can tell them their favorite
				o.userRankWine1 = rankWine.selection[0];//1 if favorite - 3 least favorite
				o.userRankWine2 = rankWine.selection[1];
				o.userRankWine3 = rankWine.selection[2];
				
				//array of 3 objects from the JSON
				var wineList:Array = wineData.getWineDataFromSelections(configDialog.selectedWines(selectPreference.selection));
				
				o.wine1 = wineList[0];
				o.wine2 = wineList[1];
				o.wine3 = wineList[2];
				
				q.add(o);
			}
			
			thanks.addEventListener(Thanks.COMPLETE, hideThanks, false, 0, true);
			thanks.show(didEmail);
		}
		
		
		private function hideThanks(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, hideThanks);
			thanks.addEventListener(Thanks.HIDDEN, doReset, false, 0, true);
			thanks.hide();
		}
		
		
		private function doReset(e:Event):void
		{
			thanks.removeEventListener(Thanks.HIDDEN, doReset);
			init();
		}
		
		
		private function closeApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}