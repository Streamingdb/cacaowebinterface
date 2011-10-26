var Cacaoweb = {
	/** 
	  the parameters for the player and the javascript API
	  they can be overwritten by calling the function setup() of this API
	  */
	  
	/**
	  javascript parameters
	  */
	version: "2.13",
	timerTasksInterval: 0.5,
	lasttimeclientrunning: 0,
	lasttimestatuscheck: 0,
	isclientrunningHysteresisInterval: 30000,
	timeoutClientAlive: 2000,
	timeStart: (new Date()).getTime(),
	status: 'Unknown',
	myFuncs: [],
	missingpluginimage: 'http://www.cacaoweb.org/images/plugin.png', 
	
	/**
	  player default parameters
	  */
	videowidth: 640,
	videoheight: 360,
	autoplay: true,
	//playerurl: "http://127.0.0.1:4001/player.swf",
	playerurl: "player.swf",
	
	
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
	 * ATTENTION: ne marche qu'avec une fonction maximum
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
	
	
	playvideo: function(o, width, height) {
		var link = o.getAttribute("cacaolink");
		var id = o.id;
		var player = '<object id="' + id + '" width="' + width + '" height="' + height + '">';
		player += '<param name="allowFullScreen" value="true" />';
		player += '<param name="flashvars" value="file=' + link + '" />';
		player += '<param name="movie" value="' + this.playerurl + '" />';
		player += '<embed src="' + this.playerurl + '" ';
		player += 'flashvars="file=' + link + '" ';
		player += 'width="' + width + '" height="' + height + '" allowFullScreen="true" name="' + id + '" />';
		player += '</object>';
		o.innerHTML = player;
	},
	
	insertAllVideos: function() {
		var all = document.getElementsByTagName("div");
		for (var i = 0; i < all.length; i++) {
			if (all[i].getAttribute("cacaolink")) {
				this.playvideo(all[i], this.videowidth, this.videoheight);
			}
		}
	},
	
	insertDownloadPlugin: function() {
		var all = document.getElementsByTagName("div");
		for (var i = 0; i < all.length; i++) {
			if (all[i].getAttribute("cacaolink")) {
				all[i].innerHTML = '<a href="javascript:Cacaoweb.download()"><img src="' + this.missingpluginimage + '" /></a>';
			}
		}
	},





	/**
          functions exposed by the API
	 */

	/**
	 * On joue les vidéos de la page en attendant 2s pour voir si cacaoweb est en route, sinon on affiche une image de téléchargement
	 */
	findAndPlay: function() {
		if (this.status == 'On') {
			this.insertAllVideos();
		} else {
			var timeout = setTimeout("Cacaoweb.insertDownloadPlugin()", this.timeoutClientAlive);
			var f = null;
			f = function (status) { if (status == "On") {
										clearTimeout(timeout);
										Cacaoweb.unsubscribeStatusChange(f);
										Cacaoweb.insertAllVideos();
									}
								};
			this.subscribeStatusChange(f);
		}
	}
}

setInterval(function() { Cacaoweb.checkStatus(); }, Cacaoweb.timerTasksInterval * 1000);
Cacaoweb.checkStatus(); 


/**
 * we define a global object cacaoplayer to access player instances - it is also a function
 */
if (typeof cacaoplayer == "undefined") { // in case the API is included twice

	var cacaoplayer = function(id) {
		if (cacaoplayer.getPlayer){ // TODO: remove it?
			return cacaoplayer.getPlayer(id);
		}
	};


	(function(cacaoplayer) { // we don't pollute the global scope

		// the list of registered player objects
		var _players = [];
		
		// the constructor to build our player object
		cacaoplayer.builder = function(container) {
			this.container = container;
			this.id = container.id;
			this.playerurl = Cacaoweb.playerurl;
			this.width = Cacaoweb.videowidth;
			this.height = Cacaoweb.videoheight;

			this.insertFlash = function() {
				var link = this.container.getAttribute("cacaolink");
				var id = this.container.id;
				var player = '<object id="' + id + 'flash" width="' + this.width + '" height="' + this.height + '">';
				player += '<param name="allowFullScreen" value="true" />';
				player += '<param name="flashvars" value="file=' + link + '" />';
				player += '<param name="movie" value="' + this.playerurl + '" />';
				player += '<embed src="' + this.playerurl + '" ';
				player += 'flashvars="file=' + link + '" ';
				player += 'width="' + this.width + '" height="' + this.height + '" allowFullScreen="true" name="' + id + 'flash" />';
				player += '</object>';
				this.container.innerHTML = player;
			}


			this.getFlashPlayer = function(movieName) { 
				if (movieName) {
					if (navigator.appName.indexOf("Microsoft") != -1) { 
						return window[movieName]; 
					} else { 
						return document[movieName]; 
					}
				} else {
					// TODO: return any instance
				}
			}


			this.play = function (link) {
				// TODO
				var flashplayer = this.getFlashPlayer(this.id + "flash");
				if (flashplayer) {

				} else { // first create the flash object
					this.insertFlash();
				}
				
				return this;
			}

			this.error = function (errormsg) {
				var flashplayer = this.getFlashPlayer(this.id + "flash");
				flashplayer.error(errormsg);
				return this;
			}

			this.setup = function (setupoptions) {
				// TODO
				return this;
			}

			this.test = function () {
				alert("test");
			}

		};



		/** 
		 * functions to manipulate the list of registered player objects
		 */


		cacaoplayer.getRegisteredPlayerById = function(id) {
			for (var i = 0; i < _players.length; i++) {
				if (_players[i].id == id) {
					return _players[i];
				}
			}
			return null;
		};
	
		cacaoplayer.registerPlayer = function(player) {
			// first check if the player is already registered
			for (var i = 0; i < _players.length; i++) {
				if (_players[i] == player) {
					return player;
				}
			}
		
			_players.push(player);
			return player;
		};



		cacaoplayer.getPlayer = function(id) {
			// TODO: do the case where id is undefined and we have to return all the players of the document
			var _container = document.getElementById(id);

			if (_container) {
				var registeredplayer = cacaoplayer.getRegisteredPlayerById(id);
				if (registeredplayer) {
					return registeredplayer;
				} else {
					return cacaoplayer.registerPlayer(new cacaoplayer.builder(_container));
				}
			}
			return null;
		};

			
		
	})(cacaoplayer);

}



