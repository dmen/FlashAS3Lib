/**
 * Document class for Banshee.fla
 */

 
package com.gmrmarketing.banshee
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.text.TextFieldAutoSize;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Bitmap;
	
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;

	import flash.media.Sound;
    import flash.media.SoundLoaderContext;
    import flash.events.IOErrorEvent;
	import flash.media.SoundChannel;


	public class Banshee extends MovieClip 
	{
		private var xmlLoader:URLLoader;		
		private var bansheeData:XML;
		
		private var dotHolder:Sprite;
		private var dotTimer:Timer;
		private var whiteTimer:Timer;
		
		private var xc:int; //center of play button
		private var yc:int;
		private var ang:Number;
		private var numCircles:int = 24;
		private var angStep:Number;
		private var radius:int;
		private var animateBuild:Boolean; //used by page 1 - animates when coming intro, not from page 2
		private var imLoader:Loader;
		private var caseStudyImageLoader:Loader; //used for the case study image only
		
		//library clips
		private var logo:bansheeLogo;
		private var theText:introText;
		private var blackBG:blackBackground;
		private var btnPlay:btnForward;
		private var btnRewind:btnBack;
		private var whiteBars:whiteSlashes;
		private var blackBars:blackSlashes;
		//p1
		private var blackBars2:blackSlashes;		
		private var sideMenu:sideBar;
		private var p1Text:page1Text;
		//p2		
		private var p2TitleText:page2Title;
		//p3
		private var p3TitleText:page3Title;
		private var actMenu:activationMenu;
		private var pricingText:activationPricing;
		private var details:activationDetails;
		private var hoLine:hLine;
		private var idealHolder:Sprite = new Sprite();
		
		private var soundDot:dotSound;
		private var playDot:Boolean;
		
		private var bulArray:Array = new Array(); //contains bullet instances - for easy removal
		private var currentPage2Bullet:int = -1;		
		private var currentPage3Menu:int = -1;
		private var currentPage3Bullet:int = -1;
		private var page3Bulls:XMLList;
		
		private var soundFiles:Array = new Array(); //files defined in the loopingsound section of the XML		
		private var channel:SoundChannel = new SoundChannel();
		private var context:SoundLoaderContext;
		private var soundCount:int = 0; //index in the soundFiles array
		private var soundStarted:Boolean = false;
		private var soundPosition:Number = 0; //used to record current position when pausing
		private var soundIsPlaying:Boolean = false;
		
		public function Banshee()
		{
			TweenPlugin.activate([ColorTransformPlugin]);
			stage.align = StageAlign.TOP;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			context = new SoundLoaderContext(3000, false); //buffer for 3 seconds before beginning play
			
			xmlLoader = new URLLoader();
			imLoader = new Loader();
			caseStudyImageLoader = new Loader();
			caseStudyImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fadeInCaseStudyLoader, false, 0, true);
			
			blackBars2 = new blackSlashes();			
			sideMenu = new sideBar();
			p1Text = new page1Text();
			
			blackBG = new blackBackground();
			logo = new bansheeLogo();
			theText = new introText();
			btnPlay = new btnForward();
			btnRewind = new btnBack();
			whiteBars = new whiteSlashes();
			blackBars = new blackSlashes();
			
			soundDot = new dotSound();
			
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.load(new URLRequest("banshee.xml"));
			
			addChild(blackBG);
			addChild(logo);			
			addChild(theText);
			addChild(btnPlay);
			addChild(whiteBars);
			addChild(blackBars);
			whiteBars.x = -38;
			whiteBars.y = 440;
			blackBars.x = -48;
			blackBars.y = 512;
			
			TweenLite.to(logo, 0, { x:480, y:68, colorTransform: { brightness:.5 }} );
			TweenLite.to(theText, 0, { x:2, y:130, colorTransform: { brightness:.5 }} );
			TweenLite.to(btnPlay, 0, {x:452, y:291, colorTransform:{brightness:.5}});
			
			dotHolder = new Sprite();
			
			//draw dots around play button
			xc = Math.round(btnPlay.x + (btnPlay.width / 2))-1;
			yc = Math.round(btnPlay.y + (btnPlay.height / 2))-1;			
			
			angStep = Math.PI * 2 / numCircles;
			radius = btnPlay.width / 2 + 12;
			
			addChild(dotHolder);
			
			playDot = false; //no music first time around
			dotHolder.graphics.beginFill(0x555555); //gray dots
			ang = 0;
			dotTimer = new Timer(1, numCircles);
			dotTimer.addEventListener(TimerEvent.TIMER, addDot, false, 0, true);
			dotTimer.addEventListener(TimerEvent.TIMER_COMPLETE, whiteDots, false, 0, true);
			dotTimer.start();
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			bansheeData = new XML(e.target.data);
			var soundList:XMLList = bansheeData.loopingsound.file;
			for (var i = 0; i < soundList.length(); i++) {
				soundFiles.push(soundList[i]);
			}
		}
		
		
		/**
		 * Places a radius 2 circle at the current angle around the play button loc (xc, yc)
		 * Called by timer
		 * @param	e
		 */
		private function addDot(e:TimerEvent):void
		{			
			if (playDot) {
				soundDot.play();
			}
			dotHolder.graphics.drawCircle(xc + Math.cos(ang) * radius, yc + Math.sin(ang) * radius, 2);
			ang += angStep;
		}
		
		
		private function whiteDots(e:TimerEvent):void
		{			
			dotTimer.removeEventListener(TimerEvent.TIMER, addDot);
			dotTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, whiteDots);
			
			dotHolder.graphics.beginFill(0xFFFFFF);
			
			ang = 0;
			playDot = true; //turn on music
			whiteTimer = new Timer(70, numCircles);
			whiteTimer.addEventListener(TimerEvent.TIMER, addDot, false, 0, true);
			whiteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, allWhite, false, 0, true);
			whiteTimer.start();
		}
		
		
		private function allWhite(e:TimerEvent):void
		{
			whiteTimer.removeEventListener(TimerEvent.TIMER, addDot);
			whiteTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, allWhite);
			
			TweenLite.to(logo, .25, { colorTransform: { brightness:1 }} );
			TweenLite.to(theText, .25, { colorTransform: { brightness:1 }} );
			TweenLite.to(btnPlay, .25, { colorTransform: { brightness:1 }} );
			
			btnPlay.addEventListener(MouseEvent.CLICK, showPage1, false, 0, true);
			btnPlay.buttonMode = true;
			animateBuild = true;
			var pb:playBeep = new playBeep(); //library sound
			pb.play();
		}
		
		
		private function playNextSong(pos:Number = 0):void
		{
			var req:URLRequest = new URLRequest(soundFiles[soundCount]);						
			var snd:Sound = new Sound();
			snd.load(req, context);
            channel = snd.play(pos);
			soundIsPlaying = true;
            snd.addEventListener(IOErrorEvent.IO_ERROR, soundLoadError, false, 0, true);
			channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler, false, 0, true);
		}
		
		
		private function soundCompleteHandler(e:Event):void
		{
			soundCount++;
			if (soundCount >= soundFiles.length) {
				soundCount = 0;
			}
			playNextSong();
		}
		
		
		private function soundLoadError(e:IOErrorEvent):void
		{
			soundCount++;
			if (soundCount >= soundFiles.length) {
				soundCount = 0;
			}
			playNextSong();
		}
		
		
		/**
		 * Called from the sound stop button
		 * @param	e CLICK MouseEvent
		 */
		private function pauseSound(e:MouseEvent):void
		{
			soundPosition = channel.position;
			channel.stop();
			soundIsPlaying = false;
		}
		
		
		/**
		 * Called from the music play button
		 * @param	e CLICK MouseEvent
		 */
		private function playSound(e:MouseEvent):void
		{			
			if(!soundIsPlaying){
				playNextSong(soundPosition);
			}
		}
		
		
		/**
		 * Tweens imLoader's alpha to 1
		 * @param	e
		 */
		private function fadeInImageLoader(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}			
			imLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fadeInImageLoader);
			TweenLite.to(imLoader, 1, { alpha:1 } );
		}
		
		
		/**
		 * This is for page 3 images
		 * @param	e
		 */
		private function fadeInImageLoader2(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}			
			imLoader.x = 460 + ((480 - imLoader.width) * .5);
			TweenLite.to(imLoader, 1, { alpha:1 } );
		}
		
		private function fadeInCaseStudyLoader(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}			
			TweenLite.to(caseStudyImageLoader, 1, { alpha:1 } );
			
		}
		
		public function clearIntro():void
		{			
			if(contains(dotHolder)){
				dotHolder.graphics.clear();
				removeChild(dotHolder);
				removeChild(logo);
				removeChild(theText);
				removeChild(btnPlay);
				removeChild(whiteBars);
				removeChild(blackBars);
				removeChild(blackBG);
			}		
		}
		
		
		private function clearPage1():void
		{
			if(contains(p1Text)){
				removeChild(p1Text);
			}
		}
		
		
		private function clearPage2():void
		{			
			if(p2TitleText != null){
				if (contains(p2TitleText)) {
					removeChild(p2TitleText);
				}
			}
			
			while (bulArray.length > 0) {
				var o:Sprite = bulArray.splice(0, 1)[0];
				removeChild(o);
				o.removeChild(o.getChildByName("bulletBox"));
				while (o.numChildren > 0) {
					o.removeChildAt(0);
				}
				o = null;
			}
		}
		
		
		private function clearPage3():void
		{
			caseStudyImageLoader.unload();
			
			if(p3TitleText != null){
				if (contains(p3TitleText)) {
					removeChild(p3TitleText);
				}
			}			
			if (actMenu != null) {
				if (contains(actMenu)) {
					removeChild(actMenu);
				}
				actMenu.b1.gotoAndStop(1);
				actMenu.b2.gotoAndStop(1);
				actMenu.b3.gotoAndStop(1);
				actMenu.b4.gotoAndStop(1);			
			}			
			
			if (hoLine != null) {
				if (contains(hoLine)) {
					removeChild(hoLine);
				}
			}
			if (pricingText != null) {
				if (contains(pricingText)) {
					removeChild(pricingText);
				}
			}
			if (details != null) {
				if (contains(details)) {
					removeChild(details);
				}
			}
			clearPage3Bullets();
		}

		/**
		 * Clears the upper and lower bullets
		 */
		private function clearPage3Bullets():void
		{
			while (bulArray.length > 0) {
				var o:Sprite = bulArray.splice(0, 1)[0];
				removeChild(o);			
				o = null;
			}
			while (idealHolder.numChildren > 0) {
				idealHolder.removeChildAt(0);
			}
			if(contains(idealHolder)){
				removeChild(idealHolder);
			}
		}
		
		
		private function showPage1(e:MouseEvent):void
		{
			btnPlay.removeEventListener(MouseEvent.CLICK, showPage1);
			btnPlay.removeEventListener(MouseEvent.CLICK, showPage3);
			btnPlay.addEventListener(MouseEvent.CLICK, showPage2, false, 0, true);
			
			if (!soundStarted) {
				playNextSong();
				soundStarted = true;
			}
			
			if (contains(btnRewind)) { removeChild(btnRewind); }
			
			clearIntro();
			clearPage2();
			
			if(!contains(sideMenu)){
				addChild(sideMenu);
				sideMenu.y = 37;
				sideMenu.x = 0 - sideMenu.width; //begin off left side
			}
			sideMenu.musicOn.addEventListener(MouseEvent.CLICK, playSound, false, 0, true);
			sideMenu.musicOff.addEventListener(MouseEvent.CLICK, pauseSound, false, 0, true);
			sideMenu.musicOn.buttonMode = true;
			sideMenu.musicOff.buttonMode = true;
			
			if(!contains(blackBars)){
				addChild(blackBars);
				addChild(blackBars2);
				blackBars.x = -49;
				blackBars2.x = -49;
				blackBars.y = 0 - blackBars.height;
				blackBars2.y = stage.height + 5
			}
			
			if(!contains(imLoader)){
				addChild(imLoader);
			}
			imLoader.load(new URLRequest(bansheeData.images.page1));
			imLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fadeInImageLoader, false, 0, true);
			imLoader.x = 252;
			imLoader.y = 53;
			imLoader.alpha = 0;
			
			addChild(p1Text);
			p1Text.y = 361;
			p1Text.x = stage.width + 5;
			
			if(!contains(btnPlay)){
				addChild(btnPlay);
			}
			btnPlay.width = btnPlay.height = 25;
			btnPlay.x = 925;
			btnPlay.y = 528;
			btnPlay.alpha = 0;
			
			if (animateBuild) {
				var tr:transition = new transition(); //library sound
				tr.play();
				TweenLite.to(sideMenu, 1, { x:0 } );
				TweenLite.to(blackBars, 1, { y: -60 } );
				TweenLite.to(blackBars2, 1, { y:560 } );
				TweenLite.to(p1Text, 1, { x:247 } );			
				TweenLite.to(btnPlay, .5, { alpha:1 } );
			}else {
				sideMenu.x = 0;
				blackBars.y = -60;
				blackBars2.y = 560;
				p1Text.x = 247;
				btnPlay.alpha = 1;				
			}			
		}
		
		
		
		private function showPage2(e:MouseEvent):void
		{			
			clearPage1();
			clearPage3();
			
			btnRewind.removeEventListener(MouseEvent.CLICK, showPage2);
			btnPlay.removeEventListener(MouseEvent.CLICK, showPage2);
			btnPlay.addEventListener(MouseEvent.CLICK, showPage3, false, 0, true);
			
			if(!contains(btnRewind)){
				addChild(btnRewind);

			}
			if(!contains(btnPlay)){
				addChild(btnPlay);
			}			
			animateBuild = false; //dont animate p1 when coming from p2
			btnRewind.addEventListener(MouseEvent.CLICK, showPage1, false, 0, true);
			btnRewind.width = btnRewind.height = 25;
			btnRewind.buttonMode = true;
			btnRewind.x = 895;
			btnRewind.y = 528;			
			
			imLoader.load(new URLRequest(bansheeData.images.page2));
			imLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fadeInImageLoader2);	
			imLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fadeInImageLoader, false, 0, true);			
			imLoader.x = 234;
			imLoader.y = 80;
			imLoader.alpha = 0;
			
			p2TitleText = new page2Title();
			addChild(p2TitleText);
			p2TitleText.x = 232;
			p2TitleText.y = 38;
			
			//get objectives from XML
			var obj:XMLList = bansheeData.page2.objective;			
			var objLength:int = obj.length();
			var startY:int = 80;
			
			bulArray = new Array();
			
			for (var i:int = 0; i < objLength; i++) {
				var objective:XML = obj[i];				
				var s:Sprite = new Sprite();				
				var buls:Sprite = new Sprite(); //bullet container
				buls.name = "bulletBox";
				buls.alpha = 0;
				var ob:objectiveButton = new objectiveButton();
				s.addChild(ob);
				ob.index = i;
				ob.buttonMode = true;
				ob.name = "button";
				ob.addEventListener(MouseEvent.CLICK, p2ObjectiveClick, false, 0, true);
				var ot:objectiveTitle = new objectiveTitle();
				s.addChild(ot);
				ot.x = 30;
				ot.theText.text = objective.@title;
				s.addChild(buls);
				var bullets:XMLList = objective.bullet;
				for (var j:int = 0; j < bullets.length(); j++) {
					var bul:objectiveBullet = new objectiveBullet();
					bul.theText.autoSize = TextFieldAutoSize.LEFT;
					bul.theText.wordWrap = false;
					bul.theText.text = objective.bullet[j];					
					buls.addChild(bul);
					bul.x = 40;
					bul.y = 15 + (j * 11);					
				}
				
				addChild(s);
				s.x = 536,
				s.y = startY;
				
				startY += s.height + 3;
				
				//add each objective to array for clearing
				bulArray.push(s);
			}
		}
		
		
		/**
		 * Called when one of the arrow buttons, next to an objective, are clicked
		 * Hides previous bullet and shows clicked one
		 * @param	e
		 */
		private function p2ObjectiveClick(e:MouseEvent):void
		{
			if (currentPage2Bullet != -1) {
				bulArray[currentPage2Bullet].getChildByName("button").gotoAndStop(1);
				bulArray[currentPage2Bullet].getChildByName("bulletBox").alpha = 0;
			}
			currentPage2Bullet = e.currentTarget.index;
			e.currentTarget.gotoAndStop(2);
			bulArray[currentPage2Bullet].getChildByName("bulletBox").alpha = 1;
			
		}
		
		
		
		private function showPage3(e:MouseEvent):void
		{			
			clearPage2();
			
			btnRewind.removeEventListener(MouseEvent.CLICK, showPage1);
			btnRewind.addEventListener(MouseEvent.CLICK, showPage2, false, 0, true);
			removeChild(btnPlay);
			
			imLoader.unload();
			imLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fadeInImageLoader);
			imLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fadeInImageLoader2, false, 0, true);		
			imLoader.y = 115;
			
			if(p3TitleText == null){
				p3TitleText = new page3Title();
			}
			addChild(p3TitleText);
			p3TitleText.x = 232;
			p3TitleText.y = 38;
			
			if(pricingText == null){
				pricingText = new activationPricing();
			}
			addChild(pricingText);
			pricingText.x = 235;
			pricingText.y = 104;
			pricingText.theText.text = "";
			
			if(actMenu == null){
				actMenu = new activationMenu();
			}
			addChild(actMenu);
			actMenu.x = 234;
			actMenu.y = 73;
			actMenu.b1.index = 1;
			actMenu.b2.index = 2;
			actMenu.b3.index = 3;
			actMenu.b4.index = 4;
			actMenu.b1.buttonMode = true;
			actMenu.b2.buttonMode = true;
			actMenu.b3.buttonMode = true;
			actMenu.b4.buttonMode = true;
			actMenu.b1.addEventListener(MouseEvent.CLICK, actMenuClicked, false, 0, true);
			actMenu.b2.addEventListener(MouseEvent.CLICK, actMenuClicked, false, 0, true);
			actMenu.b3.addEventListener(MouseEvent.CLICK, actMenuClicked, false, 0, true);
			actMenu.b4.addEventListener(MouseEvent.CLICK, actMenuClicked, false, 0, true);
			
			actMenuClicked();
		}
		
		
		/**
		 * Called by clicking one of the activation menu buttons - CDs, Digital, Music Licensing, Case Studies		 
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function actMenuClicked(e:MouseEvent = null):void
		{	
			currentPage3Bullet = -1;
			imLoader.unload();
			if (details != null) {
				details.theText.htmlText = "";
			}
			if (currentPage3Menu != -1) {
				//prior menu item clicked
				actMenu["b" + currentPage3Menu].gotoAndStop(1);
				clearPage3Bullets();
			}			
			
			if (e == null) {
				currentPage3Menu = 1;
				actMenu.b1.gotoAndStop(2);
			}else {
				e.currentTarget.gotoAndStop(2);
				currentPage3Menu = e.currentTarget.index; //1 - 4
			}
			
			var p3Section:String;
			switch(currentPage3Menu) {
				case 1:
					p3Section = "CDs";
					break;
				case 2:
					p3Section = "Digital";
					break;
				case 3:
					p3Section = "Music Licensing";
					break;
				case 4:
					p3Section = "Case Studies";					
					break;
			}
			
			var sectionXML:XMLList = bansheeData.page3.section.(@name == p3Section);
			
			if (p3Section != "Case Studies") {
				
				caseStudyImageLoader.unload();
				
				var idealFit:XMLList = sectionXML.idealfit.bullet;
				if (!contains(idealHolder)) {
					addChild(idealHolder);
				}
				if (hoLine == null) {
					hoLine = new hLine();
				}
				if (!contains(hoLine)) {
					addChild(hoLine);
					hoLine.x = 237;
					hoLine.y = 431;
				}
				
				var anIdealText:anIdealFitText = new anIdealFitText(); //small 'An Ideal Fit For' text in upper left corner
				idealHolder.addChild(anIdealText);
				anIdealText.x = 233;
				anIdealText.y = 436;
				//add ideal fit bullets
				var iy:int = 450;			
				var il:int = Math.min(8, idealFit.length());			
				for (var j:int = 0; j < il; j++) {
					var f:activationSmallBullet = new activationSmallBullet();
					f.theText.text = idealFit[j];
					f.x = 233;
					f.y = iy;
					idealHolder.addChild(f);
					iy += 12;
				}
				//column 2 bullets
				if (idealFit.length() > 8) {
					iy = 450;
					for (j = 8; j < idealFit.length(); j++) {
						f = new activationSmallBullet();
						f.theText.text = idealFit[j];
						f.x = 623;
						f.y = iy;
						idealHolder.addChild(f);
						iy += 12;
					}
				}
				
				pricingText.theText.htmlText = sectionXML.sectiontext;
				
				page3Bulls = sectionXML.bullets.bullet;			
				var numBuls:int = page3Bulls.length();
				
				//main bullets
				bulArray = new Array();			
				var startY:int = 158;
				
				for (var i:int = 0; i < numBuls; i++) {
					var b:activationMainBullet = new activationMainBullet();
					addChild(b);				
					b.x = 235;
					b.y = startY;
					b.theText.text = page3Bulls[i].title;
					startY += 20; //space between bullets
					bulArray.push(b); //push to bulArray for clearing
					b.theButton.index = i; //index in the xml list
					b.theButton.addEventListener(MouseEvent.CLICK, p3BulletClicked, false, 0, true);
					b.theButton.buttonMode = true;
				}
				p3BulletClicked();
			}else {
				//section is case studies
				clearPage3Bullets();
				pricingText.theText.text = "";
				if(hoLine != null){
					if (contains(hoLine)) {
						removeChild(hoLine);
					}
				}
				caseStudyImageLoader.alpha = 0;
				caseStudyImageLoader.load(new URLRequest(sectionXML.image));
				addChild(caseStudyImageLoader);
				caseStudyImageLoader.x = 290;
				caseStudyImageLoader.y = 128;
			}
		}
		
		
		/**
		 * Called by clicking one of the bullets for the selected section
		 * @param	e CLICK MouseEvent
		 */
		private function p3BulletClicked(e:MouseEvent = null):void
		{
			if (currentPage3Bullet != -1) {
				//turn off old bullet indicator
				bulArray[currentPage3Bullet].theButton.gotoAndStop(1);
			}
			if (e == null) {
				currentPage3Bullet = 0;
			}else{
				currentPage3Bullet = e.currentTarget.index; //index in the page3Bulls xmllist
			}
			bulArray[currentPage3Bullet].theButton.gotoAndStop(2);
			imLoader.alpha = 0;
			imLoader.load(new URLRequest(page3Bulls[currentPage3Bullet].image));
			
			//detail
			var dets:XMLList = page3Bulls[currentPage3Bullet].details.detail;
			if (details == null) {
				details = new activationDetails();
			}
			if (!contains(details)) {
				addChild(details);
				details.x = 530;
				details.y = 360;
			}
			details.theText.htmlText = "<font color='#CC8A3E' size='12'><b>Details:</b></font><br/>";
			for (var i = 0; i < dets.length(); i++) {
				details.theText.htmlText += dets[i] + "<br/>";
			}
		}
	}
	
}

