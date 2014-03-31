package away3d.textures {
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.TextureUtils;

	import flash.display.BitmapData;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	public class BRFVideoTexture extends BitmapTexture {
		
		private var _videoData : BitmapData;
		private var _materialSize : uint;
		private var _matrix : Matrix;
		private var _smoothing : Boolean;

		public function BRFVideoTexture(videoData : BitmapData, materialSize : uint = 512, smoothing : Boolean = true) {
			_materialSize = validateMaterialSize(materialSize);

			super(new BitmapData(_materialSize, _materialSize, false, 0));

			// Use default camera if none supplied
			_videoData = videoData;

			_matrix = new Matrix();
			_matrix.scale(_materialSize / videoData.width, _materialSize / videoData.height);
			_smoothing = smoothing;
		}

		/**
		 * Toggles smoothing on the texture as it's drawn (and potentially scaled)
		 * from the video stream to a BitmapData object.
		 */
		public function get smoothing() : Boolean {
			return _smoothing;
		}

		public function set smoothing(value : Boolean) : void {
			_smoothing = value;
		}

		/**
		 * Draws the video and updates the bitmap texture
		 * If autoUpdate is false and this function is not called the bitmap texture will not update!
		 */
		public function update() : void {
			bitmapData.lock();
			bitmapData.fillRect(bitmapData.rect, 0);
			bitmapData.draw(_videoData, _matrix, null, null, bitmapData.rect, _smoothing);
			bitmapData.unlock();
			invalidateContent();
		}

		/**
		 * Clean up used resources.
		 */
		override public function dispose() : void {
			super.dispose();
			bitmapData.dispose();
			_matrix = null;
		}

		override protected function uploadContent(texture : TextureBase) : void {
			super.uploadContent(texture);
			update();
		}

		private function validateMaterialSize(size : uint) : int {
			if (!TextureUtils.isDimensionValid(size)) {
				var oldSize : uint = size;
				size = TextureUtils.getBestPowerOf2(size);
				trace("Warning: " + oldSize + " is not a valid material size. Updating to the closest supported resolution: " + size);
			}

			return size;
		}
	}
}
