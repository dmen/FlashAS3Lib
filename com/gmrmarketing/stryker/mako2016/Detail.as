package com.gmrmarketing.stryker.mako2016
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Detail extends EventDispatcher
	{
		public static const CLOSE_DETAIL:String = "backButtonPressed";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var _reminders:Array;
		private var clickClip:String;
		
		
		public function Detail()
		{
			clip = new mcGateDetail();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		/**
		 * 
		 * @param	whichClip String one of: aCutAbove, kneet,  hipnotic, kneedeep, theBalconKnee, theJoint, experiencePredictability, operationMako, virtualReality, performanceSolutions
		 * @param	user
		 * @param	recommendations Array - array of objects from Map.recommendations - contains name (gate name) prettyName, id properties
		 * @param	appointments Array - array of objects from Map.appointments - contains name (gate name) prettyName, id, time proeprties
		 */
		public function show(whichClip:String, user:Object, recommendations:Array, appointments:Array):void
		{
			clickClip = whichClip;
			
			//uses the index of the gate name to figure out the frame number in the detail clip
			var clips:Array = ["aCutAbove", "kneet",  "hipnotic", "kneedeep", "theBalconKnee", "theJoint", "experiencePredictability", "operationMako", "virtualReality", "performanceSolutions"];
			var i:int;
			
			
			//CHECK FOR RECOMMENDED STATION
			clip.recItem.visible = false;
			
			//limit checking to the first two recommended stations
			var num:int = Math.min(2, recommendations.length);
			
			if (whichClip == "aCutAbove"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "A Cut Above entry"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "kneet"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Kneet! entry"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "hipnotic"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Demo 3"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "kneedeep"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Demo 1" || recommendations[i].name == "Demo 2"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "theBalconKnee"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Demo 4" || recommendations[i].name == "Demo 5"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "theJoint"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Demo 6" || recommendations[i].name == "Demo 7"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "experiencePredictability"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Predictability game"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "operationMako"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Operation game"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "virtualReality"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Virtual Reality"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			if (whichClip == "performanceSolutions"){
				for (i = 0; i < num; i++){
					if (recommendations[i].name == "Performance solutions"){
						clip.recItem.visible = true;
						break;
					}
				}
			}
			//END CHECK RECOMMENDED
			
			
			//CHECK FOR APPOINTMENTS - can only have appointments for Demos
			_reminders = appointments;			
			
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.gotoAndStop(clips.indexOf(whichClip) + 1);
			clip.detail.gotoAndStop(user.profileType);//1 - 4
			clip.detail.x = 0;//hide under the yellow bar
			
			clip.fname.text = user.firstName;
			
			//btnBack is the Back to Full Map View button
			clip.btnBack.x = 1920;
			clip.btnBack.alpha = 0;
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			
			clip.x = -clip.width;
			TweenMax.to(clip, .5, {x:0});
			TweenMax.to(clip.detail, .5, {x:666, delay:.5, onStart:showReminders});
			TweenMax.to(clip.btnBack, .5, {x:1564, alpha:1, delay:1, ease:Back.easeOut});
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip.btnBack, .5, {x:2500, alpha:0});
			TweenMax.to(clip.detail, .3, {x:0});
			TweenMax.to(clip, .3, {x:-666, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
		/**
		 * Check for demo reminders once the detail clip is showing - and on the proper frame
		 */
		private function showReminders():void
		{
			var i:int;
			if (clickClip == "hipnotic"){
				
				clip.detail.reminder3.alpha = 0;
				
				for (i = 0; i < _reminders.length; i++){
					if (_reminders[i].name == "Demo 3"){						
						clip.detail.reminder3.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder3, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder3.circ, .5, {colorTransform:{tint:0x4c7d7a, tintAmount:1}});//green
						break;
					}
				}
			}
			if (clickClip == "kneedeep"){
				
				clip.detail.reminder1.alpha = 0;
				clip.detail.reminder2.alpha = 0;
				
				for (i = 0; i < _reminders.length; i++){
					if (_reminders[i].name == "Demo 1"){
						
						clip.detail.reminder1.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder1, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder1.circ, .5, {colorTransform:{tint:0x86468b, tintAmount:1}});//purple
						break;
					}else if(_reminders[i].name == "Demo 2"){
						
						clip.detail.reminder2.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder2, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder2.circ, .5, {colorTransform:{tint:0xffb500, tintAmount:1}});//yellow
						break;
					}
				}
			}
			if (clickClip == "theBalconKnee"){
				
				clip.detail.reminder4.alpha = 0;
				clip.detail.reminder5.alpha = 0;
				
				for (i = 0; i < _reminders.length; i++){
					if (_reminders[i].name == "Demo 4"){
						
						clip.detail.reminder4.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder4, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder4.circ, .5, {colorTransform:{tint:0xffb500, tintAmount:1}});//yellow
						break;
					}else if(_reminders[i].name == "Demo 5"){
						
						clip.detail.reminder5.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder5, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder5.circ, .5, {colorTransform:{tint:0xffb500, tintAmount:1}});//yellow
						break;
					}
				}
			}			
			
			if (clickClip == "theJoint"){
				
				clip.detail.reminder6.alha = 0;
				clip.detail.reminder7.alpha = 0;
				
				for (i = 0; i < _reminders.length; i++){
					if (_reminders[i].name == "Demo 6"){
						
						clip.detail.reminder6.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder6, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder6.circ, .5, {colorTransform:{tint:0xffb500, tintAmount:1}});//yellow
						break;
					}else if(_reminders[i].name == "Demo 7"){
						
						clip.detail.reminder7.theText.text = "You're registered for " + _reminders[i].time;
						TweenMax.to(clip.detail.reminder7, 1, {alpha:1, delay:.5});
						TweenMax.to(clip.detail.reminder7.circ, .5, {colorTransform:{tint:0xffb500, tintAmount:1}});//yellow
						break;
					}
				}
			}
		}
		
		
		private function backPressed(e:MouseEvent):void
		{
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			dispatchEvent(new Event(CLOSE_DETAIL));//caught by Main.showFullMap()
		}
	}
	
}