/**
 * General Shared Object wrapper utility
 * Manages an array of aribitrary objects
 * 
 * useage:
 * 
 * var mySO:SharedObjectWrapper = new SharedObjectWrapper();
 * 
 * Get current cata in the SO:
 * var soData = mySO.getData();
 * 
 * Clear all data in the SO:
 * mySO.clearData();
 * 
 * Add a new object to the SO:
 * mySO.addObject(object:Object);
 */
package com.gmrmarketing.utilities
{
	import flash.net.SharedObject;
	
	public class SharedObjectWrapper
	{
		private var so:SharedObject;
		private var myData:Array;
		
		
		public function SharedObjectWrapper()
		{			
			so = SharedObject.getLocal("bcbs_fyb");
			myData = so.data.userData;
			
			if (myData == null) {
				trace("so myData is null setting to empty array");
				myData = new Array();
			}
			
			trace("so", myData, myData.length);
		}
		
		
		/**
		 * Returns the current array of objects
		 * @return
		 */
		public function getData():Array
		{
			return myData;			
		}
		
		
		/**
		 * Replaces the current data array with a new one
		 * @param	newData
		 */
		public function setData(newData:Array):void
		{
			trace("setData");
			myData = newData;
			so.data.userData = myData;
			so.flush();
		}
		
		
		/**
		 * Clears all data in the object
		 */
		public function clearData():void
		{	
			trace("clearData");
			var a:Array = new Array();
			setData(a);
		}
		
		
		/**
		 * Adds a new array to the current data array
		 * @param	newOb
		 */
		public function addObject(newOb:Array):void
		{			
			trace("so addObject", newOb,newOb.length);
			myData.push(newOb);
			
			so.data.userData = myData;
			so.flush();			
		}
	}
	
}