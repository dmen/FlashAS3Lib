package 
{
	
	/**
	 * ...
	 * @author 
	 */
	public class  
	{
		/**
		 * Returns 1 if the user is over 18
		 * Returns 0 if the user is not over 18
		 * Returns -1 if the user entered an invalid DOB
		 * 
		 * @return integer
		 */
		/*
		private function checkEighteen():int
		{
			var userDOB:String = eighteen.dob.text;
			
			var yrmo:Array = userDOB.split("/");
			if (yrmo.length != 2) { return -1; }
			if (yrmo[0].length != 2 || yrmo[1].length != 4) { return -1; }
			
			var a:Date = new Date(); //today
			var b:Date = new Date(Number(yrmo[1]), Number(yrmo[0]));

			var yr:Number = a.getFullYear() - b.getFullYear();

			if (a.getMonth() < b.getMonth() - 1) {
				yr--;
			}
			
			return yr >= 18 ? 1 : 0;
		}
		*/
		
		/**
		 * Shows or hides the eighteen age verification box
		 * called from clearField() - that clears the user code when the field is clicked
		 * @param	onOff
		 */
		/*
		private function showEighteen(onOff:Boolean):void
		{
			var v = onOff == true ? 1 : 0;
			
			//if show - clear dob field 18
			//if (v) { eighteen.dob.text = ""; }
			
			TweenLite.to(eighteen, .5, { alpha:v } );
		}
		*/
		
		eighteen = new eighteenCheck(); //library clip			
			addChild(eighteen);
			eighteen.x = 626;
			eighteen.y = 41;
			eighteen.alpha = 0;
			eighteen.dob.text = "";
			eighteen.dob.restrict = "/0-9";
			eighteen.dob.maxChars = 7;
	}
	
}