package com.tastenkunst.as3.brf.shapemasks {
	import com.greensock.TweenMax;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Marcel Klammer, 2011
	 */
	public class ButtonIcon extends Sprite {
		
		public var _bt : Sprite = new Sprite();
		public var _icon : Sprite = new Sprite();
		
		protected var _active : Boolean = false;
		protected var _over : Boolean = false;
		
		protected var _normalColor : uint;
		protected var _hoverColor : uint;
		protected var _downColor : uint;
		protected var _activeColor : uint;
		protected var _alpha : Number = 1.0;
		
		public function ButtonIcon(
				normalColor : uint = 0xffffff,
				hoverColor : uint = 0xff0000, 
				downColor : uint = 0x0000ff, 
				activeColor : uint = 0x0000ff,
				alpha : Number = 1.0) {
			
			addChild(_icon);
			addChild(_bt);
			
			_icon.graphics.beginFill(0xffffff);
			_icon.graphics.drawRect(-0.5, -5, 1, 10);
			_icon.graphics.drawRect(-5, -0.5, 10, 1);
			_icon.graphics.endFill();
			
			_bt.graphics.beginFill(0xffffff);
			_bt.graphics.drawRect(-5, -5, 10, 10);
			_bt.graphics.endFill();
			_bt.alpha = 0.0;
			
			_normalColor = normalColor;
			_downColor = downColor;
			_hoverColor = hoverColor;
			_activeColor = activeColor;
			_alpha = alpha;
			
			TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _normalColor});
						
			_bt.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_bt.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_bt.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDOWN);
			_bt.addEventListener(MouseEvent.MOUSE_UP, onMouseUP);
			
			_bt.buttonMode = true;
			_bt.mouseChildren = false;
			_bt.useHandCursor = true;
		}

		protected function onMouseUP(event : MouseEvent) : void {
			if(!_active) {
				if(_over) {
					TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _hoverColor});
				} else {
					TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _normalColor});
				}
			}
		}

		protected function onMouseDOWN(event : MouseEvent) : void {
			if(!_active) {
				TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _downColor});
			}
		}

		protected function onMouseOut(event : MouseEvent) : void {
			if(!_active) {
				TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _normalColor});
			}
			_over = false;
		}

		protected function onMouseOver(event : MouseEvent) : void {
			if(!_active) {
				TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _hoverColor});
			}
			_over = true;
		}
				
		public function setActive(bool : Boolean) : void {
			if(bool) {
				TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _activeColor});
			} else {
				if(_over) {
					TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _hoverColor});
				} else {
					TweenMax.to(_icon, 0.2, {alpha: _alpha, tint: _normalColor});
				}
			}
			
			_active = bool;
			mouseEnabled = !_active;
		}
		
		public function isActive() : Boolean {
			return _active;
		}

		public function dispose() : void {
			TweenMax.killTweensOf(_icon);
			_bt.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_bt.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_bt.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDOWN);
			_bt.removeEventListener(MouseEvent.MOUSE_UP, onMouseUP);
		}
	}
}