// Decompiled by AS3 Sorcerer 5.64
// www.as3sorcerer.com

//com.gmrmarketing.katyperry.witness.HeadMask

package com.gmrmarketing.katyperry.witness
{
    import flash.display.Sprite;
    import flare.basic.Scene3D;
    import flare.core.Camera3D;
    import flare.core.Light3D;
    import flare.core.Pivot3D;
    import flare.materials.filters.LightFilter;
    import flash.geom.Rectangle;
    import flare.utils.Matrix3DUtils;
    import brfv4.BRFFace;
    import flash.events.Event;
    import flash.display.BitmapData;

    public class HeadMask extends Sprite 
    {

        private var scene:Scene3D;
        private var camera:Camera3D;
        private var modelZ:int;
        private var renderWidth:int;
        private var renderHeight:int;
        private var light:Light3D;
        private var daveHolder:Pivot3D;
        private var head1:Pivot3D;
        private var head2:Pivot3D;

        public function HeadMask(_arg_1:Rectangle)
        {
            this.scene = new Scene3D(this);
            this.scene.antialias = 2;
            this.scene.allowImportSettings = false;
            this.camera = new Camera3D();
            this.camera.orthographic = true;
            this.modelZ = 2000;
            this.daveHolder = new Pivot3D();
            this.head1 = this.getHolder();
            this.head2 = this.getHolder();
            this.daveHolder.addChild(this.head1);
            this.daveHolder.addChild(this.head2);
            this.scene.addChild(this.daveHolder);
            this.scene.lights.maxDirectionalLights = 1;
            this.scene.lights.maxPointLights = 1;
            this.scene.lights.techniqueName = LightFilter.PER_VERTEX;
            this.scene.lights.defaultLight.color.setTo(0.25, 0.25, 0.25);
            this.light = new Light3D("scene_light", Light3D.POINT);
            this.light.setPosition(150, 150, 0);
            this.light.infinite = true;
            this.light.color.setTo((0xFF / 0xFF), (253 / 0xFF), (244 / 0xFF));
            this.light.multiplier = 1;
            this.scene.addChild(this.light);
            this.loadModels();
            this.updateLayout(_arg_1.width, _arg_1.height);
        }

        public function updateLayout(_arg_1:int, _arg_2:int):void
        {
            this.renderWidth = _arg_1;
            this.renderHeight = _arg_2;
            this.scene.setViewport(0, 0, _arg_1, _arg_2, 2);
            this.camera.projection = Matrix3DUtils.buildOrthoProjection((-(_arg_1) * 0.5), (_arg_1 * 0.5), (-(_arg_2) * 0.5), (_arg_2 * 0.5), 0, 10000);
            this.camera.setPosition(0, 0, 0);
            this.camera.lookAt(0, 0, 1);
            this.camera.near = 10;
            this.camera.far = 5000;
            this.scene.camera = this.camera;
        }

        public function update(_arg_1:int, _arg_2:BRFFace, _arg_3:Boolean):void
        {
            var _local_11:Number;
            var _local_4:Number = (_arg_2.scale * 0.0055555555555556);
            var _local_5:Number = (_arg_2.translationX - (this.renderWidth * 0.5));
            var _local_6:Number = -(_arg_2.translationY - (this.renderHeight * 0.5));
            var _local_7:Number = this.modelZ;
            var _local_8:Number = (-(_arg_2.rotationX) * 57.29578);
            var _local_9:Number = (_arg_2.rotationY * 57.29578);
            var _local_10:Number = (-(_arg_2.rotationZ) * 57.29578);
            if (_local_8 > 0)
            {
                _local_8 = ((_local_8 * 1.35) + 5);
            }
            else
            {
                _local_11 = (Math.abs(_local_9) * 0.025);
                _local_8 = ((_local_8 * (1 - (_local_11 * 1))) + 5);
            };
            this.daveHolder.setPosition(_local_5, _local_6, _local_7);
            this.daveHolder.setScale(_local_4, _local_4, _local_4);
            this.daveHolder.setRotation(_local_8, _local_9, _local_10);
        }

        public function render():void
        {
            this.scene.render();
        }

        public function showHead1():void
        {
            this.head1.show();
            this.head2.hide();
        }

        public function showHead2():void
        {
            this.head2.show();
            this.head1.hide();
        }

        public function loadModels():void
        {
            this.scene.addEventListener(Scene3D.COMPLETE_EVENT, this.headLoaded);
            this.scene.addChildFromFile("assets/maleHead.zf3d", this.head1);
            this.scene.addChildFromFile("assets/female.zf3d", this.head2);
        }

        private function headLoaded(_arg_1:Event):void
        {
            this.head2.hide();
        }

        private function getHolder():Pivot3D
        {
            var _local_1:Pivot3D = new Pivot3D();
            _local_1.setPosition(-5, -15, 115);
            _local_1.setScale(1.5, 1.6, 1.2);
            _local_1.setRotation(-20, 0, 0);
            return (_local_1);
        }

        public function getScreenshot():BitmapData
        {
            var _local_1:BitmapData = new BitmapData(this.scene.viewPort.width, this.scene.viewPort.height, true, 0);
            this.scene.context.clear();
            this.scene.render();
            this.scene.context.drawToBitmapData(_local_1);
            return (_local_1);
        }


    }
}//package com.gmrmarketing.katyperry.witness

