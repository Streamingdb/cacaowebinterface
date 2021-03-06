package org.fas.effects
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.filters.GlowFilter;
    
    import org.fas.utils.FuMath;

    public class LightRay extends Sprite
    {
    	public static var TYPE_LINE:String = 'line';
    	public static var TYPE_COMET:String = 'comet';
    	public var rayType:String = '';//line comet
        /**
         *loop sum loop unlimited when equal -1
         */            
        private var loop:int = 1;
        /**
         *ray weith
         */            
        public var rayWidth:Number;
        /**
         *ray heigth
         */            
        public var rayLength:Number;
        /**
         *ray color
         */            
        private var er_rayColor:uint;
        /**
         *ray alpha
         */            
        private var er_rayAlpha:Number;
        /**
         *ray GlowFiltr
         */            
        private var er_glowFilter:GlowFilter;
        /**
         *ray BlurFilter
         */            
        private var er_blurFilter:BlurFilter;
       
        private var trackArray:Array;
        private var pointArr:Array = new Array();
        private var nowOrder:int = 0;
        public function LightRay(_type:String = '',_width:Number=10,_length:Number=16,_color:uint=0xFFFFFF,_alpha:Number=0.6,_glowFilter:GlowFilter=null,_blurFilter:BlurFilter=null){
            super();
            this.rayType = Boolean(_type)?_type:TYPE_LINE;
            this.rayWidth = _width;
            this.rayLength = _length;
            this.rayColor = _color;
            this.rayAlpha = _alpha;
            this.glowFilter = _glowFilter!=null?_glowFilter:new GlowFilter(this.rayColor,this.rayAlpha,20,20);
    		this.blurFilter  = _blurFilter!=null?_blurFilter:new BlurFilter(8,8);
        }
		
        public function get rayAlpha():Number
        {
        	return er_rayAlpha;
        	if(this.glowFilter!=null){
        		this.glowFilter.color = this.rayColor;
        		this.updateFilter();
        	}
        }

        public function set rayAlpha(v:Number):void
        {
        	er_rayAlpha = v;
        }

        public function get rayColor():uint
        {
        	return er_rayColor;
        }

        public function set rayColor(v:uint):void
        {
        	er_rayColor = v;
        	if(this.glowFilter!=null){
        		this.glowFilter.color = this.rayColor;
        		this.updateFilter();
        	}
        }

        public function get blurFilter():BlurFilter
        {
        	return er_blurFilter;
        }

        public function set blurFilter(v:BlurFilter):void
        {
        	er_blurFilter = v;
        	this.updateFilter();
        }

		public function get glowFilter():GlowFilter
        {
        	return er_glowFilter;
        }
        public function set glowFilter(v:GlowFilter):void
        {
        	er_glowFilter = v;
        	this.updateFilter();
        }
        /**
         * build by a no rotation point array to draw ray
         * every point in array is a Object has x,y attribute
         * and rotation will be count by x,y
         * @param _arr   a no rotation point array to draw ray
         * @param _loop  loop sum  default:1  loop unlimited when equal -1
         * 
         */                  
        public function buildByNoRoArray(_arr:Array,_loop:int = 1):void{
                if(_arr.length<=1){//ray array is too short can't draw
                	return ;
                }
                for(var i:int = 0;i<_arr.length-1;i++){
                	_arr[i].ro = FuMath.angle(_arr[i+1].x-_arr[i].x,_arr[i+1].y-_arr[i].y);
                }
                _arr[_arr.length-1].ro = _arr[_arr.length-2].ro;
                this.buildByRoArray(_arr,_loop);
        }
        /**
         * 
         * @param _arr    a no rotation point array to draw ray
         * @param _loop   loop sum  default:1  loop unlimited when equal -1
         * 
         */        
        public function buildByRoArray(_arr:Array,_loop:int = 1):void{
                this.loop = _loop;
                this.trackArray = _arr;
                pointArr=[];
                this.clear();
                this.addEventListener(Event.ENTER_FRAME,evtFrame);
        }
        public function updateXY(_x:Number,_y:Number):void{
                var _ro:Number;
                if(pointArr.length==0){
                	_ro = 0;
                }else{
                	pointArr[pointArr.length-1].ro = 90+FuMath.angle(_x-pointArr[pointArr.length-1].x,_y-pointArr[pointArr.length-1].y);
                }
                pointArr.push({x:_x,y:_y,ro:0});
                if (pointArr.length>rayLength) {
                	pointArr.shift();
                }
                run();
        }
        private function updateFilter():void{
			var _arr:Array = new Array();
        	if(this.glowFilter!=null){
        		_arr.push(this.glowFilter);
        	}
        	if(this.blurFilter!=null){
        		_arr.push(this.blurFilter);
        	}
        	this.filters = _arr;
        }
        private function evtFrame(_e:Event):void{
                //put Position in
                if(nowOrder<this.trackArray.length){
                	pointArr.push({x:this.trackArray[nowOrder].x, y:this.trackArray[nowOrder].y, ro:this.trackArray[nowOrder].ro+90});
                	nowOrder++;
                }else{
                    pointArr.shift();
                }
                if (pointArr.length>rayLength) {
                    pointArr.shift();
            	}
                if(pointArr.length==0){
                    this.clear();
                    return;
                }else{
                    run();
                }
        }
        private function run():void {
            this.graphics.clear();
            var pointArr1:Array = new Array();
            var pointArr2:Array = new Array();
            var i:int = 0;
            var _width:Number;
            for (i=0; i<pointArr.length; i++) {
				_width = rayWidth*FuMath.sin(90*i/pointArr.length);
				switch(this.rayType){
					case TYPE_COMET:
						_width = rayWidth*FuMath.sin(90*i/pointArr.length);
						break;
					default:
						_width = rayWidth*FuMath.sin(180*i/pointArr.length);
						break;
				}
                var _point:Object = pointArr[i];
                var x1:Number = _point.x+FuMath.cos(_point.ro)*_width/2;
                var y1:Number = _point.y+FuMath.sin(_point.ro)*_width/2;
                var x2:Number = _point.x-FuMath.cos(_point.ro)*_width/2;
                var y2:Number = _point.y-FuMath.sin(_point.ro)*_width/2;
                pointArr1.push({x:x1, y:y1});
                pointArr2.push({x:x2, y:y2});
            }
            var _ro:Number = pointArr1.length;
            var _c:uint = rayColor;
            //dray rim line
            this.graphics.beginFill(_c,rayAlpha);
//			this.graphics.lineStyle(1,0xFFFFFF);
            this.graphics.moveTo(pointArr1[0].x,pointArr1[0].y);
            for (i = 1; i<_ro-1; i++) {
                 this.graphics.lineTo(pointArr1[i].x,pointArr1[i].y);
            }
            for (i = _ro-1; i>0; i--) {
                this.graphics.lineTo(pointArr2[i].x,pointArr2[i].y);
            }
            this.graphics.lineTo(pointArr1[0].x,pointArr1[0].y);
            this.graphics.endFill();
            this.graphics.beginFill(_c,rayAlpha);
            if(this.rayType == TYPE_COMET){
            	this.graphics.lineStyle(1,0xFFFFFF,0);
           	 	this.graphics.drawCircle(pointArr[pointArr.length-1].x,pointArr[pointArr.length-1].y,_width/2);
           	 	this.graphics.endFill();
            }
        }
        /**
         * stop draw and clear ray
         *
         */            
        public function clear():void {
            this.nowOrder = 0;
            this.loop -= 1;
            pointArr=[];
            if(this.loop==0){
                trackArray = [];
                this.graphics.clear();
                this.removeEventListener(Event.ENTER_FRAME,evtFrame);
            }
        }
    }
}