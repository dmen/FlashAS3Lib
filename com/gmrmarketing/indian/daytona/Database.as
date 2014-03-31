/**
 * Singleton that controls all SQLite database activity
 * 
 * used by: Admin.as, Main.as
 */

package com.gmrmarketing.indian.daytona
{
	import flash.events.*;
	import flash.filesystem.*;
	import flash.data.*;
	import flash.net.*;
	
	public class Database extends EventDispatcher
	{
		public static const DB_ERROR:String = "db_error";
		public static const INDB:String = "indbresult";
		public static const USER_ADDED:String = "userAdded";
		public static const WINNERS_SELECTED:String = "winnersSelected";
		public static const NO_WINNERS:String = "noWinnersInPastHour";		
		public static const GOT_NAMES:String = "gotNames";
		
		private static var instance:Database;
		
		private var baseFile:File;
		private var sqlConnection:SQLConnection;
		private var sqlExec:SQLStatement;
		
		private var inDBRes:Boolean;
		private var winners:Array = [];
		private var names:Array = [];
		private var userData:Array;
		
		private var xmlLoader:URLLoader;
		
		
		public static function getInstance():Database
		{
			if (instance == null) {
				instance = new Database(new SingletonBlocker());
			}
			return instance;
		}
		
		
		public function Database(p_key:SingletonBlocker):void
		{
			// this shouldn't be necessary unless they fake out the compiler:
			if (p_key == null) {
				throw new Error("Error-Singleton");
			}else {
				xmlLoader = new URLLoader(new URLRequest("database.xml"));
				xmlLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			}
		}
		
		private function configLoaded(e:Event):void
		{
			var xm:XML = new XML(e.target.data);
			
			baseFile = new File(xm.path);	
			//baseFile = File.desktopDirectory;
			//baseFile = baseFile.resolvePath("indianData.db");
			
			sqlConnection = new SQLConnection();
			sqlExec = new SQLStatement();				
			
			//create the db if it doesn't exist
			if (!baseFile.exists) {
				sqlConnection.open(baseFile);
				sqlExec.sqlConnection = sqlConnection;
				sqlExec.text = "CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, fname TEXT, lname TEXT, zip TEXT, phone TEXT, email TEXT, timeentered TEXT, moreinfo INTEGER, claimed INTEGER, noshow INTEGER)";
				sqlExec.addEventListener(SQLEvent.RESULT, createdDBResult, false, 0, true);
				sqlExec.execute();				
			}			
		}
		
		
		private function createdDBResult(e:SQLEvent):void
		{
			sqlExec.removeEventListener(SQLEvent.RESULT, createdDBResult);
			sqlConnection.close();
		}
	
		/**
		 * Called from EmailForm.as
		 * @param	email
		 */
		public function inDatabase(email:String):void
		{
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "SELECT * FROM users WHERE email='" + email + "'";
			sqlExec.addEventListener(SQLEvent.RESULT, inDBResult, false, 0, true);
			
			sqlExec.execute();			
		}
		
		
		
		private function inDBResult(e:SQLEvent):void
		{
			sqlExec.removeEventListener(SQLEvent.RESULT, inDBResult);
			sqlConnection.close();
			
			userData = sqlExec.getResult().data;
			
			if(userData){
				if (userData.length > 0) {
					inDBRes = true;
				}else {
					inDBRes = false;
				}
			}else {
				inDBRes = false;
				userData = [ {fname:"", lname:"" } ]; //empty object at index 0 so getUserData() returns an empty object
			}			
			
			dispatchEvent(new Event(INDB));
		}
		
		
		public function getUserData():Object
		{
			return userData[0];
		}
		
		
		public function getInDBResult():Boolean
		{
			return inDBRes;
		}
			
		
		
		public function addUser(fName:String, lName:String, zip:String, phone:String, email:String, moreInfo:int):void
		{
			var stamp:String = getTimeStamp();
			
			var efName:String = escape(fName);
			var elName:String = escape(lName);
			
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "INSERT INTO users (fname, lname, zip, phone, email, timeentered, moreinfo, claimed, noshow) VALUES ('" + efName + "','" + elName + "','" + zip + "','" + phone + "','" + email + "','" + stamp + "'," + moreInfo + ",0,0)";
			
			sqlExec.addEventListener(SQLEvent.RESULT, addResult, false, 0, true);
			
			sqlExec.execute();			
		}
		
		
		
		private function addResult(e:SQLEvent):void
		{			
			sqlExec.removeEventListener(SQLEvent.RESULT, addResult);
			sqlConnection.close();
			//trace(sqlExec.getResult().data); //null
			dispatchEvent(new Event(USER_ADDED));
		}
		
		
		
		/**
		 * Updates the users timestamp to the current time
		 * Called from MainForm.submitClicked() when the user is 
		 * already in the system
		 * 
		 * @param	email
		 */
		public function updateTimestamp(email:String):void
		{			
			var stamp:String = getTimeStamp();
			
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "UPDATE users SET timeentered='" + stamp + "' WHERE email='" + email + "'";
			sqlExec.addEventListener(SQLEvent.RESULT, updateResult, false, 0, true);
			sqlExec.execute();
			
		}
		
		private function updateResult(e:SQLEvent):void
		{
			sqlExec.addEventListener(SQLEvent.RESULT, updateResult);
			sqlConnection.close();
			dispatchEvent(new Event(USER_ADDED));
		}
		
		
		/**
		 * Called from Admin.showWinnerScreen()
		 * Gets the list of people entered in the last hour
		 */
		public function selectWinners():void
		{
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			
			//construct time stamp
			var a:Date = new Date(); //now
			
			var t:String = String(a.getFullYear()) + "-";
			
			var m:String = String(a.getMonth() + 1); //add 1 because month is returned as 0-11
			if (m.length < 2) {
				m = "0" + m;
			}
			var d:String = String(a.getDate());
			if (d.length < 2) {
				d = "0" + d;
			}
			
			t = t + m + "-" + d;
			
			var h:int = a.getHours();
			
			//in the next hour past the giveaway time?
			//ie it might be 3:02 for a 2:48 giveaway time
			if (a.getMinutes() < 48) {				
				h--; //subtract an hour			
			}
			
			var hours:String = String(h);
			if (hours.length < 2) {
				hours = "0" + hours;
			}
			
			t = t + " " + hours + ":48:00";			
			
			sqlExec.text = "SELECT * FROM users WHERE datetime(timeentered) > datetime('" + t + "','-1 hours')";
			
			sqlExec.addEventListener(SQLEvent.RESULT, selectWinnersResult, false, 0, true);
			//sqlExec.addEventListener(SQLEvent.ERROR, onError);
			
			sqlExec.execute();			
		}		

		
		private function selectWinnersResult(e:SQLEvent):void
		{	
			sqlExec.removeEventListener(SQLEvent.RESULT, selectWinnersResult);
			sqlConnection.close();
			
			var res:SQLResult = sqlExec.getResult();			
			
			winners = [];
			
			if(res != null && res.data != null){							
				winners = res.data.concat();
				for (var i:int = 0; i < winners.length; i++) {
					winners[i].fname = unescape(winners[i].fname);
					winners[i].lname = unescape(winners[i].lname);
				}
				dispatchEvent(new Event(WINNERS_SELECTED));
			}else {				
				dispatchEvent(new Event(NO_WINNERS));
			}
			
		}
		
		
		/**
		 * Called by Admin - gets the first and last names only
		 * used for the name animation
		 */
		public function selectNames():void
		{			
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "SELECT fname,lname FROM users ORDER BY timeentered DESC LIMIT 250";
			
			sqlExec.addEventListener(SQLEvent.RESULT, selectNamesResult, false, 0, true);			
			
			sqlExec.execute();		
		}
		
		
		private function selectNamesResult(e:SQLEvent):void
		{	
			sqlExec.removeEventListener(SQLEvent.RESULT, selectNamesResult);
			sqlConnection.close();
			
			var res:SQLResult = sqlExec.getResult();			
			
			if(res != null && res.data != null){							
				names = res.data.concat();
				for (var i:int = 0; i < names.length; i++) {
					names[i].fname = unescape(names[i].fname);
					names[i].lname = unescape(names[i].lname);					
				}
				dispatchEvent(new Event(GOT_NAMES));
			}			
		}
		
		
		public function getNames():Array
		{		
			return names;
		}
		
		
		/**
		 * Returns a random winner object from the array of possible winners
		 * @return
		 */
		public function getWinner():Object
		{
			var oneWinner:Object = { fname:"", lname:"" };
			
			if (winners.length) {
				oneWinner = winners[Math.floor(Math.random() * winners.length)];			
			}
			
			return oneWinner;
		}
		
		
		public function getNumWinners():int
		{
			return winners.length;
		}
		
		
		/**
		 * Called from Admin
		 * @param	curWin
		 */
		public function claimWinner(curWin:Object):void
		{
			removeFromWinners(curWin);
			
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "UPDATE users SET claimed=claimed+1 WHERE id=" + curWin.id;
			sqlExec.addEventListener(SQLEvent.RESULT, claimUpdated, false, 0, true);	
			sqlExec.execute();
			
		}
		
		private function claimUpdated(e:SQLEvent):void
		{
			sqlExec.removeEventListener(SQLEvent.RESULT, claimUpdated);
			sqlConnection.close();
		}
		
		/**
		 * Called from Admin
		 * @param	curWin
		 */
		public function noShow(curWin:Object):void
		{
			removeFromWinners(curWin);
			
			sqlConnection.open(baseFile);
			sqlExec.sqlConnection = sqlConnection;
			sqlExec.text = "UPDATE users SET noshow=noshow+1 WHERE id=" + curWin.id;
			sqlExec.addEventListener(SQLEvent.RESULT, noshowUpdated, false, 0, true);	
			sqlExec.execute();			
		}
		
		private function noshowUpdated(e:SQLEvent):void
		{
			sqlExec.removeEventListener(SQLEvent.RESULT, noshowUpdated);
			sqlConnection.close();
		}
		
		
		/**
		 * Removes a winner from the list of winners
		 * called from noShow or claimWinner
		 * 
		 * @param	curWin
		 */
		private function removeFromWinners(curWin:Object):void
		{
			for (var i:int = 0; i < winners.length; i++) {
				if (winners[i].id == curWin.id) {
					winners.splice(i, 1);
					break;
				}
			}
		}
		/**
		 * Returns a UTC timestamp for NOW
		 * in the form YYYY-MM-DD HH:MM:SS
		 * 
		 * @return String timestamp
		 */
		private function getTimeStamp():String
		{
			var now:Date = new Date();
			
			var y:String = String(now.getFullYear());
			var m:String = String(now.getMonth() + 1); //add 1 because month is returned as 0-11
			if (m.length < 2) {
				m = "0" + m;
			}
			var d:String = String(now.getDate());
			if (d.length < 2) {
				d = "0" + d;
			}
			var h:String = String(now.getHours());
			if (h.length < 2) {
				h = "0" + h;
			}
			var mm:String = String(now.getMinutes());
			if (mm.length < 2) {
				mm = "0" + mm;
			}
			var s:String = String(now.getSeconds());
			if (s.length < 2) {
				s = "0" + s;
			}
			
			return y + "-" + m + "-" + d + " " + h + ":" + mm + ":" + s;
		}
	}	
}

internal class SingletonBlocker {}