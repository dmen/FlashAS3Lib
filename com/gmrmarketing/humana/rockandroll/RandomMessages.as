package com.gmrmarketing.humana.rockandroll
{	
	public class RandomMessages
	{
		private var messages:Array;
		
		public function RandomMessages()
		{
			var now:Number = new Date().valueOf();			
			
			messages = new Array();
			
			var a:Object;
			
			a = new Object();
			a.fName = "Pete";
			a.lName = "Smith";
			a.messages = [ { message:"Go Pete Go!", fromFName:"Dave", fromLName:"Johnson" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Eric";
			a.lName = "Flanders";
			a.messages = [ { message:"Run Faster Eric.", fromFName:"Eric", fromLName:"Flanders" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Tom";
			a.lName = "Johnson";
			a.messages = [ { message:"Tom, you're doing great!", fromFName:"Bill", fromLName:"Neely" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Kati";
			a.lName = "Darning";
			a.messages = [ { message:"We're Proud of You Kati!", fromFName:"Mom", fromLName:"Seville" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);			
			
			a = new Object();	
			a.fName = "Penny";
			a.lName = "Rich";
			a.messages = [ { message:"Go Penny Go!", fromFName:"Jerry", fromLName:"Lewis" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Nick";
			a.lName = "Nowak";
			a.messages = [ { message:"Nick, I'm going to beat you!", fromFName:"Tim", fromLName:"Witmer" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Ewan";
			a.lName = "ODonnell";
			a.messages = [ { message:"Run you big Scott!", fromFName:"Rio", fromLName:"Coleman" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Jim";
			a.lName = "Vernson";
			a.messages = [ { message:"Run HARD Jim!", fromFName:"Nancy", fromLName:"Kensington" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Kim";
			a.lName = "Lewis";
			a.messages = [ { message:"Go Kim GO!", fromFName:"Jon", fromLName:"Jaedike" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);
			
			a = new Object();
			a.fName = "Jenny";
			a.lName = "Froth";
			a.messages = [ { message:"You're doing amazing Jenny!", fromFName:"Dad", fromLName:"Froth" } ];
			a.viewingTime = now;
			a.messageTime = 45;
			a.missedTime = now + 90000;			
			messages.push(a);			
		}
	}
	
}