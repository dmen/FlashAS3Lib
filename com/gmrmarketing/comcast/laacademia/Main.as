package com.gmrmarketing.comcast.laacademia
{
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import com.gmrmarketing.website.VPlayer;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.display.Loader;
	import com.gmrmarketing.kiosk.*;
	import flash.system.fscommand;
	
	
	public class Main extends MovieClip
	{
		//library clips
		private var glow:glows;
		private var langButtons:buttons;
		private var engButton:buttonCover;
		private var spanButton:buttonCover;
		private var mainLogo:logo;
		
		//button lib clips
		private var btnSmallLogo:small_logo;
		private var btnTv:button_tv;
		private var btnNet:button_internet;
		private var btnPhone:button_phone;
		private var btnGames:button_games;
		
		//corner logos
		private var xfinity:logoXfinity;
		private var comcast:logoComcast;
		
		private var language:String;
		
		private var dsFilter:DropShadowFilter;
		private var redGlow:GlowFilter;
		
		private var vid:VPlayer;
		private var vid2:VPlayer;
		private var vidMenu:videoMenu; //lib clip
		private var vidContainer:MovieClip;
		
		private var gameLoader:Loader;
		
		//set in addVids() - just holds menu name string so the same menu button can't be pressed twice		
		private var curMenu:String = ""; 
		
		private var theIntroText:introText; //text above the main icons on screen 2
		
		private var kiosk:KioskHelper;
		private var touch:touchToBegin; //library clip
		
		public function Main()
		{
			fscommand("fullscreen", "true");
			fscommand("allowscale", "false");
			
			kiosk = KioskHelper.getInstance();
			kiosk.attractInit(this.stage, 120000);
			kiosk.addEventListener(KioskEvent.START_ATTRACT, showAttractVideo, false, 0, true);
			kiosk.fourCornerInit(this); //defaults to upper left
			kiosk.addEventListener(KioskEvent.FOUR_CLICKS, quit);
			
			dsFilter = new DropShadowFilter(0, 0, 0x000000, 1, 10, 10, 1, 2, false);
			redGlow = new GlowFilter(0xFF0000, 1, 10, 10, 2, 2, false, false);
			
			//icon buttons
			btnSmallLogo = new small_logo();
			btnTv = new button_tv();
			btnNet = new button_internet();
			btnPhone = new button_phone();
			btnGames = new button_games();
			
			btnSmallLogo.filters = [dsFilter];
			btnTv.filters = [dsFilter];
			btnNet.filters = [dsFilter];
			btnPhone.filters = [dsFilter];
			btnGames.fitlers = [dsFilter];
			
			theIntroText = new introText();
			theIntroText.x = 25;
			
			
			//screen items
			glow = new glows();
			mainLogo = new logo();
			langButtons = new buttons();
			engButton = new buttonCover();
			spanButton = new buttonCover();
			
			//corner logos
			xfinity = new logoXfinity();
			comcast = new logoComcast();
			
			mainLogo.x = 48;
			mainLogo.y = -13;
			
			engButton.x = 400;
			engButton.y = 650;
			engButton.alpha = 0;
			
			spanButton.x = 712;
			spanButton.y = 650;
			spanButton.alpha = 0;
			
			langButtons.x = 364;
			langButtons.y = 620;
			
			xfinity.x = 38;
			xfinity.y = 24;
			
			comcast.x = 1105;
			comcast.y = 37;
			
			vid = new VPlayer();
			vid2 = new VPlayer();
			vid.autoSizeOn();
			
			vidContainer = new videoContainer();			
			vidMenu = new videoMenu();
			
			gameLoader = new Loader();
			
			touch = new touchToBegin();
			touch.x = 280;
			touch.y = 34;
			
			buildIntroScreen();
		}
		
		
		private function buildIntroScreen():void
		{
			addChild(glow);
			addChild(mainLogo);
			
			addChild(langButtons);
			
			addChild(engButton);
			addChild(spanButton);
			
			addChild(xfinity);
			addChild(comcast);
			
			glow.alpha = 0;
			mainLogo.alpha = 0;
			langButtons.alpha = 0;
			xfinity.alpha = 0;
			comcast.alpha = 0;
			
			TweenLite.to(glow, 2, { alpha:1 } );
			TweenLite.to(mainLogo, 2, { alpha:1, delay:.5 } );
			TweenLite.to(xfinity, 2, { alpha:1, delay:1 } );
			TweenLite.to(comcast, 2, { alpha:1, delay:1 } );
			TweenLite.to(langButtons, 1, { alpha:1, delay:1.5, onComplete:enableButtons } );
			
			kiosk.moveToTop();
		}
		
		
		/**
		 * Called from returnToMain() and spinnerLoaded()
		 */
		private function resetIconButtons():void
		{			
			justShadows();
			
			btnSmallLogo.scaleX = btnSmallLogo.scaleY = 1;
			if (contains(btnSmallLogo)) { removeChild(btnSmallLogo); }
			btnTv.scaleX = btnTv.scaleY = 1;
			if (contains(btnTv)) { removeChild(btnTv); }
			btnNet.scaleX = btnNet.scaleY = 1;
			if (contains(btnNet)) { removeChild(btnNet); }
			btnPhone.scaleX = btnPhone.scaleY = 1;
			if (contains(btnPhone)) { removeChild(btnPhone); }
			if (contains(btnGames)) { removeChild(btnGames); }
			if (contains(theIntroText)) { removeChild(theIntroText); }
			btnSmallLogo.removeEventListener(MouseEvent.CLICK, returnToMain);
			
			btnTv.removeEventListener(MouseEvent.CLICK, showTV);
			btnTv.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
			
			btnNet.removeEventListener(MouseEvent.CLICK, showNet);
			btnNet.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
			
			btnPhone.removeEventListener(MouseEvent.CLICK, showPhone);
			btnPhone.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
		}
		
		
		private function enableButtons():void
		{
			engButton.addEventListener(MouseEvent.CLICK, englishClicked, false, 0, true);
			spanButton.addEventListener(MouseEvent.CLICK, spanishClicked, false, 0, true);
		}
		
		
		private function englishClicked(e:MouseEvent):void
		{
			engButton.removeEventListener(MouseEvent.CLICK, englishClicked);
			language = "en";
			clearIntroScreen();
			buildMainButtons();
		}
		
		
		private function spanishClicked(e:MouseEvent):void
		{
			spanButton.removeEventListener(MouseEvent.CLICK, spanishClicked);
			language = "sp";
			clearIntroScreen();
			buildMainButtons();
		}
		
		
		/**
		 * Called by clicking a language button
		 */
		private function clearIntroScreen():void
		{
			if(contains(engButton)){
				removeChild(engButton);
				removeChild(spanButton);			
				removeChild(langButtons);
			}
			if(contains(mainLogo)){
				removeChild(mainLogo);
				removeChild(glow);
			}
		}		
		
		
		/**
		 * add buttons to the secondary screen
		 * This is the main 'menu' screen with the big section buttons in the middle
		 */
		private function buildMainButtons():void
		{
			addChild(btnSmallLogo);
			addChild(btnTv);
			addChild(btnNet);
			addChild(btnPhone);			
			
			addChild(theIntroText);
			theIntroText.alpha = 0;
			if (language == "en") {
				theIntroText.theText.text = "To learn about our products touch the corresponding icon";
				theIntroText.y = 194;
			}else {
				theIntroText.theText.htmlText = "Para obtener más información sobre nuestros productos,<br/>toca el icono correspondiente";
				theIntroText.y = 180;
			}
			TweenLite.to(theIntroText, 2, { alpha:1 } );
			
			btnSmallLogo.x = 1400;
			btnSmallLogo.y = 283;
			
			btnTv.x = 1400;
			btnTv.y = 283;
			
			btnNet.x = 1400;
			btnNet.y = 283;
			
			btnNet.x = 1400;
			btnNet.y = 283;
			
			btnPhone.x = 1400;
			btnPhone.y = 283;
			
			TweenLite.to(btnSmallLogo, .5, { x:256 } );
			TweenLite.to(btnTv, .5, { x:490, delay:.25 } );
			TweenLite.to(btnNet, .5, { x:707, delay:.5 } );
			TweenLite.to(btnPhone, .5, { x:927, delay:.75, onComplete:enableMainButtons } );
		}
		
		
		/**
		 * Enables the buttons on the main icon menu screen
		 */
		private function enableMainButtons():void
		{
			btnSmallLogo.addEventListener(MouseEvent.CLICK, returnToMain, false, 0, true);
			
			btnTv.addEventListener(MouseEvent.CLICK, showTV, false, 0, true);
			btnTv.addEventListener(MouseEvent.CLICK, moveButtonsDown, false, 0, true);
			
			btnNet.addEventListener(MouseEvent.CLICK, showNet, false, 0, true);
			btnNet.addEventListener(MouseEvent.CLICK, moveButtonsDown, false, 0, true);
			
			btnPhone.addEventListener(MouseEvent.CLICK, showPhone, false, 0, true);
			btnPhone.addEventListener(MouseEvent.CLICK, moveButtonsDown, false, 0, true);
		}
		
		private function returnToMain(e:MouseEvent = null):void
		{
			curMenu = "";
			clearVid();
			resetIconButtons();
			spinDone();
		}
		
		private function moveButtonsDown(e:MouseEvent):void
		{
			//remove introText
			TweenLite.to(theIntroText, 1, { alpha:0, onComplete:removeIntroText } );
			
			TweenLite.to(btnSmallLogo, 1, {x:424, y:643, scaleX:.5, scaleY:.5 } );
			TweenLite.to(btnTv, 1, {x:539, y:643, scaleX:.5, scaleY:.5 } );
			TweenLite.to(btnNet, 1, {x:649, y:643, scaleX:.5, scaleY:.5 } );
			TweenLite.to(btnPhone, 1, {x:759, y:643, scaleX:.5, scaleY:.5, onComplete:showGamesButton } );
		}
		
		private function removeIntroText():void
		{
			if(contains(theIntroText)){
				removeChild(theIntroText);
			}
		}
		
		/**
		 * Called from moveButtonsDown() once buttons are at the bottom
		 * Adds the games button
		 * Removes the moveButtonsDown listeners from the buttons
		 */
		private function showGamesButton():void
		{
			addChild(btnGames);
			btnGames.x = 869;
			btnGames.y = 643;
			btnGames.alpha = 0;
			TweenLite.to(btnGames, 1, { alpha:1 } );
			btnGames.addEventListener(MouseEvent.CLICK, showGames, false, 0, true);
			
			//remove listeners to move buttons down
			btnTv.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
			btnNet.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
			btnPhone.removeEventListener(MouseEvent.CLICK, moveButtonsDown);
		}
		

		/**
		 * Removes red highlight glow from all buttons
		 */
		private function justShadows():void
		{
			btnTv.filters = [dsFilter];
			btnNet.filters = [dsFilter];
			btnPhone.filters = [dsFilter];
			btnGames.filters = [dsFilter];
		}
		
		
		private function showTV(e:MouseEvent):void
		{
			justShadows();
			removeVid();
			removeMatchGame();
			btnTv.filters = [redGlow, dsFilter];
			addVids("tv");
		}
		
		
		private function showNet(e:MouseEvent):void
		{
			justShadows();
			removeVid();
			removeMatchGame();
			btnNet.filters = [redGlow, dsFilter];
			addVids("net");
		}
		
		
		private function showPhone(e:MouseEvent):void
		{
			justShadows();
			removeVid();
			removeMatchGame();
			btnPhone.filters = [redGlow, dsFilter];
			addVids("phone");
		}
		
		
		private function showGames(e:MouseEvent):void
		{
			if(curMenu != "games"){
				curMenu = "games";
				
				justShadows();
				removeVid();
				btnGames.filters = [redGlow, dsFilter];
				loadMatch();
			}
		}
		
		
		private function addVids(which:String = ""):void
		{
			if (curMenu != which) {
					
				curMenu = which;
				
				addChild(vidMenu);
				vidMenu.x = 330;
				vidMenu.y = 135;
				vidMenu.alpha = 0;
				
				vidMenu.theText.autoSize = TextFieldAutoSize.LEFT;
				
				//remove old thumbs
				if (vidMenu.v1.thumbHolder.numChildren > 1) {
					vidMenu.v1.thumbHolder.removeChildAt(1); //index 0 is the gray bg shape
				}
				if (vidMenu.v2.thumbHolder.numChildren > 1) {
					vidMenu.v2.thumbHolder.removeChildAt(1); //index 0 is the gray bg shape
				}
				
				TweenLite.to(vidMenu, 1, { alpha:1 } );
				switch(which) {
					case "tv":
						if(language == "en"){
							vidMenu.theTitle.text = "On Demand";
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>Sit back and soak up a huge collection of entertainment to play as you please.</li><li>Get thousands of choices including premium movies, shows, kids’ programs, videos, and more, including early premieres.</li><li>Watch newly released movies for about the same price as the video store.</li><li>Enjoy TV on your schedule.</li></ul>";					
						}else {
							vidMenu.theTitle.text = "On Demand";
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>Toma asiento, relájate y explora la enorme colección de entretenimiento que tienes a tu disposición en el momento que desees.</li><li>Obtén miles de opciones, incluyendo las mejores películas, series, programación infantil, videos y más, incluyendo preestrenos.</li><li>Obtén cientos de opciones en español, incluyendo contenido exclusivo de Univisión, Telemundo, GolTV y más.</li><li>Ve películas estrenadas recientemente disponibles el mismo día que sale a la venta el DVD, ¡y dobladas al español!</li><li>Disfruta la televisión en tus propios horarios.</li></ul>";					
						}
						//video thumbnails
						vidMenu.v1.theVideo = "ondemand2.mp4";
						vidMenu.v2.theVideo = "ondemand1.mp4";
						
						vidMenu.v1.thumbHolder.addChild(new ondemandthumb2());
						vidMenu.v2.thumbHolder.addChild(new ondemandthumb1());
						
						break;
					case "net":
						if(language == "en"){
							vidMenu.theTitle.text = "Incredibly fast speed";
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>Watch streaming HD movies online</li><li>Dominate games with less lag.</li><li>Download music and upload photos in the blink of an eye with PowerBoost.</li><li>Get blazing fast connections—even with the whole family online at the same time.</li></ul>";
						}else {
							vidMenu.theTitle.text = "Velocidades increíblemente rápidas";						
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>Recibe la velocidad de Internet adecuada para tu familia en nuestra poderosa y avanzada red de fibra óptica.</li><li>Ve películas de alta definición de transmisión continua en línea.</li><li>Domina tus juegos favoritos con menos retrasos.</li><li>Descarga música y carga fotos en un abrir y cerrar de ojos con PowerBoost.</li><li>Conéctate a velocidades ultrarrápidas, incluso cuando toda la familia está en línea al mismo tiempo.</li></ul>";
						}
						//video thumbnails
						vidMenu.v1.theVideo = "internet1.mp4";
						vidMenu.v2.theVideo = "internet2.mp4";
						
						vidMenu.v1.thumbHolder.addChild(new vidThumb_internet1());
						vidMenu.v2.thumbHolder.addChild(new vidThumb_internet1());
						
						break;
					case "phone":
						if(language == "en"){
							vidMenu.theTitle.text = "International Calling";
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>Keep in touch with loved ones near, far, and really far… for less.</li><li>Enjoy low everyday minute-by-minute rates to over 200 countries around the world.</li><li>Sign up for our International Carefree Minutes™ plans and get 100 anytime minutes to use within the regions you call the most. Choose from plans to Asia, Latin America, Western Europe, and Mexico.</li></ul>";
						}else {
							vidMenu.theTitle.text = "Planes de Llamadas Internacionales";
							vidMenu.theSubTitle.text = "";
							vidMenu.theText.htmlText = "<ul><li>También ofrecemos llamadas internacionales para que puedas mantenerte en comunicación con tus seres queridos, no importa si se encuentran cerca, lejos o muy lejos... todo pagando menos.</li><li>Tarifas bajas para llamar a más de 200 países de todo el mundo para ayudar a que te mantengas en comunicación con tu familia y amigos, ya sea que se encuentren cerca o lejos.</li><li>Habla con tus seres queridos desde la comodidad de tu hogar con el plan de tarifas fijas que mejor se ajuste a tus necesidades.</li></ul>";
						}
						//video thumbnails
						vidMenu.v1.theVideo = "intcall2.mp4";
						vidMenu.v2.theVideo = "intcall1.mp4";
						
						vidMenu.v1.thumbHolder.addChild(new intCallThumb2());
						vidMenu.v2.thumbHolder.addChild(new intCallThumb1());
						break;
				}
				
				vidMenu.v1.addEventListener(MouseEvent.CLICK, playVid, false, 0, true);
				vidMenu.v2.addEventListener(MouseEvent.CLICK, playVid, false, 0, true);
			}
			
		}
		
		
		private function playVid(e:MouseEvent):void
		{		
			if (!contains(vidContainer)) {
				addChild(vidContainer);
				vidContainer.x = 313;
				vidContainer.y = 112;
				vidContainer.alpha = 0;
				TweenLite.to(vidContainer, 1, { alpha:1 } );
			}
			vid.showVideo(vidContainer.holder);
			
			vid.playVideo("videos\\" + e.currentTarget.theVideo);
			vid.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);
		}
		
		
		private function removeVid():void
		{
			vid.hideVideo(); //removes vid from container
			TweenLite.to(vidContainer, 1, { alpha:0, onComplete:removeVidContainer } );
		}
		
		
		private function removeVidContainer():void
		{
			if(contains(vidContainer)){
				removeChild(vidContainer);
			}
		}
		
		
		private function vidStatus(e:Event):void
		{
			if (vid.getStatus() == "NetStream.Play.Stop") {
				removeVid();
			}
		}
		
		
		private function clearVid():void
		{
			if (contains(vidContainer)) {
				vid.hideVideo();
				removeChild(vidContainer);
			}
			if (contains(vidMenu)) {
				vidMenu.v1.removeEventListener(MouseEvent.CLICK, playVid);
				vidMenu.v2.removeEventListener(MouseEvent.CLICK, playVid);
				removeChild(vidMenu);
			}
		}
		
		
		private function removeMatchGame():void
		{
			if(contains(gameLoader)){
				MovieClip(gameLoader.content).stopGame();
				gameLoader.unload();
				removeChild(gameLoader);
			}
		}
		
		
		private function loadMatch():void
		{
			clearVid();			
			gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, matchLoaded, false, 0, true);
			gameLoader.load(new URLRequest("match.swf"));
		}
		
		
		private function matchLoaded(e:Event):void
		{
			gameLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, matchLoaded);
			addChild(gameLoader);
			gameLoader.alpha = 0;
			MovieClip(gameLoader.content).setLanguage(language);
			TweenLite.to(gameLoader, 2, { alpha:1 } );
			gameLoader.content.addEventListener("continueButtonClicked", loadSpinner, false, 0, true);
		}
		
		
		private function loadSpinner(e:Event):void 
		{
			removeMatchGame();
			clearVid();
			gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, spinnerLoaded, false, 0, true);
			gameLoader.load(new URLRequest("spinner.swf"));
		}
		
		
		private function spinnerLoaded(e:Event):void
		{
			resetIconButtons();
			
			gameLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, spinnerLoaded);
			addChild(gameLoader);
			gameLoader.alpha = 0;
			MovieClip(gameLoader.content).setLanguage(language);
			TweenLite.to(gameLoader, 2, { alpha:1 } );
			gameLoader.content.addEventListener("continueButtonClicked", spinDone, false, 0, true);
		}
		
		
		private function spinDone(e:Event = null):void
		{
			removeMatchGame();
			buildIntroScreen();
		}
		
		
		private function showAttractVideo(e:KioskEvent = null):void
		{	
			clearIntroScreen();
			resetIconButtons();
			clearVid(); //
			removeMatchGame();
			
			kiosk.attractStop();		
			vid2.autoSizeOff();
			vid2.setVidSize( { width:1366, height:768 } );
			vid2.showVideo(this);			
			vid2.playVideo("videos\\attractor.mp4");
			stage.addEventListener(MouseEvent.CLICK, closeAttractor, false, 0, true);			
			vid2.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus2, false, 0, true);
			
			touch.alpha = 0;
			addChild(touch);
			TweenLite.to(touch, 1, { alpha:1 } );
		}
		
		
		private function vidStatus2(e:Event):void
		{
			//trace(vid2.getStatus());
			if (vid2.getStatus() == "NetStream.Play.Stop") {				
				vid2.playVideo("videos\\attractor.mp4");
			}
		}
		
		
		private function closeAttractor(e:MouseEvent):void
		{
			vid2.removeEventListener(VPlayer.STATUS_RECEIVED, vidStatus2);
			
			removeChild(touch);
			
			vid2.stopVideo();
			vid2.hideVideo();
			
			stage.removeEventListener(MouseEvent.CLICK, closeAttractor);
			
			returnToMain();
			kiosk.attractStart();
		}
		
		
		private function quit(e:KioskEvent):void
		{
			fscommand("quit");
		}
	}
	
}