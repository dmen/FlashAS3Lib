////////////////////////////////////////////////////////////////////////////////////////////////////////	
//	ADOBE SYSTEMS INCORPORATED																		  //
//	Copyright 2011 Adobe Systems Incorporated														  //
//	All Rights Reserved.																			  //
//																									  //
//	NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the		  //
//	terms of the Adobe license agreement accompanying it.  If you have received this file from a	  //
//	source other than Adobe, then your use, modification, or distribution of it requires the prior	  //
//	written permission of Adobe.																	  //
////////////////////////////////////////////////////////////////////////////////////////////////////////

package com.adobe.nativeExtensions
{
	public class GyroscopeIntervalValue
	{
		public static const INTERVAL_NORMAL:int = 3;
		public static const INTERVAL_UI:int = 2;
		public static const INTERVAL_GAME:int = 1;
		public static const INTERVAL_FASTEST:int = 0;
		 
		public function GyroscopeIntervalValue() 
		{
			throw new Error("This class should not be instantiated");
		}
	}
}