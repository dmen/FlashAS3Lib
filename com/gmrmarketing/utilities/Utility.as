package com.gmrmarketing.utilities
{
	
	public class Utility 
	{
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
	}
}