package com.gmrmarketing.comcast.scratchoff
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import com.greensock.TweenLite;
	

	public class PunchOut extends MovieClip
	{
		private var gameIcons:Array;
		
		private var faces:Array;
		
		private var leftEdge:int = 78;
		private var topEdge:int = 230;
		private var colWidth:int = 110;
		
		private var winArray:Array;
		private var tries:int;
		
		private var channel:SoundChannel;
		private var sound:Sound;
		
		private var animIcon:MovieClip;
		
		
		
		public function PunchOut() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, clear, false, 0, true);
		}
		
		private function init(e:Event):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			sound = new punchSound(); //library sound
			buildGameBoard();
		}
		
		private function clear(e:Event = null):void
		{
			//channel.removeEventListener(Event.SOUND_COMPLETE, soundDone);
			for (var i:int = 0; i < faces.length; i++) {
				faces[i].removeEventListener(MouseEvent.MOUSE_DOWN, faceClicked);
			}
		}
		
		private function buildArray():Array
		{
			//holds tv, internet, phone counts
			winArray = new Array(0, 0, 0);			
			tries = 0;
			
			var iconStrings:Array = new Array();
			
			var i:int;
			
			for (i = 0; i < 6; i++) {
				iconStrings.push("tv");
			}
			for (i = 0; i < 6; i++) {
				iconStrings.push("internet");
			}
			for (i = 0; i < 6; i++) {
				iconStrings.push("phone");				
			}
			for (i = 0; i < 6; i++) {
				iconStrings.push("blank");
			}
			
			//randomize the array
			var ind:int;
			var ar:Array = new Array();
			while (iconStrings.length) {
				ind = Math.floor(Math.random() * iconStrings.length);
				ar.push(iconStrings.splice(ind, 1)[0]);
			}
			
			return ar;
		}
		
		
		private function buildGameBoard():void
		{
			gameIcons = buildArray();
			
			faces = new Array();
			
			for (var i:int = 0; i < gameIcons.length; i++) {
				var loc:Array = gridLoc(i + 1, 8);
				var face:punchFace = new punchFace(); //library clip
				face.x = leftEdge + (loc[0] - 1) * colWidth;
				face.y = topEdge + loc[1] * colWidth;
				face.ind = i;
				addChild(face);
				faces.push(face);
				face.addEventListener(MouseEvent.MOUSE_DOWN, faceClicked, false, 0, true);
			}
		}
		
		
		private function killIcon():void
		{
			if (contains(animIcon)) {
				removeChild(animIcon);
			}			
		}
		
		
		private function faceClicked(e:MouseEvent):void
		{
			channel = sound.play();
			
			//index in the gameIcons array
			var i:int = e.currentTarget.ind;
			var s:String = gameIcons[i];
			
			//remove listener from face to prevent multiple presses
			faces[i].removeEventListener(MouseEvent.MOUSE_DOWN, faceClicked);
			
			var bmd:BitmapData;
			
			switch(s) {
				case "tv":
					bmd = new tv(103, 102);
					
					if(winArray[0] != 1){
						animIcon = new iconTVRed(); //library clip
						addChild(animIcon);
						animIcon.x = e.currentTarget.x;
						animIcon.y = e.currentTarget.y;
						TweenLite.to(animIcon, .75, { x:tvCover.x + 14, y:tvCover.y + 6, onComplete:killIcon } );
						TweenLite.to(tvCover, .5, { alpha:0, delay:.75 } );
					}
					
					winArray[0] = 1;					
					break;
				case "internet":
					bmd = new internet(103, 102);					
					
					if(winArray[1] != 1){
						animIcon = new iconMouseRed(); //library clip
						addChild(animIcon);
						animIcon.x = e.currentTarget.x;
						animIcon.y = e.currentTarget.y;
						TweenLite.to(animIcon, .75, { x:internetCover.x + 14, y:internetCover.y + 6, onComplete:killIcon } );
						TweenLite.to(internetCover, .5, { alpha:0, delay:.75 } );
					}
					
					winArray[1] = 1;
					break;
				case "phone":
					bmd = new phone(103, 102);
					
					if(winArray[2] != 1){
						animIcon = new iconPhoneRed(); //library clip
						addChild(animIcon);
						animIcon.x = e.currentTarget.x;
						animIcon.y = e.currentTarget.y;
						TweenLite.to(animIcon, .75, { x:phoneCover.x + 14, y:phoneCover.y + 6, onComplete:killIcon } );
						TweenLite.to(phoneCover, .5, { alpha:0, delay:.75 } );
					}
					winArray[2] = 1;
					break;
				case "blank":
					bmd = new blank(103, 102);					
					break;
			}
			
			tries++;
			
			var bmp:Bitmap = new Bitmap(bmd);
			var loc:Array = gridLoc(i + 1, 8);
			
			bmp.x = leftEdge + (loc[0] - 1) * colWidth;
			bmp.y = topEdge + loc[1] * colWidth;
			addChild(bmp);
			
			var broke:punched = new punched(103, 102);
			var brokeBMP = new Bitmap(broke);
			brokeBMP.x = leftEdge + (loc[0] - 1) * colWidth;
			brokeBMP.y = topEdge + loc[1] * colWidth;
			addChild(brokeBMP);
			
			
			if (winArray[0] == 1 && winArray[1] == 1 && winArray[2] == 1) {					
				//win
				//removeListeners();
				clear();
				dispatchEvent(new Event("win"));
			}else {
				if (tries >= 5) {
					//lose
					//removeListeners();
					clear();
					dispatchEvent(new Event("lose"));
				}
			}
		}
		
		/*
		private function removeListeners():void
		{
			for (var i:int = 0; i < faces.length; i++) {
				faces[i].removeEventListener(MouseEvent.MOUSE_DOWN, faceClicked);
			}
		}
		*/

		
		
		/** 
		 * Returns column,row in array like 1,1 for upper left corner
		 * @param	index 1 - n
		 * @param	perRow
		 * @return	Array with two elements x,y
		 */
		private function gridLoc(index:Number, perRow:Number):Array
        {
            return new Array(index % perRow == 0 ? perRow : index % perRow, Math.ceil(index / perRow));
        }
	}
	
}