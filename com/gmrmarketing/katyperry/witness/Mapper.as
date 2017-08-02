package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.filesystem.*;
	
	public class Mapper extends MovieClip
	{
		private var drawing:Sprite;
		private var triangles:Vector.<int>;
		private var faceFile:File;
		
	
		public function Mapper()
		{
			uvsText.text = "";
			drawing = new Sprite();
			addChildAt(drawing, 1);//above face
			
			triangles = new Vector.<int>();			
			triangles.push(0,36,1,1,41,2,2,31,3,3,48,4,4,48,5,5,48,6,6,59,7,7,58,8,8,56,9,9,55,10,10,54,11,11,54,12,12,54,13,13,35,14,14,46,15,15,45,16,17,36,0,17,36,18,18,37,19,19,38,20,20,39,21,21,39,27,21,27,22,27,22,42,22,42,23,23,43,24,24,44,25,25,45,26,26,45,16,27,42,28,27,39,28,28,42,29,28,39,29,29,47,35,29,40,31,29,35,30,29,31,30,31,30,32,32,30,33,33,30,34,34,30,35,36,18,37,37,19,38,38,20,39,39,29,40,40,31,41,41,31,2,41,1,36,42,29,47,47,35,46,46,35,14,46,15,45,48,31,49,49,31,50,50,32,51,51,34,52,52,35,53,53,35,54,54,10,55,55,9,56,56,8,57,57,8,58,58,7,59,59,6,48,48,3,31,54,13,35,42,23,43,43,24,44,44,25,45,20,23,21,48,49,60,49,50,61,50,51,62,51,52,62,52,53,63,53,54,64,54,55,64,55,56,65,56,57,66,57,58,66,58,59,67,48,59,60,60,49,61,61,50,62,62,52,63,63,53,64,64,55,65,65,56,66,66,58,67,67,59,60,31,50,32,32,51,33,33,51,34,34,52,35);
			
			for (var i:int = 0; i < 68; i++){
				var m:MovieClip = this["p" + i];
				m.theText.text = i.toString();
				m.addEventListener(MouseEvent.MOUSE_DOWN, beginMove, false, 0, true);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMove, false, 0, true);
			addEventListener(Event.ENTER_FRAME, update);
			
			btnImportFace.addEventListener(MouseEvent.MOUSE_DOWN, openFileDialog, false, 0, true);
			btnExport.addEventListener(MouseEvent.MOUSE_DOWN, exportUVs, false, 0, true);
			
			faceFile = new File();
			
			readUVs();
		}
		
		
		private function beginMove(e:MouseEvent):void
		{
			e.currentTarget.startDrag(false, new Rectangle(224,14,512,512));
		}
		
		
		private function stopMove(e:MouseEvent):void
		{
			stopDrag();
		}
		
		
		private function update(e:Event):void
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < 68; i++){
				var m:MovieClip = this["p" + i];
				v.push(m.x, m.y);
			}
			drawTriangles(v);
		}
		
		
		public function drawTriangles(vertices : Vector.<Number>, clear : Boolean = false, lineThickness : Number = 0.50, lineColor : uint = 0x00a0ff, lineAlpha : Number = 0.85) : void 
		{			
			var g : Graphics = drawing.graphics;
			g.clear();
			
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			g.drawTriangles(vertices, triangles);
			g.lineStyle();
		}
		
		
		private function getNorms():Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < 68; i++){
				var m:MovieClip = this["p" + i];
				
				var nx:Number = (m.x - 224) / 512;
				var ny:Number = (m.y - 14) / 512;
				
				v.push(nx, ny);
			}
			
			return v;
		}
		
		
		private function readUVs():void
		{
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, onLoaded);
			l.load(new URLRequest("assets/femaleFaceUVs.txt"));
		}
		
		
		private function onLoaded(e:Event):void 
		{		
			var uvs:Array = e.target.data.split(",");
			
			var pts:Vector.<Point> = new Vector.<Point>();
			
			var i:int = 0;
			
			var px:Number;
			var py:Number;
			
			while (i < uvs.length){
				px = uvs[i] * 512 + 224;
				i++;
				py = uvs[i] * 512 + 14;
				i++;
				pts.push(new Point(px, py));
			}
			
			
			for (i = 0; i < 68; i++){
				var m:MovieClip = this["p" + i];
				
				m.x = pts[i].x;
				m.y = pts[i].y;
			}
		}
			
		
		private function exportUVs(e:MouseEvent):void
		{
			var v:Vector.<Number> = getNorms();
			var s:String = "";
			
			for (var i:int = 0; i < v.length; i++){
				s += v[i] + ",";
			}
			
			uvsText.text = s;
		}
		
		
		private function openFileDialog(e:MouseEvent):void
		{
			faceFile.browseForOpen("Select Face File");
			faceFile.addEventListener(Event.SELECT, faceSelected);
		}
		
		
		private function faceSelected(e:Event):void
		{
			var loader:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(faceFile.url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, faceLoaded);
			loader.load(urlReq);
		}
		
		private function faceLoaded(e:Event):void
		{
			var bmp:Bitmap = e.target.content as Bitmap;
			//faceTexture = bmp.bitmapData;
		}


	}
	
}