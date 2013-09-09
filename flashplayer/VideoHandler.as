﻿package {    import flash.net.NetStream;    import flash.display.Sprite;    import flash.media.Video;    import flash.media.StageVideo;    import flash.events.StageVideoAvailabilityEvent;    import flash.events.Event;    import flash.media.StageVideoAvailability;    import flash.events.StageVideoEvent;    import flash.events.VideoEvent;    import flash.geom.Rectangle;    public class VideoHandler     {        public static const ASPECT_RATIO_4_TO_3:String = "4:3";        public static const ASPECT_RATIO_16_TO_9:String = "16:9";        public static const ASPECT_RATIO_ORIGINAL:String = "original";        private static const ALL_ASPECT_RATIOS:Array = [ASPECT_RATIO_ORIGINAL, ASPECT_RATIO_16_TO_9, ASPECT_RATIO_4_TO_3];        private var _aspectRatio:String;		private var _stream:NetStream;		private var _url:String;		private var _played:Boolean = false;        private var _classicVideoBackground:Sprite;        private var _classicVideo:Video;        private var _stageVideo:StageVideo;        private var _stageVideoInUse:Boolean = false;        private var _classicVideoInUse:Boolean = false;        public function VideoHandler(ns:NetStream, vid:Video, url:String)        {			this._stream = ns;			this._url = url;            this._classicVideo = vid;            this._classicVideo.smoothing = true;            this._aspectRatio = ALL_ASPECT_RATIOS[0];            Main.getStage().addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, this.onStageVideoState);            Main.getStage().addEventListener(Event.RESIZE, this.stageResizeHandler);        }						public function changeCurrentStream(newstream:NetStream):void {			this._stream = newstream;			if (this._stageVideoInUse) {				this._stageVideo.attachNetStream(this._stream);			} else {				this._classicVideo.attachNetStream(this._stream);			}		}				        private function onStageVideoState(e:StageVideoAvailabilityEvent):void        {			Main.log("stage video availability = " + e.availability);            var _stageVideoAvailable:Boolean = (e.availability == StageVideoAvailability.AVAILABLE);            this.toggleStageVideo(_stageVideoAvailable);        }        private function stageResizeHandler(e:Event):void        {            this.resize();        }		        private function toggleStageVideo(b:Boolean):void        {            if (b) { // we activate stagevideo                this._stageVideoInUse = true;                if (this._stageVideo == null) {					Main.log("activating stagevideo");                    this._stageVideo = Main.getStage().stageVideos[0];                    this._stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, this.onStageVideoStateChange);                    Main.log("added RENDER_STATE event handler for StageVideo");					this._stageVideo.attachNetStream(this._stream);                }                if (this._classicVideoInUse) {                    this._classicVideo.clear(); 					Main.getStage().removeChild(this._classicVideo);					this._classicVideoInUse = false;                     this._classicVideo.removeEventListener(VideoEvent.RENDER_STATE, this.onVideoStateChange);                }            } else { // classic video				Main.log("activating classic video");                this._stageVideoInUse = false;                if (this._stageVideo != null) {                    this._stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE, this.onStageVideoStateChange);                    this._stageVideo = null;                }                if (!this._classicVideoInUse) {                    this._classicVideoInUse = true;					Main.getStage().addChildAt(this._classicVideo, 0);                    this._classicVideo.addEventListener(VideoEvent.RENDER_STATE, this.onVideoStateChange);                    this._classicVideo.attachNetStream(this._stream);                }            }			if ( !_played ) { 				this._played = true;				this._stream.play(this._url);				Main.log("videohandler: playing url " + this._url);			}        }        private function onVideoStateChange(e:VideoEvent):void        {			Main.log("classic video: " + e.status);            this.resize();        }        private function onStageVideoStateChange(e:StageVideoEvent):void        {			Main.log("stage video: " + e.status);            if (e.status == flash.media.VideoStatus.UNAVAILABLE) { // we are in stagevideo but it becomes unavailable for some reason				toggleStageVideo(false);			} else {				this.resize();			}        }        private function getVideoRect(w:uint, h:uint):Rectangle        {            var rect:Rectangle = new Rectangle(0, 0, 0, 0);            var minratio:Number = Math.min((Main.getStage().stageWidth / w), (Main.getStage().stageHeight / h));            var vwidth = w * minratio;            var vheight = h * minratio;            var _local7:uint = ((Main.getStage().stageWidth - vwidth) / 2);            var _local8:uint = ((Main.getStage().stageHeight - vheight) / 2);            rect.x = _local7;            rect.y = _local8;            rect.width = vwidth;            rect.height = vheight;			Main.log("rectangle = " + rect);            return rect;        }        public function resize():void        {            var rect:Rectangle;            if (this._stageVideoInUse) {                switch (this._aspectRatio) {                    case ASPECT_RATIO_ORIGINAL:                        rect = this.getVideoRect(this._stageVideo.videoWidth, this._stageVideo.videoHeight);                        break;                    case ASPECT_RATIO_16_TO_9:                        rect = this.getVideoRect(16, 9);                        break;                    case ASPECT_RATIO_4_TO_3:                        rect = this.getVideoRect(4, 3);                        break;                };                this._stageVideo.viewPort = rect;            } else {                switch (this._aspectRatio) {                    case ASPECT_RATIO_ORIGINAL:                        rect = this.getVideoRect(this._classicVideo.videoWidth, this._classicVideo.videoHeight);                        break;                    case ASPECT_RATIO_16_TO_9:                        rect = this.getVideoRect(16, 9);                        break;                    case ASPECT_RATIO_4_TO_3:                        rect = this.getVideoRect(4, 3);                        break;                };                this._classicVideo.width = rect.width;                this._classicVideo.height = rect.height;                this._classicVideo.x = rect.x;                this._classicVideo.y = rect.y;            };        }        public function setAspectRatio(aspectratio:String):void        {            switch (aspectratio) {                case ASPECT_RATIO_4_TO_3:                    return;                case ASPECT_RATIO_16_TO_9:                    return;                case ASPECT_RATIO_ORIGINAL:                    return;            };        }        public function getAspectRatio():String        {            return (this._aspectRatio);        }        public function getNextAspectRatio():String        {            var _local1:uint = (((ALL_ASPECT_RATIOS.indexOf(this._aspectRatio))==(ALL_ASPECT_RATIOS.length - 1)) ? 0 : (ALL_ASPECT_RATIOS.indexOf(this._aspectRatio) + 1));            return (ALL_ASPECT_RATIOS[_local1]);        }        public function switchToNextAspectRatio():String        {            var _local1:uint = (((ALL_ASPECT_RATIOS.indexOf(this._aspectRatio))==(ALL_ASPECT_RATIOS.length - 1)) ? 0 : (ALL_ASPECT_RATIOS.indexOf(this._aspectRatio) + 1));            this._aspectRatio = ALL_ASPECT_RATIOS[_local1];            this.resize();            return (this._aspectRatio);        }        public function getStageVideoInUse():Boolean        {            return (this._stageVideoInUse);        }    }}