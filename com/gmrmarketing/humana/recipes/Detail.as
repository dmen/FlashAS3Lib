package com.gmrmarketing.humana.recipes
{
	import flash.display.DisplayObjectContainer;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Detail extends EventDispatcher
	{
		public static const WATCH_VIDEO:String = "watchVideoClicked";
		
		private var container:DisplayObjectContainer;
		private var loader:Loader;
		private var content:Sprite;
		
		private var title:MovieClip; //instance of mc_detailTitle from lib
		private var ingredients:MovieClip; //instance of mc_detailIngredientsBG
		private var instructions:MovieClip; //instance of mc_detailInstructions
		private var nutrition:MovieClip; //instance of mc_detailInstructions
		
		private var clickY:Number; //initial y position when clicking to scroll
		private var initialContentY:Number;
		private var offsetY:Number;
		private var lastMousePos:Number;
		private var mouseDelta:Number;//mouse movement since last update
		
		private var recipe:XML;
		private var timeout:TimeoutHelper;
		
		
		
		public function Detail()
		{
			content = new Sprite();
			
			timeout = TimeoutHelper.getInstance();
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function hide():void
		{
			try {
				loader.close();
			}catch (e:Error) {
				
			}
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
			
			if(ingredients){
				while (ingredients.numChildren) {
					ingredients.removeChildAt(0);
				}
			}
			while (content.numChildren) {
				content.removeChildAt(0);
			}
			if (container) {
				if (container.contains(content)) {
					container.removeChild(content);
				}
			}
		}
		
		/**
		 * Called from Main
		 * @param	$recipe
		 */
		public function show($recipe:XML):void
		{
			recipe = $recipe;
			timeout.buttonClicked();
			
			title = new mc_detailTitle(); //lib clip 68px = height
			title.y = 355; //detail image is 800x355
			
			ingredients = new mc_detailIngredientsBG(); //lib clip -- holder for the ingredients
			ingredients.y = 424; //height of detail image + title height
			ingredients.title.theText.text = "Ingredients";
			
			instructions = new mc_detailInstructions();
			instructions.title.theText.text = "Directions";
			
			nutrition = new mc_detailInstructions();
			nutrition.title.theText.text = "Nutrition";			
			
			container.addChild(content);
			
			loader.load(new URLRequest(recipe.detailImage));
		}
		
		
		/**
		 * Called by COMPLETE listener on the loader
		 * called when the recipe's detailImage is loaded
		 * @param	e
		 */
		private function imageLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			b.alpha = 0;
			content.addChild(b);
			TweenMax.to(b, .5, { alpha:1 } );			
			
			
			//TITLE
			content.addChild(title);
			title.theText.text = recipe.title;
			if(recipe.courtesyOf != ""){
				title.courtesy.text = "Recipe Courtesy of: " + recipe.courtesyOf;
			}else {
				title.courtesy.text = "";
			}
			if (recipe.numberOfServings != "") {
				title.servings.text = "Makes " + recipe.numberOfServings + " servings";
			}else{
				title.servings.text = "";
			}
			
			if (recipe.video == "") {
				//no video, hide the button
				title.btnVideo.visible = false;
				title.btnVideo.removeEventListener(MouseEvent.MOUSE_DOWN, vidClicked);
			}else {
				title.btnVideo.visible = true;
				title.btnVideo.theText.text = "Watch video";
				title.btnVideo.addEventListener(MouseEvent.MOUSE_DOWN, vidClicked, false, 0, true);
			}
			
			
			//INGREDIENTS			
			content.addChild(ingredients);
			
			var list:XMLList = recipe.ingredients.item;			
			var curY:int = 28;
			for (var i:int = 0; i < list.length(); i++) {
				var it:MovieClip = new mc_detailRecipeIngredient(); //lib clip
				it.theText.autoSize = TextFieldAutoSize.LEFT;
				if (String(list[i]).substr(0, 2) == "::") {
					//this is a new title in the ingredient list
					it.theText.text = "\n" + String(list[i]).substr(2);
				}else{
					it.theText.text = "•    " + list[i];
				}
				it.x = 30;
				it.y = curY;
				ingredients.addChild(it);
				curY += it.theText.textHeight;
			}
			ingredients.bg.height += curY - 28;
			ingredients.grayLine.y = ingredients.bg.height;
			
			
			//INSTRUCTIONS
			content.addChild(instructions);
			instructions.y = ingredients.y + ingredients.height;
			
			instructions.theText.autoSize = TextFieldAutoSize.LEFT;
			list = recipe.directions.item;
			var inst:String = "";
			for (i = 0; i < list.length(); i++) {
				inst += list[i] + "\n\n";
			}
			instructions.theText.text = inst;
			instructions.bg.height = 72 + instructions.theText.textHeight + 10;
			instructions.grayLine.y = instructions.bg.height;
			
			
			//NUTRITION INFO
			list = recipe.nutrition.item;
			
			content.addChild(nutrition);
			nutrition.y = instructions.y + instructions.height;
			nutrition.theText.autoSize = TextFieldAutoSize.LEFT;
			
			
			if(recipe.nutrition.@servingSize != ""){
				inst = "serving size: " + recipe.nutrition.@servingSize + "\n\n";
			}else {
				inst = "";
			}
			for (i = 0; i < list.length() - 1; i++) {
				inst += list[i] + ", ";
			}
			inst += list[i];
			
			nutrition.theText.text = inst;
			nutrition.bg.height = 72 + nutrition.theText.textHeight + 30;
			
			//66 is height of footer buttons for printing / going back
			var spaceLeft:int = 1280 - (content.height + 66);
			if (spaceLeft > 0) {
				//there's blank space under the nutrition - before the buttons
				nutrition.bg.height += spaceLeft - 1;
			}
			nutrition.grayLine.y = nutrition.bg.height;
			
			if (list.length() < 2) {
				nutrition.title.alpha = 0;
			}else {
				nutrition.title.alpha = 1;
			}
			
			//1214 = 1280 - 66 (height of bottom buttons)
			if (content.height > 1214) {
				//need to allow user to scroll the content
				//trace("scroll", content.height);
				container.stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			}
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{
			timeout.buttonClicked();
			
			clickY = container.stage.mouseY;
			offsetY = container.stage.mouseY;
			initialContentY = content.y;
			lastMousePos = container.stage.mouseY;
			
			content.addEventListener(Event.ENTER_FRAME, mouseMove, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		private function endDrag(e:MouseEvent):void
		{
			timeout.buttonClicked();
			
			content.removeEventListener(Event.ENTER_FRAME, mouseMove);
			
			var scrollDist:Number = Math.round(mouseDelta * 16);	
			TweenMax.to(content, 1, { y:content.y + scrollDist, onUpdate:checkPos } );	
		}
		
		
		private function mouseMove(e:Event):void
		{		
			timeout.buttonClicked();
			
			content.y = container.stage.mouseY - offsetY + initialContentY;
			checkPos();
			mouseDelta = container.mouseY - lastMousePos;
			lastMousePos = container.mouseY;
		}
		
		
		private function checkPos():void
		{			
			if (content.y > 0) {
				content.y = 0;
			}
			
			if (content.y + content.height < 1214) {
				content.y = 1214 - content.height;
			}
		}
		
		
		private function vidClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(WATCH_VIDEO));
		}
		
	}
	
}