package com.gmrmarketing.jimbeam.devilscut
{
	import flash.display.MovieClip;
	import fl.data.DataProvider;
	import flash.events.*;
	
	
	public class Main extends MovieClip 
	{
		private var monthProvider:DataProvider;
		
		public function Main()
		{
			var months:Array = new Array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
			monthProvider = new DataProvider();
			for (var i:int = 0; i < months.length; i++) {
				monthProvider.addItem( { label:months[i], data:months[i] } );
			}
			addEventListener(Event.ADDED_TO_STAGE, init);			
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			intro.theMonth.dataProvider = monthProvider;
		}
	}
	
}