/**
* EmailValidator<br>
* (c) 2006 blurredistinction, LLC<br>
* www.blurredistinction.com
* <p>
* by Dave Mennenoh<br>
* dave@blurredistinction.com
* <p>
* Allows email addresses to be easily checked for validity using current verification rules.
* <p>
* Usage: 	var emv:EmailValidator = new EmailValidator();<br>
* 			var valid = emv.validate("dave@blurredistinction.com");
*/
package com.blurredistinction.validators
{
	public class EmailValidator {
		
		//ranges of valid ASCII values for email addresses
		private var validASCII:Array = [[43, 43], [45, 46], [48, 57], [61, 61], [65, 90], [94, 95], [97, 123], [125, 126]];
		
		
		/**
		* Constructor
		*/
		public function EmailValidator (){}
		
		
		/**
		* Checks an email address for validity. 
		* 
		* @param	email Email string to be checked for validity
		* @return	Boolean - True if valid
		*/
		public function validate (email:String):Boolean 
		{
			//split email into local and domain portions  
			var localDom:Array = email.split ("@");
			//
			//there can be only one @ sign - and there has to be one
			//and there must be something before the @
			if ((localDom.length != 2) || (localDom[0].length < 1)) {
				return false;
			}
			//local portion can't start or end with a .    
			if ((localDom[0].charAt(0) == ".") || (localDom[0].charAt (localDom[0].length - 1) == ".")) {
				return false;
			}
			//split the domain portion into domain name and extension      
			var domExtension:Array = localDom[1].split (".");
			//
			//domain must contain at least one .
			if(domExtension.length < 2){
				return false;
			}
			//
			//domain can't start with a .
			if(domExtension[0].length == 0){
				return false;
			}
			// 
			//there can be multiple .'s in the domain portion so use the last item in the array
			//extension length must be between 2 and 4 characters
			if (domExtension[domExtension.length - 1].length < 2 || domExtension[domExtension.length - 1].length > 4) {
				return false;
			}
			//finally check the local portion & domain for invalid chars     
			if ((!checkString (localDom[0])) || (!checkString (localDom[1]))) {
				return false;
			}
			return true;
		}
		
		
		/**
		* Checks each character in the string to see if it's in the range of valid ascii
		* 
		* @param	theString String to be validated
		* @return  	True if each character is in a valid range
		*/
		private function checkString (theString:String):Boolean 
		{
			var sl = theString.length;
			var ind:Number;
			for (ind = 0; ind < sl; ind++) {
				if (!isValidASCII (theString.charCodeAt (ind))) {
					return false;
				}
			}
			return true;
		}
		
		
		
		
		/**
		* See if the input character falls in the valid range of valid ascii chars
		* 
		* @param	theChar Single character passed in from checkString()
		* @return	True if individual char is in a valid range
		*/
		private function isValidASCII (theChar:Number):Boolean 
		{
			var ind:Number;
			for (ind = 0; ind < validASCII.length; ind++) {
				if ((theChar >= validASCII[ind][0]) && (theChar <= validASCII[ind][1])) {
					return true;
				}
			}
			return false;
		}
	}
}
