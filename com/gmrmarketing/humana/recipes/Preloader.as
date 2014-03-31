package com.gmrmarketing.humana.recipes
{	
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	public class Preloader
	{
		public function Preloader(){}
		
		/**
		 * 
		 * @param	items XMLList of the recipes from the xml
		 * preloads the list image so they appear right away the first time
		 * list view is accessed
		 */
		public function preload(items:XMLList):void
		{
			var num:int = items.length();
			for (var i:int = 0; i < num; i++) {
				var a:Loader = new Loader();
				a.load(new URLRequest(items[i].listImage));
			}
		}
	}
	
}