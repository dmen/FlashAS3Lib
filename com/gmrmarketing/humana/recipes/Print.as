package com.gmrmarketing.humana.recipes
{	
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.text.TextFieldAutoSize;
	
	
	public class Print extends EventDispatcher 
	{
		public static const BEGIN_PRINTING:String = "printingStarted";
		
		private var pj:PrintJob;
		private var recipe:XML;
		private var loader:Loader;
		
		public function Print()
		{
			pj = new PrintJob();
		}
		
		
		public function print($recipe:XML):void
		{
			recipe = $recipe;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			loader.load(new URLRequest(recipe.detailImage));
		}
		
		
		private function imageLoaded(e:Event):void
		{
			var header:Sprite = new Sprite();
			
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			b.scaleX = b.scaleY = .925; //so matches the logo width
			header.addChild(b);
			var topWhite = new mc_topWhite();
			topWhite.scaleX = topWhite.scaleY = .925; //so matches the logo width
			header.addChild(topWhite);
			var logo:MovieClip = new mc_header_mainLogo();
			header.addChild(logo);
			
			var doc:Sprite = new Sprite();			
			
			var title:MovieClip = new mc_printTitle();
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
			
			//ingredients
			var allIngredients:Sprite = new Sprite();
			allIngredients.addChild(new mc_printIngredients()); //ingredients title
			
			var list:XMLList = recipe.ingredients.item;
			var curY:int = 28;
			for (var i:int = 0; i < list.length(); i++) {
				var it:MovieClip = new mc_detailRecipeIngredient(); //lib clip
				it.theText.autoSize = TextFieldAutoSize.LEFT;
				it.theText.text = "•    " + list[i];
				it.x = 10; //slight indent
				it.y = curY;
				allIngredients.addChild(it);
				curY += it.theText.textHeight;;
			}
			
			//instructions
			var instructions:MovieClip = new mc_printRecipeIngredient();
			var instTitle:MovieClip = new mc_printIngredients();
			instTitle.theText.text = "Directions";
			instructions.theText.autoSize = TextFieldAutoSize.LEFT;
			
			list = recipe.directions.item;
			var inst:String = "";
			for (i = 0; i < list.length(); i++) {
				inst += list[i] + "\n\n";
			}
			instructions.theText.text = inst;
			
			
			//nutrition
			//var nutTitle:MovieClip = new mc_printIngredients();
			//nutTitle.theText.text = "Nutrition";
			var nutrition:MovieClip = new mc_nutrition();
			nutrition.theText.autoSize = TextFieldAutoSize.LEFT;
			
			list = recipe.nutrition.item;
			if(recipe.nutrition.@servingSize != ""){
				inst = "SS: " + recipe.nutrition.@servingSize + "\n";
			}else {
				inst = "";
			}
			for (i = 0; i < list.length() - 1; i++) {
				inst += list[i] + "\n";
			}
			inst += list[i];
			nutrition.theText.text = inst;
			
			var rect:Shape = new Shape();
			rect.graphics.lineStyle(1,0xCCCCCC, 1, true);
			rect.graphics.drawRoundRect(0, 0, nutrition.theText.textWidth + 30, nutrition.theText.y + nutrition.theText.textHeight + 12, 15, 15);
			nutrition.addChildAt(rect, 0);				
			
			var options:PrintJobOptions = new PrintJobOptions();
			options.printAsBitmap = true;
		 
			if (pj.start2(null, false)) {
				
				dispatchEvent(new Event(BEGIN_PRINTING));
				
				doc.addChild(header);				
				
				title.y = header.height + 15;
				doc.addChild(title);
				
				allIngredients.y = title.y + title.height + 15;
				doc.addChild(allIngredients);
				
				instTitle.y = allIngredients.y + allIngredients.height + 15;
				doc.addChild(instTitle);
				instructions.y = instTitle.y + instTitle.height + 6;
				doc.addChild(instructions);
				
				nutrition.y = title.y + 8;
				nutrition.x = header.width - rect.width;
				doc.addChild(nutrition);
				
				doc.width = pj.pageWidth * .8; 
				doc.scaleY = doc.scaleX;
				
				try{
					pj.addPage(doc, null, options);
				}catch (e:Error) {
					
				}
				pj.send();
			}
		}		
		
	}
	
}