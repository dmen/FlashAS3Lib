/**
 * Used by Capture
 * 
 * creates the text file
 */
package com.gmrmarketing.reeses.gameday
{
	import flash.events.EventDispatcher;
	
	public class Stitcher extends EventDispatcher
	{
		public function Stitcher()
		{
			
		}
		
		/**
		 * questions array is intro, five questions, outro
		 * Builds the text file that will be given to ffmpeg
		 */
		public function set questions(q:Array):void
		{
			//adobe media server path where videos are recorded
			var userPath:String = "c:/Program Files/Adobe/Flash Media Server 4.5/applications/reesesGameDay/streams/_definst_/";
			
			var sl:String = "";
			sl += "file '" + q.shift() + "'\n";//intro
			sl += "file '" + q.shift() + "'\n";//question 1 from rece
			sl += "file '" + userPath + "user1.flv'\n";
			
			sl += "file '" + q.shift() + "'\n";//question 2 from rece
			sl += "file '" + userPath + "user2.flv'\n";
			
			sl += "file '" + q.shift() + "'\n";//question 3 from rece
			sl += "file '" + userPath + "user3.flv'\n";
			
			sl += "file '" + q.shift() + "'\n";//question 4 from rece
			sl += "file '" + userPath + "user4.flv'\n";
			
			sl += "file '" + q.shift() + "'\n";//question 5 from rece
			sl += "file '" + userPath + "user5.flv'\n";
			
			sl += "file '" + q.shift() + "'\n";//outro
			
			
			trace("stitcher", sl);
		}
	}
	
}