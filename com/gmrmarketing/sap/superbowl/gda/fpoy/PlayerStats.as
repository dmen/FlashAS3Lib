package com.gmrmarketing.sap.superbowl.gda.fpoy
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	
	public class PlayerStats extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var pic:MovieClip;//player pic from library
		
		public function PlayerStats(which:String):void
		{	
			myClip = new statsPlayerR(); //lib clip
			
			myClip.stat1.label.autoSize = TextFieldAutoSize.RIGHT;
			myClip.stat1.value.autoSize = TextFieldAutoSize.RIGHT;
			myClip.stat2.label.autoSize = TextFieldAutoSize.RIGHT;
			myClip.stat2.value.autoSize = TextFieldAutoSize.RIGHT;
			myClip.stat3.label.autoSize = TextFieldAutoSize.RIGHT;
			myClip.stat3.value.autoSize = TextFieldAutoSize.RIGHT;
			myClip.thePosition.theText.autoSize = TextFieldAutoSize.RIGHT;
			myClip.theSentiment.value.autoSize = TextFieldAutoSize.RIGHT;
			
			switch(which) {				
				case "luck":					
					pic = new mcLuck();
					myClip.theName.theText.text = "ANDREW LUCK";					
					myClip.thePosition.theText.text = "QB/INDIANA";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "351.74";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "5,034";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "43";
					break;
				case "bell":
					pic = new mcBell();
					myClip.theName.theText.text = "LE'VEON BELL";
					myClip.thePosition.theText.text = "RB/PITTSBURGH";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "287.5";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "2,215";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "11";
					break;
				case "murray":
					pic = new mcMurray();
					myClip.theName.theText.text = "DEMARCO MURRAY";
					myClip.thePosition.theText.text = "RB/DALLAS";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "294.1";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "2,261";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "13";
					break;
				case "brown":
					pic = new mcBrown();
					myClip.theName.theText.text = "ANTONIO BROWN";
					myClip.thePosition.theText.text = "WR/PITTSBURGH";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "251.9";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "1,731";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "14";
					break;
					
				case "beckham":
					pic = new mcBeckham();
					myClip.theName.theText.text = "ODELL BECKHAM JR.";
					myClip.thePosition.theText.text = "WR/NEW YORK";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "204";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "1,340";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "12";
					break;
				case "gronkowski":
					pic = new mcGronkowski();
					myClip.theName.theText.text = "ROB GRONKOWSKI";
					myClip.thePosition.theText.text = "TE/NEW ENGLAND";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "184.4";
					myClip.stat2.label.text = "YDS:";
					myClip.stat2.value.text = "1,124";
					myClip.stat3.label.text = "TDS:";
					myClip.stat3.value.text = "12";
					break;
				case "gostkowski":
					pic = new mcGostkowski();
					myClip.theName.theText.text = "STEPHEN GOSTKOWSKI";
					myClip.thePosition.theText.text = "K/NEW ENGLAND";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "158";
					myClip.stat2.label.text = "FGS:";
					myClip.stat2.value.text = "35";
					myClip.stat3.label.text = "XPS:";
					myClip.stat3.value.text = "51";
					break;
				case "eagles":
					pic = new mcEagles();
					myClip.theName.theText.text = "PHILADELPHIA EAGLES";
					myClip.thePosition.theText.text = "DEF/PHILADELPHIA";
					myClip.stat1.label.text = "PTS:";
					myClip.stat1.value.text = "177";
					myClip.stat2.label.text = "TOS:";
					myClip.stat2.value.text = "12";
					myClip.stat3.label.text = "SKS:";
					myClip.stat3.value.text = "49";
					break;
			}
			
			myClip.stat1.label.x = 224 - myClip.stat1.value.textWidth - 10 - myClip.stat1.label.textWidth;
			//myClip.stat2.label.x = 108 - myClip.stat2.value.textWidth - 10 - myClip.stat2.label.textWidth;
			//myClip.stat3.label.x = 108 - myClip.stat3.value.textWidth - 10 - myClip.stat3.label.textWidth;
			
			var w:int = (122 - (myClip.stat2.label.textWidth + 6 + myClip.stat2.value.textWidth)) * .5;
			myClip.stat2.label.x = w;
			myClip.stat2.value.x = w + myClip.stat2.label.textWidth + 6;
			
			w = (122 - (myClip.stat3.label.textWidth + 6 + myClip.stat3.value.textWidth)) * .5;
			myClip.stat3.label.x = w;
			myClip.stat3.value.x = w + myClip.stat3.label.textWidth + 6;
			
			myClip.addChild(pic);
		}
		
		
		/**
		 * called from Main.dataLoaded()
		 * Once service call returns
		 * @param	s
		 */
		public function sentiment(s:String):void
		{
			myClip.theSentiment.value.text = s;
		}
		
		public function set number(n:String):void
		{
			myClip.theNumber.theText.text = n;					
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * use for setting x,y
		 */
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		public function get circ():Graphics
		{
			return pic.circ.graphics;
		}
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
			myClip.alpha = 1;
		}
		
		public function hide():void
		{
			TweenMax.to(myClip, .5, { alpha:0, onComplete:remove } );
		}
		
		
		public function remove():void
		{
			if (myClip.contains(pic)) {
				myClip.removeChild(pic);
			}
			if (myContainer.contains(myClip)) {
				myContainer.removeChild(myClip);
			}
			circ.clear();
		}
		
		
		/**
		 * Show just the player pic
		 */
		public function hideStats():void
		{
			myClip.theNumber.x = -65;
			myClip.theName.x = -296;
			myClip.thePosition.x = -162;
			myClip.theSentiment.x = -162;
			myClip.stat1.x = -175;
			myClip.stat2.x = -59;
			myClip.stat3.x = -59;			
		}
		
		
		/**
		 * Shows just the player name and number
		 */
		public function showStats():void
		{
			var tx:int;		
		
			TweenMax.to(myClip.theNumber, .25, { x:-145 } );				
			
			tx = -296 + myClip.theName.theText.textWidth + 70;
			TweenMax.to(myClip.theName, .25, { x:tx } );
			
			tx = -162 + myClip.thePosition.theText.textWidth + 42;
			TweenMax.to(myClip.thePosition, .25, { x:tx, delay:.1 } );
			
			tx = -162 + myClip.theSentiment.value.textWidth + 122 + 42;//122 is width of "Fan Sentiment" static text in field
			TweenMax.to(myClip.theSentiment, .25, { x:33, delay:.2 } );
			
			tx = -175 + (224 - myClip.stat1.label.x + 30);
			TweenMax.to(myClip.stat1, .25, { x:tx, delay:.3 } );
			
			tx = tx + myClip.stat1.width - 14;
			TweenMax.to(myClip.stat2, .25, { x: tx, delay:.4 } );
			tx = tx + myClip.stat2.width - 14;
			TweenMax.to(myClip.stat3, .25, { x: tx, delay:.5 } );
			
			
		}
		
	}
	
}