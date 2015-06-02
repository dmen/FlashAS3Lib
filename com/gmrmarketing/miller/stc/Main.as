package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	
	public class Main extends MovieClip
	{
		private var bg:Background;//contains the background image/animation
		private var logoContainer:Sprite;//container for the intro/Logo so it can be scaled
		private var introLogo:Intro;//initial build that scales down and remains on screen
		private var mainContainer:Sprite;
		private var topContainer:Sprite;
		private var cornerContainer:Sprite;
		private var cq:CornerQuit;
		
		private var data:DataEntry;//dataEntry screen with birthday,phone,gender
		private var passionSelect:PassionSelect;//right now this is just choose music or sports
		private var colorSelect:ColorSelect;//golden color beer selection screen
		private var challenge:Challenge;//physical beer glass selection
		private var results:Results; //win-no win screen
		private var tapToBegin:TapToBegin;//very first screen
		
		private var dataPost:DataPost;//for sending data to the service
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			data = new DataEntry()
			data.container = this;

			bg = new Background();
			bg.container = this;
			bg.show();
			
			logoContainer = new Sprite();
			addChild(logoContainer);
			
			mainContainer = new Sprite();
			mainContainer.cacheAsBitmap = true;
			addChild(mainContainer);
			
			topContainer = new Sprite();
			addChild(topContainer);
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
			introLogo = new Intro();
			introLogo.container = logoContainer;
			
			passionSelect = new PassionSelect();
			passionSelect.container = mainContainer;
			
			colorSelect = new ColorSelect();
			colorSelect.container = mainContainer;
			
			challenge = new Challenge();
			challenge.container = mainContainer;
			
			results = new Results();
			results.container = mainContainer;
			
			tapToBegin = new TapToBegin();
			tapToBegin.container = mainContainer;
			
			dataPost = new DataPost();
			
			cq = new CornerQuit();			
			
			init();
		}
		
		
		private function init():void
		{
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			tapToBegin.show();
			tapToBegin.addEventListener(TapToBegin.COMPLETE, buildLogo);
		}
		
		
		private function buildLogo(e:Event = null):void
		{
			tapToBegin.removeEventListener(TapToBegin.COMPLETE, buildLogo);
			tapToBegin.hide();
			
			introLogo.container = logoContainer;
			logoContainer.scaleX = logoContainer.scaleY = 1;
			logoContainer.x = 0;
			logoContainer.y = 0;
			introLogo.addEventListener(Intro.FINISHED, showDataEntry);
			introLogo.show();//initial logo build
		}
		
		
		private function showDataEntry(e:Event):void
		{
			introLogo.removeEventListener(Intro.FINISHED, showDataEntry);
			TweenMax.to(logoContainer, 1, { scaleX:.475, scaleY:.475, x:555, y:-55, delay:.5 } );
			
			TweenMax.delayedCall(1, data.show);
			data.addEventListener(DataEntry.COMPLETE, choosePassion);
			data.addEventListener(DataEntry.BACK, backToDOB);
		}
		
		
		private function backToDOB(e:Event):void
		{
			e.stopImmediatePropagation();
			data.removeEventListener(DataEntry.COMPLETE, choosePassion);
			data.removeEventListener(DataEntry.BACK, backToDOB);
			data.hide();
			introLogo.hide();
			init();
		}
		
		
		private function choosePassion(e:Event = null):void
		{
			data.removeEventListener(DataEntry.COMPLETE, choosePassion);
			data.removeEventListener(DataEntry.BACK, backToDOB);
			data.hide();			
			introLogo.hide();//fades out
			
			passionSelect.show();
			passionSelect.addEventListener(PassionSelect.COMPLETE, showColorSelect);
			passionSelect.addEventListener(PassionSelect.BACK, backToForm);
		}
		
		
		private function backToForm(e:Event):void
		{
			passionSelect.removeEventListener(PassionSelect.BACK, backToForm);
			passionSelect.hide();
			buildLogo();
		}
		
		
		private function showColorSelect(e:Event = null):void
		{
			passionSelect.removeEventListener(PassionSelect.COMPLETE, showColorSelect);
			passionSelect.hide();
			
			colorSelect.show();
			colorSelect.addEventListener(ColorSelect.COMPLETE, showGlasses);
			colorSelect.addEventListener(ColorSelect.BACK, backToPassion);
		}
		
		
		private function backToPassion(e:Event):void
		{
			colorSelect.removeEventListener(ColorSelect.COMPLETE, showGlasses);
			colorSelect.removeEventListener(ColorSelect.BACK, backToPassion);
			colorSelect.hide();
			choosePassion();
		}
		
		
		private function showGlasses(e:Event):void
		{
			colorSelect.removeEventListener(ColorSelect.COMPLETE, showGlasses);
			colorSelect.hide();
			
			challenge.show(bg.getBG());
			challenge.addEventListener(Challenge.COMPLETE, showResults);
			challenge.addEventListener(Challenge.BACK, backToColor);
			
			topContainer.scaleX = topContainer.scaleY = .485;
			topContainer.x = 565;
			topContainer.y = 850;
			
			introLogo.container = topContainer;
			introLogo.show();
		}
		
		private function backToColor(e:Event):void
		{
			introLogo.hide();
			challenge.hide();
			challenge.removeEventListener(Challenge.COMPLETE, showResults);
			challenge.removeEventListener(Challenge.BACK, backToColor);
			showColorSelect();
		}
		
		private function showResults(e:Event):void
		{
			challenge.removeEventListener(Challenge.COMPLETE, showResults);
			challenge.removeEventListener(Challenge.BACK, backToColor);
			introLogo.hide();
			challenge.hide();
			
			var userData:Object = data.entryData; //Object with Gender,MobilePhone,FirstName keys
			userData.DOB = tapToBegin.dob;
			
			results.show(challenge.clicked, passionSelect.passion);//l or r, sports or music
			dataPost.post(challenge.clicked, passionSelect.passion, userData);
			TweenMax.delayedCall(1, showLogoOnPhone);
		}
		
		
		private function showLogoOnPhone():void
		{
			topContainer.scaleX = topContainer.scaleY = .2;
			topContainer.x = 852;
			topContainer.y = 830;
			introLogo.show();
			results.addEventListener(Results.COMPLETE, restart);
		}
		
		
		private function restart(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, restart);
			results.hide();
			introLogo.hide();
			init();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}