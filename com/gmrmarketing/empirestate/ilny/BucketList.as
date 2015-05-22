/**
 * The visual bucket list slide out in the app
 * used by Map.as
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.filesystem.*;
	import org.gestouch.gestures.TransformGesture;
	import org.gestouch.events.GestureEvent;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class BucketList
	{		
		private var clip:MovieClip;//mcBucketList
		private var myContainer:DisplayObjectContainer;
		private var itemContainer:Sprite;
		private var interests:InterestsManager;//the users actual bucket list
		private var tranGes:TransformGesture;
		private var itemMask:Shape;
		private var tim:TimeoutHelper;
		
		
		public function BucketList()
		{
			clip = new mcBucketList();
			clip.x = 69;// 359;
			clip.y = 225;			
			
			itemContainer = new Sprite();
			clip.addChild(itemContainer);
			itemContainer.x = 1;
			itemContainer.y = 44;
			
			itemMask = new Shape();
			itemMask.graphics.beginFill(0x00FF00, 1);
			itemMask.graphics.drawRect(0, 0, 290, 811);
			itemMask.graphics.endFill();
			itemMask.x = 0;
			itemMask.y = 44;
			clip.addChild(itemMask);
			
			itemContainer.mask = itemMask;
			
			tranGes = new TransformGesture(itemContainer);
			
			interests = InterestsManager.getInstance();
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_ENDED, onGestureEnded);
			tranGes.addEventListener(org.gestouch.events.GestureEvent.GESTURE_CANCELLED, onGestureEnded);
			clip.btnBucket.addEventListener(MouseEvent.MOUSE_DOWN, toggleList);
			clip.btnHeader.addEventListener(MouseEvent.MOUSE_DOWN, toggleList);
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1 } );
			update();
		}
		
		
		public function hide():void
		{
			clip.x = 69;
			clip.btnBucket.x = 290;
		}
		
		/**
		 * called from Map.hide
		 */
		public function kill():void
		{
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_BEGAN, onGesture);
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_CHANGED, onGesture);
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_ENDED, onGestureEnded);
			tranGes.removeEventListener(org.gestouch.events.GestureEvent.GESTURE_CANCELLED, onGestureEnded);
			clip.btnBucket.removeEventListener(MouseEvent.MOUSE_DOWN, toggleList);
			clip.btnHeader.removeEventListener(MouseEvent.MOUSE_DOWN, toggleList);
			hide();
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}		
		}
		
		
		/**
		 * Called from Map.updateInterests()
		 */
		public function update():void
		{			
			while (itemContainer.numChildren) {
				itemContainer.removeChildAt(0);
			}
			
			var list:Array = interests.interests;
			for (var i:int = 0; i < list.length; i++) {
				var a:MovieClip = new mcBucketItem();
				a.title.text = list[i].name;
				a.region.text = list[i].city + ", " + list[i].region;
				a.y = itemContainer.numChildren * 69;
				a.listIndex = i;//inject list index for deleteClicked
				a.btnDelete.addEventListener(MouseEvent.MOUSE_DOWN, deleteClicked, false, 0, true);
				//load image
				var f:File = File.applicationDirectory.resolvePath("detailImages/" + list[i].name + ".jpg");
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				a.addChild(l);
				l.x = 6; 
				l.y = 4;		
					
				if (f.exists) {								
					l.load(new URLRequest(f.nativePath));
				}else {
					//show default
					switch(list[i].cat1) {
						case "Must See":
							l.load(new URLRequest("detailImages/Default_MustSee.png"));
							break;
						case "History":
							l.load(new URLRequest("detailImages/Default_History.png"));
							break;
						case "Family Fun":
							l.load(new URLRequest("detailImages/Default_FamilyFun.png"));
							break;
						case "Family Fun":
							l.load(new URLRequest("detailImages/Default_FamilyFun.png"));
							break;
						case "Wineries":
							l.load(new URLRequest("detailImages/Default_Wineries.png"));
							break;
						case "Breweries":
							l.load(new URLRequest("detailImages/Default_Breweries.png"));
							break;
						case "Wineries":
							l.load(new URLRequest("detailImages/Default_Wineries.png"));
							break;
						case "Art & Culture":
							l.load(new URLRequest("detailImages/Default_Culture.png"));
							break;
						case "Parks and Beaches":
							l.load(new URLRequest("detailImages/Default_Parks.png"));
							break;
					}
				}
				
				itemContainer.addChild(a);
			}
		}
		
		
		private function toggleList(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.x == 359) {
				//move in
				TweenMax.to(clip, .3, { x:69 } );
				TweenMax.to(clip.btnBucket, .3, { x:290 } );
			}else {
				//move out
				TweenMax.to(clip, .3, { x:359 } );
				TweenMax.to(clip.btnBucket, .3, { x:0 } );
			}
		}
		
		
		private function imageLoaded(e:Event):void
		{
			LoaderInfo(e.target).loader.width = 70;
			LoaderInfo(e.target).loader.height = 62;
			Bitmap(LoaderInfo(e.target).loader.content).smoothing = true;
		}
		
		
		private function onGesture(e:org.gestouch.events.GestureEvent):void
		{			
			tim.buttonClicked();
			var matrix:Matrix = itemContainer.transform.matrix;
			matrix.translate(0, tranGes.offsetY);
			itemContainer.transform.matrix = matrix;
		}
		
		
		private function onGestureEnded(e:org.gestouch.events.GestureEvent):void
		{
			if (itemContainer.height < 811) {
				//not long enough to fill entire list space... can't be moved...
				TweenMax.to(itemContainer, .3, { y:44 } );
			}else {
				//list is longer than the viewing space
				if (itemContainer.y > 44) {
					TweenMax.to(itemContainer, .3, { y:44 } );
				}
				if (itemContainer.y + itemContainer.height < 855) {
					var diff:int = 855 - (itemContainer.y + itemContainer.height);
					TweenMax.to(itemContainer, .3, { y:itemContainer.y + diff } );
				}
			}
		}
		
		
		private function deleteClicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			var list:Array = interests.interests;
			var i:int = MovieClip(e.currentTarget.parent).listIndex;
			interests.remove(i);
		}
		
	}
	
}