package com.gmrmarketing.humana.gifbooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class EmailReview extends EventDispatcher
	{
		public static const SHOWING:String = "emailReviewShowing";
		public static const COMPLETE:String = "emailReviewComplete";
		public static const ADD_PERSON:String = "emailReviewAdd";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var itemContainer:Sprite;
		private var items:Array;
		private var tim:TimeoutHelper;
		
		
		public function EmailReview()
		{
			clip = new mcEmailReview();
			
			itemContainer = new Sprite();
			clip.addChild(itemContainer);
			itemContainer.x = 450;
			itemContainer.y = 400;
			
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		
		/**
		 * 
		 * @param	data Array of objects with email,phone,opt keys
		 */
		public function show(data:Array):void
		{
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.btnFinish.addEventListener(MouseEvent.MOUSE_DOWN, doFinish, false, 0, true);
			clip.btnAdd.addEventListener(MouseEvent.MOUSE_DOWN, doAdd, false, 0, true);
			
			items = data;
			
			addData();
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function addData():void
		{
			while (itemContainer.numChildren) {
				itemContainer.removeChildAt(0);
			}
			
			for (var i:int = 0; i < items.length; i++) {
				var m:MovieClip = new mcEmailItem();				
				m.y = 60 * i;
				m.email.text = items[i].email;
				m.phone.text = items[i].phone;
				m.arrayIndex = i; //inject 
				m.btnRemove.addEventListener(MouseEvent.MOUSE_DOWN, removeItem, false, 0, true);				
				itemContainer.addChild(m);
			}
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			while (itemContainer.numChildren) {
				itemContainer.removeChildAt(0);
			}
			
			clip.btnFinish.removeEventListener(MouseEvent.MOUSE_DOWN, doFinish);
			clip.btnAdd.removeEventListener(MouseEvent.MOUSE_DOWN, doAdd);
		}
		
		
		private function doFinish(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (items.length > 0) {
				dispatchEvent(new Event(COMPLETE));
			}else {
				message("Please enter at least one email or phone number");
			}
		}
		
		
		private function doAdd(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(ADD_PERSON));
		}
		
		
		private function removeItem(e:MouseEvent):void
		{
			tim.buttonClicked();
			//trace(MovieClip(e.currentTarget.parent).arrayIndex);
			items.splice(MovieClip(e.currentTarget.parent).arrayIndex, 1);
			addData();//redraw the items list
		}
		
		
		private function message(m:String):void
		{
			clip.theTitle.text = m;			
			TweenMax.to(clip.theTitle, .5, { alpha:0, delay:2, onComplete:doTitle } );
		}
		
		
		private function doTitle():void
		{
			clip.theTitle.text = "Review Email and Phone";
			TweenMax.to(clip.theTitle, .5, { alpha:1 } );
		}
		
	}
	
}