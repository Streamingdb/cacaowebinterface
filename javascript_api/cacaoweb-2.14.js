var Cacaoweb = {	  
	/**
	 * javascript parameters
	 */
	version: "2.14",
	timerTasksInterval: 0.5,
	lasttimeclientrunning: 0,
	lasttimestatuscheck: 0,
	isclientrunningHysteresisInterval: 30000,
	timeoutClientAlive: 2000,
	timeStart: (new Date()).getTime(),
	status: 'Unknown',
	myFuncs: [],
	missingpluginimageurl: 'http://www.cacaoweb.org/images/plugin.png', 
	
	/**
	 * player default parameters
	 */
	videowidth: 640,
	videoheight: 360,
	autoplay: true,
	playerurl: "http://127.0.0.1:4001/player.swf",
	
	/**
	 * private variables
	 */
	_swfready: false,
	
	
	/**
	 * Lance le téléchargement de cacaoweb en fonction de la plateforme de l'utilisateur
	 */
	download: function() {
		var platform = "Windows";
		
		if ( navigator.platform != null ) {
			if ( navigator.platform.indexOf( "Win32" ) != -1 ) {
				platform = "Windows";
			} else if ( navigator.platform.indexOf( "Win64" ) != -1 ) {
				platform = "Windows";
			} else if ( navigator.platform.indexOf( "Win" ) != -1 ) {
				platform = "Windows";
			} else if ( navigator.platform.indexOf( "Linux x86_64" ) != -1 ) {
				platform = "Linux64";
			} else if ( navigator.platform.indexOf( "Linux" ) != -1 ) {
				platform = "Linux32";
			} else if ( navigator.platform.indexOf( "Mac" ) != -1 && navigator.platform.indexOf( "Intel" ) != -1 ) {
				platform = "Mac OSX Intel";
			} else if ( navigator.platform.indexOf( "Mac" ) != -1 && navigator.platform.indexOf( "PPC" ) != -1 ) {
				platform = "Mac OSX PPC";
			} else if ( navigator.platform.indexOf( "Mac" ) != -1 ) {
				platform = "Mac OSX" ;
			} else
				platform = navigator.platform;
		}
		
		var uri;
		
		if (platform == "Windows"){
			uri = "http://cacaoweb.org/download/cacaoweb.exe";
		} else if (platform == "Mac OSX" || platform == "Mac OSX Intel") {
			uri = "http://cacaoweb.org/download/cacaoweb.dmg";
		} else if (platform == "Linux64") {
			uri = "http://cacaoweb.org/download/cacaoweb.linux64";
		} else if (platform == "Linux32") {
			uri = "http://cacaoweb.org/download/cacaoweb.linux";
		} else {
			alert("cacaoweb is not available for your platform");
		}
		
		setTimeout(function() { window.open(uri, '_newtab') },  0 ); // timeout could be 500 in case of direct download to make the user at ease
	},
	
	/**
	 * Inclut le script 'filename' en utilisant l'id 'scriptname'
	 * Supprime les précédents scripts insérés avec la même id 'scriptname'
	 * 
	 * @param	filename		Nom du fichier JS à inclure
	 * @param	scriptname		Id du script inclus
	 */
	includeScript: function(filename, scriptname){
		var htmlDoc = document.getElementsByTagName('body').item(0);
		var scriptblock = document.getElementById(scriptname); 
		if (scriptblock) {
			htmlDoc.removeChild(scriptblock);
		}
		var script = document.createElement("script");
		
		script.id = scriptname;
		script.src = filename;
		script.language = 'javascript';
		script.type = 'text/javascript';
		htmlDoc.appendChild(script);
	},
	
	/**
	 * Permet de spécifier une fonction qui sera appelée régulièrement ou lorsque le status de cacaoweb change (On, Off ou Unknown)
	 * La fonction doit prendre un argument (qui sera le statut de cacaoweb)
	 */
	subscribeStatusChange: function(myFunc) {
		this.myFuncs.push(myFunc);
	},
	unsubscribeStatusChange: function(myFunc) {
		for (var i = 0; i < this.myFuncs.length; i++) {
			if (this.myFuncs[i] == myFunc) {
				this.myFuncs.splice(i, 1);
				return;
			}
		}
	},
	
	/**
	 * Met à jour l'état de cacaoweb.
	 * On		si cacaoweb tourne sur la machine
	 * Off		si cacaoweb ne tourne pas sur la machine
	 * Unknown	si le statut n'a pas encore été initialisé ou s'il n'a plus été mis à jour depuis un certain délai
	 */
	updateStatusVariable: function() {
		if ((new Date()).getTime() - this.lasttimeclientrunning < this.timeoutClientAlive + this.isclientrunningHysteresisInterval) {
			this.status = 'On';
		} else if ((new Date()).getTime() - this.timeStart < 2000) {
			this.status = 'Unknown';
		} else {
			this.status = 'Off';
		}
	},
	
	/**
	 * Toutes les actions à effectuer à chaque fois qu'il peut y avoir un changement dans l'état
	 */
	updateActions: function() {
		this.updateStatusVariable();
		for (var i = 0; i < this.myFuncs.length; i++) {
			this.myFuncs[i](this.status);
		}
	},
	
	/**
	 * Vérifie et met à jour à jour l'état de cacaoweb
	 */
	checkStatus: function() {
		if ((new Date()).getTime() - this.lasttimeclientrunning > this.isclientrunningHysteresisInterval && 
			(new Date()).getTime() - this.lasttimestatuscheck > this.timeoutClientAlive) {
			var i = Math.floor(Math.random() * 1000000);
			this.lasttimestatuscheck = (new Date()).getTime();
			this.includeScript('http://127.0.0.1:4001/isrunning?unique=' + i, 'isrunningscript');
			this.updateActions();
		}
	},

	/**
	 * Fonction appelée en callback de checkInstalled (par le client cacaoweb s'il est en route)
	 */
	callbackIsRunning: function() {
		Cacaoweb.lasttimeclientrunning = (new Date()).getTime();
		this.updateActions();
	},
	
	insertDownloadPlugin: function(id) {
		var cacaodiv = document.getElementById(id); 
		cacaodiv.innerHTML = '<a href="javascript:Cacaoweb.download()"><img src="' + this.missingpluginimageurl + '" /></a>';
	},
	
	/**
	 * this can be called by the flash player object through ExternalInterface
	 * to check whether cacaoweb javascript API has been loaded in the document
	 */
	isReady: function() {
		return true;
	},
	
	/** 
	 * this is called by the flash player object to tell Javascript that it has finished
	 * the registration of its callbacks, at this point they are defined
	 * HOWEVER this obviously doesn't work well if we have multiple players on the page
	 */
	setSWFIsReady: function() {
		this._swfReady = true;
	}

}

setInterval(function() { Cacaoweb.checkStatus(); }, Cacaoweb.timerTasksInterval * 1000);
Cacaoweb.checkStatus(); 


/**
 * here we define a global function object cacaoplayer to access player instances
 */
if (typeof cacaoplayer == "undefined") { // to prevent the API from being included more than once

	var cacaoplayer = function(id) {
		if (cacaoplayer.getPlayer){ // TODO: remove it?
			return cacaoplayer.getPlayer(id);
		}
	};


	(function(cacaoplayer) { // to create a new nested scope

		// the list of registered player objects
		var _players = [];
		
		function getFlashPlayer(movieName) {
			if (movieName) {
				if (navigator.appName.indexOf("Microsoft") != -1) { 
					return window[movieName]; 
				} else { 
					return document[movieName]; 
				}
			}
		}
		
		// used as the constructor to build our player objects
		cacaoplayer.builder = function(container) {
			this.container = container;
			this.id = container.id;
			this.link = container.getAttribute("cacaolink");
			
			/* the default parameters - they can be changed later with a call to the .setup() function */
			this.playerurl = Cacaoweb.playerurl;
			this.width = Cacaoweb.videowidth;
			this.height = Cacaoweb.videoheight;
			this.missingpluginimageurl = Cacaoweb.missingpluginimageurl;
			
			this.subtitlesoptions = {};
			this.flashobjectadded = false; // tells if we have added the flash object or not yet
			

			this.insertFlash = function() {
				var player = '<object id="' + this.id + 'flash" width="' + this.width + '" height="' + this.height + '">';
				player += '<param name="allowFullScreen" value="true" />';
				player += '<param name="flashvars" value="file=' + this.link + '" />';
				player += '<param name="movie" value="' + this.playerurl + '" />';
				player += '<param name="AllowScriptAccess" value="always">';
				player += '<param name="wmode" value="direct">';
				player += '<embed src="' + this.playerurl + '" ';
				player += 'flashvars="file=' + this.link + '" ';
				player += 'width="' + this.width + '" height="' + this.height + '" allowFullScreen="true" name="' + this.id + 'flash" AllowScriptAccess="always" wmode="direct" />';
				player += '</object>';
				this.container.innerHTML = player;
				this.flashobjectadded = true;
				if (this.subtitlesoptions != {}) {
					this.subtitles(this.subtitlesoptions);
				}
			}

						
			/**
			 * find the player object and play the link
			 */
			this.realplay = function (link) {
				if (typeof link != "undefined") {
					this.link = link;
				}
				var flashplayer = getFlashPlayer(this.id + "flash");
				if (flashplayer) {
					flashplayer.play(this.link);
				} else { // first create the flash object
					this.insertFlash.call(this);
				}
				return this;
			}

			/**
			 * play a link
			 * also checks if cacaoweb is running on the host computer
			 * if cacaoweb is running, it calls realplay to show the player, if not then it show the missing plugin image
			 */
			this.play = function (link) {
				if (Cacaoweb.status == 'On') {
					return this.realplay(link);
				} else {
					var timeout = setTimeout("Cacaoweb.insertDownloadPlugin('" + this.id + "')", Cacaoweb.timeoutClientAlive);
					var that = this;
					var f = function (status) { if (status == "On") {
												clearTimeout(timeout);
												Cacaoweb.unsubscribeStatusChange(f);
												that.realplay(link);
											}
										};
					Cacaoweb.subscribeStatusChange(f);
				}
			}

			/**
			 * show a message on the player screen
			 */
			this.showmessage = function (msg) {
				getFlashPlayer(this.id + "flash").showMessage(msg);
				return this;
			}
			
			/**
			 * seeks in the video
			 * parameter newtime has to be given in seconds
			 * current limitation: must be to some area that is already downloaded (will be improved later)
			 */
			this.seek = function (newtime) {
				getFlashPlayer(this.id + "flash").seek(newtime);
				return this;
			}
			
			/**
			 * return the current position of the playback in seconds
			 */
			this.position = function () {
				return getFlashPlayer(this.id + "flash").position();
			}
			
			/**
			 * return the duration of the video in seconds
			 */
			this.duration = function () {
				return getFlashPlayer(this.id + "flash").duration();
			}
			
			/**
			 * return the status of the player as a string
			 * 4 possible values:
			 * - Buffering
			 * - Pausing
			 * - Playing
			 * - Stopped
			 */
			this.playbackStatus = function () {
				return getFlashPlayer(this.id + "flash").playbackStatus();
			}
			
			/**
			 * mute the player
			 */
			this.mute = function () {
				// TODO
				return this;
			}
			
			this.pause = function() {
				// TODO
				return this;
			}
			
			this.subtitles = function(subsoptions) {
				if (this.flashobjectadded) { // the flash object player has been added to the DOM
					var flashplayer = getFlashPlayer(this.id + "flash");
					if (flashplayer && flashplayer.subtitles) {
						return flashplayer.subtitles(subsoptions.subtitlesurl, subsoptions.subtitleslanguage, subsoptions.subtitlesoffset);
					} else { 
						// the flash player object has not been added to the DOM yet
						// or the functions attached to the flash player object have not been registered yet 
						// (it takes time for the browser to do these things)
						var that = this;
						setTimeout(function() { that.subtitles(subsoptions) }, 1000);
					}
				} else { // in this case, it means we haven't called play() yet, thus we are doing player setup
					this.subtitlesoptions = subsoptions;
				}
			}

			/**
			 * set up the player instance options
			 */
			this.setup = function (setupoptions) {
				for (var option in setupoptions) {
					switch (option) {
						case "width":
							this.width = setupoptions[option];
							break;
						case "height":
							this.height = setupoptions[option];
							break;
						case "missingpluginimageurl":
							this.missingpluginimageurl = setupoptions[option];
							break;
						case "playerurl":
							this.playerurl = setupoptions[option];
							break;
						default:
							break;
					}
				}
				return this;
			}

			this.test = function () {
				alert("test");
			}

		};



		/** 
		 * functions to manipulate the list of registered player objects
		 */


		function getRegisteredPlayerById(id) {
			for (var i = 0; i < _players.length; i++) {
				if (_players[i].id == id) {
					return _players[i];
				}
			}
		};
	
		function registerPlayer(player) {
			// first check if the player is already registered
			for (var i = 0; i < _players.length; i++) {
				if (_players[i] == player) {
					return player;
				}
			}
			_players.push(player);
			return player;
		};


		/**
		 * a fonction exposed by the object cacaoplayer (which is also a function)
		 * this is the function called when we call "cacaoplayer(id_of_the_cacao_div)" from javascript
		 * it returns a new object or an existing object if already created before
		 * this object has a bunch of useful functions on it for the comsumers of the API to use
		 */
		cacaoplayer.getPlayer = function(id) {
			var _container = document.getElementById(id);
			if (_container) {
				var registeredplayer = getRegisteredPlayerById(id);
				if (registeredplayer) {
					return registeredplayer;
				} else {
					return registerPlayer(new cacaoplayer.builder(_container));
				}
			}
		};

			
		
	})(cacaoplayer);

}



