package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Form extends EventDispatcher
	{
		public static const FORM_SHOWING:String = "formShowing";
		public static const FORM_COMPLETE:String = "formComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Form()
		{
			clip = new mcForm();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(email:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.btnPlay.addEventListener(MouseEvent.MOUSE_DOWN, formSubmit, false, 0, true);
			
			clip.fname.text = "";
			clip.lname.text = "";
			clip.add1.text = "";
			clip.add2.text = "";
			clip.city.text = "";
			clip.state.text = "";
			clip.zip.text = "";
			clip.email.text = email;
			clip.phone.text = "";
			clip.phone.restrict = "-0-9.";
			clip.zip.restrict = "0-9";
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(FORM_SHOWING));
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		/**
		 * Returns the current form data as an object
		 * Object properties are fname,lname,add1,add2,city,state,zip,phone,email
		 * @return
		 */
		public function getFormData():Object
		{
			var o:Object = new Object();
			o.fname = clip.fname.text;
			o.lname = clip.lname.text;
			o.add1 = clip.add1.text;
			o.add2 = clip.add2.text;
			o.city = clip.city.text;
			o.state = clip.state.text;
			o.zip = clip.zip.text;
			o.phone = clip.phone.text;
			o.email = clip.email.text;
			return o;
		}
	
		
		private function formSubmit(e:MouseEvent):void
		{
			if (clip.fname.text == "" || clip.lname.text == "" || clip.add1.text == "" || clip.city.text == "" || clip.state.text == "" || clip.zip.text == "" || clip.phone.text == "") {
				showError("All fields must be completed");
			}else {
				clip.btnPlay.removeEventListener(MouseEvent.MOUSE_DOWN, formSubmit);
				dispatchEvent(new Event(FORM_COMPLETE));
			}
		}
		
		
		private function showError(mess:String):void
		{
			clip.error.theText.text = mess;
			clip.error.alpha = 1;
			TweenMax.to(clip.error, 2, { alpha:0, delay:2 } );
		}
		
	}
	
}