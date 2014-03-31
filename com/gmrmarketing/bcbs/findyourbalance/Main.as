package com.gmrmarketing.bcbs.findyourbalance
{
	import com.gmrmarketing.esurance.sxsw_2014.SocketServer;
	import flash.display.*;
	import flash.events.*;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.constraint.PivotJoint;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import nape.callbacks.*;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var debug:Debug; 
		private var server:SocketServer;
		private var gravity:Vec2;
		private var space:Space;
		private var floorCollisionType:CbType;
		private var shapeCollisionType:CbType;
		private var floorBody:Body;
		private var interactionListener:InteractionListener;
		private var fulcrumBody:Body;
		private var fulcrumShape:Polygon;
		private var teeterBody:Body;
		private var teeterShape:Polygon;		
		private var pj:PivotJoint;
		
		public function Main()
		{
			server = new SocketServer()
			server.addEventListener(SocketServer.CONNECT, clientConnect, false, 0, true);
			server.addEventListener(SocketServer.MESSAGE, clientMessage, false, 0, true);
			server.addEventListener(SocketServer.DISCONNECT, clientDisconnect, false, 0, true);
			
			gravity = new Vec2(0, 500); // units are pixels/second/second
			space = new Space(gravity);
			
			floorCollisionType = new CbType();
			shapeCollisionType = new CbType();
			
			//floor is a static object does not rotate, so we don't need to
			//care that the origin of the Body (0, 0) is not in the
			//center of the Body's shapes.
			floorBody = new Body(BodyType.STATIC);
			floorBody.shapes.add(new Polygon(Polygon.rect(50, 350, 450, 1)));
			floorBody.cbTypes.add(floorCollisionType);
			
			interactionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, floorCollisionType, shapeCollisionType, shapeHitFloor);
			space.listeners.add(interactionListener);
			
			fulcrumBody = new Body(BodyType.STATIC);
			fulcrumShape = new Polygon(Polygon.regular(20, 20, 3));
			fulcrumBody.shapes.add(fulcrumShape);
			fulcrumBody.align();
			fulcrumBody.position.setxy(290, 340);
			fulcrumBody.rotation = -Math.PI / 2;
			
			teeterBody = new Body(BodyType.DYNAMIC);
			teeterShape = new Polygon(Polygon.box(200, 10));//width, height
			teeterShape.material.density = 1;
			teeterBody.shapes.add(teeterShape); //add shape to body
			teeterBody.position.setxy(290, 280);//316
						
			pj = new PivotJoint(space.world, teeterBody,  new Vec2(), teeterBody.localCOM);
			pj.stiff = true;
			pj.space = space;
			pj.anchor1.setxy(290, 314);
			
			space.bodies.add(floorBody);//add body to space
			space.bodies.add(fulcrumBody);//add body to space
			space.bodies.add(teeterBody);//add body to space
			
			debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color);
			addChild(debug.display);
			debug.drawConstraints = true;
			
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function showTestingUI():void
		{			
			var b:MovieClip = new btn();
			var c:MovieClip = new btn();
			var d:MovieClip = new btn();
			addChild(b);
			addChild(c);
			addChild(d);
			c.x += 100;
			d.x += 200;
			b.addEventListener(MouseEvent.CLICK, applyNegAngVel);
			c.addEventListener(MouseEvent.CLICK, applyAngVel);
			d.addEventListener(MouseEvent.CLICK, addShape);
		}
		
		
		private function applyNegAngVel(e:MouseEvent):void
		{	
			teeterBody.angularVel += -1;
		}

		
		private function applyAngVel(e:MouseEvent):void
		{	
			teeterBody.angularVel += 1;
		}
		
		
		private function shapeHitFloor(collision:InteractionCallback):void 
		{
			var shape:Body = collision.int2 as Body;
			shape.space = null;
		}
		
		private function addShape(e:MouseEvent = null):void
		{
			var body:Body = new Body(BodyType.DYNAMIC);
			
			var polygon:Polygon = new Polygon(Polygon.box(20, 20));
			polygon.material.elasticity = 1;
			polygon.material.density = .5 + (Math.random() * .5);
			polygon.material.staticFriction = .08;
			polygon.material.dynamicFriction = .05;
			body.shapes.add(polygon);
			body.cbTypes.add(shapeCollisionType);
			body.position.setxy(250, 250);
			space.bodies.add(body);//add body to space
					/*
			var ballBody:Body = new Body(BodyType.DYNAMIC);
			var ballShape:Circle = new Circle(10);
			ballShape.material.density = 1.5;
			ballBody.shapes.add(ballShape);
			ballBody.position.setxy(250,250);
			space.bodies.add(ballBody);//add body to space*/
		}

		private function clientConnect(e:Event):void
		{
			//trace("client connect");
			addShape();
		}


		private function clientMessage(e:Event):void
		{
			//-90 to 90
			var angVel:Number = parseFloat(server.getMessage()) * -1;	
			teeterBody.angularVel += angVel / 30;
		}


		private function clientDisconnect(e:Event):void
		{
			//trace("client disconnected");
		}


		private function update(e:Event):void {
			// Step forward in simulation by the required number of seconds.
			space.step(1 / stage.frameRate);	
			debug.clear();
			debug.draw(space);
			debug.flush();
		}
		
	}
 
}