package com.gmrmarketing.bcbs.findyourbalance
{		
	import flash.utils.getDefinitionByName;
	import flash.display.MovieClip;
	
	public class Icons	
	{	
		private const L1ICONS:int = 8;
		private const L2ICONS:int = 8;
		private const L3ICONS:int = 8;
		
		public function Icons(){}
		
		public function getIcon(level:int):MovieClip
		{		
			var i:int;
			var classRef:Class;
			var clip:MovieClip;
			
			switch(level) {
				case 1:
					i = Math.ceil(Math.random() * L1ICONS);
					classRef = getDefinitionByName( "mcIcon_home" + i ) as Class;
					clip = new classRef();
					break;
				case 2:
					i = Math.ceil(Math.random() * L2ICONS);
					classRef = getDefinitionByName( "mcIcon_work" + i ) as Class;
					clip = new classRef();
					break;
				case 3:
					i = Math.ceil(Math.random() * L3ICONS);
					classRef = getDefinitionByName( "mcIcon_extra" + i ) as Class;
					clip = new classRef();
					break;
			}
			return clip;
		}
	}
	
}