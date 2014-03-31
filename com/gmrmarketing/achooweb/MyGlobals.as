/**
 * Globals singleton object
 * Currently used only to store the incoming hsurl FlashVar
 */

package com.gmrmarketing.achooweb
{	
	public class MyGlobals
	{	
		private var myXMLURL:String = "";
		public static var instance:MyGlobals;
		
		/**
		 * Singleton Instantiator
		 * @return MyGlobals object
		 */
		public static function getInstance():MyGlobals
		{
			if (instance == null) {
				instance = new MyGlobals(new SingletonBlocker());
			}
			return instance;
		}		
		
		/**
		 * Private Constructor
		 * @param	key
		 */
		public function MyGlobals(key:SingletonBlocker) 
		{
			if (key == null) {
				throw new Error("Error: Singleton - use getInstance()");
			}
		}
		
		/**
		 * Called by the preloader
		 * @param	url High Scores xml url
		 */
		public function setXMLURL(url:String):void
		{
			myXMLURL = url;
		}
		
		/**
		 * Returns the high scores xml url
		 * @return url of xml file
		 */
		public function getXMLURL():String
		{
			return myXMLURL;
		}
	}	
}
class SingletonBlocker {}