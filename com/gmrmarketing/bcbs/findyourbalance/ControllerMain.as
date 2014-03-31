package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.sensors.Accelerometer;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
 
	
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
		private var cq:CornerQuit;
		private var currentIPPort:String;
		
		private var mainContainer:Sprite;
		private var dialogContainer:Sprite;//for ipDialog
		private var ipDialog:MovieClip;//lib clip mcIPDialog
		private var LED:MovieClip; //mcLED in lib
		
		private var playingGame:Boolean = false; //when false accel updates aren't sent
		
		
		public function ControllerMain()
		{
			socketConnected = false;
			
			socket = new Socket();
			socket.addEventListener(Event.CONNECT, onConnect);
			socket.addEventListener(Event.CLOSE, onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onServerData );
			
			accel = new Accelerometer();			
			accel.setRequestedUpdateInterval(75);//ms - can be changed through ip dialog
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
			cq.addEventListener(CornerQuit.CORNER_QUIT, openIPDialog, false, 0, true);
			
			LED = new mcLED();
			LED.x = 500;
			LED.y = 2;
			dialogContainer.addChild(LED);
			
			ipDialog = new mcIPDialog();
			dialogContainer.addChild(ipDialog);
			ipDialog.y = - ipDialog.height;
			
			doReset();
		}
		
		
		/**
		 * called from constructor and from onServerData() when 'reset' is received
		 */
		private function doReset(e:Event = null):void
		{
			inGame.hide();
			sweeps.removeEventListener(ControllerSweeps.DONE, sweepsDone);
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
			tim.start();
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
		
		
		private function openIPDialog(e:Event):void
		{
			TweenMax.to(ipDialog, .5, { y:0 } );
			ipDialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeIPDialog, false, 0, true);
			ipDialog.btnShutdown.addEventListener(MouseEvent.MOUSE_DOWN, shutdown, false, 0, true);
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
			accel.setRequestedUpdateInterval(parseInt(ipDialog.theInterval.text));
		}
		
		private function shutdown(e:MouseEvent):void
		{
			if(socketConnected){
				socket.writeUTFBytes("***shutdown***");
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
			dialog.show("You must accept the official rules");
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
				socket.writeUTFBytes("***avatar***");
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
				socket.writeUTFBytes("***start***" + String(avatars.getAvatar()));
				socket.flush();				
			}
			inGame.show();//shows game in progress....
		}
		
		
		private function newAvatar(e:Event):void
		{			
			if(socketConnected){
				socket.writeUTFBytes("***avpoint***" + String(avatars.getAvatar()));
				socket.flush();				
			}
		}
		
		
		/**
		 * Called when a connection to the game server is established
		 * @param	e
		 */
		private function onConnect(e:Event):void
		{	
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

		
		private function onServerData(e:ProgressEvent):void
		{
			var buffer:ByteArray = new ByteArray();
			socket.readBytes( buffer, 0, socket.bytesAvailable );
			var m:String = buffer.toString();
			
			if(m == "reset"){				
				doReset();
			}
			if (m == "gameOver") {
				playingGame = false; //stop accel events
				sweeps.show();
				sweeps.addEventListener(ControllerSweeps.DONE, sweepsDone, false, 0, true);
			}
			if (m == "questionOne") {
				playingGame = false; //stop accel events
				q1.show();
				q1.addEventListener(ControllerQuestion_1.Q1, q1Answered, false, 0, true);
				q1.addEventListener(ControllerQuestion_1.NO_Q1, qNotAnswered, false, 0, true);
			}
			if (m == "questionTwo") {
				playingGame = false; //stop accel events
				q2.show();
				q2.addEventListener(ControllerQuestion_2.Q2, q2Answered, false, 0, true);
				q2.addEventListener(ControllerQuestion_2.NO_Q2, qNotAnswered, false, 0, true);
			}
		}
		
		
		private function q1Answered(e:Event):void
		{
			//could change message in inGame here
			q1.hide();
			q1.removeEventListener(ControllerQuestion_1.Q1, q1Answered);
			q1.removeEventListener(ControllerQuestion_1.NO_Q1, qNotAnswered);
			playingGame = true;
			if(socketConnected){
				socket.writeUTFBytes("***answered***");
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
				socket.writeUTFBytes("***answered***");
				socket.flush();
			}
		}
		
		
		private function qNotAnswered(e:Event):void
		{
			dialog.show("Please select an answer");
		}
		
		
		/**
		 * listener on sweeps
		 * called when sweeps entries are complete and thank you is finished showing
		 * sends userdata to game server
		 * @param	e
		 */
		private function sweepsDone(e:Event):void
		{			
			sweeps.removeEventListener(ControllerSweeps.DONE, sweepsDone);
			
			//userData is: fname,lname,email,phone,state,entry,optin,q1a,q2a
			var userData:Array = intro.getData().concat(sweeps.getData());			
			userData.push(q1.getAnswer());
			userData.push(q2.getAnswer());
			
			var uds:String = userData.join(); //comma sep string
			
			if(socketConnected){
				socket.writeUTFBytes("***userData***" + uds);
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