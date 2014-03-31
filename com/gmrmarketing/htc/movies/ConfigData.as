/**
 * Static config / path data
 */
package com.gmrmarketing.htc.movies
{	
	public class ConfigData
	{		
		public static const LANGUAGE:String = "en"; //en or fr
		
		public static const USE_KEN_BURNS:Boolean = false; //shows slow zoom on the images if true
		public static const SHOW_OVERLAYS:Boolean = false; //shows english or french overlay on images if true
		
		public static const IMAGE_PATH:String = "HTCImages/"; //path to load xml from
		//public static const IMAGE_PATH:String = "369243-web1/c$/inetpub/wwwroot/media/HTCOne/ftpsync/"; //path to load xml from
		public static const IMAGE_XML:String = "fileList.xml";
		public static const SCALE_AMOUNT:Number = 1.3; //amount to scale if using ken burns
		
		//image set 1
		public static const IMAGEX:int = 0;
		public static const IMAGEY:int = 0;
		public static const IMAGE_WIDTH:int = 640;
		public static const IMAGE_HEIGHT:int = 360;
		
		//image set 2
		public static const IMAGEX2:int = 0;
		public static const IMAGEY2:int = 360;
		public static const IMAGE_WIDTH2:int = 640;
		public static const IMAGE_HEIGHT2:int = 360;		
		
		//video
		public static const VIDEO_PATH:String = "HTCImages/";
		public static const VIDEO_BASE_NAME:String = "vid";
		public static const VIDEO_STATIC_NAME:String = "staticVid.MP4";
		public static const MAX_VIDEOS:int = 20;
		public static const VIDEOX:int = 640;
		public static const VIDEOY:int = 0;
		public static const VIDEO_WIDTH:int = 640;
		public static const VIDEO_HEIGHT:int = 360;		
		
		public function ConfigData(){}
	}	
}