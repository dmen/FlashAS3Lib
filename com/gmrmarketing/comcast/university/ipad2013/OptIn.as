package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;	
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.SliderV;
	import com.gmrmarketing.utilities.Validator;
	
	public class OptIn extends EventDispatcher
	{
		public static const OPTIN_SHOWING:String = "optinShowing";
		public static const OPTIN_COMPLETE:String = "optinComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		private var schools:Array; //for the dataProvider
		private var slider:SliderV;
		private var initialY:int;
		private var heightOver:int;
		private var schoolID:int;
		
		
		public function OptIn()
		{
			clip = new mcOptIn();
			
			initialY = clip.theList.y;
			heightOver = clip.theList.height - clip.theMask.height;
			
			slider = new SliderV(clip.slide, clip.track);			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			closeSchoolList();
			
			clip.error.alpha = 0;
			//clip.theSchool.text = "Choose your school";
			clip.theEmail.text = "Enter your email";
			clip.theEmail.addEventListener(MouseEvent.MOUSE_DOWN, clearEmail, false, 0, true);
			clip.check1.visible = false;
			clip.check2.visible = false;
			clip.outline.visible = false;
			clip.btnCheck1.addEventListener(MouseEvent.MOUSE_DOWN, check1Clicked, false, 0, true);
			clip.btnCheck2.addEventListener(MouseEvent.MOUSE_DOWN, check2Clicked, false, 0, true);
			clip.btnList.addEventListener(MouseEvent.MOUSE_DOWN, openSchoolList, false, 0, true);
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, playClicked, false, 0, true);
			slider.addEventListener(SliderV.DRAGGING, updateSchoolList, false, 0, true);
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
		}
		
		/*
		public function getSchool():String
		{
			return clip.theSchool.text;
		}*/
		
		public function getRegData():Object
		{
			var o:Object = new Object();
			o.id = schoolID;
			o.email = clip.theEmail.text;
			o.optInAge = clip.check1.visible == true ? "true" : "false";
			o.optInEmail = clip.check2.visible == true ? "true" : "false";
			return o;
		}
		
		
		public function getSchoolID():int
		{
			return schoolID;
		}
		
		
		public function getEmail():String
		{
			return clip.theEmail.text;
		}
		
		
		private function clearEmail(e:MouseEvent):void
		{
			if (clip.theEmail.text == "Enter your email") {
				clip.theEmail.text = "";
			}
		}
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			
			clip.theEmail.removeEventListener(MouseEvent.MOUSE_DOWN, clearEmail);
			clip.btnCheck1.removeEventListener(MouseEvent.MOUSE_DOWN, check1Clicked);
			clip.btnCheck2.removeEventListener(MouseEvent.MOUSE_DOWN, check2Clicked);
			clip.btnList.removeEventListener(MouseEvent.MOUSE_DOWN, openSchoolList);
			clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, playClicked);
			slider.removeEventListener(SliderV.DRAGGING, updateSchoolList);
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(OPTIN_SHOWING));
		}
		
		
		private function openSchoolList(e:MouseEvent):void
		{
			if(!clip.theList.visible){
				clip.theList.visible = true;
				clip.slide.y = clip.track.y;
				clip.theList.y = initialY;
				clip.slide.visible = true;
				clip.track.visible = true;
				clip.outline.visible = true;
				//add listeners
				for(var i:int = 1000; i < 1041; i++){
					clip.theList["u" + i].addEventListener(MouseEvent.MOUSE_DOWN, schoolClicked, false, 0, true);
				}
			}else {
				closeSchoolList();
			}
		}
		
		
		private function updateSchoolList(e:Event):void
		{
			clip.theList.y = initialY - (heightOver * slider.getPosition());
		}
		
		
		private function schoolClicked(e:MouseEvent):void
		{
			schoolID = parseInt(String(e.currentTarget.name).substr(1));			
			TweenMax.from(MovieClip(e.currentTarget).hit, .2, { alpha:1, onComplete:closeSchoolList } );
			clip.theSchool.text = MovieClip(e.currentTarget).theText.text;			
		}
		
		
		private function closeSchoolList():void
		{
			//school list dropdown
			clip.theList.visible = false;
			clip.slide.visible = false;
			clip.track.visible = false;
			clip.outline.visible = false;
			//remove listeners
			for(var i:int = 1000; i < 1041; i++){
				clip.theList["u" + i].removeEventListener(MouseEvent.MOUSE_DOWN, schoolClicked);
			}
		}
		
		
		private function playClicked(e:MouseEvent):void
		{			
			TweenMax.from(clip.btnPlay, .2, { alpha:1 } );
			if (clip.theSchool.text == "Choose your school"){			
				showError("Please choose your school");				
			}else if (clip.theEmail.text == "Enter your email" || !Validator.isValidEmail(clip.theEmail.text)) {
				showError("Please enter a valid email");
			}else if (!clip.check1.visible) {
				showError("Rules acknowlegement required");
			}else {							
				dispatchEvent(new Event(OPTIN_COMPLETE));
			}
		}
		
		
		public function showError(mess:String):void
		{			
			TweenMax.killTweensOf(clip.error);
			clip.error.theText.text = mess;
			clip.error.alpha = 1;
			TweenMax.to(clip.error, 2, { alpha:0, delay:2 } );
		}
		
		
		private function check1Clicked(e:MouseEvent):void
		{
			clip.check1.visible = !clip.check1.visible;
		}
		
		private function check2Clicked(e:MouseEvent):void
		{
			clip.check2.visible = !clip.check2.visible;
		}
	}
	
}


