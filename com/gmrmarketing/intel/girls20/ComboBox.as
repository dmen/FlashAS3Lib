package com.gmrmarketing.intel.girls20
{
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import itemMask;
	
	//theText is top label
	
	public class ComboBox extends MovieClip
	{
		public const CHANGE:String = "selectionChanged";
		
		private var itemContainer:Sprite; //added to listContainer - holds individual item clips
		private var dragRange:int; //how many pixels the dragger can move
		private var listHeight:int; //total height of the list/item container
		private var fullHeight:int; //total height of the container once all items have been added
		private var dragRatio:Number; //full height of the clip being dragged divided by the dragger track height
		private var listMask:MovieClip;
		private var opened:Boolean;
		private var myRect:Rectangle;
		private var dragOffset:int;
		
		
		
		public function ComboBox()
		{
			itemContainer = new Sprite();
			listContainer.addChild(itemContainer);
			
			listHeight = listContainer.height;
			dragRange = listHeight - listContainer.drag.height;
			
			listMask = new itemMask(); //lib clip
			
			opened = false;
			
			btn.addEventListener(MouseEvent.MOUSE_DOWN, toggleDrop, false, 0, true);
			listContainer.drag.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			
			addEventListener(Event.ADDED_TO_STAGE, calcRect, false, 0, true);			
			//addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
		}
		
		
		private function calcRect(e:Event):void
		{
			myRect = new Rectangle(x, y, width, 54 + listHeight);			
		}
		
		
		private function toggleDrop(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			if(opened){
				closeCombo();
			}else{
				openCombo();
			}
		}
		
		
		private function closeCombo():void
		{			
			opened = false;
			TweenMax.to(listContainer, .5, { y: -252 } );
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, checkForClose);
		}
		
		
		private function openCombo():void
		{			
			opened = true;
			listContainer.drag.y = 0;
			itemContainer.y = 0;			
			TweenMax.to(listContainer, .5, { y:52 } );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, checkForClose, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 0, true);
		}
		
		
		private function checkForClose(e:MouseEvent):void
		{			
			if (!myRect.containsPoint(new Point(stage.mouseX, stage.mouseY))) {
				closeCombo();
			}
		}
		
		
		public function keyPressed(theKey:String):void
		{
			//find index 
			for (var i:int = 0; i < itemContainer.numChildren; i++) {
				var curItem:String = MovieClip(itemContainer.getChildAt(i)).theText.text;
				if (curItem.substr(0, 1) == theKey.toUpperCase()) {
					itemContainer.y = -1 * (MovieClip(itemContainer.getChildAt(i)).height * i);
					break;
				}
			}
		}
		
		
		public function populate(items:Array):void
		{			
			for(var i:int = 0; i < items.length; i++){
				var item:MovieClip = new countryItem(); //lib clip
				item.theText.text = items[i];
				itemContainer.addChild(item);
				item.y = item.height * i; //37
				item.addEventListener(MouseEvent.MOUSE_DOWN, itemClicked, false, 0, true);
			}
			
			theText.text = "";
			
			fullHeight = itemContainer.height - listHeight; //height of all items
			dragRatio = fullHeight / dragRange;
			
			listContainer.addChild(listMask);
			itemContainer.mask = listMask;
		}
		
		
		public function setSelection(sel:String):void
		{
			theText.text = sel;
		}
		
		
		public function getSelection():String
		{
			return theText.text;
		}
		
		
		public function reset():void
		{
			theText.text = "";
		}
		
		
		private function itemClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(CHANGE));
			theText.text = e.currentTarget.theText.text;
			e.currentTarget.highlight.alpha = 1;
			TweenMax.to(e.currentTarget.highlight, .25, { alpha:0 } );
			closeCombo();			
		}

		
		/**
		 * Called by MOUSE_DOWN on the dragger - listContainer.drag
		 * @param	e
		 */
		private function beginDrag(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			addEventListener(Event.ENTER_FRAME, updateDrag, false, 0, true);
			dragOffset = listContainer.drag.mouseY;
		}
		
		
		private function updateDrag(e:Event):void
		{
			listContainer.drag.y  = listContainer.mouseY - dragOffset;
			
			if(listContainer.drag.y < 0){listContainer.drag.y = 0;}
			if(listContainer.drag.y > dragRange){listContainer.drag.y = dragRange;}	
			
			itemContainer.y  = -1 * listContainer.drag.y * dragRatio;
		}
		
		
		private function endDrag(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrag);
		}
		
		
		private function cleanUp(e:Event):void
		{			
			removeEventListener(Event.ENTER_FRAME, updateDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, checkForClose);			
		}
		
	}
	
}