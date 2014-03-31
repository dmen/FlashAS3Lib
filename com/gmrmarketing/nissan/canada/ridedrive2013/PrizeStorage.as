package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import com.gmrmarketing.utilities.Utility;
	import flash.utils.Timer;
	
	public class PrizeStorage
	{
		private var so:SharedObject;
		private var savedPrizes:Array;
		private var prizeList:Array;
		//private var failedPostList:Array;
		private var failedPost:Array; //current failed initial post - one item from savedPrizes
		private var failedTimer:Timer;
		private var doShowCar:Boolean;
		private var poster:PostData;
		
		private var userID:String;
		private var prize:String;
		
		
		public function PrizeStorage()
		{
			so = SharedObject.getLocal("nissanData");
			
			poster = new PostData();
			poster.addEventListener(PostData.TOKEN_RECEIVED, tokenReceived);
			poster.addEventListener(PostData.DATA_POSTED, prizePosted);
			poster.addEventListener(PostData.POST_ERROR, prizeNotPosted);
			poster.addEventListener(PostData.FAIL_DATA_POSTED, failPrizePosted);
			poster.addEventListener(PostData.FAIL_POST_ERROR, failPrizeError);
			
			savedPrizes = so.data.prizes;//array of arrays - subarrays contain id,prize,didPost
			if (savedPrizes == null) {
				savedPrizes = new Array();
			}			
			
			prizeList = so.data.prizeList;
			
			if(prizeList == null){
				prizeList = new Array();
				for (var i:int = 0; i < 995; i++) {
					prizeList.push("$1,000");
				}
				//5 3000 prizes
				for (i = 0; i < 4; i++) {
					prizeList.push("$3,000");
				}
				prizeList.push("$30,000");
				
				prizeList = Utility.randomizeArray(prizeList);				
				
				for (i = 0; i < 10000; i++) {
					prizeList.push("$1,000");
				}
				prizeList.push("$3,000");//last entry is $3000
				
				so.data.prizeList = prizeList;				
			}			
			
			if (so.data.doShowCar == null) {
				doShowCar = true;
				so.data.doShowCar = true;
			}else {
				doShowCar = so.data.doShowCar;
			}			
			
			so.flush();			
		}
		
		
		public function numFailed():int
		{
			var num:int = 0;
			for (var i:int = 0; i < savedPrizes.length; i++) {
				if (savedPrizes[i][2] == "0") {
					num++;
				}
			}
			return num;
		}
		
		/**
		 * called once the token has been received from the poster (PostData) object
		 * @param	e
		 */
		private function tokenReceived(e:Event):void
		{
			poster.removeEventListener(PostData.TOKEN_RECEIVED, tokenReceived);
			
			failedTimer = new Timer(300000, 1);
			failedTimer.addEventListener(TimerEvent.TIMER, getFailed);
			
			getFailed();
		}
		
		
		/**
		 * populates the failedPostList array - which is any items
		 * in the savedPrizes list where index 2 is 0 - indicating
		 * an unsuccessful initial post to the server
		 * 
		 * @param	e
		 */
		private function getFailed(e:TimerEvent = null):void
		{
			//failedPostList = new Array();
			failedPost = new Array();
			for (var i:int = 0; i < savedPrizes.length; i++) {
				if (savedPrizes[i][2] == "0") {
					//failedPostList.push(savedPrizes[i]);
					failedPost = savedPrizes[i];
					break;
				}
			}
			
			if (failedPost.length != 0) {
				postNextFail();
			}else {
				failedTimer.reset();
				failedTimer.start();//call getFailed() again in 5 minutes
			}
			//postNextFail();
		}
		
		
		/**
		 * called from failPrizePosted() once a fail has posted
		 * and from getFailed() after populating the failedPostList array
		 */
		private function postNextFail():void
		{
			//trace("postNextFail", failedPost[0], failedPost[1]);
			//if (failedPostList.length > 0) {	
			//if(failedPost.length == 1){
				//poster.postFail(failedPostList[0][0], failedPostList[0][1]);
				poster.postFail(failedPost[0], failedPost[1]);//id,prize
			//}else {
				//no failed posts - wait 30 seconds and call getFailed()
				//failedTimer.reset();
				//failedTimer.start();
			//}
		}
		
		
		/**
		 * Called by listener on the poster object once the call to postNextFail - poster.postFail completes
		 * removes the failed post from the failedPostList and then 
		 * changes the "0" to a "1" in the savedPrizes array
		 * 
		 * @param	e FAIL_DATA_POSTED event from PostData
		 */
		private function failPrizePosted(e:Event):void
		{			
			//var fail:Array = failedPostList.shift();	
			
			for (var i:int = 0; i < savedPrizes.length; i++) {
				if (savedPrizes[i][0] == failedPost[0]){// fail[0]) { //match id
					savedPrizes[i][2] = "1"; //did post
					break;//only one
				}
			}
			
			flushPrizes();
			
			so.data.prizes = savedPrizes;
			so.flush();
			
			//postNextFail();
			getFailed();
		}
		
		
		/**
		 *  Called by listener on the poster if the call to postNextFail
		 * @param	e PrizeStorage.FAIL_POST_ERROR
		 */
		private function failPrizeError(e:Event):void
		{
			failedTimer.reset();//call get failed in 30 seconds
			failedTimer.start();
		}
		
		
		/**
		 * Adds an ID and prize to the list of stored prizes
		 * 
		 * @param	userID
		 * @param	prize
		 */
		public function addPrize($userID:String, $prize:String):void
		{
			userID = $userID;
			prize = $prize;
			poster.post(userID, prize);//post to web service
		}
		
		
		/**
		 * called by listener on PostData once the initial and follow_up
		 * posts are successful
		 * 
		 * @param	e PostData.DATA_POSTED event
		 */
		private function prizePosted(e:Event):void
		{
			savedPrizes.push([userID, prize, "1"]);	//a 1 in index 2 indicates a successful post
			
			flushPrizes();
			
			so.data.prizes = savedPrizes;
			so.flush();
		}
		
		
		/**
		 * 
		 * @param	e PostData.POST_ERROR event
		 */
		private function prizeNotPosted(e:Event):void
		{
			savedPrizes.push([userID, prize, "0"]);	//0 in index 2 to indicate a failed post	
			so.data.prizes = savedPrizes;
			so.flush();
			
			failedTimer.reset();
			failedTimer.start();//call getFailed() again in 5 minutes
		}
		
		
		public function idExists(userID:String):Boolean
		{
			for (var i:int = 0; i < savedPrizes.length; i++) {
				if (savedPrizes[i][0] == userID) {
					return true;
				}
			}
			return false;
		}
		
		
		public function getNextPrize():String
		{
			var nextPrize:String = prizeList.shift();
			if (nextPrize == "$30,000" && !doShowCar) {
				//get next prize if grand prize is selected but not being shown on the wheel
				nextPrize = prizeList.shift();
			}
			so.data.prizeList = prizeList;
			so.flush();
			return nextPrize;
		}
		
		
		public function showCar():Boolean
		{
			return doShowCar;
		}
		
		
		public function numSpins():int
		{
			return savedPrizes.length;
		}
		
		
		public function setShowCar(sh:Boolean):void
		{
			so.data.doShowCar = sh;
			doShowCar = sh;
			so.flush();
		}
		
		
		/**
		 * removes any 00000 id's from the savedPrizes array
		 */
		private function flushPrizes():void
		{
			var l:int = savedPrizes.length - 1;
			
			for (var i:int = l; i >= 0; i--) {
				
				if (savedPrizes[i][0] == "00000") {
					savedPrizes.splice(i, 1);
				}
			}
			
		}
		
	}
	
}