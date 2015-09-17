package com.gmrmarketing.comcast.book3d
{
	import flare.basic.*;
	import flare.collisions.*;
	import flare.core.*;
	import flare.events.*;
	import flare.modifiers.*;
	import flare.primitives.*;
	import flash.filters.BlurFilter;
	
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Vector3D;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	import com.gmrmarketing.utilities.Utility;
	//import com.gmrmarketing.particles.Dust;
	
	public class Main extends MovieClip
	{
		private var _scene:Scene3D;
		private var _camera:Camera3D;
		private var sceneContainer:Sprite;
		
		private var model:Pivot3D;
		private var book:Pivot3D;
		private var clickPage:Pivot3D;
		
		private var tweenObject:Object;
		
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		
		private var schoolList:SchoolList;
		private var intro:Intro;
		private var form:Form;
		private var instructions:Instructions;
		private var winLose:WinLose;
		private var vignette:Vignette;
		
		private var meshL:Mesh3D;
		private var skinL:SkinModifier;
		private var pageL:Pivot3D;
		private var meshM:Mesh3D;
		private var skinM:SkinModifier;
		private var pageM:Pivot3D;
		private var meshR:Mesh3D;
		private var skinR:SkinModifier;
		private var pageR:Pivot3D;
		private var ipad:Mesh3D;
		
		private var shuffle1:Mesh3D;
		private var shuffle2:Mesh3D;
		private var shufflePos1:Vector3D;
		private var shufflePos1End:Vector3D;
		private var shufflePos2:Vector3D;
		private var shufflePos2End:Vector3D;		
		
		private var theBooks:Array;
		private var bookPositions:Array;//initial positions of the three books - used to reset positions in init()
		private var shuffleSpeed:Number;
		
		private var sequences:Array;
		private var currentSequence:Array;//one sequence from sequences
		private var sequenceIndex:int;//index in currentSequence
		
		private var windex:int; //index of the winning book
		private var didWin:Boolean;
		
		private var shadowLight:ShadowProjector3D;		
		
		private var queue:Queue;		
		
		private var mainContainer:Sprite;
		private var vignetteContainer:Sprite;
		
		
		public function Main()
		{
			sceneContainer = new Sprite();
			mainContainer = new Sprite();
			vignetteContainer = new Sprite();
			
			schoolList = new SchoolList();
			schoolList.addEventListener(SchoolList.COMPLETE, showSchoolList);
			schoolList.container = mainContainer;
			
			intro = new Intro();
			intro.container = mainContainer;
			
			form = new Form();
			form.container = mainContainer;
			
			instructions = new Instructions();
			instructions.container = mainContainer;
			
			vignette = new Vignette();
			vignette.container = vignetteContainer;
			
			winLose = new WinLose();
			winLose.container = mainContainer;
			
			tweenObject = { };
			
			queue = new Queue();
			
			sequences = [[0,1,0,2,1,2,0,1,1,2,0,2,1,2,0,1,0,2,1,2], [1,2,0,2,0,1,0,2,1,2,0,2,0,1,1,2,0,1,0,2], [0,2,1,2,0,1,0,2,1,2,0,2,0,1,1,2,0,2,1,2],[1,2,0,1,0,2,0,1,1,2,0,2,1,2,0,1,1,2,0,1,0,2,1,2]];
			
			_scene = new Scene3D(sceneContainer);
			_scene.clearColor = new Vector3D ();
			_scene.antialias = 4;			
		
			addChildAt(sceneContainer, 0);//behind book click sprites
			addChild(vignetteContainer);
			addChild(mainContainer);			
			/*
			for (var i:int = 0; i < 75; i++) {
				var d:Sprite = new Dust();
				d.x = Math.random() * 1024;
				d.y = Math.random() * 768;
				dustContainer.addChild(d);
			}*/
		}
		
		
		private function showSchoolList(e:Event):void
		{
			schoolList.show();
			schoolList.removeEventListener(SchoolList.COMPLETE, showSchoolList);
			schoolList.addEventListener(SchoolList.SELECTED, schoolSelected);
		}
		
		
		private function schoolSelected(e:Event):void
		{
			schoolList.removeEventListener(SchoolList.SELECTED, schoolSelected);
			schoolList.hide();
			
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );
			model = _scene.addChildFromFile("xfin.zf3d");
			_scene.pause();
		}
		
		
		private function mapLoaded(e:Event):void
		{
			_scene.resume();
			_scene.removeEventListener( Scene3D.COMPLETE_EVENT, mapLoaded );						
			
			_camera = _scene.camera;
			
			meshL = model.getChildByName("bookL") as Mesh3D;			
			skinL = meshL.modifier as SkinModifier;
			pageL = skinL.root.getChildByName( "Page_L" );
			
			meshM = model.getChildByName("bookM") as Mesh3D;			
			skinM = meshM.modifier as SkinModifier;
			pageM = skinM.root.getChildByName( "Page_L" );	
			
			meshR = model.getChildByName("bookR") as Mesh3D;			
			skinR = meshR.modifier as SkinModifier;
			pageR = skinR.root.getChildByName( "Page_L" );
			
			ipad = model.getChildByName("iPad2") as Mesh3D;			
			
			bookPositions = [meshL.getPosition(false), meshM.getPosition(false), meshR.getPosition(false)];
			init();
		}
		
		
		/**
		 * Closes all three books and moves the ipad out of view
		 */
		private function init():void
		{	
			winLose.hide();			
			
			_camera.fieldOfView = 42.96;
			
			theBooks = [meshL, meshM, meshR];
			
			meshL.setPosition(bookPositions[0].x, bookPositions[0].y, bookPositions[0].z, 1, false);
			meshM.setPosition(bookPositions[1].x, bookPositions[1].y, bookPositions[1].z, 1, false);
			meshR.setPosition(bookPositions[2].x, bookPositions[2].y, bookPositions[2].z, 1, false);
			
			pageL.setRotation(90, 0, 180);
			pageM.setRotation(90, 0, 180);			
			pageR.setRotation(90, 0, 180);
			
			ipad.setPosition( -1.27, 0.14, 4, 1, false);			
			
			tweenObject.fov = 42.96
			tweenObject.mult = 0;//light multiplier
						
			vignette.show();
			intro.show();			
			intro.addEventListener(Intro.CLICKED, showForm);
			
			bookL.removeEventListener(MouseEvent.MOUSE_DOWN, bookLClicked);
			bookM.removeEventListener(MouseEvent.MOUSE_DOWN, bookMClicked);
			bookR.removeEventListener(MouseEvent.MOUSE_DOWN, bookRClicked);
			//TweenMax.delayedCall(.2, scenePause);
		}
		private function scenePause():void
		{
			_scene.pause();
		}
		
		
		private function showForm(e:Event):void
		{
			form.show();
			intro.hide();
			form.addEventListener(Form.COMPLETE, showInstructions, false, 0, true);
		}
		
		
		private function showInstructions(e:Event):void
		{
			form.removeEventListener(Form.COMPLETE, showInstructions);
			form.hide();
			instructions.addEventListener(Instructions.INST_COMPLETE, startDolly, false, 0, true);
			instructions.show();
		}		
		
		private function startDolly(e:Event):void
		{	
			instructions.removeEventListener(Instructions.INST_COMPLETE, startDolly);
			instructions.hide();
			vignette.hide(.5);			
			//_scene.resume();
			TweenMax.to(tweenObject, 3, { fov:71.06, mult:1, onUpdate:dollyCamera } );			
			
			TweenMax.delayedCall(3, openAllBooks);
			TweenMax.delayedCall(4, bringInIpad);
		}
		
		
		private function dollyCamera():void
		{
			_camera.fieldOfView = tweenObject.fov;			
		}
		
		
		private function openAllBooks():void
		{
			tweenObject.r = 0;
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:rotateAll } );
		}
		
		
		private function closeAllBooks():void
		{
			tweenObject.r = 110;
			TweenMax.to(tweenObject, 1, { r:0, onUpdate:rotateAll } );
		}
		
		
		private function bringInIpad():void
		{
			tweenObject.i = 4;
			TweenMax.to(tweenObject, 1, { i:-1.26, onUpdate:moveIpad, onComplete:lowerIpad } );
		}
		
		
		private function moveIpad():void
		{			
			ipad.setPosition( -1.17, .14, tweenObject.i, 1, false);
		}
		
		
		//move down on Y - into book
		private function lowerIpad():void
		{
			tweenObject.i = 0.14; //current y
			TweenMax.to(tweenObject, .5, { i: -.02, onUpdate:moveIpadVertically, onComplete:closeAllBooks } );			
			TweenMax.delayedCall(1.5, startShuffle);
		}
		
		
		private function moveIpadVertically():void
		{
			ipad.setPosition( -1.17, tweenObject.i, -1.26, 1, false);			
		}
		
		
		private function rotateOne():void
		{
			clickPage.setRotation(90, 0, 180 + tweenObject.r);
		}
		
		
		private function rotateAll():void
		{
			pageL.setRotation(90, 0, 180 + tweenObject.r);
			pageM.setRotation(90, 0, 180 + tweenObject.r);
			pageR.setRotation(90, 0, 180 + tweenObject.r);
		}
		
		
		private function startShuffle():void
		{			
			//hide ipad
			ipad.visible = false;	
			
			var ind:int = Math.floor(Math.random() * sequences.length);
			currentSequence = sequences[ind];
			sequenceIndex = -2;//index in the currently selected sequence					
			
			shuffleSpeed = .6;
			nextShuffle();		
		}
		
		
		private function nextShuffle():void
		{
			shuffleSpeed -= .1;
			shuffleSpeed = shuffleSpeed < .35 ? .35 : shuffleSpeed;
			
			sequenceIndex += 2;			
			
			if (sequenceIndex < currentSequence.length) {
				shuffle();
			}else {
				addMouseListeners()
			}			
		}
		
		private function shuffle():void
		{
			shuffle1 = theBooks[currentSequence[sequenceIndex]];
			shufflePos1 = shuffle1.getPosition(false);
		
			shuffle2 = theBooks[currentSequence[sequenceIndex + 1]];
			shufflePos2 = shuffle2.getPosition(false);
			
			shufflePos1End = shufflePos2;
			shufflePos2End = shufflePos1;			
			
			var temp:Mesh3D = theBooks[currentSequence[sequenceIndex + 1]];
			theBooks[currentSequence[sequenceIndex + 1]] = theBooks[currentSequence[sequenceIndex]];
			theBooks[currentSequence[sequenceIndex]] = temp;
			
			//y to .8 to move up
			tweenObject.r = 0;
			tweenObject.r1 = 0;
			TweenMax.to(tweenObject, shuffleSpeed * .5, { r:.5, r1:1, onUpdate:shuffleBooksUp, onComplete:shuffleSwap});
		}
		
		
		private function shuffleBooksUp():void
		{			
			shuffle1.setPosition(shufflePos1.x, tweenObject.r, shufflePos1.z, 1, false);
			shuffle2.setPosition(shufflePos2.x, tweenObject.r1, shufflePos2.z, 1, false);
		}
		
		
		private function shuffleSwap():void
		{
			var p1p:Vector3D = shuffle1.getPosition(false);
			var p2p:Vector3D = shuffle2.getPosition(false);				
			
			tweenObject.p1x = p1p.x;
			tweenObject.p1y = p1p.y;
			tweenObject.p1z = p1p.z;
			
			tweenObject.p2x = p2p.x;
			tweenObject.p2y = p2p.y;
			tweenObject.p2z = p2p.z;
			
			TweenMax.to(tweenObject, shuffleSpeed, { p1x:shufflePos1End.x, onUpdate:shuffleSwapAnim, onComplete:shuffleDown } );
			TweenMax.to(tweenObject, shuffleSpeed, { p2x:shufflePos2End.x } );
		}
		
		
		private function shuffleSwapAnim():void
		{
			shuffle1.setPosition(tweenObject.p1x, tweenObject.p1y, tweenObject.p1z, 1, false);
			shuffle2.setPosition(tweenObject.p2x, tweenObject.p2y, tweenObject.p2z, 1, false);
		}
		
		
		private function shuffleDown():void
		{
			var p1p:Vector3D = shuffle1.getPosition(false);
			var p2p:Vector3D = shuffle2.getPosition(false);
			tweenObject.p1x = p1p.x;
			tweenObject.p1y = p1p.y;
			tweenObject.p1z = p1p.z;
			
			tweenObject.p2x = p2p.x;
			tweenObject.p2y = p2p.y;
			tweenObject.p2z = p2p.z;
			TweenMax.to(tweenObject, shuffleSpeed * .5, { p1y:0, onUpdate:shuffleBooksDown, onComplete:nextShuffle } );
			TweenMax.to(tweenObject, shuffleSpeed * .5, { p2y:0 } );
		}
		
		
		private function shuffleBooksDown():void
		{
			shuffle1.setPosition(tweenObject.p1x, tweenObject.p1y, tweenObject.p1z, 1, false);
			shuffle2.setPosition(tweenObject.p2x, tweenObject.p2y, tweenObject.p2z, 1, false);
		}
		
		
		private function addMouseListeners():void
		{
			ipad.visible = true;
			
			windex = theBooks.indexOf(meshM);
			didWin = false;
			
			var bv:Vector3D = theBooks[windex].getPosition(false);
			
			ipad.setPosition(bv.x - .95, bv.y - .025, bv.z - 1.25, 1, false);
			
			bookL.addEventListener(MouseEvent.MOUSE_DOWN, bookLClicked);
			bookM.addEventListener(MouseEvent.MOUSE_DOWN, bookMClicked);
			bookR.addEventListener(MouseEvent.MOUSE_DOWN, bookRClicked);
		}
		
		
		private function bookLClicked(e:MouseEvent):void
		{	
			var mesh:Mesh3D = theBooks[0];			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			clickPage = skin.root.getChildByName( "Page_L" );
			
			if (windex == 0) {
				didWin = true;
			}
			
			tweenObject.r = 0;		
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:rotateOne, onComplete:showWinLose } );
		}
		
		
		private function bookMClicked(e:MouseEvent):void
		{
			var mesh:Mesh3D = theBooks[1];			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			clickPage = skin.root.getChildByName( "Page_L" );
			
			if (windex == 1) {
				didWin = true;
			}
			
			tweenObject.r = 0;		
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:rotateOne, onComplete:showWinLose } );
		}
		
		
		private function bookRClicked(e:MouseEvent):void
		{
			var mesh:Mesh3D = theBooks[2];			
			var skin:SkinModifier = mesh.modifier as SkinModifier;
			clickPage = skin.root.getChildByName( "Page_L" );
			
			if (windex == 2) {
				didWin = true;
			}
			
			tweenObject.r = 0;		
			TweenMax.to(tweenObject, 1, { r:110, onUpdate:rotateOne, onComplete:showWinLose } );
		}		
		
		
		private function showWinLose():void
		{
			vignette.show();
			
			winLose.show(didWin ? "win" : "lose");
			winLose.addEventListener(WinLose.COMPLETE, restart);
			/*
			firstName: 'ravi', 
			lastName: 'pujari', 
			school: 'University of Wisconsin', 
			wonShellGame: true, 
			dp: '2015-09-01T04:37:11.035Z', 
			Email : 'pujarit@gmail.com',
			PhoneNumber : '6147472636', 
			Agree : true, 
			OptIn : false
			*/
			
			var userData:Object = form.userData; //firstName,lastName,PhoneNumber,Agree,(OptIn)
			
			//Email no longer in the form
			userData.Email = "";
			
			userData.school = schoolList.selected.label;
			userData.wonShellGame = didWin;
			userData.dp = Utility.hubbleTimeStamp;
			
			queue.add(userData);
		}
		
		private function restart(e:Event):void
		{			
			winLose.removeEventListener(WinLose.COMPLETE, restart);
			init();
		}
	}
	
}