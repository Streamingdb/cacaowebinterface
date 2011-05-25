package {    
	import flash.display.Sprite;
    import flash.events.*;
    import flash.net.*;
	import flash.utils.*;
	
    public class SubtitlesLoader extends Sprite {
		var loaders:Dictionary = new Dictionary(); // dictionnaire loader => language
		var subtitles:Dictionary = new Dictionary(); // dictionnaire language => sous-titres
		public var timeoffset:Number = 0;
		
        public function SubtitlesLoader() {
			
        }
		public function loadSubtitle(url:String, language:String, offset:Number):Boolean {
			var loader:URLLoader = new URLLoader();
			loaders[loader] = new Array(language, offset);
            configureListeners(loader);
			var req:URLRequest = new URLRequest(url);
            try {
                loader.load(req);
				return true;
            } catch (error:Error) {
                trace("Unable to load requested document.");
				return false;
            }
			return false;
		}
		public function getCurrent(language:String, time:Number):String {
			if (subtitles[language] != null) {
				var subs:Array = subtitles[language];
				var curtime = time + timeoffset;
				// on peut diminuer drastiquement la consommation processeur en mettant en cache 
				// le sous-titre actuel et l'enregistrement suivant
				function fitsintime(item:*, index:int, array:Array):Boolean {
					return item != null && item[1][0] < curtime && item[1][1] > curtime;
				};
				var goodsubs:Array = subs.filter(fitsintime);
				//trace("getting subtitles at time " +  time + ". subsfound=" + goodsubs.length);
				if (goodsubs.length > 0) {
					return goodsubs[0][2];
				} else {
					return "";
				}
			} else {
				return "";
			}
		}
		public function isLanguageSubtitleActive(language:String):Boolean {
			return (subtitles[language] != null);
		}
		
		
		private function parseSubtitlesData(rawdata:String, offset:Number):Array {
			var re:RegExp = /[\r|\n]{2,}(?=\d+[\r|\n])/;
			var subarray:Array = rawdata.split(re);
			function extractinfo(item:*, index:int, array:Array):Array {
				var a:Array = item.split(/[\r|\n]+/);
				if (a.length >= 3) {
					var id:Number = a[0];
					var timespanrefs:Array = timespanrefs = a[1].split(/[-]{1,2}>/);
					if (timespanrefs.length == 2) {
						var pos1 = timespanrefs[0].indexOf(",");
						var pos2 = timespanrefs[1].indexOf(",");
						if (pos1 > -1 && pos2 > -1) {
							var time1:String = timespanrefs[0].substr(0, pos1);
							var milli1:Number = timespanrefs[0].substr(pos1+1) / 1000;
							var time2:String = timespanrefs[1].substr(0, pos2);
							var milli2:Number = timespanrefs[1].substr(pos2+1) / 1000;
							var atime1:Array = time1.split(":");
							var atime2:Array = time2.split(":");
							if (atime1.length >= 3 && atime2.length >= 3) {
								//trace(id);
								//trace(atime1);
							//trace(milli1);
								var t1:Number = atime1[0] * 3600 + atime1[1] * 60 + atime1[2] * 1 + milli1 - offset;
								var t2:Number = atime2[0] * 3600 + atime2[1] * 60 + atime2[2] * 1 + milli2 - offset;
								var subtitle = (a.slice(2)).join("\n");
								
								//trace(t1 + " --> " + t2);
								return new Array(id, new Array(t1, t2), subtitle);
							} else {
								return null;
							}
						} else {
							//trace("error proceeding " + a[1] + " with id " + a[0]);
							return null;
						}
					} else {
						//trace("error proceeding " + a[1] + " with id " + a[0]);
						return null;
					}
				} else {
					//trace("error proceeding " + item);
					return null;
				}
			};
			var arr:Array = subarray.map(extractinfo);
			//arr.forEach(function (item:*, index:int, array:Array):void { if (item != null) { trace(item[0]) } });
			//var arr = subarray.map(function (elt:String):Array { return elt.split("\r\n"); });
			//trace(arr.length);
			return arr;
		}
		private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }
        private function completeHandler(event:Event):void {
			trace("subtitles download completed");
            var loader:URLLoader = URLLoader(event.target);
			var paramsloader:Array = loaders[loader];
			var language:String = paramsloader[0];
			var offset:Number = paramsloader[1];
			delete loaders[loader];
			subtitles[language] = parseSubtitlesData(loader.data, offset);
			trace("subtitles length = " + subtitles[language].length);
        }
        private function openHandler(event:Event):void {
            trace("openHandler: " + event);
        }
        private function progressHandler(event:ProgressEvent):void {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }
        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }
        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }
    }
}
