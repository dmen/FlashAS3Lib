package com.gmrmarketing.utilities
{	
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class LogTest
	{
		private var log:Logger;
		
		public function LogTest()
		{
			log = Logger.getInstance();
			log.log("LogTest.start");
		}
	}
	
}