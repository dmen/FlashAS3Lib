package com.gmrmarketing.pm.matchgame
{
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.data.DataProvider;
	import flash.display.MovieClip;	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.gmrmarketing.pm.matchgame.IPadFile;
	import com.greensock.TweenMax;
	import flash.text.TextFormat;
	
	
	public class VenueDialog extends MovieClip 
	{
		private var iFile:IPadFile; //data for venue dialog
		private var currentVenue:String = "none";
		private var headerFormat:TextFormat;
		private var textFormat:TextFormat;
		
		
		public function VenueDialog()
		{
			iFile = new IPadFile();
			iFile.addEventListener("venueExists", venueAlreadyExists, false, 0, true);
			iFile.addEventListener("venueAdded", newVenueAdded, false, 0, true);
			
			textFormat = new TextFormat("Font1");
			textFormat.size = 18;
			headerFormat = new TextFormat("Font1");
			headerFormat.bold = true;
			headerFormat.size = 20;
			
			dg.setStyle("headerTextFormat", headerFormat); 
			dg.setRendererStyle("textFormat", textFormat); 
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var dgc:DataGridColumn = new DataGridColumn("date");
			dgc.headerText = "Date";
			dgc.width = 80;
			dg.addColumn(dgc);
			
			dgc = new DataGridColumn("venue");
			dgc.headerText = "Venue";
			dgc.width = 170;
			dg.addColumn(dgc);
			
			dgc = new DataGridColumn("games");
			dgc.headerText = "Games Played";
			dgc.width = 100;
			dg.addColumn(dgc);
			
			dgc = new DataGridColumn("avg");
			dgc.headerText = "Average Score";
			dgc.width = 100;
			dg.addColumn(dgc);
			
			dg.addEventListener(Event.CHANGE, venueSelected, false, 0, true);
			
			hideMessage();
			newVenue.visible = false;
			newVenue.venueName.text = "";
			btnNew.addEventListener(MouseEvent.MOUSE_DOWN, showNewVenue, false, 0, true);
			btnNo.addEventListener(MouseEvent.MOUSE_DOWN, noVenue, false, 0, true);
			btnReset.addEventListener(MouseEvent.MOUSE_DOWN, resetData, false, 0, true);
			btnOK.addEventListener(MouseEvent.MOUSE_DOWN, okSelected, false, 0, true);
		}
		
		
		
		/**
		 * Called by Engine when the dialog is opened
		 * Sets the data provider on the grid
		 */
		public function show():void
		{
			//iFile.getData() an array of objects with date,venue,games,total,avg properties			
			var dp:DataProvider = new DataProvider(iFile.getData());
			dg.dataProvider = dp;
			
			venueName.text = currentVenue;
		}
		
		
		public function addGame(score:int):void
		{			
			iFile.addGame(currentVenue, score);
		}
		
		
		/**
		 * Called by clicking the add new venue button
		 * Unhides the newVenue dialog
		 * 
		 * @param	e
		 */
		private function showNewVenue(e:MouseEvent):void
		{
			newVenue.visible = true;
			newVenue.venueName.text = "";
			newVenue.btnOK.addEventListener(MouseEvent.MOUSE_DOWN, addNewVenue, false, 0, true);
			newVenue.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelNewVenue, false, 0, true);
		}
		
		
		/**
		 * Called by clicking cancel in the add new venue dialog
		 * @param	e
		 */
		private function cancelNewVenue(e:MouseEvent = null):void
		{
			newVenue.venueName.text = "";
			newVenue.visible = false;
			newVenue.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, addNewVenue);
			newVenue.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelNewVenue);
		}
		
		
		
		/**
		 * Called by clicking OK in the add new venue dialog
		 * Tries to add the new venue to the iPadFile object
		 * 
		 * @param	e
		 */
		private function addNewVenue(e:MouseEvent):void
		{
			var newVenue:String = newVenue.venueName.text;
			iFile.addVenue(newVenue);
		}
		
		
		
		/**
		 * Called by event handler on iPadFile when the venue name already exists in the file
		 * @param	e
		 */
		private function venueAlreadyExists(e:Event):void
		{
			message.btnOK.visible = false;
			message.btnCancel.visible = false;
			message.theText.text = "Venue Already Exists";
			message.visible = true;
			message.alpha = 1;
			TweenMax.to(message, 1, { alpha:0, delay:.5, onComplete:hideMessage});
		}
		
		
		
		/**
		 * Called by event handler on iPadFile if the new venue was successfully added to the file
		 * @param	e
		 */
		private function newVenueAdded(e:Event):void
		{
			message.btnOK.visible = false;
			message.btnCancel.visible = false;
			message.theText.text = "New Venue Added";
			message.visible = true;
			message.alpha = 1;
			
			venueName.text = newVenue.venueName.text;
			currentVenue = newVenue.venueName.text;
			
			show();
			cancelNewVenue();
			TweenMax.to(message, 1, { alpha:0, delay:.5, onComplete:hideMessage});
		}
		
		
		/**
		 * Called from tweenMax when the message box is done fading out
		 * @param	e
		 */
		private function hideMessage(e:MouseEvent = null):void
		{
			message.visible = false;
			message.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, resetOK);
			message.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, hideMessage);
		}
		
		
		/**
		 * Called by clicking the reset button
		 * Shows the mssage box to confirm reset
		 * @param	e
		 */
		private function resetData(e:MouseEvent):void
		{
			message.visible = true;
			message.alpha = 1;
			message.btnOK.visible = true;
			message.btnCancel.visible = true;
			message.theText.text = "Press OK to reset all game data";
			message.btnOK.addEventListener(MouseEvent.MOUSE_DOWN, resetOK, false, 0, true);
			message.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, hideMessage, false, 0, true);
		}
		
		
		/**
		 * Called if OK is clicked in the confirm reset dialog
		 * @param	e
		 */
		private function resetOK(e:MouseEvent):void
		{
			iFile.reset();
			message.visible = true;
			message.alpha = 1;
			message.btnOK.visible = false;
			message.btnCancel.visible = false;
			message.theText.text = "All Data Reset";
			noVenue();
			show();
			TweenMax.to(message, 1, { alpha:0, delay:.5, onComplete:hideMessage});
		}
		
		
		
		/**
		 * Called by clicking the no venue button
		 * @param	e
		 */
		private function noVenue(e:MouseEvent = null):void
		{
			currentVenue = "none";
			venueName.text = currentVenue;			
		}
		
		
		
		/**
		 * Called by clicking the OK button at bottom right
		 * dispatches a close to Engine which calls closeVenueDialog
		 * @param	e
		 */
		private function okSelected(e:MouseEvent):void
		{
			dispatchEvent(new Event("closeVenueDialog"));
		}
		
		
		
		/**
		 * Called by selecting a venue in the grid
		 * @param	e
		 */
		private function venueSelected(e:Event):void
		{	
			currentVenue = dg.selectedItem.venue;
			venueName.text = currentVenue;
		}
		
		
		
		public function getCurrentVenue():String
		{
			return currentVenue;
		}
	}
	
}