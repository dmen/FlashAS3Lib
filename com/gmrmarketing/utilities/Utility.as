package com.gmrmarketing.utilities
{
	import flash.display.Graphics;
	
	public class Utility 
	{
		private static var degToRad:Number = 0.0174532925; //PI / 180
		
		public function Utility():void
		{			
		}
		
		
		
		/**
		 * Returns a unique alpha numeric id string
		 * Uses the milliseconds since a given date - change the date to one
		 * closer to the event start
		 * 
		 * Returns a string line A90B67U
		 * 
		 * @return n character long string A-Z 0-9
		 */
		public static function getUniqueID():String
		{
			var charArray:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

			var d:Date = new Date(2013, 8, 4); //september 3rd - month is 0 based
			var e:Date = new Date(); //now
			
			var m:String = String(e.valueOf() - d.valueOf()); //delta of now - then in milliseconds

			var curIndex:int = 0;
			var numArray:Array = new Array();
			
			//create array of two digit values taken from the delta string
			while(curIndex < m.length){
				numArray.push(parseInt(m.substr(curIndex, 2)));
				curIndex += 2;
			}
			
			//turn array values into characters - or leave as is if the value isn't in the charArray
			var fin:String = "";
			for(var i:int = 0; i < numArray.length; i++){
				var cur:int = numArray[i];
				if(cur < charArray.length){
					fin += charArray.charAt(cur);
				}else{
					fin += String(cur);
				}
			}
			
			return fin;
		}
		
		
		/** 
		 * Returns column,row in array like 1,1 for upper left corner
		 * @param	index 1 - n
		 * @param	perRow
		 * @return	Array with two elements x,y
		 */
		public static function gridLoc(index:Number, perRow:Number):Array
        {
            return new Array(index % perRow == 0 ? perRow : index % perRow, Math.ceil(index / perRow));
        }
		
		
		/**
		 * Returns a randomized version of the incoming array
		 * @param	array
		 * @return Array
		 */
		public static function randomizeArray(array:Array):Array
		{
			var newArray:Array = new Array();
			while(array.length > 0){
				newArray.push(array.splice(Math.floor(Math.random() * array.length), 1)[0]);
			}
			return newArray;
		}
		
		
		/**
		 * Traces name/value pairs for the passed in object
		 * @param	ob
		 */
		public static function iterateObject(ob:Object):void
		{		
			for (var i:* in ob) 
			{ 				
				trace(i, ob[i]); 
			} 
		}
		
		
		/**
		 * Returns a timestamp like: "8/23/2013 9:20:57 am"
		 * @return date/time String
		 */
		public static function getTimeStamp():String
		{	
			var today:Date = new Date();
			var ampm:String;
			
			var dateString = String(today.getMonth() + 1) + "/" + String(today.getDate()) + "/" + String(today.getFullYear());
			
			//This returns the seconds, minutes and the hour.
			var theSeconds = today.getSeconds();
			var theMinutes = today.getMinutes();
			var theHours = today.getHours();

			//Displays am/pm depending on the current hour.
			if (theHours >= 12) {
				 ampm = "pm";
			} else {
				 ampm = "am";
			}
			//This subtracts 12 from the hour when it greater than 13.
			if (theHours >= 13) {
				theHours = theHours - 12;
			}
			//Adds '0' if there is only one digit.
			if (String(theMinutes).length == 1) {    
				theMinutes = "0" + theMinutes; 
			} 
			if (String(theSeconds).length == 1) {     
			   theSeconds = "0" + theSeconds; 
			} 
			 //Displays the time in the dynamic text field. 
			 return dateString + " " + theHours + ":" + theMinutes + ":" + theSeconds + " " + ampm;			
		}
		
		
		
		public static function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number, alph:Number = 1):void
		{
			g.clear();
			//g.lineStyle(1, lineColor, alph, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			if(angle_diff > 0){
				g.beginFill(lineColor, alph);
				g.moveTo(px_inner, py_inner);
				
				var i:int;
			
				// drawing the inner arc
				for (i = 1; i <= steps; i++) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
				}
				
				// drawing the outer arc
				for (i = steps; i >= 0; i--) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
				}
				
				g.lineTo(px_inner, py_inner);
				g.endFill();
			}
		}
		
		private static function getX(angle:Number, radius:Number, center_x:Number):Number
		{
			return Math.cos((angle-90) * degToRad) * radius + center_x;
		}
		
		
		private static function getY(angle:Number, radius:Number, center_y:Number):Number
		{
			return Math.sin((angle-90) * degToRad) * radius + center_y;
		}
	}
}