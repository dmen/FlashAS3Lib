package ascensionsystems.mirror
{
	
import flash.geom.Matrix;
import flash.display.*;
	
	public class reflect extends MovieClip
	{
		var fnxFlipMatrix:Matrix;
		var fnxMatrix:Matrix;
		var colors:Array;
		var alphas:Array;
		var ratios:Array;
		var fnxBMD:BitmapData;
		var fnxBitmap:Bitmap;
		var fnxBMHolder:MovieClip;
		var fnxMasker:MovieClip;
		public var fnxWorkingItem:MovieClip;
		var fnxMovieClip:MovieClip;
		var fnxOriginalWidth:Number;
		var fnxOriginalHeight:Number;
				
		public function constructReflection(fnxWorkingItem:MovieClip, fnxReflectionAlpha:Number, fnxReflectionStart:Number, fnxReflectionEnd:Number, fnxOffset:Number)
		{
			
			fnxOriginalWidth = new Number(fnxWorkingItem.width);
			fnxOriginalHeight = new Number(fnxWorkingItem.height);
			
			fnxMovieClip = new MovieClip();
			fnxMovieClip = fnxWorkingItem as MovieClip;
			
			fnxMatrix = new Matrix();
			
			//fnxMatrix.createGradientBox(fnxOriginalWidth, fnxOriginalHeight, 1.55, 0, 0);

			fnxBMD = new BitmapData(fnxMovieClip.width, fnxMovieClip.height);
			fnxBitmap = new Bitmap(fnxBMD);
			fnxBMD.draw(fnxMovieClip);
			fnxBMHolder = new MovieClip();
			fnxBMHolder.addChild(fnxBitmap);
			fnxBMHolder.cacheAsBitmap = true;
			//fnxBMHolder.rotationX = 180;
			
			fnxFlipMatrix = new Matrix();
			fnxFlipMatrix = fnxBMHolder.transform.matrix;
			fnxFlipMatrix.d=-1;
			fnxFlipMatrix.ty=fnxBMHolder.height+fnxBMHolder.y;
			fnxBMHolder.transform.matrix=fnxFlipMatrix;			
			
			fnxBMHolder.y = ((fnxMovieClip.height + fnxBMHolder.height) + fnxOffset);
			fnxMovieClip.addChild(fnxBMHolder);
			
			colors = new Array();
			alphas = new Array();
			ratios = new Array();
			colors.push(0xFFFFFF, 0xFFFFFF);
			alphas.push(100, 0);
			ratios.push(fnxReflectionStart, fnxReflectionEnd);
			
			//fnxMasker = new MovieClip();
			//fnxMasker.cacheAsBitmap = true;
			//fnxMasker.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, fnxMatrix);
			//fnxMasker.graphics.drawRect(0, 0, fnxOriginalWidth, fnxOriginalHeight);
			//fnxMasker.y = (fnxOriginalHeight) + fnxOffset;
			//fnxMovieClip.addChild(fnxMasker);
			//fnxBMHolder.mask = fnxMasker;
			fnxBMHolder.alpha = fnxReflectionAlpha;			
		}
		
		public function refresh()
		{
			fnxBMD.fillRect(fnxBMD.rect,0xFF000000)
			fnxBMD.draw(fnxMovieClip);
		}
		
	}//End Public Class Tag
	
}//End Package Tag


