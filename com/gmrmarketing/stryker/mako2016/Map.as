package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Map extends EventDispatcher
	{
		//dispatched when an event area is clicked (like kneedeep)
		public static const DETAIL:String = "detailClicked";
		private var _detail:String; //clip name of the clicked detail area
		
		private var clip:MovieClip;//instance of mcMap
		private var myContainer:DisplayObjectContainer;
		
		//ids of gates that have been visited - populated in setVisited - used when setting demo reminders so that a reminder
		//isn't set for a demo they've visited
		private var visitedIDs:Array; 
		
		private var _recommendations:Array;
		private var _appointments:Array;
		private var pulse:MovieClip;//red outline around the kiosk
		
		
		public function Map()
		{
			clip = new mcMap();
			clip.x = 620;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{			
			myContainer = c;
		}
		
		
		/**
		 * Called from Main.gotUserData() once the rfid is scanned and data is retrieved from orchestrate
		 * @param	kioskLogin String Info Kiosk login name - like Kiosk2
		 */
		public function show(kioskLogin:String):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.kiosk1.redOutline.alpha = 0;
			clip.kiosk2.redOutline.alpha = 0;
			clip.kiosk3.redOutline.alpha = 0;
			clip.kiosk4.redOutline.alpha = 0;
			clip.kiosk5.redOutline.alpha = 0;
			clip.kiosk6.redOutline.alpha = 0;
			clip.kiosk7.redOutline.alpha = 0;
			clip.kiosk8.redOutline.alpha = 0;
			
			var pt:Point = new Point();			
			pt.x = clip[kioskLogin.toLowerCase()].x;
			pt.y = clip[kioskLogin.toLowerCase()].y;
			pulse = clip[kioskLogin.toLowerCase()].redOutline;
			
			clip.youAreHere.x = pt.x + 8;//kiosk sprites are 16x18 so this gets the pt on center
			clip.youAreHere.y = pt.y + 9;
			clip.youAreHere.scaleX = clip.youAreHere.scaleY = 1.5;
			
			TweenMax.to(clip.youAreHere, 1, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.5});
			TweenMax.to(clip.youAreHere, 1, {scaleX:0, scaleY:0, delay:1.5, onComplete:startPulse });
		}
		
		
		private function startPulse():void
		{
			TweenMax.to(pulse, .5, {alpha:1, onComplete:endPulse});
		}
		
		
		private function endPulse():void
		{
			TweenMax.to(pulse, .5, {alpha:0, onComplete:startPulse});
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			TweenMax.killTweensOf(pulse);
		}
		
		
		/**
		 * Checks the users history object and marks off areas on the map that they've been to
		 * @param	user
		 * @param	gates This is the gates array from Orchestrate class
		 */
		public function setVisited(user:Object, gates:Array):void
		{
			visitedIDs = [];
			
			var hist:Array = user.history;
			
			clearIcons(gates);
			
			for (var i:int = 0; i < gates.length; i++){
				
				for (var j:int = 0; j < hist.length; j++){
					
					if (gates[i].id == hist[j].gateId){
						//user has been here - need to see if it's an entry point or a demo area
						//if entry point we turn the clip gray - if demo we put a check in the icon
						
						visitedIDs.push( hist[j].gateId);
						
						if (gates[i].hasOwnProperty("clip")){
							//entry point - turn the clip gray
							TweenMax.to(clip[gates[i].clip], 1, {colorTransform:{tint:0xE4E5E3, tintAmount:1}, delay:.25 * i});
						}						
						
						if (gates[i].hasOwnProperty("icon")){
							//demo - turn the clip gray
							clip[gates[i].icon].addChild(new iconCheck());
						}
						
						break;
					}
				}
			}
		}
		
		
		/**
		 * Checks the users optionalActivitySelections list - this is the list of demos they've scheduled
		 * if we're within one hour of an appointment, and the demo hasn't already been visited (it's id in the visitedIDs array)
		 * then place a bell icon in the holder
		 * 
		 * @param	user
		 * @param	gates This is the gates array from Orchestrate class
		 */
		public function setDemoReminders(user:Object, gates:Array):void
		{
			_appointments = [];
			
			var now:Date = new Date();
			var nh:Number = now.hours;
			var nm:Number = now.minutes;
			
			var demos:Array = user.optionalActivitySelections;//array of appointment objects
			
			//check each demos title property - gate name		
			
			var showBell:Boolean;
			
			for (var i:int = 0; i < gates.length; i++){
				
				for (var j:int = 0; j < demos.length; j++){
					
					showBell = false;
					
					if (gates[i].name == demos[j].title){
						
						if (visitedIDs.indexOf(gates[i].id) == -1){							
							
							//demo scheduled and not already visited
							//is the demos startTime within the next hour
							var a:String = demos[j].startTime;
							var t:String = a.substr(11);//just the time portion
							var h:int = parseInt(t.substr(0,2));//the hour
							var m:int = parseInt(t.substr(3, 2));//the minute
							
							//if it's less than 0 then we're past the appointment time
							var diff:int = h - nh;							
							if(diff >= 0 && diff < 2){
								
								//either 0 or 1
								if(diff == 0){		
									
									//in the same hour
									if(m > nm){
										
										//remind - the user is not late	
										showBell = true;										
										visitedIDs.push(gates[i].id);//add this id to visited so it's not recommended...										
									}
									
								}else{									
									//diff = 1
									
									if(nm > m){			
										//less than one hour to the event - remind
										showBell = true;
										visitedIDs.push(gates[i].id);//add this id to visited so it's not recommended...
									}		
								}
							}
							
							if (showBell){
								
								//convert to 12 hour time
								if (h > 12){
									h -= 12;
								}
								
								_appointments.push({"name":gates[i].name, "id":gates[i].id, "time":h + ":" + m + " pm"});
								
								var bell:MovieClip = new iconBell();
								clip[gates[i].icon].addChild(bell);
								
								var color:Number;
								if(gates[i].name == "Demo 1"){
										color = 0x86468b; //purple
								}else if(gates[i].name == "Demo 3"){
										color = 0x4d7e7c; //green
								}else{
									//demo 2,4,5,6,7
									color = 0xfdb414//yellow
								}
								
								TweenMax.to(bell, .5, {colorTransform:{tint:color, tintAmount:1}});
							}
							
						}
					
					}
				}//demos for
				
				
				
			}//gates for
			
		}
		
		/**
		 * Returns the appointments, for this user, that fall within the next hour
		 * each appointment is an object with name (gate name), id and time properties
		 * time is already converted to regular local time - like 7:30pm
		 * 
		 */
		public function get appointments():Array
		{
			return _appointments;
		}
		
		
		
		public function showRecommendedGates(user:Object, gates:Array, kioskLoginName:String):void
		{
			var profile:int = user.profileType;
			
			var rec:Array; //recommendations
			 switch(profile){
				case 1:
					rec = [{"name":"totalKnee", "id":0}, {"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"A Cut Above entry", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Virtual Reality", "id":0}];
					break;
				case 2:
					rec = [{"name":"A Cut Above entry", "id":0}, {"name":"totalKnee", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Virtual Reality", "id":0}];
					break;
				case 3:
					rec = [{"name":"Operation game", "id":0}, {"name":"Predictability game", "id":0},  {"name":"totalKnee", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"A Cut Above entry", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Virtual Reality", "id":0}];
					break;
				case 4:
					rec = [{"name":"A Cut Above entry", "id":0}, {"name":"Virtual Reality", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}];
					break;
			 }
			
			 //have the recommendations for this profile... if there's a totalKnee entry = that needs to change to Demo 2, Demo 4, Demo 5, Demo 6, Demo 7 based on proximity to this kiosk			
			var demoName:String;
			switch(kioskLoginName){
				case "Kiosk1":
					demoName = "Demo 2";
					break;
				case "Kiosk2":
					demoName = "Demo 6";
					break;
				case "Kiosk3":
					demoName = "Demo 2";
					break;
				case "Kiosk4":
					demoName = "Demo 7";
					break;
				case "Kiosk5":
					demoName = "Demo 4";
					break;
				case "Kiosk6":
					demoName = "Demo 5";
					break;
				case "Kiosk7":
					demoName = "Demo 4";
					break;
				case "Kiosk8":
					demoName = "Demo 5";
					break;
			}
			
			if (profile == 1){
				rec[0].name = demoName;
			}else if (profile == 2){
				rec[1].name = demoName;
			}else if (profile == 3){
				rec[2].name = demoName;
			}
			
			//the rec list is now complete with proper gate names - now need to compare to the gate list to get the id's for each recommended gate
			for (var i:int = 0; i < rec.length; i++){
				
				for (var j:int = 0; j < gates.length; j++){
					
					if (gates[j].name == rec[i].name)
					{
						rec[i].id = gates[j].id;
						rec[i].icon = gates[j].icon; //inject icon... for star placement
						rec[i].prettyName = gates[j].prettyName;
						break;
					}
				}
			}
			
			//now have the rec list populated with gate id's - remove any items where the gate id matches an id in the visitedID's array
			var realRecommendations:Array = [];
			for (var k:int = 0; k < rec.length; k++){
				if (visitedIDs.indexOf(rec[k].id) == -1){
					realRecommendations.push(rec[k]);
				}
			}
			
			//make a copy of the full list
			_recommendations = realRecommendations.concat();
			
			//realRecommendations now contains only those gates not visited - may need to further work out TotalKnee...need testing to be sure
			while (realRecommendations.length > 2){
				realRecommendations.pop();
			}
			
			//add the two blue stars at the recommended locs
			for (k = 0; k < realRecommendations.length; k++){
				var star:MovieClip = new iconStar();				
				clip[realRecommendations[k].icon].addChild(star);
				TweenMax.to(star, .5, {colorTransform:{tint:0x185889, tintAmount:1}});
			}			
		}
		
		
		/**
		 * Returns the full list of recommendations for this user - only the first two are displayed on the map
		 * _recommendations is an array of objects with name (gate name), prettyName and id properties
		 * used by Main when creating the recommendations on the left side- the blue bars
		 */
		public function get recommendations():Array
		{
			return _recommendations;
		}
		
		
		/**
		 * Called from Main.gotUserData()
		 * adds mouse listeners to the clickable detail areas - these are the clips
		 * on the coloredBacks layer in the map
		 */
		public function addListeners():void
		{
			clip.kneedeep.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.hipnotic.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.kneet.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.aCutAbove.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.theBalconKnee.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.theJoint.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.experiencePredictability.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.operationMako.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.virtualReality.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.performanceSolutions.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
		}
		
		
		private function detailClick(e:MouseEvent):void
		{
			_detail = MovieClip(e.currentTarget).name;
			dispatchEvent(new Event(DETAIL));
		}
		
		
		/**
		 * returns the clip name of the clicked area
		 * 
		 * Possible values: kneedeep, hipnotic, kneet, aCutAbove, theBalconKnee, theJoint, experiencePredictability, operationMako, virtualReality, performanceSolutions
		 * 
		 * these values match the clip value in the gates array from orchestrate
		 */
		public function get detail():String
		{
			return _detail;
		}
		
		
		
		/**
		 * Removes any icons in the icon holders
		 * @param	gates
		 */
		private function clearIcons(gates:Array):void
		{
			for (var i:int = 0; i < gates.length; i++){
				if(gates[i].hasOwnProperty("icon")){
					var mc:MovieClip = clip[gates[i].icon];
					while (mc.numChildren){
						mc.removeChildAt(0);
					}
				}
			}
		}
		
	}
	
}