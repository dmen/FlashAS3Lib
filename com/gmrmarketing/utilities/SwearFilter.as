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
		private static var unique:Array;
		private static var swears:Array;
		private static var threeCharSwears:Array;
		private static var punctuation:Array;
		private static var majorSwears:Array; //used in cleanString
		
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
			var i:int;
			
			var t:String = text.toLowerCase();
			
			var compacted:String;
			//regExps to remove all punctuation from the string
			var regs:Array = new Array(/\!/g,/\./g,/\,/g,/\</g,/\>/g,/\|/g,/\@/g,/\#/g,/\$/g,/\%/g,/\^/g,/\&/g,/\*/g,/\,/g,/\(/g,/\)/g,/\-/g,/\_/g,/\+/g,/\=/g,/\:/g,/\;/g,/\~/g,/\`/g,/\//g,/\\/g);
			
			compacted = t.replace(regs[0], "");
			for(i = 1; i < regs.length; i++){
				compacted = compacted.replace(regs[i],  "");
			}			
			
			compacted = " " + compacted + " "; //add a space to the start and end			
			
			//remove the exception from the swears list, if it exists
			if (exception != null) {
				swears.splice(swears.indexOf(exception), 1);
			}			
			
			//test for swears - spaces around the word
			for (i = 0; i < swears.length; i++) {
				if (compacted.indexOf(" " + swears[i] + " ") != -1) {
					return true;
				}
			}
			
			//test for uniques - can exist inside a word - such as 'mefuckyou'
			for (i = 0; i < unique.length; i++) {
				if (compacted.indexOf(unique[i]) != -1) {
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
		
		
		/**
		 * Returns a cleaned string - where major swears are removed and replaced with null
		 * @param	s
		 * @return String cleaned of any words defined in majorSwears
		 */
		public static function cleanString(s:String):String
		{			
			init();
			var t:Array = s.split(" ");
			
			for (var j:int = 0; j < majorSwears.length; j++){
				for (var i:int = t.length -1; i >= 0; i--) {
					if (String(t[i]).toLowerCase().indexOf(String(majorSwears[j]).toLowerCase()) != -1) {					
						t.splice(i, 1);		
					}
				}
			}
			
			var m:String = t.join(" ");
			
			for (j = 0; j < majorSwears.length; j++) {
				var r:RegExp = new RegExp(majorSwears[j], "ig");//flags are ignore case and global
				m = m.replace(r, "");
			}
			
			return m;
		}
		
		
		private static function init():void
		{
			//used for cleaning major swears out of twitter feeds
			majorSwears = new Array("fuck", "fvck", "shit", "bitch", "cunt", "fagg", "pussy", "asshole", "nigger", "retard", "vagina", "penis", "douche");
			
			//uniques can exist inside a word and still provide a positive
			unique = new Array();
			unique.push("assmuncher", "asseater", "assbeater", "asslick", "asshole", "asshat", "assface", "a55", "bullshit", "buttplug", "blowjob");		unique.push("cameltoe", "cunt", "cunny", "prostitute");
			unique.push("fellatio", "fuck", "fvck", "faggot")
			unique.push("nigger", "nigg3r", "niglet", "nutsack", "motherfucker");
			unique.push("jigaboo", "junglebunny", "handjob", "p3nis", "sh1t", "shithead", "retard", "queer");
			unique.push("testicle", "titsucker", "titlicker", "titfeeler", "titmilker", "titpuller", "tittoucher", "titty", "titties");
			unique.push("vagina", "vjayjay", "vajayjay", "pu55", "pu55y", "pussy", "wetback", "rimjob");
			
			//swears must be individual - aka a space around them to be a swear
			swears = new Array();
			swears.push("anus", "anal", "ass","airhead");
			swears.push("bitch", "boner");
			swears.push("chinc", "clit", "cock", "cooch", "cum");
			swears.push("damn", "dammit", "dago", "dick", "dildo", "douche", "dyke");			
			swears.push("fag", "fart", "flamer");
			swears.push("gook", "guido");
			swears.push("homo", "honkey", "hooker");
			swears.push("jap");
			swears.push("kike", "kooch", "kraut", "kyke");
			swears.push("lesbo", "lezzie", "lez");
			swears.push("muff");
			swears.push("nigga");
			swears.push("pecker", "penis", "piss", "pi55", "poon", "prick" );
			swears.push("queef", "queer");			
			swears.push("schmuck", "shit", "skank", "slut", "snatch", "spic", "spick", "splooge");
			swears.push("tard", "twat");
			swears.push("vag");
			swears.push("wank", "whore", "wop");
			
			threeCharSwears = new Array();
			threeCharSwears.push("god", "ass", "azz", "anl", "aho", "fuk", "fkr", "fuc", "fck", "fux");
			threeCharSwears.push("vag", "pus", "psy", "cnt", "cun", "pis", "pee", "sht", "poo", "cum", "jiz");
			threeCharSwears.push("dik", "dic", "dck", "pns", "cok", "coc", "cox", "gay", "yag", "fag");
			threeCharSwears.push("lez", "tit", "tty", "kkk", "ngr", "nig", "sex", "xes", "suk", "sux", "lix", "pig");		
		}
	}
	
}