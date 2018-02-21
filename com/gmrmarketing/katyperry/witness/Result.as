// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.Result

package com.gmrmarketing.katyperry.witness
{
    import flash.events.EventDispatcher;
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import com.dmennenoh.keyboard.KeyBoard;
    import flash.text.TextFormat;
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.display.Bitmap;
    import com.gmrmarketing.utilities.TimeoutHelper;
    import flash.events.MouseEvent;
    import com.greensock.TweenMax;
    import com.greensock.easing.Expo;
    import com.gmrmarketing.utilities.Validator;
    import flash.events.Event;
    import flash.display.*;
    import flash.events.*;
    import com.greensock.easing.*;

    public class Result extends EventDispatcher 
    {

        public static const COMPLETE:String = "resultComplete";
        public static const RETAKE:String = "retakePhoto";

        private var clip:MovieClip;
        private var myContainer:DisplayObjectContainer;
        private var numpad:KeyBoard;
        private var kbd:KeyBoard;
        private var spacer8Message:TextFormat;
        private var spacer8Email:TextFormat;
        private var photo:BitmapData;
        private var photoScaler:Matrix;
        private var photoHolder:Bitmap;
        private var isEmail:Boolean;
        private var tim:TimeoutHelper;

        public function Result()
        {
            this.clip = new results();
            this.numpad = new KeyBoard();
            this.kbd = new KeyBoard();
            this.numpad.x = 1067;
            this.numpad.y = 340;
            this.kbd.x = 2000;
            this.kbd.y = 460;
            this.spacer8Message = new TextFormat();
            this.spacer8Message.letterSpacing = 0;
            this.spacer8Message.size = 42;
            this.spacer8Email = new TextFormat();
            this.spacer8Email.size = 24;
            this.spacer8Email.letterSpacing = 0;
            this.photo = new BitmapData(654, 654, false, 0);
            this.photoScaler = new Matrix();
            this.photoScaler.scale(0.6055555, 0.6055555);
            this.photoHolder = new Bitmap(this.photo);
            this.tim = TimeoutHelper.getInstance();
            this.numpad.loadKeyFile("numpad.xml");
            this.kbd.loadKeyFile("kbd.xml");
        }

        public function set container(_arg_1:DisplayObjectContainer):void
        {
            this.myContainer = _arg_1;
        }

        public function show(_arg_1:BitmapData):void
        {
            if (!this.myContainer.contains(this.clip))
            {
                this.myContainer.addChild(this.clip);
            };
            if (!this.myContainer.contains(this.photoHolder))
            {
                this.myContainer.addChild(this.photoHolder);
            };
            this.photo.draw(_arg_1, this.photoScaler, null, null, null, true);
            this.isEmail = false;
            if (!this.clip.contains(this.numpad))
            {
                this.clip.addChild(this.numpad);
            };
            if (!this.clip.contains(this.kbd))
            {
                this.clip.addChild(this.kbd);
            };
            this.numpad.x = 1067;
            this.kbd.x = 2000;
            this.photoHolder.x = 127;
            this.photoHolder.y = 210;
            this.clip.authCheck.x = 1067;
            this.clip.authText.x = 1104;
            this.clip.partCheck.x = 1067;
            this.clip.partCheck.y = 857;
            this.clip.partText.x = 1104;
            this.clip.partText.y = 854;
            this.clip.authCheck.gotoAndStop(1);
            this.clip.partCheck.gotoAndStop(2);
            this.clip.emailBG.alpha = 0;
            this.clip.userInput.text = "";
            this.clip.userInput.border = false;
            this.clip.userInput.textColor = 0;
            this.clip.userInput.height = 64;
            this.clip.userInput.x = 1067;
            this.clip.userInput.y = 324;
            this.clip.btnSend.x = 1067;
            this.clip.btnSend.y = 931;
            this.numpad.addEventListener(KeyBoard.KBD, this.numPadPress, false, 0, true);
            this.kbd.addEventListener(KeyBoard.KBD, this.kbdPress, false, 0, true);
            this.clip.getYour.x = 1065;
            this.clip.btnText.x = 1063;
            this.clip.btnEmail.x = 1381;
            this.clip.btnText.gotoAndStop(1);
            this.clip.btnEmail.gotoAndStop(2);
            this.clip.authError.alpha = 0;
            this.clip.emailError.alpha = 0;
            this.clip.btnText.addEventListener(MouseEvent.MOUSE_DOWN, this.switchToText, false, 0, true);
            this.clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, this.switchToEmail, false, 0, true);
            this.clip.authCheck.addEventListener(MouseEvent.MOUSE_DOWN, this.toggleAuthCheck, false, 0, true);
            this.clip.partCheck.addEventListener(MouseEvent.MOUSE_DOWN, this.togglePartCheck, false, 0, true);
            this.clip.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, this.sendPressed, false, 0, true);
            this.clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, this.retakePressed, false, 0, true);
            this.numpad.setFocusFields([[this.clip.userInput, 12]]);
            this.checkEmptyVis();
        }

        public function hide():void
        {
            if (this.myContainer.contains(this.clip))
            {
                this.myContainer.removeChild(this.clip);
            };
            if (this.myContainer.contains(this.photoHolder))
            {
                this.myContainer.removeChild(this.photoHolder);
            };
            if (this.clip.contains(this.kbd))
            {
                this.clip.removeChild(this.kbd);
            };
            if (this.clip.contains(this.numpad))
            {
                this.clip.removeChild(this.numpad);
            };
            this.numpad.removeEventListener(KeyBoard.KBD, this.numPadPress);
            this.kbd.removeEventListener(KeyBoard.KBD, this.kbdPress);
            this.clip.btnText.removeEventListener(MouseEvent.MOUSE_DOWN, this.switchToText);
            this.clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, this.switchToEmail);
            this.clip.authCheck.removeEventListener(MouseEvent.MOUSE_DOWN, this.toggleAuthCheck);
            this.clip.partCheck.removeEventListener(MouseEvent.MOUSE_DOWN, this.togglePartCheck);
            this.clip.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, this.sendPressed);
            this.clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, this.retakePressed);
        }

        public function get data():Object
        {
            var _local_1:Object = new Object();
            _local_1.isEmail = this.isEmail;
            if (!this.isEmail)
            {
                _local_1.num = this.clip.userInput.text.split("-").join("");
            }
            else
            {
                _local_1.num = this.clip.userInput.text;
            };
            _local_1.opt = ((this.clip.authCheck.currentFrame == 2) ? true : false);
            _local_1.part = ((this.clip.partCheck.currentFrame == 2) ? true : false);
            return (_local_1);
        }

        private function switchToText(_arg_1:MouseEvent):void
        {
            if (!this.isEmail)
            {
                return;
            };
            this.tim.buttonClicked();
            this.isEmail = false;
            this.clip.emailError.alpha = 0;
            this.clip.authError.alpha = 0;
            this.clip.btnText.gotoAndStop(1);
            this.clip.btnEmail.gotoAndStop(2);
            this.clip.userInput.background = false;
            this.clip.userInput.text = "";
            this.clip.userInput.setTextFormat(this.spacer8Message);
            this.clip.userInput.border = false;
            this.clip.userInput.textColor = 0;
            this.clip.userInput.height = 64;
            TweenMax.to(this.clip.emailBG, 0.5, {"alpha":0});
            TweenMax.to(this.clip.getYour, 0.5, {
                "x":1065,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnText, 0.5, {
                "x":1063,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnEmail, 0.5, {
                "x":1381,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.userInput, 0.5, {
                "x":1067,
                "y":324,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnSend, 0.5, {
                "x":1067,
                "y":931,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.authCheck, 0.5, {
                "x":1067,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.authText, 0.5, {
                "x":1104,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.partCheck, 0.5, {
                "x":1067,
                "y":857,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.partText, 0.5, {
                "x":1104,
                "y":854,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.numpad, 0.5, {
                "x":1067,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.kbd, 0.5, {
                "x":2000,
                "ease":Expo.easeOut
            });
            this.numpad.setFocusFields([[this.clip.userInput, 12]]);
            this.checkEmptyVis();
        }

        private function switchToEmail(_arg_1:MouseEvent):void
        {
            if (this.isEmail)
            {
                return;
            };
            this.tim.buttonClicked();
            this.isEmail = true;
            this.clip.emailError.alpha = 0;
            this.clip.authError.alpha = 0;
            this.clip.btnText.gotoAndStop(2);
            this.clip.btnEmail.gotoAndStop(1);
            this.clip.userInput.background = false;
            this.clip.userInput.text = "";
            this.clip.userInput.setTextFormat(this.spacer8Email);
            this.clip.userInput.textColor = 11232946;
            this.clip.userInput.border = false;
            this.clip.userInput.height = 50;
            TweenMax.to(this.clip.emailBG, 0.5, {"alpha":1});
            TweenMax.to(this.clip.getYour, 0.5, {
                "x":856,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnText, 0.5, {
                "x":856,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnEmail, 0.5, {
                "x":1174,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.userInput, 0.5, {
                "x":864,
                "y":360,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.btnSend, 0.5, {
                "x":856,
                "y":885,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.authCheck, 0.5, {
                "x":1950,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.authText, 0.5, {
                "x":1950,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.partCheck, 0.5, {
                "x":864,
                "y":781,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.clip.partText, 0.5, {
                "x":901,
                "y":778,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.numpad, 0.5, {
                "x":2000,
                "ease":Expo.easeOut
            });
            TweenMax.to(this.kbd, 0.5, {
                "x":755,
                "ease":Expo.easeOut
            });
            this.kbd.setFocusFields([[this.clip.userInput, 50]]);
            this.checkEmptyVis();
        }

        private function toggleAuthCheck(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            if (this.clip.authCheck.currentFrame == 1)
            {
                this.clip.authCheck.gotoAndStop(2);
            }
            else
            {
                this.clip.authCheck.gotoAndStop(1);
            };
        }

        private function togglePartCheck(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            if (this.clip.partCheck.currentFrame == 1)
            {
                this.clip.partCheck.gotoAndStop(2);
            }
            else
            {
                this.clip.partCheck.gotoAndStop(1);
            };
        }

        private function sendPressed(_arg_1:MouseEvent):void
        {
            var _local_2:Boolean;
            this.tim.buttonClicked();
            this.clip.btnSend.fill.alpha = 1;
            TweenMax.to(this.clip.btnSend.fill, 0.3, {"alpha":0});
            if (this.isEmail)
            {
                _local_2 = Validator.isValidEmail(this.clip.userInput.text);
                if (!_local_2)
                {
                    TweenMax.killTweensOf(this.clip.emailBG.outline);
                    TweenMax.to(this.clip.emailBG.outline, 0, {"colorTransform":{
                            "tint":0xFF0000,
                            "tintAmount":1
                        }});
                    TweenMax.to(this.clip.emailBG.outline, 1, {
                        "colorTransform":{
                            "tint":null,
                            "tintAmount":0
                        },
                        "delay":3
                    });
                    TweenMax.killTweensOf(this.clip.emailError);
                    this.clip.emailError.text = "Please enter a valid email address";
                    this.clip.emailError.alpha = 1;
                    this.clip.emailError.x = 860;
                    this.clip.emailError.y = 420;
                    TweenMax.to(this.clip.emailError, 1, {
                        "alpha":0,
                        "delay":3
                    });
                };
            }
            else
            {
                _local_2 = Validator.isValidPhoneNumber(this.clip.userInput.text);
                if (!_local_2)
                {
                    TweenMax.killTweensOf(this.clip.emailError);
                    this.clip.emailError.text = "Please enter a valid phone number";
                    this.clip.emailError.alpha = 1;
                    this.clip.emailError.x = 1067;
                    this.clip.emailError.y = 372;
                    TweenMax.to(this.clip.emailError, 1, {
                        "alpha":0,
                        "delay":3
                    });
                };
                if (this.clip.authCheck.currentFrame != 2)
                {
                    TweenMax.killTweensOf(this.clip.authCheck.outline);
                    TweenMax.to(this.clip.authCheck.outline, 0, {"colorTransform":{
                            "tint":0xFF0000,
                            "tintAmount":1
                        }});
                    TweenMax.to(this.clip.authCheck.outline, 1, {
                        "colorTransform":{
                            "tint":null,
                            "tintAmount":0
                        },
                        "delay":3
                    });
                    _local_2 = false;
                    TweenMax.killTweensOf(this.clip.authError);
                    this.clip.authError.alpha = 1;
                    TweenMax.to(this.clip.authError, 1, {
                        "alpha":0,
                        "delay":3
                    });
                };
            };
            if (_local_2)
            {
                TweenMax.delayedCall(0.3, this.sendComplete);
            };
        }

        private function sendComplete():void
        {
            dispatchEvent(new Event(COMPLETE));
        }

        private function retakePressed(_arg_1:MouseEvent):void
        {
            this.tim.buttonClicked();
            dispatchEvent(new Event(RETAKE));
        }

        private function numPadPress(_arg_1:Event):void
        {
            this.tim.buttonClicked();
            this.checkEmptyVis();
            this.checkPhoneFormat();
            this.clip.userInput.setTextFormat(this.spacer8Message);
        }

        private function kbdPress(_arg_1:Event):void
        {
            this.tim.buttonClicked();
            this.checkEmptyVis();
            this.clip.userInput.setTextFormat(this.spacer8Email);
        }

        private function checkEmptyVis():void
        {
            if (this.clip.userInput.text.length == 0)
            {
                if (this.isEmail)
                {
                    this.clip.userInputEmpty.x = 864;
                    this.clip.userInputEmpty.y = 360;
                    this.clip.userInputEmpty.border = false;
                    this.clip.userInputEmpty.text = "ENTER YOUR EMAIL ADDRESS";
                    this.clip.userInputEmpty.textColor = 11232946;
                    this.clip.userInputEmpty.setTextFormat(this.spacer8Email);
                }
                else
                {
                    this.clip.userInputEmpty.x = 1067;
                    this.clip.userInputEmpty.y = 324;
                    this.clip.userInputEmpty.text = "000-000-0000";
                    this.clip.userInputEmpty.height = 64;
                    this.clip.userInputEmpty.border = false;
                    this.clip.userInputEmpty.textColor = 0;
                    this.clip.userInputEmpty.setTextFormat(this.spacer8Message);
                };
                this.clip.userInputEmpty.visible = true;
                this.clip.userInput.visible = false;
            }
            else
            {
                this.clip.userInputEmpty.visible = false;
                this.clip.userInput.visible = true;
            };
        }

        private function checkPhoneFormat():void
        {
            var _local_1:String = this.clip.userInput.text;
            if (_local_1.length > 3)
            {
                if (_local_1.indexOf("-") == -1)
                {
                    _local_1 = ((_local_1.substr(0, 3) + "-") + _local_1.substr(3));
                };
            };
            if (_local_1.length > 7)
            {
                if (_local_1.indexOf("-", 5) == -1)
                {
                    _local_1 = ((_local_1.substr(0, 7) + "-") + _local_1.substr(7));
                };
            };
            this.clip.userInput.text = _local_1;
            this.clip.userInput.setSelection(this.clip.userInput.text.length, this.clip.userInput.text.length);
        }


    }
}//package com.gmrmarketing.katyperry.witness

