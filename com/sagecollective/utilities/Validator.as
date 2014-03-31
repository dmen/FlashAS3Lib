/**
 * Static class that validates email and phone numbers
 */

package com.sagecollective.utilities
{	
	public class Validator
	{
		public static function isValidEmail( str:String ):Boolean 
		{
			var emailExp:RegExp = /^[a-z0-9][-._a-z0-9]*@([a-z0-9][-_a-z0-9]*\.)+[a-z]{2,6}$/;           
			return emailExp.test( str );
		}
		
		
		public static  function isValidPhoneNumber( str:String ):Boolean 
		{
			var phoneRegExp:RegExp = /\d{3}\d{3}\d{4}|\d{3}-\d{3}-\d{4}|\(\d{3}\)\s?\d{3}-\d{4}/;			
			return phoneRegExp.test( str );
		}
		
	}
	
}