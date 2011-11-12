﻿package {	import flash.events.*;	import flash.external.*;	import flash.utils.*;	public class JavascriptCallbacks	{		private var _maininstance;		public function JavascriptCallbacks(maininstance)		{			// constructor code			this.init();			this._maininstance = maininstance;		}				public function playurl(url):void {			_maininstance.urlofvideo = url;			this._maininstance.startplaying();		}				private function setupCallbacks():void		{			// Register the SWF client functions with the container 			ExternalInterface.addCallback("showMessage", _maininstance.errorMessage);			ExternalInterface.addCallback("play", playurl);  									ExternalInterface.addCallback("seek", _maininstance.ns.seek);			ExternalInterface.addCallback("playbackStatus", _maininstance.playbackStatus); // TODO			ExternalInterface.addCallback("position", _maininstance.ns.time);			ExternalInterface.addCallback("duration", _maininstance.playbackDuration);						// Notify the container that the SWF is ready to be called. 			ExternalInterface.call("Cacaoweb.setSWFIsReady");		}		public function init()		{			// Check if the container is able to use the external API. 			if (ExternalInterface.available)			{				// set up a Timer to call the 				// container at 100ms intervals. Once the container responds that 				// it's ready, the timer will be stopped. 				var readyTimer:Timer = new Timer(100);				readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);				readyTimer.start();			}			else			{				trace("External interface is not available for this container.");			}		}		private function timerHandler(event:TimerEvent):void		{			// calls the isReady javascript method of the container to 			// see if the container has finished loading and is ready			var isReady:Boolean = ExternalInterface.call("Cacaoweb.isReady");			if (isReady)			{				// If the container has become ready, we don't need to check anymore, 				// so stop the timer. 				Timer(event.target).stop();				// Set up the ActionScript methods that will be available to be ;				// called by the container. 				setupCallbacks();			}		}	}}