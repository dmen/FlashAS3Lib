/**
 * NoncontiguousCartogram
 * 
 * by Zachary Forest Johnson
 * indiemaps.com/blog
 * 
 * do what you will BSD license included
 * 
 */
package com.indiemaps.mapping.cartograms.noncontiguous
{
	import com.gskinner.motion.GTween;
	import com.indiemaps.mapping.utils.Geometry;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	/**
	 * NoncontiguousCartogram is a type of area cartogram that sacrifices topology and compactness for perfect shape preservation.
	 * 
	 */
	public class NoncontiguousCartogram extends Sprite
	{
	
		public var tweenDuration:Number = 1;
		public var featureGraphics:Dictionary = new Dictionary();
		public var featureStrokes:Dictionary = new Dictionary();
		public var featureFills:Dictionary = new Dictionary();
		public var featureDescriptors:Dictionary = new Dictionary();
		
		
		protected var fillColor:uint = 0;
		protected var strokeColor:uint = 0;
		protected var strokeWeight:int = 0;
		
		protected var maxWidth:Number;
		protected var maxHeight:Number;
		protected var xAdjustment:Number = 0;
		protected var yAdjustment:Number = 0;
		protected var _k:Number;
		protected var zoom:Number = 1;
		protected var _anchorPercentile:Number;
		
		protected var dataProvider:Array;
		protected var densities:Array;
		
		protected var _valueField:String;
		
		protected var featuresContainer:Sprite = new Sprite();
		
		protected var _featureCenters:Dictionary;
		
		protected var tweenOnUpdates:Boolean = false;
		
		/**
		 * 
		 * @param dataProvider An Array of objects with at least 'geometry' and 'attributes' properties.
		 * @param maxWidth The original unscaled linework will be drawn using this as the maximum width.  The resultant cartogram may be wider or narrower.
		 * @param maxHeight The original unscaled linework will be drawn using this as the maximum height.  The resultant cartogram may be taller or shorter.
		 * @param valueField The property of the 'attributes' property of the objects on which the cartogram scaling should be based.
		 * @param anchorPercentile A value between zero and one which specifies where in the distribution the anchor unit should be chosen.  A number close to zero means a unit with relatively low density will be chosen.
		 * @param appearanceObject If the properties 'fillColor', 'strokeColor', or 'strokeWeight' are found on this object, they'll be used to style the cartogram.
		 * @param tweenOnUpdates A Boolean variable specifying whether to tween when the valueField or anchorPercentile are updated.
		 * @param featureCentersDictionary A Dictionary that uses the objects in dataProvider as keys and contains Points to use as feature centers instead of their centroids.
		 * 
		 */
		public function NoncontiguousCartogram(dataProvider:Array, maxWidth:Number, maxHeight:Number, valueField:String=null, anchorPercentile:Number=1, appearanceObject:Object=null, tweenOnUpdates:Boolean=false, featureCentersDictionary:Dictionary=null)
		{
			this.maxHeight = maxHeight;
			this.maxWidth = maxWidth;
			this.dataProvider = dataProvider;
			this._valueField = valueField;
			this.tweenOnUpdates = tweenOnUpdates;
			this._featureCenters = featureCentersDictionary;
			this._anchorPercentile = anchorPercentile;
			
			if (appearanceObject != null) {
				for each (var att:String in ['fillColor', 'strokeColor', 'strokeWeight']) {
					if (appearanceObject.hasOwnProperty(att)) {
						this[att] = appearanceObject[att];
					}
				}
			}	
			figureZoom();
			createFeatures();
			if (valueField != null) {
				densities = getDensities();
				_k = 1/Math.sqrt( densities[ Math.round(_anchorPercentile * (densities.length-1)) ] );
				scaleFeatures();
			}
			addChild(featuresContainer);
		}
		
		protected function getDensities():Array {
			var ds:Array = [];
			
			for each(var featureObject:Object in dataProvider) {
				ds.push(featureObject.attributes[_valueField]/featureDescriptors[featureObject].area);
			}
			ds.sort(Array.NUMERIC);
			
			return ds;
		}
		
		protected function figureZoom():void {
			var maxX:Number = -Infinity;
			var maxY:Number = -Infinity;
			var minX:Number = Infinity;
			var minY:Number = Infinity;
			
			for each (var featureObject:Object in dataProvider) {
				for each (var ring:Array in featureObject.geometry) {
					for each (var pt:Object in ring) {
						if (pt.x > maxX)
							maxX = pt.x;
						if (pt.x < minX)
							minX = pt.x;
						if (-pt.y > maxY)
							maxY = -pt.y;
						if (-pt.y < minY)
							minY = -pt.y;
					}
				}
			}
			var width:Number = maxX - minX;
			var height:Number = maxY - minY;
			zoom = Math.min(maxWidth/width, maxHeight/height);
			yAdjustment = -minY * zoom;
			xAdjustment = -minX * zoom;
		}
		
		protected function createFeatures():void {
			for each (var featureObject:Object in dataProvider) {
				createFeature(featureObject);
			}
		}
		
		protected function createFeature(featureObject:Object):void {	
			//descriptors		
			featureDescriptors[featureObject] = getFeatureDescriptors(featureObject);
			
			//graphical portrayal
			featureGraphics[featureObject] = getFeatureGraphic(featureObject);
			
			//position it a bit
			positionFeature(featureObject);
			
			//add it to the display
			featuresContainer.addChild(featureGraphics[featureObject]);
		}
		
		protected function positionFeature(featureObject:Object, isAnUpdate:Boolean=false):void {
			var newX:Number;
			var newY:Number;
			if (_featureCenters == null) {
				newX = featureDescriptors[featureObject].center.x*zoom + xAdjustment;
				newY = -featureDescriptors[featureObject].center.y*zoom + yAdjustment;
			} else {
				newX = _featureCenters[featureObject].x;
				newY = _featureCenters[featureObject].y;
			}
			if (tweenOnUpdates && isAnUpdate) {
				new GTween(featureGraphics[featureObject], tweenDuration, { x : newX, y : newY });
			} else {
				featureGraphics[featureObject].x = newX;
				featureGraphics[featureObject].y = newY;
			}
		}
		
		protected function getFeatureGraphic(featureObject:Object):Sprite {
			var feature:Sprite = new Sprite();
			var featureFill:Sprite = new Sprite();
			var featureStroke:Sprite = new Sprite();
			
			if (strokeWeight != -1)
				featureStroke.graphics.lineStyle(strokeWeight, strokeColor);
			for each (var ring:Array in featureObject.geometry) {
				featureFill.graphics.beginFill(fillColor);
				
				featureFill.graphics.moveTo( (ring[0].x - featureDescriptors[featureObject].center.x) * zoom, -(ring[0].y - featureDescriptors[featureObject].center.y) * zoom);
				featureStroke.graphics.moveTo( (ring[0].x - featureDescriptors[featureObject].center.x) * zoom, -(ring[0].y - featureDescriptors[featureObject].center.y) * zoom);
				
				for each (var pt:Object in ring) {
					featureFill.graphics.lineTo( (pt.x - featureDescriptors[featureObject].center.x) * zoom, -(pt.y - featureDescriptors[featureObject].center.y) * zoom);
					featureStroke.graphics.lineTo( (pt.x - featureDescriptors[featureObject].center.x) * zoom, -(pt.y - featureDescriptors[featureObject].center.y) * zoom);
				}
				featureFill.graphics.endFill();
			}
			feature.addChild(featureFill);
			feature.addChild(featureStroke);
			featureFills[featureObject] = featureFill;
			featureStrokes[featureObject] = featureStroke;
			
			return feature;
		}

		protected function getFeatureDescriptors(feature:Object):Object {
			var descriptors:Object = new Object();
			var area:Number = 0;
			var mainCenter:Point = new Point();
			var maxRing:Array;
			var maxArea:Number = -Infinity;
			
			for each (var ring:Array in feature.geometry) {
				var thisArea:Number = Geometry.areaOfPolygon(ring);
				if (thisArea > maxArea)
					maxArea=thisArea, maxRing=ring;
				area += thisArea;
			}
			descriptors.area = area;
			descriptors.center = Geometry.centerOfPolygonArea(maxRing, maxArea);
			
			return descriptors;
		}
		
		protected function scaleFeatures(isAnUpdate:Boolean=false):void {
			for each (var featureObject:Object in dataProvider) {
				var newScale:Number = (_valueField==null) ? (1) : Math.sqrt( featureObject.attributes[_valueField] / featureDescriptors[featureObject].area ) * _k;
				if (!tweenOnUpdates || !isAnUpdate) {
					(featureGraphics[featureObject] as Sprite).scaleX = (featureGraphics[featureObject] as Sprite).scaleY = isNaN(newScale) ? 0 : newScale;
				} else {
					new GTween((featureGraphics[featureObject] as Sprite), tweenDuration, { scaleX : newScale, scaleY : newScale });
				}
				
			}
		}
		
		public function set anchorPercentile(value:Number):void {
			_anchorPercentile = value;
			_k = 1/Math.sqrt( densities[ Math.round(_anchorPercentile * (densities.length-1)) ] );
			scaleFeatures(true);
		}
		
		public function get anchorPercentile():Number {
			return _anchorPercentile;
		}
		
		
		public function changeProperty(newProperty:String, newAnchorPercentile:Number=NaN, newFeatureCentersDictionary:Dictionary=null):void {
			this._valueField = newProperty;
			this._featureCenters = newFeatureCentersDictionary;
			
			if (!isNaN(newAnchorPercentile)) {
				_anchorPercentile = newAnchorPercentile;
			}
			densities = getDensities();
			_k = 1/Math.sqrt( densities[ Math.round(_anchorPercentile * (densities.length-1)) ] );
			scaleFeatures(true);
			positionFeatures(true);
		}
		
		/**
		 * Overlays or underlays a multipolygon (array of array of points) on the cartogram Sprite.  Assumes they are in the same coordinate system.
		 * 
		 */
		public function addMultiPolygonOverlay(multiPolygon:Array, position:int=1, prepGraphicsFunction:Function=null):void {
			var overlay:Sprite = new Sprite();
			
			if (prepGraphicsFunction == null) {
				overlay.graphics.lineStyle(1, 0, 1, false, "none");
			} else {
				prepGraphicsFunction(overlay.graphics);
			}
			for each (var polygon:Array in multiPolygon) {
				for each (var ring:Array in polygon) {
					overlay.graphics.moveTo( ring[0].x * zoom, -ring[0].y * zoom );
					for (var i:int=1; i<ring.length; i++) {
						//trace('holla', ring[i].x);
						overlay.graphics.lineTo( ring[i].x * zoom, -ring[i].y * zoom);
					}
				}
			}
			overlay.x = xAdjustment;
			overlay.y = yAdjustment;
			featuresContainer.addChildAt(overlay, position);
		}
		
		protected function positionFeatures(isAnUpdate:Boolean=false):void {
			for each (var featureObject:Object in dataProvider) {
				positionFeature(featureObject, isAnUpdate);
			}
		}
		
		public function set featureCenters(value:Dictionary):void {
			_featureCenters = value;
			
			positionFeatures(true);
		}
	}
}