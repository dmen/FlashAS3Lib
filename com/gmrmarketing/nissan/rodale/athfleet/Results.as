package com.gmrmarketing.nissan.rodale.athfleet
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.display.MovieClip;
	import flash.events.*;	
	import com.greensock.TweenMax;	
	import flash.net.URLVariables;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.nissan.rodale.athfleet.FleetViewer;
	import com.gmrmarketing.nissan.rodale.athfleet.Facebook;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	
	
	public class Results extends EventDispatcher
	{
		public static const CLIP_ADDED:String = "resultsAdded";
		public static const TRY_AGAIN:String = "tryAgain";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var fleetXML:XML;
		private var sliderXML:XML; //for web service
		private var fleetViewer:FleetViewer;
		private var weights:Array;
		private var weightSum:int;
		private var cars:XMLList;
		private var athletePic:Bitmap;//lib clip
		private var athName:String; //set in show()
		private var userName:String//set in show()
		private var facebook:Facebook;
		private var userCar:String;//set in changeCar()
		private var carPicLoader:Loader; //holds the big car image
		private var FBDialog:MovieClip; //posting and thanks for posting dialog for facebook
		private var registeredOnFacebook:int;
		private var rfid:String; //badge number from RFID
		private var timeoutHelper:TimeoutHelper;
		
		private var process:NativeProcess;//these for the virtual keyboard
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		
		
		public function Results($container:DisplayObjectContainer, $fleetXML:XML, $sliderXML:XML)
		{
			container = $container;
			fleetXML = $fleetXML;
			sliderXML = $sliderXML;			
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			//for opening and closing the onscreen keyboard
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			facebook = new Facebook();
			facebook.addEventListener(Facebook.DATA_POSTING, fbPosting, false, 0, true);
			facebook.addEventListener(Facebook.DATA_POSTED, fbPosted, false, 0, true);
			//facebook.addEventListener(Facebook.LOGIN_FAIL, hideKeyboard, false, 0, true);
			
			carPicLoader = new Loader();
			
			FBDialog = new facebookDialog(); //lib clip
			FBDialog.dotAnim.stop();
			FBDialog.x = 648;
			FBDialog.y = 400;
			
			fleetViewer = new FleetViewer(container, fleetXML);
			
			clip = new athleteMatch(); //lib clip
			
			cars = fleetXML.cars.car;			
			
			//create weights array - weight of each model in the xml
			//weightSum is the sum of all weights
			weights = new Array();
			weightSum = 0;
			for (var i:int = 0; i < cars.length(); i++){
				weights.push(parseInt(cars[i].weight));				
				weightSum += parseInt(cars[i].weight);
			}
		}
		
		
		public function show(ath:XML, $userName:String, fb:int, id:String):void
		{
			timeoutHelper.buttonClicked();
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			FBDialog.dotAnim.stop();
			
			athName = ath.@name;
			userName = $userName;
			registeredOnFacebook = fb;
			rfid = id;
			
			changeCar(getCar());
			
			var bmd:BitmapData;
			
			switch(athName) {
				case "Chris Horner":
					bmd = new horner(); //lib pics
					break;
				case "Shalane Flanagan":
					bmd = new flanagan();
					break;
				case "Kara Goucher":
					bmd = new goucher();
					break;
				case "Ryan Hall":
					bmd = new hall();
					break;
				case "Ryan Lochte":
					bmd = new lochte();
					break;
			}
			
			athletePic = new Bitmap(bmd);
			athletePic.x = 87;
			athletePic.y = 200;
			clip.addChild(athletePic);
			
			//info under athletes pic
			var bulls:XMLList = ath.factoids.fact;
			//pick four random factoids
			var all:Array = new Array(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);			
			var four:Array = new Array();
			while(four.length < 4){
				var i:int = Math.floor(Math.random() * all.length);
				var it:int = all.splice(i,1)[0];
				four.push(it);
			}

			clip.athName.text = athName;
			clip.abull1.autoSize = TextFieldAutoSize.LEFT;
			clip.abull2.autoSize = TextFieldAutoSize.LEFT;
			clip.abull3.autoSize = TextFieldAutoSize.LEFT;
			clip.abull4.autoSize = TextFieldAutoSize.LEFT;
			clip.abull1.text = "• " + bulls[four[0]];
			clip.abull2.text = "• " + bulls[four[1]];
			clip.abull3.text = "• " + bulls[four[2]];
			clip.abull4.text = "• " + bulls[four[3]];
			
			var ySpace:int = 12;
			clip.abull2.y = clip.abull1.y + clip.abull1.textHeight + ySpace;
			clip.abull3.y = clip.abull2.y + clip.abull2.textHeight + ySpace;
			clip.abull4.y = clip.abull3.y + clip.abull3.textHeight + ySpace;
			
			clip.btnNotMyCar.addEventListener(MouseEvent.MOUSE_DOWN, showFleetViewer, false, 0, true);
			clip.btnTryAgain.addEventListener(MouseEvent.MOUSE_DOWN, tryAgain, false, 0, true);
			
			//0 not registered, 1 registered, 2 disable FB button
			if(registeredOnFacebook == 2 || registeredOnFacebook == 0){
				clip.btnShare.alpha = 0;
			}else {
				//registered
				clip.btnShare.alpha = 1;
				clip.btnShare.addEventListener(MouseEvent.MOUSE_DOWN, fbShare, false, 0, true);
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		
		public function hide():void
		{
			clip.removeChild(athletePic);
			athletePic = null;
			clip.btnNotMyCar.removeEventListener(MouseEvent.MOUSE_DOWN, showFleetViewer);
			clip.btnTryAgain.removeEventListener(MouseEvent.MOUSE_DOWN, tryAgain);
			clip.btnShare.removeEventListener(MouseEvent.MOUSE_DOWN, fbShare);
			container.removeChild(clip);
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(CLIP_ADDED));
		}
		
		
		private function showFleetViewer(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			fleetViewer.show();
			fleetViewer.addEventListener(FleetViewer.NEW_CAR_PICKED, newCar, false, 0, true);
		}
		
		
		/**
		 * Called on dispatch of NEW_CAR_PICKED event from FleetViewer
		 * @param	e
		 */
		private function newCar(e:Event):void
		{			
			fleetViewer.hide();
			changeCar(fleetViewer.getCarIndex());
		}
		
		
		private function changeCar(carIndex:int):void
		{
			timeoutHelper.buttonClicked();
			
			userCar = cars[carIndex].model;
			
			var carFacts:XMLList = cars[carIndex].factoids.fact;
			
			var carPic:String = cars[carIndex].pic2;
			if (clip.contains(carPicLoader)) {
				clip.removeChild(carPicLoader);
			}
			carPicLoader.unload();
			carPicLoader.load(new URLRequest("assets/" + carPic));
			carPicLoader.x = 465;
			carPicLoader.y = 199;
			clip.addChild(carPicLoader);
			
			clip.matchText.autoSize = TextFieldAutoSize.LEFT;			
			clip.matchText.htmlText = userName + ", your selections align with " + athName + " and the Nissan " + userCar + "!";			
			
			//car facts under pic
			clip.carModel.htmlText = "Nissan " + userCar;
			clip.bull1.autoSize = TextFieldAutoSize.LEFT;
			clip.bull2.autoSize = TextFieldAutoSize.LEFT;
			clip.bull3.autoSize = TextFieldAutoSize.LEFT;
			clip.bull4.autoSize = TextFieldAutoSize.LEFT;
			clip.bull1.htmlText = "• Starting from " + carFacts[0];
			clip.bull2.htmlText = "• " + carFacts[1];
			clip.bull3.htmlText = "• " + carFacts[2];
			clip.bull4.htmlText = "• " + carFacts[3];
			
			var ySpace:int = 12;
			clip.bull2.y = clip.bull1.y + clip.bull1.textHeight + ySpace;
			clip.bull3.y = clip.bull2.y + clip.bull2.textHeight + ySpace;
			clip.bull4.y = clip.bull3.y + clip.bull3.textHeight + ySpace;
		}
		
		
		/**
		 * Selects a random car from a weighted list
		 * First selects a random number between 0 and the weightSum
		 * Iterate list - summing weights until the summed weight is greater than
		 * or equal to the random pick
		 * 
		 * @return
		 */
		private function getCar():int
		{
			var ind:int = Math.floor(Math.random() * weightSum);
			var curWeightSum:int = weights[0];
			
			var i:int = 0;
			var l:int = weights.length;
			
			while(i < l){			
				curWeightSum += weights[i];
				if (curWeightSum >= ind) {
					break;
				}
				i++;
			}
			
			return i;
		}		
		
		
		private function tryAgain(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			facebook.closeLogin(); //be sure dialog is closed
			//hideKeyboard();
			
			fleetViewer.hide();
			
			if (!clip.contains(FBDialog)) {
				clip.addChild(FBDialog);
			}
			
			FBDialog.alpha = 1;
			FBDialog.theText.text = "Thanks for Participating!";
			FBDialog.dotAnim.gotoAndStop(1);
			
			var a:Timer = new Timer(2000, 1);
			a.addEventListener(TimerEvent.TIMER, removeThanksDialog, false, 0, true);
			a.start();
		}
		
		private function removeThanksDialog(e:TimerEvent):void
		{
			TweenMax.to(FBDialog, .5, { alpha:0, onComplete:killThanksDialog } );
		}
		
		private function killThanksDialog():void
		{
			killFBDialog();
			hide();
			
			dispatchEvent(new Event(TRY_AGAIN));
		}
		
		
		/**
		 * Called by pressing the FB share button
		 * @param	e
		 */
		private function fbShare(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			//if (registeredOnFacebook == 1) {
				//user already registered call web service
				var mess:String = userName + " just took the Nissan Fitness Test and has similar interests as " + athName + " and may someday be driving a Nissan " + userCar;
				
				if (mess.indexOf("<font face='GG Superscript'>®</font>") != -1) {
					mess = mess.replace("<font face='GG Superscript'>®</font>", "");
				}
				
				var request:URLRequest = new URLRequest(sliderXML.webServiceURL + "FacebookMessage/" + rfid + "?");
				
				var lo:URLLoader = new URLLoader();
				var vars:URLVariables = new URLVariables();
				vars.message = mess;
				request.data = vars;			
				request.method = URLRequestMethod.POST;
				
				lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
				
				lo.load(request);
				
				fbPosting(); //show posting dialog
				/*
			}else if (registeredOnFacebook == 0){
				//user not already registered on FB - bring up normal dialog
				facebook.init(userName, athName, userCar);
				showKeyboard();			
			}
			*/
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{
			trace("data error");
		}
		
		
		private function dataPosted(e:Event):void
		{		
			//hideKeyboard();
			fbPosted();
		}
		
		
		private function fbPosting(e:Event = null):void
		{
			//hideKeyboard();
			timeoutHelper.buttonClicked();
			
			if (!clip.contains(FBDialog)) {
				clip.addChild(FBDialog);
			}
			FBDialog.alpha = 1;
			FBDialog.theText.text = "Posting to Facebook";
			FBDialog.dotAnim.play();
		}
		
		
		private function fbPosted(e:Event = null):void
		{
			timeoutHelper.buttonClicked();
			
			if (!clip.contains(FBDialog)) {
				clip.addChild(FBDialog);
			}
			FBDialog.alpha = 1;
			FBDialog.theText.text = "Post Complete!";
			FBDialog.dotAnim.gotoAndStop(1);
			
			var a:Timer = new Timer(2000, 1);
			a.addEventListener(TimerEvent.TIMER, removeFBDialog, false, 0, true);
			a.start();
		}
		
		
		private function removeFBDialog(e:TimerEvent):void
		{
			TweenMax.to(FBDialog, .5, { alpha:0, onComplete:killFBDialog } );
		}
		
		
		private function killFBDialog():void
		{
			if (clip.contains(FBDialog)) {
				clip.removeChild(FBDialog);
			}
		}
		/*
		private function showKeyboard(e:Event = null):void
		{
			try{
				if(NativeProcess.isSupported){				
					var file:File = File.desktopDirectory.resolvePath("showKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
				
			}
		}
		
		
		private function hideKeyboard(e:Event = null):void
		{
			//trace("hide");
			try{
				if(NativeProcess.isSupported){
					var file:File = File.desktopDirectory.resolvePath("hideKB.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
				}
			}catch (e:Error) {
			
			}
		}
		*/
		
	}
	
}