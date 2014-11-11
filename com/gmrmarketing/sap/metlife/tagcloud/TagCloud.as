/**
 * Mananges the tags returned from the web service
 * Gets the tags and then creates the tags array
 */

package com.gmrmarketing.sap.metlife.tagcloud
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import com.gmrmarketing.utilities.SwearFilter;
	
	
	public class TagCloud extends EventDispatcher
	{
		public static const TAGS_READY:String = "tagsLoaded";//dispatched from tagsLoaded() after a call to refreshTags()
		public static const ERROR:String = "tagError";//dispatched from tagsLoaded() after a call to refreshTags()
		
		private var tags:Object; //contains arrays of tags by level1, level2, level3 keys
		
		private var tagIndex:int = 0; //index of current tag in tags
		private var totalTagCount:int; //total of all value properties in the tags array
		
		private var hText:MovieClip;//lib clips used for drawing text into
		private var vText:MovieClip;
		private var sampleSize:int;//used by measure() to return the size in grid units of each word image
		
		private var tagColors:Array; //from config.xml
		private var colorDec:int;
		private var colorIndex:int;
		private var currColor:int;
		
		private var loopCount:int;//used to force successive calls to getNextTag() further down the tag list
		//so that smaller fonts are used
		private var maxFont:int;
		private var minFont:int;
		
		private var localCache:Array;
		private var tagLevel:int; //current tag level 1-3 used when refreshing tags
		private var myDate:String;
		
		private var tagWords:Object; //contains the hashtag for each level
		
		/**
		 * Constructor
		 * @param	ss The sample size - smaller is finer detail but takes longer
		 * @param	maxFontSize
		 * @param	minFontSize
		 * @param	name one of: levis,offense,defense,49ers
		 * @param	colors
		 */
		public function TagCloud(ss:int, maxFontSize:int, minFontSize:int)
		{
			sampleSize = ss;
			maxFont = maxFontSize;
			minFont = minFontSize;	
					
			hText = new mcHText();//lib			
			vText = new mcVText();//lib	
				
			loopCount = 0;			
		}
		
		
		/**
		 * Returns the next tag from the current tags array
		 * 
		 * tags have name,value,fontSize,imageh,imagev,widthh,heighth,widthv,heightv properties
		 */
		public function getNextTag():Object
		{
			var tag:Object = tags[tagIndex];
			tagIndex++;
			if (tagIndex >= tags.length) {
				loopCount++;
				tagIndex = 6 * loopCount;//move tagIndex further down the array on each iteration - forces smaller fonts
				tagIndex = Math.min(tagIndex, tags.length - 4);				
			}			
			return tag;
		}
		
		
		/**
		 * Returns the current tags array
		 * @return Array all tags
		 */
		public function getTags(level:int):Array
		{
			var t:Array;
			switch(level) {
				case 1:
					t = tags.level1;
					break;
				case 2:
					t = tags.level2;
					break;
				case 3:
					t = tags.level3;
					break;
			}			
			return t;
		}
		
		
		public function getHashTag(level:int):String
		{
			var t:String;
			switch(level) {
				case 1:
					t = tagWords.level1;
					break;
				case 2:
					t = tagWords.level2;
					break;
				case 3:
					t = tagWords.level3;
					break;
			}
			return t;
		}
		
		/**
		 * Refreshes the tags object from the web service
		 * @param	colors
		 * @param	date
		 */
		public function refreshTags(colors:Array, date:String):void
		{
			tags = new Object();
			tagWords = new Object();
			tagLevel = 1;
			tagColors = colors;
			myDate = date;
			getTagsByLevel();
		}
		
		
		private function getTagsByLevel():void
		{			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetMetLifeWordCloud?gamedate=" + myDate + "&level=" + tagLevel +"&abc=" + String(new Date().valueOf()));					
			
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, tagsLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, tagError, false, 0, true);
			l.load(r)
		}
		
		
		/**
		 * Callback for refreshTags()
		 * Creates the tags array of tag objects
		 * @param	e
		 */
		private function tagsLoaded(e:Event):void
		{	
			var j:Object = JSON.parse(e.currentTarget.data);
			var data:Array = j.insights[0].dataset[0].set;
			var localTags:Array;
			
			switch(tagLevel) {
				case 1:
					tags.level1 = data;
					localTags = tags.level1;
					tagWords.level1 = j.themename;
					break;
				case 2:
					tags.level2 = data;
					localTags = tags.level2;
					tagWords.level2 = j.themename;
					break;
				case 3:
					tags.level3 = data;
					localTags = tags.level3;
					tagWords.level3 = j.themename;
					break;
			}
			
			tagIndex = 0;
			totalTagCount = 0;
			
			//use localTags - passed by reference so localTags will affect tags.leveln
			for (var i:int = 0; i < localTags.length; i++) {				
				
				//normalize value using a logarithm
				localTags[i].value = Math.log(localTags[i].value);				
				totalTagCount += localTags[i].value;
				
				var name:String = localTags[i].name;
				name = name.replace(/&lt;/g, "<");
				name = name.replace(/&gt;/g, "<");
				name = name.replace(/&amp;/g, "&");
				name = SwearFilter.cleanString(name);				
				
				localTags[i].name = name;
			}			
						
			//font size by tag weight - possible because of mormalizing the counts
			//var fontRatio:Number = maxFontSize / ((tags[0].value / totalTagCount) * 100);
			
			//even distribution of font size along the list
			var fontRatio:Number = maxFont / localTags.length;
			
			colorDec = Math.ceil(localTags.length / tagColors.length);			
			colorIndex = 0;
			currColor = 0;
			
			for (i = 0; i < localTags.length; i++) {				
				//tags[i].fontSize = Math.max(12, Math.round(((tags[i].value / totalTagCount) * 100) * fontRatio));
				localTags[i].fontSize = Math.max(minFont, Math.round(maxFont - fontRatio * i));					
				//trace(localTags[i].fontSize );
				measure(localTags[i]);//passed by reference so tag in array is modified by measure()
			}
			
			tagLevel++;
			if (tagLevel < 4) {
				getTagsByLevel();
			}else {				
				//trace("tags processed", tags.level1.length, tags.level2.length, tags.level3.length);
				dispatchEvent(new Event(TAGS_READY));
			}
			
			//localCache = localTags.concat();//concat duplicates the array
			
			//
		}
		
		
		private function tagError(e:IOErrorEvent):void
		{			
			if (localCache) {
				tags = localCache.concat();
				dispatchEvent(new Event(TAGS_READY));
			}else {
				
			}
		}
		
		
		/**
		 * Modifies the passed in tag object 
		 * adds imageh,imagev,widthh,heighth,widthv,heightv
		 * This is a horizontal and vertical image of the tag
		 * and size data for both versions
		 * @param	tag
		 */
		private function measure(tag:Object):void
		{
			var format:TextFormat = new TextFormat();
			format.size = tag.fontSize;
			format.color = tagColors[colorIndex];
			
			currColor++;
			if (currColor % colorDec == 0) {
				colorIndex++;
			}
			
			hText.theText.autoSize = TextFieldAutoSize.LEFT;
			vText.theText.autoSize = TextFieldAutoSize.RIGHT;
			
			hText.theText.text = tag.name;
			vText.theText.text = tag.name;
			
			hText.theText.setTextFormat(format);
			vText.theText.setTextFormat(format);
			
			//draw text into transparent horizontal bitmap
			var h:BitmapData = new BitmapData(hText.width, hText.height, true, 0x00FFFFFF);
			h.draw(hText, null, null, null, null, true);
			
			//draw text into transparent vertical bitmap
			var v:BitmapData = new BitmapData(vText.width, vText.height, true, 0x00FFFFFF);
			v.draw(vText, null, null, null, null, true);
			
			//get a rect containing all nontransparent pixels - this is the actual text
			var rh:Rectangle = h.getColorBoundsRect(0xff000000, 0x00000000, false);
			var rv:Rectangle = v.getColorBoundsRect(0xff000000, 0x00000000, false);
			
			if (rh.width == 0 && rh.height == 0) {
				rh.width = 1; rh.height = 1;
			}
			if (rv.width == 0 && rv.height == 0) {
				rv.width = 1; rv.height = 1;
			}
			//new bitmap at rect size - actual text size
			var nh:BitmapData = new BitmapData(rh.width, rh.height, true, 0x00000000);
			nh.copyPixels(h, rh, new Point(0, 0));
			
			var nv:BitmapData = new BitmapData(rv.width, rv.height, true, 0x00000000);
			nv.copyPixels(v, rv, new Point(0, 0));
			
			//want to return the grid units the text will need based on the
			//current sampleSize setting			
			var wh:int = Math.max(1, Math.ceil(nh.width / sampleSize));
			var hh:int = Math.max(1, Math.ceil(nh.height / sampleSize));
			
			var wv:int = Math.max(1, Math.ceil(nv.width / sampleSize));
			var hv:int = Math.max(1, Math.ceil(nv.height / sampleSize));
			
			tag.imageh = nh;//horizontal image - BitmapData
			tag.imagev = nv;//vertical image - BitmapData
			tag.widthh = wh; //int
			tag.heighth = hh;//int
			tag.widthv = wv;//int
			tag.heightv = hv;//int
			//return {imageh:nh, imagev:nv, widthh:wh, heighth:hh, widthv:wv, heightv:hv};
		}
	}
	
}