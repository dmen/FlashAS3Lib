
package com.gmrmarketing.utilities
{
	import flash.geom.Point;

	public class InteractionInstance
	{
		
		private var id:int = -1;
		private var path:Vector.<Point>;
		private var pendingPointDirty:Boolean = false;
		private var pendingPoint:Point;

		public function InteractionInstance()
		{
			pendingPoint = new Point();
			path = new Vector.<Point>();
		}

		public function getId():int
		{
			return id;
		}


		public function init($id:int):void
		{
			id = $id;
			path.length = 0;
			pendingPointDirty = false;
		}


		public function setPendingPointToPath(point:Point):void 
		{
			pendingPoint.x = point.x;
			pendingPoint.y = point.y;
			pendingPointDirty = true;
		}


		public function writePendingPointToPath():Boolean 
		{
			if(pendingPointDirty) {
			  pendingPointDirty = false;
			  path.push(pendingPoint.clone());
			  return true;
			}
			return false;
		}


		public function addPointToPath(point:Point):void
		{
			path.push(point);
		}


		public function getInstancePath():Vector.<Point>
		{
			return path;
		}


		public function getPathNextToEndPoint():Point
		{
			if(path.length - 1 > 0) {
				return path[path.length - 2];
			}
			return null;
		}


		public function getPathEndPoint():Point
		{
			if (path.length > 0) {
				return path[path.length - 1];
			}
			return null;
		}
	}
}