package com.gmrmarketing.sap.nba
{	
	import flash.display.MovieClip;
	
	public class Star 
	{		
		private var clip:MovieClip;
		
		public function Star($clip:MovieClip) 
		{
			clip = $clip;
			init();
		}
		
		
		public function setStar(starNumber:int):void
		{
			init();
			if (starNumber > clip.numChildren){
				starNumber = clip.numChildren;
			}
			
			for(var i:int = 1; i <= starNumber; i++){				
				clip["star" + i].gotoAndStop(2);
			}
		}
		
		
		private function init():void
		{
			for(var i:int = 1; i <= clip.numChildren; i++){
				clip["star" + i].gotoAndStop(1);
			}
		}		
	}
}