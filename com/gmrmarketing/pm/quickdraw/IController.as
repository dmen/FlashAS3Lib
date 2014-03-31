package com.gmrmarketing.pm.quickdraw
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	public interface IController extends IEventDispatcher
	{		
		function getPosition():Point;
		function getTilt():Number;
		function get trigger():String;
		function getIR():*;
		function set containerToListenOn(c:DisplayObjectContainer):void;
	}
	
}