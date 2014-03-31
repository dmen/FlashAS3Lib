package com.gmrmarketing.hp.spinner
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import org.cove.ape.*;
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class APESpinner extends Sprite
	{		
		private var circLoc:Point = new Point(500, 400);
		private var circRadius:int = 312;
		
		private var world:Group;
		
		
		public function APESpinner()
		{
			world = new Group(true);
			
			APEngine.init(1/3);
			APEngine.container = this;
			
			circLoc = new Point(500, 400);
			
			APEngine.addGroup(world);
			
			var wh:Group = spinner();
			world.addCollidable(wh);
			APEngine.addGroup(wh);
			
			var fing:Group = finger(200, 200, 100);
			world.addCollidable(fing);
			APEngine.addGroup(fing);
			
			addEventListener(Event.ENTER_FRAME, gameLoop, false, 0, true);
		}
	
		
		
		public function finger( x:Number, y:Number, w:Number):Group
		{
			var hand = new Group();
			hand.collideInternal = true;
			
			var t:int = 8;
			
			var _p1:CircleParticle = new CircleParticle( x, y, t );
			_p1.mass = .001;
			_p1.setStyle( 0, 0, 0, 0xFF0000 );
			
			var _p2:CircleParticle = new CircleParticle( x + w, y, t, true );
			_p2.setStyle( 0, 0, 0, 0x00FF00 );
			
			//particle, particle, stiffness, collidable, rectHeight
			var _platform:SpringConstraint = new SpringConstraint( _p1, _p2, 1, true, t);
			_platform.setStyle( 0, 0, 0, 0xFF0000 );
			
			
			var _hinge:CircleParticle = new CircleParticle( x + w, y - 20, 4, true );
			_hinge.setStyle( 0, 0, 0, 0xE4E4E4, 1 );
			_hinge.collidable = false;
			
			var _spring:SpringConstraint = new SpringConstraint( _p2, _hinge, .02 );
			_spring.restLength = 20;
			_spring.setLine( 1, 0xE4E4E4 );
			
			hand.addParticle( _p1 );
			hand.addParticle( _p2 );
			hand.addConstraint( _platform );
			hand.addParticle( _hinge );
			hand.addConstraint( _spring );
			
			return hand;
		}
		
		
		private function spinner():Group
		{
			var wheel:Group = new Group();
			wheel.collideInternal = false;
			
			var bigWheel:WheelParticle = new WheelParticle(circLoc.x, circLoc.y, circRadius);
			
			wheel.addParticle(bigWheel);
			
			//angle per peg in radians
			var anglePerPeg:Number = (2 * Math.PI) / 6;
			for (var i:int = 0; i < 6; i++) {
				var curAng:Number = i * anglePerPeg;
				var pegLoc:Point = new Point(Math.cos(curAng) * circRadius + circLoc.x, Math.sin(curAng) * circRadius + circLoc.y);
				
				//x,y,radius.fixed,mass,elasticity,friction
				var peg:CircleParticle = new CircleParticle(pegLoc.x, pegLoc.y, 5, false, 1, 0, 0);
				wheel.addParticle(peg);
				
				//particle, particle, stiffness, collidable, rectHeight
				var connector:SpringConstraint = new SpringConstraint( bigWheel, peg, 1, false);
				wheel.addConstraint(connector);
			}
			
			bigWheel.angularVelocity = 1;
			return wheel;
		}
	
		
		
		private function gameLoop(e:Event):void
		{
			APEngine.step();
			APEngine.paint();
		}
	}
	
}