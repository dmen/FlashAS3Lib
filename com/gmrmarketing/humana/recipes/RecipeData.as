/**
 * Loads the recipes.xml file
 * Keeps the recipe data
 */

package com.gmrmarketing.humana.recipes
{	
	import flash.errors.IOError;
	import flash.events.*;	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class RecipeData extends EventDispatcher
	{
		public static const FILE_NOT_FOUND:String = "fileNotFound";
		
		private var xml:XML;
		private var loader:URLLoader;
		private var selectedRecipe:XML;
		
		
		public function RecipeData()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, fileLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			loader.load(new URLRequest("recipes.xml"));
		}
		
		
		private function fileLoaded(e:Event):void
		{
			xml = new XML(e.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function fileNotFound(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(FILE_NOT_FOUND));
		}
		
		
		/**
		 * returns an array of objects containing all images in the recipe.slideshowImage tag
		 * Used by the slideshow
		 * 
		 * @return Array of objects with image ,title and index properties 
		 */
		public function getSlideshowImages():Array
		{
			var a:Array = new Array();
			
			var allRecipes:XMLList = xml.recipes.category.recipe;
			var thisRecipe:XML;
			var im:String;
			
			for (var i:int = 0; i < allRecipes.length(); i++) {
				thisRecipe = allRecipes[i];
				im = thisRecipe.slideshowImage;
				if (im != "") {					
					a.push({image:im, title:thisRecipe.title, index:i});
				}
			}			
			return a;
		}
		
		
		public function setSelectedRecipeByIndex(index:int):void
		{
			var allRecipes:XMLList = xml.recipes.category.recipe;
			selectedRecipe = allRecipes[index];
		}
		
		
		/**
		 * Returns the selected recipe as xml
		 * @return
		 */
		public function getSelectedRecipe():XML
		{
			return selectedRecipe;
		}
		
		
		public function getAllRecipes():XMLList
		{
			return xml.recipes.category;
		}
		
		public function getRecipeList():XMLList
		{			
			return xml.recipes.category.recipe;
		}
		
		
	}
	
}