package com.gmrmarketing.sap.nhl2015.gda.cali
{	
	
	public class Data
	{
		private var coords:Array;
		
		public function Data()
		{
			//coords maps latitude / longitude intersections to screen coords
			coords = new Array();
			
			//42 lat - lon 125 - 120
			coords.push([[257, 123], [285, 123], [315, 123], [341, 124], [372, 124], [397, 126]]);
			
			//41 lat - lon 125 - 120
			coords.push([[255, 158], [285, 158], [316, 158], [343, 159], [375, 160], [400, 160]]);
			
			//40 lat - lon 125 - 120
			coords.push([[253, 191], [285, 191], [317, 192], [346, 193], [378, 193], [404, 194]]);
			
			//39 lat - lon 125 - 120
			coords.push([[0, 0,], [284, 237], [319, 237], [349, 237], [381, 237], [409, 237]]);
			
			//38 lat - lon 125 - 118
			coords.push([[0, 0,], [0, 0,], [320, 272], [352, 272], [384, 273], [411, 273], [438, 273], [474, 273]]);
			
			//37 lat - lon 125 - 117
			coords.push([[0, 0,], [0, 0,], [322, 310], [354, 310], [386, 308], [415, 308], [442, 308], [477, 306], [508, 306]]);
			
			//36 lat - lon 125 - 115
			coords.push([[0, 0,], [0, 0,], [0, 0,], [357, 355], [389, 353], [419, 351], [446, 349], [481, 347], [511, 345], [543, 344], [573, 341]]);
			
			//35 lat - lon 125 - 114
			coords.push([[0, 0,], [0, 0,], [0, 0,], [0, 0,], [393, 396], [423, 394], [451, 392], [486, 390], [517, 387], [552, 385], [580, 383], [615, 381]]);			
			
			//34 lat - lon 125 - 114
			coords.push([[0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [427, 431], [455, 429], [489, 427], [521, 426], [558, 424], [586, 423], [620, 420]]);			
			
			//33 lat - lon 125 - 114
			coords.push([[0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [493, 462], [526, 460], [563, 458], [591, 457], [624, 456]]);			
			
			//32 lat - lon 125 - 114
			coords.push([[0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [0, 0,], [496, 492], [529, 492], [566, 489], [595, 488], [628, 484]]);			
		}
		
		
		/**
		 * 
		 * @param	lat North - 32 - 42
		 * @param	lon West 114 - 125
		 * @return
		 */
		public function getClosest(lat:Number, lon:Number):Array
		{
			var latIndex:int = Math.round(42 - lat);//index in coords array
			var latClosest:int = 42 - latIndex;//actual lat of closest intersection
			var latDiff:Number = lat - latClosest;//if negative, actual lat is south of latClosest
			
			var lonIndex:int = Math.round(125 - lon);//index in coords array
			var lonClosest:int = 125 - lonIndex;//actual lon of closest intersection
			var lonDiff:Number = lon - lonClosest; //if positive, actual is west of lonClosest
			
			var closestScreen:Array;
			
			try {
				closestScreen = coords[latIndex][lonIndex]; //actual x,y on screen of closest lat/lon intersection
			}catch (e:Error) {
				return [0, 0]; //point is not in CA
			}
			
			//lon is x, lat is y
			var xRatio:Number = 40; //~pixels per 1º of longitude
			var xMod:Number = lonDiff * xRatio;
			
			var yRatio:Number = 40; //~pixels per 1º of latitude
			var yMod:Number = latDiff * yRatio;				
			
			return [closestScreen[0] - xMod, closestScreen[1] - yMod];
		}
		
	}
	
}