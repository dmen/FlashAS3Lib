package com.gmrmarketing.comcast.sports
{	
	public class NFL implements ISports
	{	
		private var theType:String; //type from main.as
		
		
		public function NFL(type:String = "comcastEN") 
		{
			theType = type; //comcastEN, comcastSP, xfinityEN, xfinitySP
		}
		
		
		
		/**
		 * type can be "flv", "swf" or "img"
		 * @return
		 */
		public function getMedia():Object
		{
			return {type:"flv", url:"http://media2.radweblive.com/comcastsports/BRADY_NFLNetwork_CC.flv"};
		}
		
		
		
		public function getSideText():String
		{
			var st:String = "";
			
			switch(theType) {
				case "comcastEN":
					st = "Comcast English<br/><br/>Comcast is the best. It's speedy fast and super cheap.";
					break;
				case "comcastSP":
					st = "Comcast Espanol";
					break;
				case "xfinityEN":
					st = "Xfinity English";
					break;
				case "xfinitySP":
					st = "Xfinity Espanol";
					break;
			}
			return st;
		}
		
		
		
		/**
		 * If the text property is not "" then the replay button will be placed on stage with the button
		 * text set to the text property. If the text property is "" then no replay button will be added.
		 * 
		 * If url is not "" then the replay button will launch the url - if url is blank
		 * then the button will replay the video
		 * 
		 * @return replay object
		 */
		public function getReplay():Object
		{
			var st:Object;
			
			switch(theType) {
				case "comcastEN":
					st = {text:"Replay", url:""};
					break;
				case "comcastSP":
					st = {text:"Replay", url:""};
					break;
				case "xfinityEN":
					st = {text:"Replay", url:""};
					break;
				case "xfinitySP":
					st = {text:"Replay", url:""};
					break;
			}
			return st;
		}
		
	}	
}