package com.gmrmarketing.humana.recipes
{
	import flash.display.MovieClip;
	import com.gmrmarketing.humana.recipes.RecipeData;
	import com.gmrmarketing.humana.recipes.Slideshow;
	import com.gmrmarketing.humana.recipes.Header;
	import com.gmrmarketing.humana.recipes.Detail;
	import com.gmrmarketing.humana.recipes.Print;
	import com.gmrmarketing.humana.recipes.ListView;
	import com.gmrmarketing.humana.recipes.Preloader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.*;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.website.VPlayer;
	import flash.desktop.NativeApplication;	
	import com.google.analytics.GATracker;
	import com.greensock.TweenMax;
	

	public class Main extends MovieClip
	{
		private var recipes:RecipeData;
		private var slideshow:Slideshow;
		private var detail:Detail;
		private var listView:ListView;
		private var header:Header;
		private var preloader:Preloader;
		private var email:Email;
		
		private var print:Print;
		private var nowPrinting:MovieClip; //lib clip
		private var vPlayer:VPlayer;
		
		private var headerContainer:Sprite;
		private var slideshowContainer:Sprite;
		private var detailContainer:Sprite;
		private var listContainer:Sprite;
		private var vidContainer:Sprite;
		private var modalRect:Sprite;
		private var cornerQuitContainer:Sprite;
		
		private var vidTools:MovieClip;
		private var vidDuration:String;
		
		private var cq:CornerQuit;
		private var timeout:TimeoutHelper;
		
		private var ga:GATracker;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Multitouch.inputMode = MultitouchInputMode.NONE;
			Mouse.hide();
			
			headerContainer = new Sprite();
			slideshowContainer = new Sprite();
			detailContainer = new Sprite();
			listContainer = new Sprite();
			modalRect = new Sprite();
			vidContainer = new Sprite();
			cornerQuitContainer = new Sprite();
			
			//setup container layering
			addChild(slideshowContainer);
			addChild(detailContainer);
			addChild(listContainer);
			addChild(headerContainer);
			addChild(modalRect);
			addChild(vidContainer);
			addChild(cornerQuitContainer);
			
			vidContainer.y = 300; //videos are all 800x450 - 
			
			var bRect:Shape = new Shape();
			bRect.graphics.beginFill(0x000000, .7);
			bRect.graphics.drawRect(0, 0, 800, 1280);
			bRect.graphics.endFill();			
			modalRect.addChild(bRect);
			modalRect.visible = false;
			
			slideshow = new Slideshow();
			detail = new Detail();
			listView = new ListView();
			header = new Header();
			preloader = new Preloader();
			
			email = new Email();
			email.setContainer(this);
			
			vidTools = new mc_videoControl(); //lib clip
			
			ga = new GATracker(this, "UA-6580930-16");
			ga.trackPageview("app_start");
			
			vPlayer = new VPlayer();
			vPlayer.useTimeoutHelper();
			vPlayer.addEventListener(VPlayer.META_RECEIVED, videoMetaReceived, false, 0, true);
			vPlayer.addEventListener(VPlayer.STATUS_RECEIVED, videoStatus, false, 0, true);			
			
			cq = new CornerQuit();
			cq.init(cornerQuitContainer, "ur");
			cq.customLoc(1, new Point(650, 0));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			timeout = TimeoutHelper.getInstance();
			timeout.addEventListener(TimeoutHelper.TIMED_OUT, showSlideShowView, false, 0, true);
			timeout.init(180000); //3 minutes
			timeout.startMonitoring();
			
			print = new Print();
			print.addEventListener(Print.BEGIN_PRINTING, showNowPrintingDialog, false, 0, true);
			nowPrinting = new mc_nowPrinting();			
			
			slideshow.setContainer(slideshowContainer);
			detail.setContainer(detailContainer);
			listView.setContainer(listContainer);
			header.setContainer(headerContainer);
			
			header.addEventListener(Header.SLIDESHOW, showSlideShowView, false, 0, true);
			
			recipes = new RecipeData();
			recipes.addEventListener(Event.COMPLETE, recipesLoaded, false, 0, true);
			recipes.addEventListener(RecipeData.FILE_NOT_FOUND, xmlError, false, 0, true);
		}
		
		
		private function recipesLoaded(e:Event):void
		{
			preloader.preload(recipes.getRecipeList());
			
			recipes.removeEventListener(Event.COMPLETE, recipesLoaded);
			recipes.removeEventListener(RecipeData.FILE_NOT_FOUND, xmlError);
			
			showSlideShowView();
		}
		
		
		private function xmlError(e:Event):void
		{
			trace("xml file not found");
		}
		
		
		private function showSlideShowView(e:Event = null):void
		{
			timeout.buttonClicked();
			
			detail.hide();
			listView.hide();
			
			header.showSlideshowView();
			header.addEventListener(Header.VIEW_ALL, showListView, false, 0, true);
			header.addEventListener(Header.VIEW_ONE, slideshowRecipeClicked, false, 0, true);			
			
			slideshow.show(recipes.getSlideshowImages());			
			slideshow.addEventListener(Slideshow.NEW_SLIDE, changeHeaderTitle, false, 0, true);			
		}
		
		
		/**
		 * Called by clicking the view current recipe button in the slideshow
		 * Goes to detail view
		 * @param	e
		 */
		private function showDetailView(e:Event = null):void
		{	
			timeout.buttonClicked();
			
			slideshow.hide();
			listView.hide();
			listView.removeEventListener(ListView.RECIPE_CLICKED, listViewRecipeClicked);
			
			header.showDetailView();
			header.removeEventListener(Header.VIEW_ALL, showListView);
			header.removeEventListener(Header.VIEW_ONE, slideshowRecipeClicked);
			header.addEventListener(Header.BACK_PRESSED, showListView, false, 0, true);
			header.addEventListener(Header.PRINT, printRecipe, false, 0, true);			
			header.addEventListener(Header.EMAIL, emailRecipe, false, 0, true);			
			
			detail.show(recipes.getSelectedRecipe());
			detail.addEventListener(Detail.WATCH_VIDEO, detailVideoClicked, false, 0, true);
			
			ga.trackPageview("view:" + recipes.getSelectedRecipe().title);
		}
		
		
		
		/**
		 * Called by clicking the view all recipes button in the footer
		 * Goes to list view
		 * @param	e
		 */
		private function showListView(e:Event = null):void
		{
			timeout.buttonClicked();
			
			slideshow.hide();
			stopVid();
			detail.hide();
			detail.removeEventListener(Detail.WATCH_VIDEO, detailVideoClicked);
			
			header.showListView();
			header.removeEventListener(Header.VIEW_ALL, showListView);
			header.removeEventListener(Header.VIEW_ONE, slideshowRecipeClicked);
			header.removeEventListener(Header.BACK_PRESSED, showListView);
			header.removeEventListener(Header.PRINT, printRecipe);
			
			listView.show(recipes.getAllRecipes());
			listView.addEventListener(ListView.RECIPE_CLICKED, listViewRecipeClicked, false, 0, true);
		}
		
		
		/**
		 * called by listener on Slideshow whenever a new slide is tweening in
		 * @param	e
		 */
		private function changeHeaderTitle(e:Event):void
		{
			header.changeSlideshowTitle(slideshow.getCurrentRecipeTitle());
		}
		
		
		/**
		 * Called if the watch video button within the detail view is clicked
		 * @param	e
		 */
		private function detailVideoClicked(e:Event):void
		{
			timeout.buttonClicked();
			var recipe:XML = recipes.getSelectedRecipe();
			ga.trackPageview("video:" + recipe.title);
			vPlayer.showVideo(vidContainer);
			vPlayer.playVideo(recipe.video);
			modalRect.visible = true;
		}
		
		
		private function videoMetaReceived(e:Event):void
		{			
			//vPlayer.autoSizeOff();
			vPlayer.setSmoothing();
			vPlayer.setVidWidthProportional(800);
			
			vidTools.y = vidContainer.y + vPlayer.getVidSize().height;
			
			vidTools.btnStop.addEventListener(MouseEvent.MOUSE_DOWN, stopVid, false, 0, true);
			vidTools.btnPlayPause.addEventListener(MouseEvent.MOUSE_DOWN, playPause, false, 0, true);
			addChild(vidTools);
			vidTools.playPause.gotoAndStop(2);//show pause
			
			var min:Number = Math.floor(vPlayer.getDuration() / 60); //returns duration in seconds
			var sec:String = String(Math.round(vPlayer.getDuration() % 60));			
			if (sec.length < 2) {
				sec = "0" + sec;
			}
			vidDuration = String(min) + ":" + sec;
			
			addEventListener(Event.ENTER_FRAME, updateVideoTime, false, 0, true);
		}
		
		/**
		 * Called by clicking the x button in the player
		 * From videoStatus() when the video is over
		 * From showListView() so the video stops if the user switches views
		 * 
		 * @param	e
		 */
		private function stopVid(e:MouseEvent = null):void
		{
			vPlayer.hideVideo();
			modalRect.visible = false;
			if(contains(vidTools)){
				removeChild(vidTools);
			}
			vidTools.btnStop.removeEventListener(MouseEvent.MOUSE_DOWN, stopVid);
			vidTools.btnPlayPause.removeEventListener(MouseEvent.MOUSE_DOWN, playPause);
			removeEventListener(Event.ENTER_FRAME, updateVideoTime);
		}
		
		
		private function playPause(e:MouseEvent):void
		{
			if (vPlayer.isPaused()) {
				vPlayer.resumeVideo();
				vidTools.playPause.gotoAndStop(2);//pause
			}else {
				vPlayer.pauseVideo();
				vidTools.playPause.gotoAndStop(1);//play
			}			
		}
		
		private function updateVideoTime(e:Event):void
		{
			var time:Number = vPlayer.getVideoInfo().time; //playhead position in seconds
			var min:Number = Math.floor(time / 60);
			var sec:String = String(Math.round(time % 60));
			if (sec.length < 2) {
				sec = "0" + sec;
			}
			vidTools.theText.text = String(min) + ":" + sec + " / " + vidDuration;
		}
		
		
		/**
		 * video over
		 * @param	e
		 */
		private function videoStatus(e:Event):void
		{
			if(vPlayer.getStatus() == "NetStream.Play.Stop")
			{
				stopVid();
			}
		}
		
		
		/**
		 * Called by clicking the view this recipe button in the slideshow
		 * shows the detail view
		 * @param	e
		 */
		private function slideshowRecipeClicked(e:Event):void
		{
			timeout.buttonClicked();			
			recipes.setSelectedRecipeByIndex(slideshow.getSelectedRecipeIndex());
			showDetailView();
		}
		
		
		/**
		 * Called by clicking on a recipe item in the list view
		 * @param	e
		 */
		private function listViewRecipeClicked(e:Event):void
		{
			timeout.buttonClicked();			
			recipes.setSelectedRecipeByIndex(listView.getSelectedRecipeIndex());
			showDetailView();
		}
		
		
		/**
		 * Called by clicking print in the detail view
		 * @param	e
		 */
		private function printRecipe(e:Event):void
		{
			timeout.buttonClicked();
			ga.trackPageview("print:" + recipes.getSelectedRecipe().title);
			print.print(recipes.getSelectedRecipe());
		}
		
		
		/**
		 * Called by clicking the email button in the detail view
		 * @param	e
		 */
		private function emailRecipe(e:Event):void
		{
			timeout.buttonClicked();
			ga.trackPageview("email:" + recipes.getSelectedRecipe().title);
			
			email.show();
			email.addEventListener(Email.CANCELED, emailHide, false, 0, true);
			email.addEventListener(Email.SEND, emailSend, false, 0, true);
		}
		
		/**
		 * Called if cancel button is pressed in email dialog
		 * @param	e
		 */
		private function emailHide(e:Event):void
		{
			email.hide();
			
			email.removeEventListener(Email.CANCELED, emailHide);
			email.removeEventListener(Email.SEND, emailSend);
		}
		
		
		private function emailSend(e:Event):void
		{
			email.hide(true); //shows thank you message and fades out
			email.removeEventListener(Email.CANCELED, emailHide);
			email.removeEventListener(Email.SEND, emailSend);
			email.sendEmail(recipes.getSelectedRecipe());
		}
		
		private function showNowPrintingDialog(e:Event):void
		{
			addChild(nowPrinting);
			nowPrinting.alpha = 0;
			TweenMax.to(nowPrinting, 1, { alpha:1 } );
			TweenMax.to(nowPrinting, 1, { alpha:0, delay:5, onComplete:killNowPrinting } );
		}
		
		private function killNowPrinting():void
		{
			if (contains(nowPrinting)) {
				removeChild(nowPrinting);
			}
		}
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}