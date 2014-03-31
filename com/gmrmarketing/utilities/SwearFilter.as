/**
 * Static swear catcher class
 * Usage:
 *	import com.gmrmarketing.utilities.SwearFilter;
 * 
 *  var isSwear:Boolean;
 *  isSwear = SwearFilter.isSwear("xxxxxxxxx");
 * 
 *  isSwear = SwearFilter.isThreeCharSwear("xxx");
 */

package com.gmrmarketing.utilities
{
	public class  SwearFilter
	{
		private static var swears:Array;
		private static var threeCharSwears:Array;
		private static var punctuation:Array;
		
		
		public function SwearFilter(){}
		
		
		/**
		 * Returns true if the text contains any of the swear words in the swears array
		 * @param	text string to check for swear words
		 * @param	exception A String to not be checked - such as 'dick' when checking a name field
		 * @return 	Boolean True if the incoming string contains a swear
		 */
		public static function isSwear(text:String, exception:String = null):Boolean
		{	
			//need to init each time so any exceptions aren't removed for the next check
			init();
			
			var t:String = text.toLowerCase();
			
			//make a compacted string with no spaces, or punctuation to catch things like "f-u=c*k and pu55y"
			var ar:Array = t.split(/[\W'_]+/gi);
			var compacted:String = ar.join("");
			
			//remove the exception if it exists
			if (exception != null) {
				swears.splice(swears.indexOf(exception), 1);
			}
			
			var i:int;
			for (i = 0; i < swears.length; i++) {
				if (compacted.indexOf(swears[i]) != -1) {
					return true;
				}
			}
			
			return false;
		}
		
		
		/**
		 * Returns true if the passed in text is equal to any of the swear abbreviations in the threeCharSwears array
		 * Useful for checking things like initials in a high-score table
		 * @param	text
		 * @return Boolean - true if the string is a swear
		 */
		public static function isThreeCharSwear(text:String):Boolean
		{
			init();
			return threeCharSwears.indexOf(text.toLowerCase()) == -1 ? false : true;
		}
		
		
		
		private static function init():void
		{
			swears = new Array();
			swears.push("anus", "anal", "assmuncher", "asseater", "assbeater", "asslicker", "asshole", "a55");
			swears.push("beaner", "bitch", "b1t", "blowjob", "boner", "bullshit", "buttplug");
			swears.push("cameltoe", "chinc", "clit", "cock", "cooch", "cum", "cunt", "cunny");
			swears.push("dago", "dick", "dildo", "douche", "dyke");			
			swears.push("fag", "fellatio", "fuck", "flamer");
			swears.push("gay", "gook", "guido");
			swears.push("homo", "honkey", "handjob");
			swears.push("jap", "jigaboo", "junglebunny");
			swears.push("kike", "kooch", "kraut", "kyke");
			swears.push("lesbo", "lesbian", "lezzie", "lez");
			swears.push("motherfucker", "muff");
			swears.push("nigga", "nigger", "nigg3r", "niglet", "nutsack");
			swears.push("pecker", "penis", "p3nis", "piss", "pi55", "poon", "prick", "pussy", "pu55");
			swears.push("queef", "queer", "qu33");
			swears.push("retard", "rimjob");
			swears.push("shit", "sh1t", "skank", "slut", "snatch", "spic", "spick", "splooge");
			swears.push("tard", "testicle", "titsucker", "titlicker", "titfeeler", "titmilker", "titpuller", "tittoucher", "titty", "titties", "twat");
			swears.push("vag", "vagina", "vjayjay", "vajayjay");
			swears.push("wank", "wetback", "whore", "wop");
			
			threeCharSwears = new Array();
			threeCharSwears.push("god", "ass", "azz", "anl", "aho", "fuk", "fkr", "fuc", "fck", "fux");
			threeCharSwears.push("vag", "pus", "psy", "cnt", "cun", "pis", "pee", "sht", "poo", "cum", "jiz");
			threeCharSwears.push("dik", "dic", "dck", "pns", "cok", "coc", "cox", "gay", "yag", "fag");
			threeCharSwears.push("lez", "tit", "tty", "kkk", "ngr", "nig", "sex", "xes", "suk", "sux", "lix", "pig");		
		}
	}
	
}