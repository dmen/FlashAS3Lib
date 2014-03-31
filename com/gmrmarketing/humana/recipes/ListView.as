package com.gmrmarketing.humana.recipes
{
	import flash.display.*;	
	import flash.events.*;		
	import flash.net.*;
	import com.greensock.TweenMax;
	import flash.utils.getTimer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class ListView extends EventDispatcher
	{		
		public static const RECIPE_CLICKED:String = "recipeClicked";
		
		private var container:DisplayObjectContainer;
		private var clickY:Number; //initial y position when clicking to scroll
		private var initialContentY:Number;
		private var offsetY:Number;
		private var lastMousePos:Number;
		private var mouseDelta:Number;//mouse movement since last update
		private var selectedRecipeIndex:int;
		
		private var startClickTime:int;
		private var timeout:TimeoutHelper;
		
		
		public function ListView()
		{
			timeout = TimeoutHelper.getInstance();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function getSelectedRecipeIndex():int
		{
			return selectedRecipeIndex;
		}
		
		/**
		 * recipes is an xml list of categories
		 * @param	recipes
		 */
		public function show(recipes:XMLList):void
		{
			var numCategories:int = recipes.length();
			var numRecipes:int;
			var titleClip:MovieClip;
			var itemClip:MovieClip;
			var curY:int = 262; //start under the header graphic
			var recipeIndex:int = 0;
			
			for (var i:int = 0; i < numCategories; i++) {				
				
				titleClip = new mc_listTitle();
				titleClip.theText.text = recipes[i].@title;				
				container.addChild(titleClip);
				titleClip.y = curY;
				
				var iconLoader:Loader = new Loader();
				iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bitmapLoaded, false, 0, true);
				iconLoader.x = 30;
				iconLoader.y = curY + 19;
				iconLoader.load(new URLRequest(recipes[i].@icon));
				container.addChild(iconLoader);
				
				curY += titleClip.height;				
				
				numRecipes = recipes[i].recipe.length();
				for (var j:int = 0; j < numRecipes; j++) {
					
					itemClip = new mc_listRecipe();
					itemClip.theText.text = recipes[i].recipe[j].title;					
					itemClip.theText.mouseEnabled = false;
					container.addChild(itemClip);
					itemClip.y = curY;
					itemClip.recipeIndex = recipeIndex;
					recipeIndex++;
					itemClip.addEventListener(MouseEvent.MOUSE_DOWN, recipeClickDown, false, 0, true);
					itemClip.addEventListener(MouseEvent.MOUSE_UP, recipeClickUp, false, 0, true);
					
					//thumbnail image
					var thumbLoader:Loader = new Loader();
					thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bitmapLoaded, false, 0, true);
					thumbLoader.x = 614;
					thumbLoader.y = 0;
					thumbLoader.load(new URLRequest(recipes[i].recipe[j].listImage));
					itemClip.addChild(thumbLoader);					
					thumbLoader.mouseEnabled = false;					
					
					//video icon?
					if (recipes[i].recipe[j].video != "") {
						var videoIconLoader:Loader = new Loader();
						videoIconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bitmapLoaded, false, 0, true);
						videoIconLoader.x = 761;
						videoIconLoader.y = 15;
						videoIconLoader.load(new URLRequest("images/icons/list_playButton.png"));
						itemClip.addChild(videoIconLoader);					
						videoIconLoader.mouseEnabled = false;
					}
					
					curY += itemClip.height;
					
				}
				
			}
			
			//check for scroll -- height > 1280 - 262 (top header height)
			if (container.height > 1018) {
				container.stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
				//container.stage.addEventListener(TouchEvent.TOUCH_BEGIN, beginDrag2, false, 0, true);
			}
			
		}
		
		
		public function hide():void
		{
			while (container.numChildren) {
				container.removeChildAt(0);
			}
			//container.stage.removeEventListener(TouchEvent.TOUCH_MOVE, mouseMove2);
			container.removeEventListener(Event.ENTER_FRAME, mouseMove);
			TweenMax.killTweensOf(container);
		}
		
		
		private function bitmapLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{
			timeout.buttonClicked();
			
			clickY = container.stage.mouseY;
			offsetY = container.stage.mouseY;
			initialContentY = container.y;
			lastMousePos = container.stage.mouseY;
			
			container.addEventListener(Event.ENTER_FRAME, mouseMove, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		/*
		private function beginDrag2(e:TouchEvent):void
		{
			timeout.buttonClicked();
			
			clickY = e.stageY;
			offsetY = e.stageY;
			initialContentY = container.y;
			lastMousePos = e.stageY;
			
			container.stage.addEventListener(TouchEvent.TOUCH_MOVE, mouseMove2, false, 0, true);
			container.stage.addEventListener(TouchEvent.TOUCH_END, endDrag2, false, 0, true);
		}
		*/
		
		private function mouseMove(e:Event):void
		{			
			timeout.buttonClicked();
			
			container.y = container.stage.mouseY - offsetY + initialContentY;
			checkPos();
			mouseDelta = container.mouseY - lastMousePos;
			lastMousePos = container.mouseY;
		}
		/*
		private function mouseMove2(e:TouchEvent):void
		{			
			timeout.buttonClicked();
			
			container.y = e.stageY - offsetY + initialContentY;
			checkPos();
			mouseDelta = e.stageY - lastMousePos;
			lastMousePos = e.stageY;
		}
		*/
		private function endDrag(e:MouseEvent):void
		{
			timeout.buttonClicked();
			
			container.removeEventListener(Event.ENTER_FRAME, mouseMove);
			
			var scrollDist:Number = Math.round(mouseDelta * 16);	
			TweenMax.to(container, 1, { y:container.y + scrollDist, onUpdate:checkPos } );	
		}
		/*
		private function endDrag2(e:TouchEvent):void
		{
			timeout.buttonClicked();
			
			container.stage.removeEventListener(TouchEvent.TOUCH_MOVE, mouseMove2);
			
			var scrollDist:Number = Math.round(mouseDelta * 16);	
			TweenMax.to(container, 1, { y:container.y + scrollDist, onUpdate:checkPos } );	
		}
		*/
		
		private function checkPos():void
		{			
			if (container.y > 0) {
				container.y = 0;
			}
			
			if (container.y + container.height < 1018) {
				container.y = 1018 - container.height;
			}
		}
		
		
		private function recipeClickDown(e:MouseEvent):void
		{
			selectedRecipeIndex = MovieClip(e.currentTarget).recipeIndex;
			startClickTime = getTimer();		
		}
		
		
		private function recipeClickUp(e:MouseEvent):void
		{
			timeout.buttonClicked();
			
			if ((MovieClip(e.currentTarget).recipeIndex == selectedRecipeIndex) && (getTimer() - startClickTime < 300)) {
				dispatchEvent(new Event(RECIPE_CLICKED));	
			}
					
		}
		 
	}
	
}