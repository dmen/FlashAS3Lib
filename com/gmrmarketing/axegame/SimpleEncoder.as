/**
 * Simple number encoder
 * encodes up to a 10 digit number
 */

package com.gmrmarketing.axegame
{	
	public class SimpleEncoder
	{
		private const NTABLE:Array = new Array("6789012345", "3456789012", "5678901234", "7890123456", "9012345678", "2345678901", "4567890123", "6789012345", "8901234567", "0123456789");
		private const CTABLE:String = "a-j$k@nd]*";
		
		public function SimpleEncoder() { }

		public function encode(num:Number):String
		{	
			var s:String = String(num);
			var enc:String = "";
			for(var i:int = 0; i < s.length; i++){
				var c = s.charAt(i);		
				var encNum:int = NTABLE[i].indexOf(c);		
				enc += String(encNum);
			}
			return charIt(enc);
		}

		
		public function decode(num:String):String
		{
			var deNum:String = deCharIt(num);
			var dec:String = "";
			for(var i:int = 0; i < deNum.length; i++){
				var c = deNum.charAt(i);		
				var decNum:int = NTABLE[i].charAt(c);
				dec += String(decNum);
			}
			return dec;
		}
		
		
		private function charIt(num:String):String
		{
			var enc:String = "";
			for (var i:int = 0; i < num.length; i++) {
				var c = num.charAt(i);
				var encNum:String = CTABLE.charAt(c);
				enc += encNum;
			}
			return enc;
		}
		
		
		private function deCharIt(num:String):String
		{
			var dec:String = "";
			for (var i:int = 0; i < num.length; i++) {
				var c:String = num.charAt(i);
				dec += CTABLE.indexOf(c);				
			}
			return dec;
		}
	}	
}