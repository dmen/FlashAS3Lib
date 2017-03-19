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
		public static const DETAIL_REMOVED:String = "detailRemoved";
		private var _detail:String; //clip name of the clicked detail area
		
		private var clip:MovieClip;//instance of mcMap
		private var clipMask:MovieClip;//instance of mcMapMask
		private var clipCircle:Sprite;
		
		private var myContainer:DisplayObjectContainer;
		
		//ids of gates that have been visited - populated in setVisited - used when setting demo reminders so that a reminder
		//isn't set for a demo they've visited
		private var visitedIDs:Array; 
		
		private var _recommendations:Array;
		private var _appointments:Array;
		
		private var lastTint:Number;
		private var detailClip:MovieClip;
		
		private var didTotalKnee:Boolean;		
		
		
		public function Map()
		{
			clip = new mcMap();
			clipMask = new mcMapMask();
			clipCircle = new Sprite();
			
			clip.x = 640;
			clip.y = 50;
			clipMask.x = clip.x + clip.width * .5;
			clipMask.y = clip.y + clip.height * .5;
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
				myContainer.addChild(clipMask);
				myContainer.addChild(clipCircle);
				
				clip.mask = clipMask;
			}
			myContainer.x = 0;
			myContainer.y = 0;
			
			clip.goldGlow.alpha = 0;
			
			clip.time1.text = "";
			clip.time2.text = "";
			clip.time3.text = "";
			clip.time4.text = "";
			clip.time5.text = "";
			clip.time6.text = "";
			clip.time7.text = "";
			
			var pt:Point = new Point();			
			pt.x = clip[kioskLogin.toLowerCase()].x;
			pt.y = clip[kioskLogin.toLowerCase()].y;			
			
			clip.youAreHere.x = pt.x + 8;//kiosk sprites are 16x18 so this gets the pt on center
			clip.youAreHere.y = pt.y + 9;
			clip.youAreHere.scaleX = clip.youAreHere.scaleY = 1.5;
			
			startGoldGlow();
			detailClip = null;
			
			TweenMax.to(clip.youAreHere, 1, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1});
			TweenMax.to(clip.youAreHere, 1, {scaleX:.3, scaleY:.3, delay:2, onComplete:startBounce });
		}
		
		
		private function startBounce():void
		{
			TweenMax.to(clip.youAreHere, .75, {y:"-10", onComplete:endBounce});
		}
		
		
		private function endBounce():void
		{
			TweenMax.to(clip.youAreHere, .75, {y:"10", onComplete:startBounce});
		}
		
		
		private function startGoldGlow():void
		{
			TweenMax.to(clip.goldGlow, 2, {alpha:.6, delay:1, onComplete:endGoldGlow});
		}
		private function endGoldGlow():void
		{
			TweenMax.to(clip.goldGlow, 2, {alpha:0, onComplete:startGoldGlow});
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
				myContainer.removeChild(clipMask);
				myContainer.removeChild(clipCircle);
			}
			TweenMax.killTweensOf(clip.youAreHere);
			TweenMax.killTweensOf(clip.goldGlow);
		}
		
		
		/**
		 * Checks the users history object and marks off areas on the map that they've been to
		 * @param	user
		 * @param	gates This is the gates array from Orchestrate class
		 */
		public function setVisited(user:Object, gates:Array):void
		{
			didTotalKnee = false;
			
			visitedIDs = [];
			
			var hist:Array = user.history;
			
			clearIcons(gates);
			var today:int = new Date().date;
			
			for (var i:int = 0; i < gates.length; i++){
				
				//reset backgrounds to white
				if (gates[i].hasOwnProperty("clip")){						
					TweenMax.to(clip[gates[i].clip], 0, {colorTransform:{tint:0xFFFFFF, tintAmount:1}});
				}
				
				for (var j:int = 0; j < hist.length; j++){						
					
					if (gates[i].id == hist[j].gateId){
						//user has been here - need to see if it's an entry point or a demo area
						//if entry point we turn the clip gray - if demo we put a check in the icon
						
						//discard the history item if it wasn't created 'today' - dateOfScan property
						var scanDay:int = parseInt(hist[j].dateOfScan.substr(8, 2));
						
						if(scanDay == today){
						
							visitedIDs.push(hist[j].gateId);
							
							//set a flag if they went to a total knee demo already
							if (gates[i].name == "Demo 2" || gates[i].name == "Demo 4" || gates[i].name == "Demo 5" || gates[i].name == "Demo 6" || gates[i].name == "Demo 7"){
								didTotalKnee = true;
							}
							
							if (gates[i].hasOwnProperty("clip")){
								//entry point - turn the clip gray
								TweenMax.to(clip[gates[i].clip], 1, {colorTransform:{tint:0xE4E5E3, tintAmount:1}});
							}						
							
							if (gates[i].hasOwnProperty("icon")){
								//demo - turn the clip gray
								clip[gates[i].icon].addChild(new iconCheck());
							}
						
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
					
					if (gates[i].name == demos[j].title && demos[j].guestAssigned == true){
						
						if (visitedIDs.indexOf(gates[i].id) == -1){							
							
							//demo scheduled and not already visited
							//is the demos startTime within the next hour
							var a:String = demos[j].startTime;
							var t:String = a.substr(11);//just the time portion
							var h:int = parseInt(t.substr(0,2));//the hour
							var m:int = parseInt(t.substr(3, 2));//the minute							
							
							//if it's less than 0 then we're past the appointment time
							var diff:int = h - nh;							
							if(diff > 0){
							//if (diff >= 0 && diff < 2){
								showBell = true;										
								visitedIDs.push(gates[i].id);//add this id to visited so it's not recommended...
							}else if (diff == 0){
								//demo in the same hour - make sure now min is not > than demo min
								if (nm <= m){
									showBell = true;										
									visitedIDs.push(gates[i].id);//add this id to visited so it's not recommended...
								}
							}
							/*
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
							*/
							if (showBell){
								
								//convert to 12 hour time
								
								var intTime:Number = h + (m / 60.0);//for time sorting
								
								if (h > 12){
									h -= 12;
								}
								//make sure minute is 2 characters long - ie 6:05pm not 6:5pm
								var mi:String = m.toString();
								if (mi.length < 2){
									mi = "0" + mi;
								}
								
								_appointments.push({"name":gates[i].name, "prettyName":gates[i].prettyName, "id":gates[i].id, "time":h + ":" + mi + "pm", "intTime":intTime});
								
								//set didTotalKnee to true if they have one booked - so it doesn't show in recommended
								if (gates[i].name == "Demo 2" || gates[i].name == "Demo 4" || gates[i].name == "Demo 5" || gates[i].name == "Demo 6" || gates[i].name == "Demo 7"){
									didTotalKnee = true;
								}
								
								clip["time" + gates[i].name.substr(5)].text = h + ":" + mi + "pm";
								
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
			
			//test
			/*
			trace("ORIGINAL");
			for (i = 0; i < _appointments.length; i++ ){
				trace(_appointments[i].prettyName, appointments[i].time, appointments[i].intTime);
			}
			*/
			var sorted:Array = [];			
			
			//sort appointments by time use the intTime property
			while (_appointments.length){
				//trace(_appointments.length);
				var item:Object = _appointments.shift();
				
				if (sorted.length == 0){
					sorted.push(item);
				}else{
					
					var inserted:Boolean = false;
					
					for (i = 0; i < sorted.length; i++){
						if (item.intTime < sorted[i].intTime){
							sorted.splice(i, 0, item);
							inserted = true;
							break;
						}
					}
					
					if (!inserted){
						sorted.push(item);
					}
					
				}				
			}
			
			_appointments = sorted.concat();//copy
			
			//test
			/*
			trace("NEW");
			for (i = 0; i < _appointments.length; i++ ){
				trace(_appointments[i].prettyName, appointments[i].time, appointments[i].intTime);
			}
			*/
		}
		
		/**
		 * Returns the appointments, for this user, that fall within the next hour
		 * each appointment is an object with name (gate name), prettyName, id and time properties
		 * time is already converted to regular local time - like 7:30pm
		 * 
		 */
		public function get appointments():Array
		{
			return _appointments;
		}
		
		
		/**
		 * 
		 * @param	user
		 * @param	gates
		 * @param	kioskLoginName
		 */
		public function showRecommendedGates(user:Object, gates:Array, kioskLoginName:String):void
		{
			var profile:int = user.profileType;
			
			var rec:Array; //recommendations
			if (didTotalKnee){//true if they did one - or they are booked for one
				switch(profile){
					case 1:
						rec = [{"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"A Cut Above entry", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Virtual Reality", "id":0}];
						break;
					case 2:
						rec = [{"name":"A Cut Above entry", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Virtual Reality", "id":0}];
						break;
					case 3:
						rec = [{"name":"Operation game", "id":0}, {"name":"Predictability game", "id":0}, {"name":"Demo 1", "id":0}, {"name":"Demo 3", "id":0}, {"name":"A Cut Above entry", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Virtual Reality", "id":0}];
						break;
					case 4:
						rec = [{"name":"A Cut Above entry", "id":0}, {"name":"Virtual Reality", "id":0}, {"name":"Kneet! entry", "id":0}, {"name":"Operation game", "id":0}, {"name":"Performance solutions", "id":0}, {"name":"Predictability game", "id":0}];
						break;
					}
			}else{
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
			}
			
			 //have the recommendations for this profile... if there's a totalKnee entry = that needs to change to Demo 2, Demo 4, Demo 5, Demo 6, Demo 7 based on proximity to this kiosk			
			var demoName:String;
			
			switch(kioskLoginName){
				case "kiosk1":
					demoName = "Demo 2";
					break;
				case "kiosk2":
					demoName = "Demo 6";
					break;
				case "kiosk3":
					demoName = "Demo 2";
					break;
				case "kiosk4":
					demoName = "Demo 7";
					break;
				case "kiosk5":
					demoName = "Demo 4";
					break;
				case "kiosk6":
					demoName = "Demo 5";
					break;
				case "kiosk7":
					demoName = "Demo 4";
					break;
				case "kiosk8":
					demoName = "Demo 5";
					break;
			}
			
			if(!didTotalKnee){
				if (profile == 1){
					rec[0].name = demoName;
				}else if (profile == 2){
					rec[1].name = demoName;
				}else if (profile == 3){
					rec[2].name = demoName;
				}
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
			
			//realRecommendations now contains only those gates not already visited
			while (realRecommendations.length > 3){
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
			clip.click_kneedeep.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_hipnotic.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_kneet.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_aCutAbove.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_theBalconKnee.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_theJoint.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_experiencePredictability.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_operationMako.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_virtualReality.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
			clip.click_performanceSolutions.addEventListener(MouseEvent.MOUSE_DOWN, detailClick, false, 0, true);
		}
		
		public function removeListeners():void
		{
			clip.click_kneedeep.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_hipnotic.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_kneet.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_aCutAbove.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_theBalconKnee.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_theJoint.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_experiencePredictability.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_operationMako.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_virtualReality.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
			clip.click_performanceSolutions.removeEventListener(MouseEvent.MOUSE_DOWN, detailClick);
		}
		
		
		public function recItemClick(clipName:String):void
		{
			if(!TweenMax.isTweening(clipMask)){
				_detail = clipName;
				detailClick();
			}
		}
		
		private function detailClick(e:MouseEvent = null):void
		{
			
			var m:MovieClip;
			if (e == null){
				//called from recItemClick
				m = MovieClip(clip[_detail]);
			}else{
				m = MovieClip(e.currentTarget);
				_detail = m.name.substr(6);//remove click_ from the front
			}
			
			
			//click another area while still in detail view...
			if(detailClip && detailClip.name !=  MovieClip(clip[_detail]).name){
				TweenMax.to(detailClip, 1, {colorTransform:{tint:lastTint, tintAmount:1}});
			}
			
			TweenMax.killTweensOf(clip.goldGlow);
			clip.goldGlow.alpha = 0;
			
			//tint the bg of the clicked are to slight orange...
			detailClip = MovieClip(clip[_detail]);
			
			if(detailClip.transform.colorTransform.color != 0xf9e7be){
				lastTint = detailClip.transform.colorTransform.color;
				TweenMax.to(clip[_detail], 1, {colorTransform:{tint:0xf9e7be, tintAmount:1}});
			}
			
			clipMask.x = clip.x + (m.x + m.width * .5);//center mask on the clicked area
			clipMask.y = clip.y + (m.y + m.height * .5);
			
			TweenMax.to(clipMask, 1, {scaleX:.35, scaleY:.35, onUpdate:drawCirc});
			
			//need to move the container so that the circled location is centered on screen
			//map is originally at 640,50 in the container - container at 0,0
			//circle should be at 1650,480...so
			//deltaX = 1650 - clipMask.x
			//deltaY = 480 - clipMask.y
			//tween the container by these deltas...
			TweenMax.to(myContainer, 1, {x:1620 - clipMask.x, y:480 - clipMask.y});
			
			dispatchEvent(new Event(DETAIL));
		}
		
		
		public function removeDetail():void
		{
			removeListeners();
			
			if(detailClip){
				TweenMax.to(detailClip, 1, {colorTransform:{tint:lastTint, tintAmount:1}});
			}
			
			clipCircle.graphics.clear();
			TweenMax.to(clipMask, 1, {x:clip.x + clip.width * .5, y:clip.y + clip.height * .5, scaleX:1, scaleY:1});
			TweenMax.to(myContainer, 1, {x:0, y:0, onComplete:resumeListeneing});
		}
		
		
		private function resumeListeneing():void
		{
			dispatchEvent(new Event(DETAIL_REMOVED));
			addListeners();
			startGoldGlow();
		}
		
		
		/**
		 * draws a circle around the mask as it scales down - makes the black outline
		 */
		private function drawCirc():void
		{
			clipCircle.graphics.clear();
			clipCircle.graphics.lineStyle(2, 0x000000, 1);
			clipCircle.graphics.drawCircle(clipMask.x, clipMask.y, clipMask.width * .5);
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