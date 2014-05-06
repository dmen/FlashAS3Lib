package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.net.Socket;
	import flash.sensors.Accelerometer;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.intel.girls20.ComboBox;
	
	
	public class ControllerMain extends MovieClip
	{
		private var socketConnected:Boolean;
		private var socket:Socket;
		private var accel:Accelerometer;
		private var tim:Timer;
		
		private var intro:ControllerIntro;
		private var dialog:ControllerDialog;
		private var instructions:ControllerInstructions;
		private var sweeps:ControllerSweeps;
		private var avatars:ControllerAvatars;
		private var q1:ControllerQuestion_1; //goes between level 1 and 2
		private var q2:ControllerQuestion_2; //goes between level 2 and 3
		private var inGame:ControllerInGame; //shows message on controller while game is playing
		private var webService:ControllerWeb; //for getting the event list
		private var cq:CornerQuit;
		private var currentIPPort:String;
		
		private var mainContainer:Sprite;
		private var dialogContainer:Sprite;//for ipDialog
		private var ipDialog:MovieClip;//lib clip mcIPDialog
		private var LED:MovieClip; //mcLED in lib
		
		private var playingGame:Boolean = false; //when false accel updates aren't sent
		private var eventDropdown:ComboBox;
		
		private var ipStore:SharedObject; //stores the last ip in the dropdown
		private var dataTimeout:Timer; //timeout timer for sending data to server
		private var dataTimeoutAttempts:int;
		
		private var rules:ControllerRules; //webservice and rules text
		private var refreshing:Boolean;
		
		
		public function ControllerMain()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			socketConnected = false;
			
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onServerData );
			
			accel = new Accelerometer();			
			accel.setRequestedUpdateInterval(120);//ms
			accel.addEventListener(AccelerometerEvent.UPDATE, updateHandler);				
			
			mainContainer = new Sprite();
			dialogContainer = new Sprite();
			addChild(mainContainer);
			addChild(dialogContainer);
			
			intro = new ControllerIntro();
			intro.setContainer(mainContainer);
			intro.addEventListener(ControllerIntro.START, doStart);
			intro.addEventListener(ControllerIntro.REQUIRED, fieldsRequired);
			intro.addEventListener(ControllerIntro.EMAIL, badEmail);
			intro.addEventListener(ControllerIntro.PHONE, badPhone);
			intro.addEventListener(ControllerIntro.RULES, noRules);
			intro.addEventListener(ControllerIntro.STATE, noState);			
			intro.addEventListener(ControllerIntro.SHOW_RULES, showRules);			
			
			instructions = new ControllerInstructions();
			instructions.setContainer(mainContainer);
			
			dialog = new ControllerDialog();//for messages
			dialog.setContainer(mainContainer);
			
			sweeps = new ControllerSweeps();			
			sweeps.setContainer(mainContainer);
			
			avatars = new ControllerAvatars();
			avatars.setContainer(mainContainer);
			
			q1 = new ControllerQuestion_1();
			q1.setContainer(mainContainer);
			
			q2 = new ControllerQuestion_2();
			q2.setContainer(mainContainer);
			
			inGame = new ControllerInGame();
			inGame.setContainer(mainContainer);			
			
			//auto connection to game server
			tim = new Timer(2000);
			tim.addEventListener(TimerEvent.TIMER, checkConnection, false, 0, true);
			
			cq = new CornerQuit();
			cq.init(dialogContainer, "ur");
			cq.customLoc(1, new Point(1130, 0));
			cq.addEventListener(CornerQuit.CORNER_QUIT, openIPDialog, false, 0, true);
			
			LED = new mcLED();
			LED.x = 500;
			LED.y = 2;
			dialogContainer.addChild(LED);
			
			ipDialog = new mcIPDialog();
			dialogContainer.addChild(ipDialog);
			ipDialog.y = - ipDialog.height;
			eventDropdown = new ComboBox("Choose Event");			
			eventDropdown.x = 26;
			eventDropdown.y = 229;
			
			ipStore = SharedObject.getLocal("bcbs_ip");
			var ip:String = ipStore.data.ip;
			if (ip != null) {
				ipDialog.theIP.text = ip;			
			}
			
			webService = new ControllerWeb();
			webService.addEventListener(ControllerWeb.CONTROLLER_EVENTS, gotEventList, false, 0, true);
			webService.retrieveEvents();
			
			dataTimeout = new Timer(10000, 1);
			dataTimeout.addEventListener(TimerEvent.TIMER, userDataTimedOut);
			
			rules = new ControllerRules();
			rules.setContainer(dialogContainer);
			
			refreshing = false;
			
			doReset();
			openIPDialog(); //in order to help ba to remember to pick event
		}
		
		
		private function gotEventList(e:Event):void
		{			
			var o:Object = webService.getEvents();
			var a:Array = new Array();
			for (var i:int = 0; i < o.length; i++) {
				a.push(o[i].pid + ":" + o[i].descr);
			}
			eventDropdown.populate(a);			
			ipDialog.addChild(eventDropdown);
			eventDropdown.reset();//shows reset message
		}
		
		
		private function showRules(e:Event):void
		{
			rules.show();
			rules.addEventListener(ControllerRules.RULES_DONE, hideRules, false, 0, true);
		}
		
		private function hideRules(e:Event):void
		{
			rules.removeEventListener(ControllerRules.RULES_DONE, hideRules);
			rules.hide();
		}
		
		
		/**
		 * called from constructor and from onServerData() when 'reset' is received
		 */
		private function doReset(e:Event = null):void
		{
			dataTimeout.reset(); //stop timeout timer
			dataTimeoutAttempts = 1;
			
			inGame.hide();
			sweeps.removeEventListener(ControllerSweeps.DONE, sweepsDone);
			sweeps.removeEventListener(ControllerSweeps.RULES, showRules);
			sweeps.hide();
			avatars.hide();
			avatars.removeEventListener(ControllerAvatars.READY, avatarSelected);
			avatars.removeEventListener(ControllerAvatars.NEW_AVATAR, newAvatar);
			q1.hide();
			q1.removeEventListener(ControllerQuestion_1.Q1, q1Answered);
			q1.removeEventListener(ControllerQuestion_1.NO_Q1, qNotAnswered);
			q2.hide();
			q2.removeEventListener(ControllerQuestion_2.Q2, q2Answered);
			q2.removeEventListener(ControllerQuestion_2.NO_Q2, qNotAnswered);
			instructions.hide();
			instructions.removeEventListener(ControllerInstructions.READY, instructionsDone);
			tim.reset();
			intro.show();	//show form
			playingGame = false;
			tim.start();//start calling checkConnection()
		}
		
		
		private function checkConnection(e:TimerEvent):void
		{
			if(!socketConnected){
				try {
					socket.connect(ipDialog.theIP.text, parseInt(ipDialog.thePort.text));
				} catch (e:Error) {
					
				}
			}else {
				//stop timer if this is being called and the socket is connected
				tim.stop();
			}
		}
		
		
		private function openIPDialog(e:Event = null):void
		{
			TweenMax.to(ipDialog, .5, { y:0 } );
			webService.retrieveEvents();//refresh the event list
			ipDialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeIPDialog, false, 0, true);
			ipDialog.btnShutdown.addEventListener(MouseEvent.MOUSE_DOWN, shutdown, false, 0, true);
			//ipDialog.btnRefresh.addEventListener(MouseEvent.MOUSE_DOWN, refreshConnection, false, 0, true);
		}
		
		
		private function closeIPDialog(e:MouseEvent):void
		{
			TweenMax.to(ipDialog, .5, { y: - ipDialog.height } );
			
			if (currentIPPort != ipDialog.theIP.text + ipDialog.thePort.text) {
				if(socketConnected){
					socket.close();
					tim.reset();
					tim.start();
				}
			}
			
			//update rules
			if (eventDropdown.getSelection() != "" && eventDropdown.getSelection() != eventDropdown.getResetMessage()) {
				var ev:String = eventDropdown.getSelection();
				var a:Array = ev.split(":");
				rules.getRuleData(parseInt(a[0]));
			}			
			
			ipStore.data.ip = ipDialog.theIP.text;
			ipStore.flush();
			
			//accel.setRequestedUpdateInterval(parseInt(ipDialog.theInterval.text));
			
			ipDialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeIPDialog);
			ipDialog.btnShutdown.removeEventListener(MouseEvent.MOUSE_DOWN, shutdown);
			//ipDialog.btnRefresh.removeEventListener(MouseEvent.MOUSE_DOWN, refreshConnection);
		}
		
		
		private function refreshConnection(e:MouseEvent):void
		{
			if(socketConnected){
				socket.writeUTFBytes("refresh");//asks server to send last message it sent
				socket.flush();				
			}
		}
		
		
		private function shutdown(e:MouseEvent):void
		{
			if(socketConnected){
				socket.writeUTFBytes("shutdown");
				socket.flush();				
			}
			NativeApplication.nativeApplication.exit();
		}
		
		
		//Intro Form error/validation callbacks
		private function fieldsRequired(e:Event):void
		{
			dialog.show("Please fill in all required fields");
		}
		private function badEmail(e:Event):void
		{
			dialog.show("Please enter a valid email address");
		}
		private function badPhone(e:Event):void
		{
			dialog.show("Please enter a valid phone number");
		}
		private function noRules(e:Event):void
		{
			dialog.show("You must accept the terms and conditions");
		}
		private function noState(e:Event):void
		{
			dialog.show("Please select your state");
		}
		
		
		/**
		 * Called when start button is pressed in ControllerIntro (initial form)
		 * Will not be called until intro form is filled out and data is validated
		 * @param	e
		 */
		private function doStart(e:Event):void
		{
			intro.hide();		
			
			if(socketConnected){
				socket.writeUTFBytes("instructions");
				socket.flush();
			}
			
			instructions.show();
			instructions.addEventListener(ControllerInstructions.READY, instructionsDone, false, 0, true);
		}
		
		
		/**
		 * Called when ready button is pressed in instructions
		 * Shows the avatar selection screen
		 * @param	e
		 */
		private function instructionsDone(e:Event):void
		{
			instructions.hide();
			instructions.removeEventListener(ControllerInstructions.READY, instructionsDone);
			
			if(socketConnected){
				socket.writeUTFBytes("avatar");
				socket.flush();
			}
			
			avatars.show();
			avatars.addEventListener(ControllerAvatars.READY, avatarSelected, false, 0, true);
			avatars.addEventListener(ControllerAvatars.NEW_AVATAR, newAvatar, false, 0, true);
		}
		
		
		/**
		 * Called once ready in the avatar selector is pressed
		 * sends start to the game
		 * @param	e
		 */
		private function avatarSelected(e:Event):void
		{
			avatars.hide();
			avatars.removeEventListener(ControllerAvatars.READY, avatarSelected);
			avatars.removeEventListener(ControllerAvatars.NEW_AVATAR, newAvatar);
			
			playingGame = true; //accel updates are now sent in updateHandler()
			if(socketConnected){
				socket.writeUTFBytes("start");
				socket.flush();				
			}
			
			inGame.show();//shows game in progress....
		}
		
		
		private function newAvatar(e:Event):void
		{			
			if(socketConnected){
				socket.writeUTFBytes("avpoint" + String(avatars.getAvatar()));
				socket.flush();				
			}
		}
		
		
		/**
		 * Called when a connection to the game server is established
		 * @param	e
		 */
		private function onConnect(e:Event):void
		{	
			if (refreshing) {
				refreshing = false;
				//socket.writeUTFBytes("***refresh***");
				//socket.flush();			
			}
			tim.reset();
			socketConnected = true;
			currentIPPort = ipDialog.theIP.text + ipDialog.thePort.text;
			LED.gotoAndStop(2);
		}


		private function onClose(e:Event):void
		{
			socketConnected = false;
			LED.gotoAndStop(1);//red
			//btnStart.alpha = .25;
			tim.start();//start auto connect to server
		}


		private function onError(e:IOErrorEvent):void
		{
			//info.appendText("IOError: " + e.toString() + "\n");
		}


		private function onSecError(e:SecurityErrorEvent):void
		{
			//info.appendText("SecurityError: " + e.toString() + "\n");
		}

		
		/**
		 * Called when a message arrives from the server
		 * @param	e
		 */
		private function onServerData(e:ProgressEvent):void
		{
			var buffer:ByteArray = new ByteArray();
			socket.readBytes( buffer, 0, socket.bytesAvailable );
			var m:String = buffer.toString();
			
			if (m == "reset") {
				//acknowledge();
				doReset();
			}
			if (m == "gameOver") {
				playingGame = false; //stop accel events
				//acknowledge();
				dataTimeoutAttempts = 1;
				sweeps.show();
				sweeps.addEventListener(ControllerSweeps.DONE, sweepsDone, false, 0, true);
				sweeps.addEventListener(ControllerSweeps.RULES, showRules, false, 0, true);
			}
			if (m == "questionOne") {
				playingGame = false; //stop accel events
				//acknowledge();
				q1.show();
				q1.addEventListener(ControllerQuestion_1.Q1, q1Answered, false, 0, true);
				q1.addEventListener(ControllerQuestion_1.NO_Q1, qNotAnswered, false, 0, true);
			}
			if (m == "questionTwo") {
				playingGame = false; //stop accel events
				//acknowledge();
				q2.show();
				q2.addEventListener(ControllerQuestion_2.Q2, q2Answered, false, 0, true);
				q2.addEventListener(ControllerQuestion_2.NO_Q2, qNotAnswered, false, 0, true);
			}			
		}
		/*
		private function acknowledge():void
		{
			if(socketConnected){
				socket.writeUTFBytes("***ack***");
				socket.flush();
			}
		}
		*/
		private function q1Answered(e:Event):void
		{
			//could change message in inGame here
			q1.hide();
			q1.removeEventListener(ControllerQuestion_1.Q1, q1Answered);
			q1.removeEventListener(ControllerQuestion_1.NO_Q1, qNotAnswered);
			playingGame = true;
			if(socketConnected){
				socket.writeUTFBytes("answered");
				socket.flush();				
			}
		}
		
		
		private function q2Answered(e:Event):void
		{
			//could change message in inGame here
			q2.hide();
			q2.removeEventListener(ControllerQuestion_2.Q2, q2Answered);
			q2.removeEventListener(ControllerQuestion_2.NO_Q2, qNotAnswered);
			playingGame = true;
			if(socketConnected){
				socket.writeUTFBytes("answered");
				socket.flush();
			}
		}
		
		
		private function qNotAnswered(e:Event):void
		{
			dialog.show("Please select an answer");
		}
		
		private function userDataTimedOut(e:TimerEvent):void
		{
			dataTimeout.reset();
			//sending user data to the server timeout after 10 seconds...
			//try again
			dataTimeoutAttempts++; //reset to 1 in onServerData() when gameOver is received
			if(dataTimeoutAttempts < 3){				
				//if do this twice and it fails again - stop trying
				sweepsDone();
			}else {
				//tried twice... stop trying
				doReset();
			}
		}
		
		/**
		 * listener on sweeps
		 * called when sweeps entries are complete and thank you is finished showing
		 * sends userdata to game server
		 * @param	e
		 */
		private function sweepsDone(e:Event = null):void
		{			
			sweeps.removeEventListener(ControllerSweeps.DONE, sweepsDone);
			
			//userData is: fname,lname,email,phone,state,entry,optin,moreInfo,q1a,q2a,event
			var userData:Array = intro.getData().concat(sweeps.getData());			
			userData.push(q1.getAnswer());
			userData.push(q2.getAnswer());
			
			//event - send empty string if no event is selected
			if (eventDropdown.getSelection() == "" || eventDropdown.getSelection() == eventDropdown.getResetMessage()) {
				userData.push("-");
			}else {
				userData.push(eventDropdown.getSelection()); //this is program id:program description     aka: 45:Trenton Super
			}			
			
			var uds:String = userData.join(); //comma sep string
			
			dataTimeout.start(); //calls userDataTimedOut in 10 seconds
			
			//now waits for reset from server
			if(socketConnected){
				socket.writeUTFBytes("userData" + uds);
				socket.flush();
			}
		}

		
		private function updateHandler(e:AccelerometerEvent):void
		{
			var aX:Number = e.accelerationX;
			var aY:Number = e.accelerationY;
			var aZ:Number = e.accelerationZ;
			 
			// These numbers can creep outside of the interval -1 to 1 if the device is even moving very slightly, so we use the following lines to keep the values between -1 and 1.
			if (aX < -1) aX = -1;
			if (aX > 1) aX = 1;
			if (aY < -1) aY = -1;
			if (aY > 1) aY = 1;
			if (aZ < -1) aZ = -1;
			if (aZ > 1) aZ = 1;
			 
			/* 
			Calculate the angle by using the vector identity u.v = |u| |v| cos(angle), 
			where u is the vector (aX,aY,aZ) and v is the vector (0,aY,0) which points vertically. 
			We have to subract 90 because arccos essentially returns values between 0 and 180,
			and we would like to interpret these between -90 and 90.
			*/
			var mag:Number = Math.sqrt(aX * aX + aY * aY + aZ * aZ);
			var angle:Number = Math.round((180 / Math.PI) * Math.acos(aX / mag)) - 90;
			 
			// We do not allow the angle to get outside of the range -90 to 90.
			if (angle < -90) angle = -90;
			if (angle > 90) angle = 90;	 
			
			angle *= -1;
			
			if(socketConnected && playingGame){
				socket.writeUTFBytes(angle.toString());
				socket.flush();
			}
		}
	}	
}