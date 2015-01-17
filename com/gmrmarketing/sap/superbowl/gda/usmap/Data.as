package com.gmrmarketing.sap.superbowl.gda.usmap
{
	
	
	public class Data
	{
		private var coords:Array;
		
		public function Data()
		{
			coords = new Array();
			coords.push([[84, 150], [125, 159], [168, 168], [203, 173], [247, 180], [284, 179], [330, 178], [380, 174], [416, 168], [458, 163], [505, 153], [543, 148]]);
			coords.push([[57, 201], [102, 212], [148, 224], [191, 227], [240, 229], [282, 232], [333, 234], [386, 219], [427, 220], [473, 209], [524, 194], [569, 188], [626, 174]]);
			coords.push([[31, 247], [79, 268], [127, 278], [176, 284], [231, 287], [279, 290], [336, 293], [392, 284], [442, 280], [493, 269], [549, 255], [601, 243]]);
			coords.push([[0, 312], [49, 334], [104, 344], [161, 353], [219, 357], [276, 357], [340, 359], [399, 356], [457, 349], [516, 338], [574, 327]]);
			coords.push([[0, 0], [27, 386], [85, 398], [147, 411], [207, 424], [273, 429], [344, 430], [406, 430], [473, 423], [539, 407], [602, 391]]);
			coords.push([[0, 0], [0, 0], [0, 0], [0, 0], [196, 501], [269, 511], [343, 510], [416, 508], [491, 505], [565, 488]]);
		}
		
		
		/**
		 * 
		 * @param	lat North - 25 - 50
		 * @param	lon West 65 - 125
		 * @return
		 */
		public function getClosest(lat:Number, lon:Number):Array
		{
			var lonIndex:int = Math.round((125 - lon) / 5);
			var latIndex:int = Math.round((50 - lat) / 5);
			trace(lat, lon, latIndex, lonIndex);
				return coords[latIndex][lonIndex];
		}
	}
	
}