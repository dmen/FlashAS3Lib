package com.gmrmarketing.sap.superbowl.gda.usmap
{	
	
	public class Data
	{
		private var coords:Array;
		
		public function Data()
		{
			//coords maps latitude / longitude intersections to screen coords
			coords = new Array();
			//50 lat - lon 125 - 70
			coords.push([[84, 150], [125, 159], [168, 168], [203, 173], [247, 180], [284, 179], [330, 178], [380, 174], [416, 168], [458, 163], [505, 153], [543, 148]]);
			//45 lat - lon 125 - 65
			coords.push([[57, 201], [102, 212], [148, 224], [191, 227], [240, 229], [282, 232], [333, 234], [386, 219], [427, 220], [473, 209], [524, 194], [569, 188], [626, 174]]);
			//40 lat - lon 125 - 70
			coords.push([[31, 247], [79, 268], [127, 278], [176, 284], [231, 287], [279, 290], [336, 293], [392, 284], [442, 280], [493, 269], [549, 255], [601, 243]]);
			//35 lat - lon 125 - 75
			coords.push([[0, 312], [49, 334], [104, 344], [161, 353], [219, 357], [276, 357], [340, 359], [399, 356], [457, 349], [516, 338], [574, 327]]);
			//30 lat - lon 125 - 75
			coords.push([[0, 0], [27, 386], [85, 398], [147, 411], [207, 424], [273, 429], [344, 430], [406, 430], [473, 423], [539, 407], [602, 391]]);
			//25 lat - lon 125 - 80
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
			var latIndex:int = Math.round((50 - lat) / 5);//index in coords array
			var latClosest:int = 50 - latIndex * 5;//actual lat of closest intersection
			var latDiff:Number = lat - latClosest;//if negative, actual lat is south of latClosest
			
			var lonIndex:int = Math.round((125 - lon) / 5);//index in coords array
			var lonClosest:int = 125 - lonIndex * 5;//actual lon of closest intersection
			var lonDiff:Number = lon - lonClosest; //if positive, actual is west of lonClosest
			
			var closestScreen:Array;
			
			try {
				closestScreen = coords[latIndex][lonIndex]; //actual x,y on screen of closest lat/lon intersection
			}catch (e:Error) {
				return [0, 0]; //point is not in the lower 48
			}
			
			//lon is x, lat is y
			var xRatio:Number = 50 / 5; //about 50 pixels per 5º of longitude
			var xMod:Number = lonDiff * xRatio;
			
			var yRatio:Number = 50 / 5; //about 50 pix per 5º of latitude
			var yMod:Number = latDiff * yRatio;				
			
			return [closestScreen[0] - xMod, closestScreen[1] - yMod];
		}
	}
	
}