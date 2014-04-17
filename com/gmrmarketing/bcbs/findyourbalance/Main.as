package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.SocketServer;
	import com.gmrmarketing.utilities.TimerDisplay;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import nape.callbacks.*;
	import nape.constraint.PivotJoint;
	import nape.constraint.WeldJoint;
	import nape.geom.Vec2;
	import nape.phys.*;	
	import nape.dynamics.*;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;	
	import nape.shape.Circle;	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.desktop.NativeApplication;
 
	
	public class Main extends Sprite 
	{
		private const RAD:Number = 180 / Math.PI; //one radian
		
		private var space:Space;//physics spacs
		private var debug:BitmapDebug;//if DEBUG flag is true this shows the debug physics
		private var server:SocketServer;//for communicating with android tablet
		
		private var floorCollisionType:CbType;//added to floor
		private var shapeCollisionType:CbType;//added to player and falling balls for detecting floor collisions	
		private var playerCollisionType:CbType;//added to playerCircleBody for detecting collisions with shield icons
		private var shieldIconCollisionType:CbType;//added to shield icons for collisions with player
		private var shieldActiveCollisionType:CbType;//added to shield for collisions with falling shapes
		
		private var teeterBody:Body;//teeter beam
		private var playerCircleBody:Body;//main player
		private var playerShield:Body; //big circle shield surrounding player
		private var pivotJoint:PivotJoint;//joint between teeter and fulcrum
		private var shieldJoint:WeldJoint;//joint between player and shield
		private var floorListener:InteractionListener;//callback for circle hitting floor
		private var shieldListener:InteractionListener;//callback for shield icon hitting player
		private var shieldActiveListener:InteractionListener;//callback for balls hitting shield	
		private var shieldActivePreListener:PreListener;//callback for balls hitting shield	
		
		private var totterClip:MovieClip;//library images for the physics objects
		private var playerClip:MovieClip; 
		private var shieldClip:MovieClip;
		
		private var clientConnected:Boolean = false;//true once the controller connects
		private var playingGame:Boolean;//true when the game is running		
		
		private var shieldActive:Boolean;//true when the players shield is active		
		
		private var timeDisplay:TimerDisplay;//timer and display - takes a field to display in
		
		private var maxBallSize:Number;
		private var currentBallSize:Number;//the current size of the dropping balls - used to determine density
		private var sizeTimer:Timer;//timer to call makeHarder() on some interval
		private var shapeTimer:Timer;//used to drop shapes at some interval	
		
		private var shieldGroup:InteractionGroup; //group for shield to ignore teeter plank
		private var floorPlankGroup:InteractionGroup; //so floor and plank can still interact
		
		private var icons:Icons;//the falling icon graphics
		private var pointsDisplay:PointsDisplay; //for displaying messages at the point of contact - like "shield" or "+2sec"
		
		private var webService:WebService;//for sending user data
		
		private var intro:GameIntro;//intro screen	
		private var instructions:Instructions; //instructions
		private var avatars:Avatars;//duplicates avatar selection screen on tablet
		private var levelIntro:LevelIntro;//level intro right before countdown
		private var countdown:Countdown;//3-2-1
		
		private var gameOverClip:MovieClip;
		
		private var theLevel:int;//current game level - init'd in newGame()
		
		
		
		public function Main():void 
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();			

			server = new SocketServer(); //use default port: 1080
			server.addEventListener(SocketServer.CONNECT, clientConnect, false, 0, true);//set clientConnected to true
			server.addEventListener(SocketServer.MESSAGE, clientMessage, false, 0, true);//angle changed
			server.addEventListener(SocketServer.DISCONNECT, clientDisconnect, false, 0, true);//set clientConnected to false
			
			timeDisplay = new TimerDisplay(theTime, theScore);
			
			var gravity:Vec2 = new Vec2(0, 900); // units are pixels/second/second
			space = new Space(gravity);			
			
			floorCollisionType = new CbType();
			shapeCollisionType = new CbType();
			playerCollisionType = new CbType();
			shieldIconCollisionType = new CbType();
			shieldActiveCollisionType = new CbType();
			
			var pos:Vec2 = new Vec2(960, 1050);//fulcrum center
			var triangleSize:Number = 128;
			var planeSize:Vec2 = new Vec2(900, 20);
			
			//FLOOR
			var floorBody:Body = new Body(BodyType.STATIC);
			floorBody.shapes.add(new Polygon(Polygon.rect(0, 1080, 1920, 1)));//x,y,w,h
			floorBody.cbTypes.add(floorCollisionType);
			
			//FULCRUM
			var fulcrumBody:Body = new Body(BodyType.STATIC, pos);
			fulcrumBody.shapes.add(new Polygon(Polygon.regular(triangleSize, triangleSize, 3, -Math.PI * 0.5)));			
			
			//TEETER
			teeterBody = new Body(BodyType.DYNAMIC, new Vec2(pos.x, pos.y - triangleSize - planeSize.y * 0.5));			
			var teeterShape:Polygon = new Polygon(Polygon.box(planeSize.x, planeSize.y));
			teeterShape.material.density = 1.5;
			teeterBody.shapes.add(teeterShape);
			
			//PLAYER
			playerCircleBody = new Body(BodyType.DYNAMIC);
			var playerCircle:Circle = new Circle(90);
			playerCircle.material.density = 3;
			playerCircle.material.rollingFriction = .65; //.01 is default
			playerCircleBody.shapes.add(playerCircle);
			playerCircleBody.position.setxy(960, 727);
			//playerClip = new mcSmiles();
			//playerCircleBody.userData.graphic = playerClip;
			playerCircleBody.userData.player = true;
			playerCircleBody.cbTypes.add(shapeCollisionType);
			playerCircleBody.cbTypes.add(playerCollisionType);
			
			//SHIELD
			shieldClip = new mcBigShield(); //lib clip
			playerShield = new Body(BodyType.DYNAMIC);
			var shieldShape:Circle = new Circle(200);			
			shieldShape.material.density = .1;
			shieldShape.material.elasticity = 5;
			playerShield.userData.shield = true;
			playerShield.shapes.add(shieldShape);
			playerShield.userData.graphic = shieldClip;
			playerShield.cbTypes.add(shieldActiveCollisionType);
			
			//group so teeter and shield ignore each other
			shieldGroup = new InteractionGroup();			
			floorPlankGroup = new InteractionGroup();			
			shieldGroup.ignore = true;
			floorPlankGroup.ignore = false;
			playerShield.group = shieldGroup;			
			fulcrumBody.group = shieldGroup;
			teeterBody.group = floorPlankGroup;
			floorBody.group = floorPlankGroup;
			floorPlankGroup.group = shieldGroup;
			
			//FULCRUM PIVOT
			var pivotPos:Vec2 = new Vec2(pos.x, pos.y - triangleSize);			
			pivotJoint = new PivotJoint(fulcrumBody, teeterBody, fulcrumBody.worldPointToLocal(pivotPos), teeterBody.worldPointToLocal(pivotPos));
			pivotJoint.stiff = true;
			pivotJoint.space = space;
			
			floorListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, floorCollisionType, shapeCollisionType, shapeHitFloor);
			space.listeners.add(floorListener);
			
			shieldListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, playerCollisionType, shieldIconCollisionType, playerGotShield);
			space.listeners.add(shieldListener);
			
			shieldActiveListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, shieldActiveCollisionType, shapeCollisionType, ballHitShield);
			space.listeners.add(shieldActiveListener);
			
			space.bodies.add(floorBody);//add body to space
			space.bodies.add(fulcrumBody);//add body to space
			space.bodies.add(teeterBody);//add body to space
			space.bodies.add(playerCircleBody);//add body to space
			
			playerCircleBody.allowMovement = false;
			teeterBody.allowMovement = false;
			
			totterClip = new plank(); //lib clip			
			teeterBody.userData.graphic = totterClip;
			
			shapeTimer = new Timer(500);
			shapeTimer.addEventListener(TimerEvent.TIMER, addShape, false, 0, true);
			
			sizeTimer = new Timer(2000);
			sizeTimer.addEventListener(TimerEvent.TIMER, makeHarder, false, 0, true);
			
			icons = new Icons();
			pointsDisplay = new PointsDisplay();
			pointsDisplay.setContainer(this);
			
			webService = new WebService();			
			
			intro = new GameIntro();//find your balance - play this game / leaderboard
			intro.setContainer(this);
			
			levelIntro = new LevelIntro();
			levelIntro.setContainer(this);
			
			countdown = new Countdown();
			countdown.setContainer(this);
			
			avatars = new Avatars();
			avatars.setContainer(this);
			
			instructions = new Instructions();
			instructions.setContainer(this);
			
			gameOverClip = new mcGameOver(); //lib clip
			
			newGame();
		}		
		
		
		/**
		 * Starts a new game
		 * sends reset to the controller to show the initial login form
		 * initially called from Constructor
		 * called from clientMessage() when message is ***userData***
		 */
		private function newGame():void
		{			
			intro.show(webService.getLeaderboard());//show the find your balance - play this game intro screen
			//intro swaps between play and leaderboard screens
			
			theLevel = 1;
			bg.gotoAndStop(1);//background level graphic on stage
			if(contains(gameOverClip)){
				removeChild(gameOverClip);
			}
			playingGame = false;
			if (clientConnected) {
				server.sendToClient("reset");//reset the controller and show the initial data collection form
				//wait for ***start*** from controller
			}
		}
		
		
		/**
		 * called from levelEnd when the level > 3
		 * show sweeps / thanks on the controller before calling newGame
		 */
		private function gameOver():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, update);
			if (clientConnected) {
				server.sendToClient("gameOver");//show sweeps and thank you				
				addChild(gameOverClip);
				//now wait for "***userData***" from the client
			}
		}
		
		
		/**
		 * Called when client connects
		 * @param	e
		 */
		private function clientConnect(e:Event):void
		{
			clientConnected = true;
			if(!playingGame){
				server.sendToClient("reset");//reset the controller and show the initial data collection form
			}
		}

		
		/**
		 * listener for socket server
		 * called whenever data is received from the controller
		 * @param	e
		 */
		private function clientMessage(e:Event):void
		{			
			var s:String = server.getMessage();
			
			if (!playingGame) {
				if (s.indexOf("***start***") != -1) {					
					
					if(playerClip){
						if (contains(playerClip)) {
							removeChild(playerClip);
						}
					}
					playerClip = null;
					
					switch(avatars.getAvatarNumber()) { //0-7
						case 0:
							playerClip = new av1();
							break;
						case 1:
							playerClip = new av2();
							break;
						case 2:
							playerClip = new av3();
							break;
						case 3:
							playerClip = new av4();
							break;
						case 4:
							playerClip = new av5();
							break;
						case 5:
							playerClip = new av6();
							break;
						case 6:
							playerClip = new av7();
							break;
						case 7:
							playerClip = new av8();
							break;
					}					
					
					trace("av clip:", playerClip);
					playerCircleBody.userData.graphic = playerClip;					

					if(!contains(totterClip)){
						addChild(totterClip);						
					}
					addChild(playerClip);
					
					avatars.hide();					
					levelIntro.show(1);
					
					//show bodies
					space.liveBodies.foreach(updateGraphics);
					
					var t:Timer = new Timer(10000, 1);
					t.addEventListener(TimerEvent.TIMER, levelIntroComplete, false, 0, true);
					t.start();
				
				}else if (s.indexOf("***userData***") != -1) {
					//userData is sent once sweeps entry and thank you are shown
					var user:String = s.substr(s.indexOf("***userData***") + 14);
					var userData:Array = user.split(",");				
					//array is: fname,lname,email,phone,state,entry,optin,moreInfo,q1a,q2a,event
					userData.push(timeDisplay.getScore());
					webService.addUser(userData);
					
					newGame();
					
				}else if (s.indexOf("***instructions***") != -1) {
					intro.hide();
					instructions.show();
					
				}else if (s.indexOf("***avatar***") != -1) {
				
					//player is picking their avatar
					instructions.hide();
					avatars.show();
				
				}else if (s.indexOf("***avpoint***") != -1) {
					var i:int = parseInt(s.substr(s.indexOf("***avpoint***") + 13));//number 1-8 after string
					avatars.avatarClicked(i);
					
				}else if (s.indexOf("***answered***") != -1) {
					
					//user ansered a question on the controller
					levelIntro.hide();
					countdown.addEventListener(Countdown.COMPLETE, countdownComplete, false, 0, true);
					countdown.show();
					
				}else if (s.indexOf("***shutdown***") != -1) {
					NativeApplication.nativeApplication.exit();
				}
					
			}else {
				//game in progress
				var angVel:Number = (parseFloat(s) * -1) / 20;
					
				if (angVel < -4.5) {
					angVel = -4.5;
				}
				if (angVel > 4.5) {
					angVel = 4.5;
				}
				
				teeterBody.angularVel = angVel;
			}		
			
		}

		
		private function levelIntroComplete(e:TimerEvent):void
		{
			levelIntro.hide();
			
			teeterBody.allowMovement = true;
			playerCircleBody.allowMovement = true;
			playerCircleBody.allowRotation = true;
			
			teeterBody.angularVel = 0;
			playerCircleBody.angularVel = 0;
			
			currentBallSize = 15 + ((theLevel - 1) * 8);//15,23,31
			maxBallSize = 25 + ((theLevel - 1) * 10);//25,35,45	
			
			countdown.addEventListener(Countdown.COMPLETE, countdownComplete, false, 0, true);
			countdown.show();		
		}
		
		
		private function countdownComplete(e:Event):void
		{
			countdown.removeEventListener(Countdown.COMPLETE, countdownComplete);
			countdown.hide();
			startLevel();
		}
		
		
		private function clientDisconnect(e:Event):void			
		{
			clientConnected = false;
		}
		
		
		
		/**
		 * Resets physics
		 * calls newGame()
		 */
		private function levelEnd():void
		{
			disableShield();
			
			shapeTimer.reset(); //stop adding shapes
			sizeTimer.reset();
			timeDisplay.stop();
			
			//reset player and teeter position
			playerCircleBody.position.setxy(960, 727);
			playerCircleBody.rotation = 0;
			playerCircleBody.angularVel = 0;
			playerCircleBody.velocity = new Vec2(0, 0);
			playerCircleBody.allowMovement = false;
			playerCircleBody.allowRotation = false;
			
			teeterBody.rotation = 0;
			teeterBody.angularVel = 0;
			
			//remove all falling balls
			space.bodies.filter(function (body) {
				if (body.userData.ball || body.userData.shield) {
					removeChild(body.userData.graphic);
					return false;
				}
				return true;
			});			
			
			playingGame = false;
			
			
			theLevel++;
			if (theLevel > 3) {
				gameOver();				
			}else {
				
				 if (theLevel == 2) {
					 //level is 2 - show question 1
					 if (clientConnected) {
						server.sendToClient("questionOne");
					}
				 }else {
					 //level is 3 - show question 2
					 if (clientConnected) {
						server.sendToClient("questionTwo");
					}
				 }
				bg.gotoAndStop(theLevel);//background level graphic on stage
				levelIntro.show(theLevel);	
			}
		}
		
		
		/**
		 * Disables the shields physics
		 * called from levelEnd() and TweenMax when the shield fade out completes
		 */
		private function disableShield():void
		{
			shieldActive = false;
			
			if(shieldJoint){
				shieldJoint.space = null;
			}
			
			space.bodies.filter(function (body) {
				if (body.userData.shield) {
					removeChild(body.userData.graphic);
					return false;
				}
				return true;
			});
		}
		
		
		/**
		 * Called from countdownComplete()
		 */
		private function startLevel():void
		{			
			playingGame = true;			
			
			stage.addEventListener(Event.ENTER_FRAME, update);
			
			teeterBody.allowMovement = true;
			playerCircleBody.allowMovement = true;
			playerCircleBody.allowRotation = true;
			
			teeterBody.angularVel = 0;
			playerCircleBody.angularVel = 0;
			
			currentBallSize = 15 + ((theLevel - 1) * 8);//15,23,31
			maxBallSize = 25 + ((theLevel - 1) * 10);//25,35,45			
			
			shapeTimer.delay = 500 - ((theLevel - 1) * 100);//500,400,300					
			
			timeDisplay.start();//starts timer at upper right
			
			var lev:String = "LEVEL ";
			switch(theLevel){
				case 1:
					lev += "ONE";
					break;
				case 2:
					lev += "TWO";
					break;
				case 3:
					lev += "THREE";
					break;
			}
			
			pointsDisplay.show(new Point(960, 500), lev);//expanding text display
			timeDisplay.setLevel(theLevel);
			
			shapeTimer.start();
			sizeTimer.start();//calls makeHarder() - which increases currentBallSize - up to maxBallSize
		}
		
		
		/**
		 * Called by shapeTimer every 500ms
		 * Adds falling circle shapes
		 * @param	e
		 */
		private function addShape(e:TimerEvent = null):void
		{
			if(Math.random() < .55){
				var graphic:MovieClip;
				var ballShape:Circle;
				var body:Body = new Body(BodyType.DYNAMIC);				
				
				body.cbTypes.add(shapeCollisionType);//all falling circles - for collisions with floor				
				body.position.setxy(540 + Math.random() * 860, 50);
				
				if (Math.random() < .1) {
					
					//Add a Special icon
					ballShape = new Circle(30);
					switch(theLevel) {
						case 1:
							graphic = new mcShield();
							break;
						case 2:
							graphic = new mcCross();
							break;
						case 3:
							graphic = new mcSkull();
							break;
					}
					
					ballShape.material.density = 1;
					ballShape.material.elasticity = .2;
					body.cbTypes.add(shieldIconCollisionType);//for collisions with player
					graphic.width = graphic.height = 60;//radius * 2
					
				}else {		
					
					//Add a normal icon
					var randomSize:Number = Math.random() * 8;
					if (Math.random() < .5) {
						randomSize *= -1;
					}
					randomSize += currentBallSize;
					ballShape = new Circle(randomSize);
					graphic = icons.getIcon(theLevel);
					ballShape.material.density = randomSize * .082;					
					ballShape.material.elasticity = .666;
					graphic.width = graphic.height = randomSize * 2;
				}
				
				body.shapes.add(ballShape);
				body.userData.graphic = graphic;
				body.userData.ball = true;
				body.space = space;				
				
				addChild(graphic);
				graphic.x = body.position.x;
				graphic.y = body.position.y;				
			}
		}

		
		private function shapeHitFloor(collision:InteractionCallback):void 
		{
			//TODO: store in array so the bodies can react a bit before beign removed
			var body:Body = collision.int2 as Body;			
			
			if (body.userData.player) {					
				levelEnd();
			}else {
				try{
					body.space = null;
					removeChild(body.userData.graphic);
				}catch (e:Error) {
					
				}	
			}			
		}
		
		
		/**
		 * Callback for playerCollisionType vs shieldIconCollisionType
		 * Called when player hits a falling special icon
		 * @param	collision
		 */
		private function playerGotShield(collision:InteractionCallback):void 
		{
			switch(theLevel) {
				case 1:
					if(!shieldActive){
						var body:Body = collision.int2 as Body; //shield icon				
						body.space = null;
						removeChild(body.userData.graphic);//remove shield icon
						
						pointsDisplay.show(new Point(body.position.x, body.position.y), "HORIZON!");
						
						shieldActive = true;
						
						playerShield.position.setxy(playerCircleBody.position.x, playerCircleBody.position.y);				
						playerShield.space = space;
						if(!contains(shieldClip)){
							addChild(shieldClip);
							shieldClip.alpha = .6;				
						}
						
						//fade shield out with Expo - so it fades right at the end of the period
						TweenMax.to(shieldClip, 10, { alpha:0, ease:Expo.easeIn, onComplete:disableShield});
						
						var weldPoint:Vec2 = new Vec2(playerCircleBody.position.x, playerCircleBody.position.y);
						shieldJoint = new WeldJoint(playerCircleBody, playerShield, playerCircleBody.worldPointToLocal(weldPoint), playerShield.worldPointToLocal(weldPoint));
						shieldJoint.ignore = true;//ignore interactions between player and shield - so shield is centered over player
						shieldJoint.space = space;
					}
					break;
					
				case 2:
					break;
					
				case 3:
					break;
			}			
		}
		
		
		/**
		 * Callback for shieldCollisionType vs shapeCollisionType
		 * IE a falling icon hit the players shield
		 * @param	collision
		 */
		private function ballHitShield(collision:InteractionCallback):void
		{			
			var body:Body = collision.int2.castBody;
			pointsDisplay.show(new Point(body.position.x, body.position.y), "+50");
			timeDisplay.addBonus(50);
			var impulse:Vec2 = body.position.sub(playerShield.position);						
			body.applyImpulse(impulse.mul(40));			
		}		
		
		
		/**
		 * Game loop
		 * @param	e ENTER_FRAME
		 */
		private function update(e:Event):void
		{	
			//space.step(1/stage.frameRate);	//1/stage.frameRate
			//space.step(1/60);	//1/stage.frameRate
			space.step(.0167);	//1/stage.frameRate
			space.liveBodies.foreach(updateGraphics);
						
			switch(theLevel) {
				case 1:
					bg.clouds1.x += .2;
					bg.clouds2.x -= .1;
					if (bg.clouds1.x > 2100) {
						bg.clouds.x = -200;
					}
					if (bg.clouds2.x < -200) {
						bg.clouds.x = 2100;
					}
					break;
			}
		}
		
		
		/**
		 * Called from pdate() by forEach body in the space
		 * updates the game graphics based on the physics
		 * @param	body
		 */
		private function updateGraphics(body:Body):void
		{			
			var image:MovieClip = MovieClip(body.userData.graphic);
			image.x = body.position.x;
			image.y = body.position.y;
			image.rotation = body.rotation * RAD;	
			
			if (body.position.y > 1080) {
				
				//body missed the floor and is off screen				
				if (body.userData.player) {
					levelEnd();
				}else {
					body.space = null;	
					removeChild(body.userData.graphic);
				}
			}
		}
		
		
		/**
		 * Called every 2 seconds by sizeTimer
		 * increases currentBallSize so that the falling objects
		 * get larger and heavier - used in addShape()
		 * current and max are set in startLevel()
		 * @param	e
		 */
		private function makeHarder(e:TimerEvent):void
		{
			currentBallSize += 1;
			currentBallSize = Math.min(currentBallSize, maxBallSize);			
		}
		
	}
	
}