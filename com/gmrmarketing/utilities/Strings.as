/**
 * Static String methods
 */

package com.gmrmarketing.utilities
{

	public class Strings 
	{		
		/**
		 * Returns a copy of the string converted to lower case, but
		 * with each word starting with an upper case letter
		 * 
		 * @param	phrase String to convert
		 * @return  String
		 */
		public static function upperCaseFirst(phrase:String):String
		{					
			var words:Array = phrase.toLowerCase().split(" ");
			
			for (var i:int = 0; i < words.length; i++) {				
				words[i] = String(words[i]).substr(0, 1).toUpperCase() + String(words[i]).substr(1);
			}
			return words.join(" ");
		}
		
		
		
		/**
		 * Trims leading and trailing spaces from the string
		 * @param	phrase
		 * @return String
		 */
		public static function trim(phrase:String):String
		{
			while(phrase.charAt(0) == " "){
				phrase = phrase.substr(1);
			}

			while(phrase.charAt(phrase.length - 1) == " "){
				phrase = phrase.substr(0, phrase.length - 1);
			}
			
			return phrase;
		}
		
		
		
		/**
		 * Returns true if the phrase begins with test
		 * @param	phrase
		 * @param	test
		 * @return	Boolean
		 */
		public static function startsWith(phrase:String, test:String):Boolean
		{
			return phrase.substr(0, test.length) == test ? true : false;
		}
		
		
		
		/**
		 * Returns true if phrase ends with test
		 * @param	phrase
		 * @param	test
		 * @return	Boolean
		 */
		public static function endsWith(phrase:String, test:String):Boolean
		{
			return phrase.substr(phrase.length - test.length, test.length) == test ? true : false;
		}
		
		
		
		/**
		 * Removes carriage return and line feeds from a string and returns it
		 * @param	s
		 * @return
		 */
		public static function removeLineBreaks(s:String):String 
		{ 
			s = s.split("\r").join("");
			return s.split("\n").join("");
		}
		
		
		/**
		 * Removes a chunk from a string that starts with a given string.
		 * Example - remove URL by calling removeChunk(string, "http://");
		 * @param	s The original string
		 * @param	starts
		 * @return	Modified original string if starts was found
		 */
		public static function removeChunk(s:String, starts:String):String
		{
			var i:int = s.indexOf(starts);
			var newString:String;
			
			if (i != -1) {
				var sp:int = s.indexOf(" ", i); //find first space after chunk start
				
				var s1:String = s.substr(0, i);
				var s2:String = s.substr(sp + 1);
				
				if (sp != -1) {
					newString = s1 + s2;
				}else {
					newString = s1;
				}				
			}else {
				//starts was not found
				newString = s;
			}
			
			return newString;
		}
	}
	
}