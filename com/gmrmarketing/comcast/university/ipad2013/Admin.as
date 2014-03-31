package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;	
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Admin extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var so:SharedObject;
		private var savedData:Object;//prizes, prize counts and prizing disabled flag
		
		private var currentReg:Object;
		private var currentForm:Object;
		private var regData:Array; //array of regData objects waiting to be uploaded
		private var winnerData:Array; //array of form objects waiting to be uploaded
		private var emails:Array; //all entered emails - used for making sure the same email is not entered twice
		
		
		
		
		public function Admin()
		{
			clip = new mcAdmin();
			
			so = SharedObject.getLocal("xfinScratchData", "/");
			savedData = so.data.adminData;//prizes and disabled state
			regData = so.data.regData;//registrations not uploaded
			winnerData = so.data.winnerData;//winner forms not uploaded
			emails = so.data.emails;
			
			if (savedData == null) {
				savedData = { disable:false, prize:"TV", prize2:"Camera", prize3:"Tablet", num:4, num2:8, num3:4 };
				so.data.adminData = savedData;				
			}
			if (regData == null) {
				regData = new Array();
				so.data.regData = regData;
			}
			if (winnerData == null) {
				winnerData = new Array();
				so.data.winnerData = winnerData;
			}
			if (emails == null) {
				emails = new Array();
				so.data.emails = emails;
			}
			so.flush();
			
			//checkRegQueue();
			//checkWinQueue();
			checkQueue();
		}
		
		private function checkQueue():void
		{
			if (regData.length > 0) {
				var reg:Object = regData.shift();
				registerUser(reg);
			}else if (winnerData.length > 0) {
				var form:Object = winnerData.shift();
				saveWinner(form);
			}
		}
		/*
		private function checkRegQueue():void
		{
			if(regData.length > 0){
				var reg:Object = regData.shift();
				registerUser(reg);
			}
		}
		
		
		private function checkWinQueue():void
		{
			if(winnerData.length > 0){
				var form:Object = winnerData.shift();
				saveWinner(form);
			}
		}
		*/
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.check.visible = savedData.disable;
			
			clip.prize.text = savedData.prize;
			clip.prize2.text = savedData.prize2;
			clip.prize3.text = savedData.prize3;
			
			clip.num.text = String(savedData.num);
			clip.num2.text = String(savedData.num2);
			clip.num3.text = String(savedData.num3);
			
			clip.regData.text = String(regData.length);
			clip.winData.text = String(winnerData.length);
			
			clip.y = 768;
			TweenMax.to(clip, .25, { y: 768 - clip.height } );
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			clip.btnDisable.addEventListener(MouseEvent.MOUSE_DOWN, disableClicked, false, 0, true);
			
			checkQueue();
		}
		
		
		/**
		 * Returns a random prize given the three prizes and counts entered in admin
		 * @return
		 */
		public function getPrize():String
		{
			var prizes:Array = new Array();			
			
			if (savedData.prize != "" && savedData.prize != " " && savedData.num > 0) {
				for (var i:int = 0; i < savedData.num; i++){
					prizes.push([savedData.prize, 1]);
				}
			}
			if (savedData.prize2 != "" && savedData.prize2 != " " && savedData.num2 > 0) {
				for (var j:int = 0; j < savedData.num2; j++){
					prizes.push([savedData.prize2, 2]);
				}
			}
			if (savedData.prize3 != "" && savedData.prize3 != " " && savedData.num3 > 0) {
				for (var k:int = 0; k < savedData.num3; k++){
					prizes.push([savedData.prize3, 3]);
				}
			}
			
			prizes = Utility.randomizeArray(prizes);	
			
			var thePrize:Array = prizes[0];
			
			if(thePrize != null){
				switch(thePrize[1]) {//prize id
					case 1:
						savedData.num = savedData.num - 1;
						break;
					case 2:
						savedData.num2 = savedData.num2 - 1;
						break;
					case 3:
						savedData.num3 = savedData.num3 - 1;
						break;
				}
				
				so.data.adminData = savedData;
				so.flush();
				
				return thePrize[0];
			}else {
				return "";
			}
		}
		
		
		public function getDisabled():Boolean
		{
			if(savedData.num > 0 || savedData.num2 > 0 || savedData.num3 > 0){
				return savedData.disable;
			}else {
				return true;
			}
		}
		
		
		public function emailAlreadyUsed(email:String):Boolean
		{
			return emails.indexOf(email) == -1 ? false : true;
		}
		
		
		/**
		 * Called from Main.showHowTo() once optIn is complete
		 * regData object comes from optIn.getRegData()
		 * regData contains id,email,optInAge,optInEmail fields
		 * @param	regData
		 */
		public function registerUser(rd:Object):void
		{
			currentReg = rd;
			
			emails.push(regData.email);
			so.data.emails = emails;
			so.flush();
			
			var request:URLRequest = new URLRequest("http://comcastfall2013.thesocialtab.net/API/RegUser/" + rd.id + "/" + rd.email + "/" + rd.optInAge + "/" + rd.optInEmail);					
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			saveCurrentReg();
		}
		
		
		/**
		 * Saves the current reg data to the local shared object
		 * if an error occurs while saving to the web service, or if
		 * true is not returned from the service
		 */
		private function saveCurrentReg():void
		{
			regData.push(currentReg);
			so.data.regData = regData;
			so.flush();
		}
		
		
		private function dataPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);
			if (lo.data != "true") {				
				saveCurrentReg();
			}else {
				clip.regData.text = String(regData.length);
				so.data.regData = regData;
				so.flush();
				//checkRegQueue();
				checkQueue();
			}
			
		}
		
		
		/**
		 * called from Main.formComplete()
		 * once the winner form has been filled out
		 * @param	formData object properties: fname,lname,add1,add2,city,state,zip,phone,email,prize
		 */
		public function saveWinner(form:Object):void
		{
			currentForm = form;
			
			var req:String = "http://comcastfall2013.thesocialtab.net/API/RegWinner/" + form.fname + "/" + form.lname + "/" + form.add1 + "/";
			req += form.city + "/" + form.state + "/" + form.zip + "/" + form.email + "/" + form.phone + "/" + form.prize;
			if (form.add2 != "") {
				req += "/" + form.add2;
			}
			
			var request:URLRequest = new URLRequest(req);
			request.method = URLRequestMethod.GET;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, winnerError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, winnerPosted, false, 0, true);
			lo.load(request);			
		}
		
		
		private function winnerError(e:IOErrorEvent):void
		{
			saveCurrentWinner();
		}
		
		
		/**
		 * Saves the currentForm data into the local shared object
		 * if an error occurs saving to the web service, or if
		 * true is not returned from the service
		 */
		private function saveCurrentWinner():void
		{
			winnerData.push(currentForm);
			so.data.winnerData = winnerData;
			so.flush();
		}
		
		
		private function winnerPosted(e:Event):void
		{
			var lo:URLLoader = URLLoader(e.target);
			if (lo.data != "true") {				
				saveCurrentWinner();
			}else {
				so.data.winnerData = winnerData;
				so.flush();
				clip.winData.text = String(winnerData.length);//show upload number remaining, in interface
				//checkWinQueue();
				checkQueue();
			}
		}
		
		
		/**
		 * Hids the dialog and saves the text in prize fields to the local shared object
		 * @param	e
		 */
		private function hide(e:MouseEvent):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			
			savedData.prize = clip.prize.text;
			savedData.prize2 = clip.prize2.text;
			savedData.prize3 = clip.prize3.text;
			
			savedData.num = parseInt(clip.num.text);
			savedData.num2 = parseInt(clip.num2.text);
			savedData.num3 = parseInt(clip.num3.text);
			
			so.data.adminData = savedData;
			so.flush();
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		/**
		 * Toggles the prizing disabled state
		 * if prizing is disabled it will be impossible to 
		 * scratch off two of the same icons
		 * @param	e
		 */
		private function disableClicked(e:MouseEvent):void
		{
			savedData.disable = !savedData.disable;
			clip.check.visible = savedData.disable;
			so.data.adminData = savedData;
			so.flush();
		}
		
		
	}
	
}