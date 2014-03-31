package com.gmrmarketing.testing
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.overlays.Marker;
	import com.google.maps.LatLng;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.controls.ZoomControl;	
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.MapMouseEvent;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.sensors.Geolocation;
	
	import com.gmrmarketing.testing.QuakeReader;
	import com.gmrmarketing.nissan.CustomZoomControl;
	
	
	public class Quakes extends MovieClip
	{
		private var map:Map;
		private var reader:QuakeReader;
		private var quakeList:Array;
		
		private var period:String; //hour,day,week
		private var compressionRatio:Number;
		
		private var loop:Boolean = false;
		private var loopTimer:Timer;
		
		private var segTimer:Timer; //for the spinning loader indicator
		private var curSegment:int; //segment to fade
		
		private var geolocation:Geolocation;
		
		
		
		public function Quakes()
		{       
			segTimer = new Timer(80);
			segTimer.addEventListener(TimerEvent.TIMER, nextSeg, false, 0, true);
			
			loopTimer = new Timer(2000, 1);
			loopTimer.addEventListener(TimerEvent.TIMER, doLoop, false, 0, true);
			
			map = new Map();
			map.key = "ABQIAAAAEmsJFo7jmBpA2NUE9158PxR8hGOqsIUX5x_H7rJ2ltblj1kXjhSB56X9unSqJCz_3pbt_rm10oWOmg";
			map.setSize(new Point(480, 320));
			map.x = 0;
			map.y = 0;
			map.url = "http://gmrmarketing.com";
			map.sensor = "true";
			
			map.addEventListener(MapEvent.MAP_READY, onMapReady);
			
			addChildAt(map, 0);
			
			btnHour.addEventListener(MouseEvent.CLICK, loadHour, false, 0, true);
			btnToday.addEventListener(MouseEvent.CLICK, loadToday, false, 0, true);
			btnDay.addEventListener(MouseEvent.CLICK, load24hr, false, 0, true);
			btnWeek.addEventListener(MouseEvent.CLICK, loadWeek, false, 0, true);
			btnAnimate.addEventListener(MouseEvent.CLICK, playQuakes, false, 0, true);
			
			loopCheck.addEventListener(MouseEvent.CLICK, toggleLoop, false, 0, true);
			
			btnMap.addEventListener(MouseEvent.CLICK, setTypeMap, false, 0, true);
			btnSat.addEventListener(MouseEvent.CLICK, setTypeSat, false, 0, true);
			
			zoomPlus.addEventListener(MouseEvent.CLICK, zoomIn, false, 0, true);
			zoomMinus.addEventListener(MouseEvent.CLICK, zoomOut, false, 0, true);
			
			
			
			if (Geolocation.isSupported){
				geolocation = new Geolocation();
				geolocation.setRequestedUpdateInterval( 10000 );
				geolocation.addEventListener( GeolocationEvent.UPDATE, handleGeolocationUpdate );
			}
		}
		
		
		private function onMapReady(e:MapEvent):void
		{
			//Add quit listeners here - if they are in the constructor then event.deactivate fires right away and
			//causes the app to quit as soon as it opens
			if(Capabilities.cpuArchitecture == "ARM")
			{
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys, false, 0, true);
			}
			
			map.removeEventListener(MapEvent.MAP_READY, onMapReady);			
			map.enableContinuousZoom();
			//map.addEventListener(MapMouseEvent.CLICK, showCoords);
			map.setCenter(new LatLng(39.90973623453747, 176.484375), 1, MapType.SATELLITE_MAP_TYPE);
			
			reader = new QuakeReader();
			reader.addEventListener(QuakeReader.QUAKES_LOADED, quakeListLoaded, false, 0, true);
			
			loadHour();
		}
		
		//for testing only
		private function showCoords(e:MapMouseEvent):void
		{
			var a:LatLng = map.getCenter();
			trace(a.lat(), a.lng(), map.getZoom());
		}
		
		private function setTypeMap(e:MouseEvent):void
		{
			map.setMapType(MapType.NORMAL_MAP_TYPE);
		}
			private function setTypeSat(e:MouseEvent):void
		{
			map.setMapType(MapType.SATELLITE_MAP_TYPE);
		}
		private function zoomIn(e:MouseEvent):void
		{
			map.zoomIn(null, false, true);
		}
			
		private function zoomOut(e:MouseEvent):void
		{
			map.zoomOut(null, true);
		}
		
		private function toggleLoop(e:MouseEvent):void
		{
			loop = !loop;
			if(loop){
				loopCheck.gotoAndStop(2);
			}else{
				loopCheck.gotoAndStop(1);
			}
		}
		
		private function quakeListLoaded(e:Event):void
		{	
			hideLoader();
			
			quakeList = reader.getQuakes();	
			quakeList.reverse(); //reverse so oldest is first - for animating
			
			for (var i:int = 0; i < quakeList.length; i++) {				
				
				var ic:MovieClip = new MovieClip(); //lib clip
				ic.graphics.lineStyle(1, 0x000000, 1);
				
				var col:Number = 0xff0000; //max color
				var mag:Number = Number(quakeList[i].magnitude);
				if (mag < 9) {
					col = 0xfe2b00;
				}
				if (mag < 8) {
					col = 0xfe5a00;
				}
				if (mag < 7) {
					col = 0xfe9100;
				}
				if (mag < 6) {
					col = 0xfee701;
				}
				if (mag < 5) {
					 col = 0xf6fa04;
				}
				if (mag < 4) {
					col = 0xd0fa0b;
				}
				if (mag < 3) {
					col = 0xa4fa13;
				}
				if (mag < 2) {
					col = 0x74fa1b;
				}
				if (mag < 1) {
					col = 0x45fa23;
				}
				
				ic.graphics.beginFill(col, 1);
				var radius:Number = quakeList[i].magnitude + 8;
				ic.graphics.drawCircle(-radius, -radius, radius);
				ic.alpha = .6;
				ic.quakeIndex = i; //index in quakeList
				
				var quakePosition:LatLng = new LatLng(Number(quakeList[i].latitude), Number(quakeList[i].longitude));
				var markerOptions:MarkerOptions = new MarkerOptions( { icon:ic, hasShadow:false, fillRGB:0x004000, name: quakeList[i].location, description: "" } );
				var marker:Marker = new Marker(quakePosition, markerOptions);
				
				marker.addEventListener(MapMouseEvent.CLICK, markerClicked, false, 0, true);
				
				map.addOverlay(marker);
				quakeList[i].marker = marker;
			}
			
			switch(period) {
				case "hour":
					quakeNum.text = String(quakeList.length) + " quakes in the last hour";
					break;
				case "today":
					quakeNum.text = String(quakeList.length) + " quakes today";
					break;
				case "day":
					quakeNum.text = String(quakeList.length) + " quakes in the last 24 hours";
					break;
				case "week":
					quakeNum.text = String(quakeList.length) + " quakes in the last week";
					break;
			}
			
		}
		
		private function markerClicked(e:MapMouseEvent):void
		{
			var qi:int = e.feature.getOptions().icon.quakeIndex;
			reader.traceQuake(qi);
			var quakePosition:LatLng = new LatLng(Number(quakeList[qi].latitude), Number(quakeList[qi].longitude));			
			
			var myTitle:String = "<b>" + quakeList[qi].location + "</b>";
			var myContent:String = quakeList[qi].month + " " + quakeList[qi].date + ", " + quakeList[qi].year + "     ";
			myContent += quakeList[qi].time + "<br/>";
			myContent += "mag: " + quakeList[qi].magnitude + "     ";
			myContent += "depth: " + quakeList[qi].depth + "<br/>";
			myContent += "nst: " + quakeList[qi].nst;
			
			map.openInfoWindow(quakePosition, new InfoWindowOptions( { titleHTML: myTitle, contentHTML: myContent } ));
			map.addEventListener(MapMouseEvent.CLICK, closeInfo, false, 0, true);
		}
		private function closeInfo(e:MapMouseEvent):void
		{
			map.closeInfoWindow();
			map.removeEventListener(MapMouseEvent.CLICK, closeInfo);
		}
		private function loadHour(e:MouseEvent = null):void
		{
			showLoader();
			clearQuakes();
			period = "hour";
			reader.loadQuakes("hour");	
		}
		
		private function loadToday(e:MouseEvent = null):void
		{
			showLoader();
			clearQuakes();
			period = "today";
			reader.loadQuakes("today");	
		}
		
		private function load24hr(e:MouseEvent = null):void
		{
			showLoader();
			clearQuakes();
			period = "day";
			reader.loadQuakes("day");	
		}
		
		
		private function loadWeek(e:MouseEvent = null):void
		{
			showLoader();
			clearQuakes();
			period = "week";
			reader.loadQuakes("week");	
		}
		
		
		private function clearQuakes():void
		{
			map.clearOverlays();			
			quakeNum.text = "";
		}

		
		private function playQuakes(e:MouseEvent = null):void
		{
			//info.text = ""
			timeScale();
			if(quakeList.length > 0){
				
				var dayMultiplier:int = 0;
				var lastHour:int;
				var lastTime:Number = 0;
				var delayTime:Number = 0;
				var msTime:Number;	
				var curTime:String = quakeList[0].time; //UTC time of the quake like 17:15:24
				var sep:Array = curTime.split(":");
				lastHour = sep[0];
				lastTime = (sep[0] * 60 * 60 * 1000) + (sep[1] * 60 * 1000) + (sep[2] * 1000);
				
				//set all quakes alphas to 0 before beginning animation
				for(var j:int = 0; j < quakeList.length; j++){					
					quakeList[j].marker.getOptions().icon.alpha = 0;
				}
				
				for(var i:int = 0; i < quakeList.length; i++){
					
					curTime = quakeList[i].time; //UTC time of the quake like 17:15:24			
					sep = curTime.split(":");
					
					if(sep[0] < lastHour){				
						dayMultiplier++;				
					}
					
					lastHour = sep[0];			
					
					msTime = ((lastHour + 24 * dayMultiplier)  * 60 * 60 * 1000) + (sep[1] * 60 * 1000) + (sep[2] * 1000);
				
					delayTime += (msTime - lastTime) * compressionRatio / 1000;		
					
					var q:MovieClip = quakeList[i].marker.getOptions().icon;
					
					//check for last one - if last one use onComplete to go to checkLoop
					if(i == quakeList.length - 1){
						TweenLite.to(q, .5, {alpha:.6, delay:delayTime, onComplete:checkLoop});
					}else{
						TweenLite.to(q, .5, {alpha:.6, delay:delayTime});
					}
					/*
					if(!keep){
						TweenLite.to(q, 1, {alpha:0, delay:delayTime+.5, overwrite:0});
					}*/
					
					lastTime = msTime;
				}
				
			
			}
		}
		
		private function checkLoop():void
		{
			//info.text = "Animation completed";
			if(loop){
				loopTimer.start(); //calls do loop in 2 seconds
			}
		}
		
		private function doLoop(e:TimerEvent):void
		{
			playQuakes();
		}
		
		//compressed time amount / original time amount = compression ratio
		private function timeScale():void
		{
			var compTimeMS:int = parseInt(sec.text) * 1000;
			
			switch(period){
				case "hour":			
					compressionRatio = compTimeMS / 3600000;
					break;
				case "day":						
					compressionRatio = compTimeMS / 86400000;
					break;
				case "today":						
					compressionRatio = compTimeMS / 86400000;
					break;
				case "week":			
					compressionRatio = compTimeMS / 604800000;
					break;
			}	
		}
		
		private function showLoader():void
		{
			curSegment = 1;
			segTimer.start();
			loader.alpha = 1;
		}
		private function hideLoader():void
		{
			segTimer.reset();
			loader.alpha = 0;
		}
		private function nextSeg(e:TimerEvent):void
		{
			loader["s" + curSegment].alpha = 1;
			TweenLite.to(loader["s" + curSegment], 1, {alpha:0});
			curSegment++;
			if(curSegment > 12){
				curSegment = 1;
			}
			
		}
		
		
		
		//CLOSE Handlers for Android
		private function handleActivate(event:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		//if Home is pressed
		private function handleDeactivate(event:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		 
		private function handleKeys(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.BACK){
				NativeApplication.nativeApplication.exit();
			}
		}
		
		
		
		
		//GPS for Android
		//e Event Object contains properties: 
		//latitude, longitude, speed (meters / sec), altitude (meters), heading (º angle with respect to north), verticalAccuracy, horizontalAccuracy
		private function handleGeolocationUpdate(e:GeolocationEvent):void
		{
			var curLoc:LatLng = new LatLng(e.latitude, e.longitude);
		}


	}
	
}