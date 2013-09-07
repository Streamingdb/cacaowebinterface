

var cacaoweb = function () {
	var cacao_addedvideostabs = [];
	var cacao_replaced = [];
	var cacaowebisrunning = -1;
	var cacaowebAPIinstalled = -1;
	
	
	/** check if cacaoweb API is installed and if cacaoweb is running
		takes 1 second to update the variables
	*/
	function init() {
		// check if cacaoweb is running on the host machine
		setTimeout(function () {
				var isrunningscript = document.getElementById('isrunningscript');
				if (!isrunningscript) { // tests if the cacaoweb API is already running in the page, if that's the case there is no need for the following
					cacaoweb.cacaowebAPIinstalled = 0;
					if (document.body) {
						var scriptblock = document.getElementById('isrunning'); 
						if (scriptblock) { // TODO: it means the isrunning script has already been inserted by someone??
							//document.body.removeChild(scriptblock);
						} else {
							// check if cacaoweb is running, if it is then Cacaoweb.callbackIsRunning will be called and a DOM witness node will be created
							var docscript = document.createElement("script");
							docscript.type = 'text/javascript';
							docscript.innerHTML = 'var Cacaoweb = { callbackIsRunning: function () { var cacaodiv = document.createElement("div"); cacaodiv.id = "cacaorunning"; document.body.appendChild(cacaodiv); } };';
							document.body.appendChild(docscript);
							
							var script = document.createElement("script");
							script.id = 'isrunning';
							script.src = 'http://127.0.0.1:4001/isrunning';
							script.type = 'text/javascript';
							document.body.appendChild(script);
						}
					}
				} else {
					cacaoweb.cacaowebAPIinstalled = 1;
				}
			}, 1000); // it's better to give 1s for the page to load, so we know for sure whether the cacaoweb API is installed
	}
	
	function putmarker() {
		var div = document.createElement("div");
		div.id = 'cacaowebchromeextension';
		document.body.appendChild(div);
	}
	
	
	/** functions to check and extract information from hosting platforms addresses
	*/
	function isVideobblink(link) {
		return (link.indexOf("videobb.com/") > -1 && (link.indexOf("video/") > -1 || link.indexOf("v=") > -1 || 
				link.indexOf("/e/") > -1 || link.indexOf("/v/") > -1 || link.indexOf("/embed/") > -1));
	}
	function getVideobbID(link) {
		var videoid = "";
		var ff = link.split("video/");
		if (!ff[1]) {
			ff = link.split("?v=");
			if (!ff[1]) {
				ff = link.split("/e/");
				if (!ff[1]) {
					ff = link.split("/embed/");
				}
			}
		}
		if (!ff[1]) {
		
		} else {
			videoid = ff[1].substring(0, 12);
		}
	
		return videoid;
	}
	
	function isVideozerlink(link) {
		return (link.indexOf("videozer.com/") > -1 && (link.indexOf("video/") > -1 || link.indexOf("v=") > -1 || 
				link.indexOf("/e/") > -1 || link.indexOf("/v/") > -1 || link.indexOf("/embed/") > -1));
	}
	function getVideozerID(link) {
		var videoid = "";
		var ff = link.split("video/");
		if (!ff[1]) {
			ff = link.split("?v=");
			if (!ff[1]) {
				ff = link.split("/e/");
				if (!ff[1]) {
					ff = link.split("/embed/");
				}
			}
		}
		if (!ff[1]) {
			/*var flashvars = embeds[i].getAttribute('flashvars');
			ff = flashvars.split("setting=");
			if (!ff[1]) {
				//alert("no videoid in videobb");
			} else {
				ff = atob(ff[1]).split("?v=");
				if (!ff[1]) {
					//alert("no videoid in videobb");
				} else {
					videoid = ff[1].substring(0, 12);
				}
			}*/
		} else {
			videoid = ff[1].substring(0, 12);
		}
	
		return videoid;
	}
	
	function isMixturelink(link) {
		return (link.indexOf("mixturecloud.com/") > -1 && 
			(link.indexOf("video=") > -1 || link.indexOf("/video/") > -1 || link.indexOf("/media/") > -1));
	}
	function getMixtureID(link) {
		var ff = link.split("video=");
		if (!ff[1]) {
			ff = link.split("/video/");
			if (!ff[1]) {
				ff = link.split("/media/");
			}
		}
		return ff[1]; // TODO: peut etre faux
	}
	
	
	function isPutlockerlink(link) {
		return (link.indexOf("putlocker.com/") > -1 && 
			(link.indexOf("/video/") > -1 || link.indexOf("/file/") > -1  || link.indexOf("/embed/") > -1));
	}
	function getPutlockerID(link) {
		var ff = link.split("/file/");
		if (!ff[1]) {
			ff = link.split("/video/");
			if (!ff[1]) {
				ff = link.split("/embed/");
			}
		}
		return ff[1];
	}
			
	function isNowvideolink(link) {
		return (link.indexOf("nowvideo.") > -1 && link.indexOf("/video/") > -1);
	}
	function getNowvideoID(link) {
		var ff = link.split("/video/");
		return ff[1];
	}
	
	function isMoevideoslink(link) {
		return (link.indexOf("moevideo") > -1 && link.indexOf("/online/") > -1);
	}
	function getMoevideosID(link) {
		var ff = link.split("/online/");
		return ff[1];
	}
	
	
	
	
	

	function replaceVids(docs) {
		var foundvids = false;
		var replacedvideoscount = 0;
		for (var j = 0; j < docs.length; j++) {
			var embeds = docs[j].getElementsByTagName("embed");
			for (var i = 0; i < embeds.length; i++) {
				if (isVideobblink(embeds[i].src) || isVideozerlink(embeds[i].src) || isMixturelink(embeds[i].src) ||
					isPutlockerlink(embeds[i].src) || isNowvideolink(embeds[i].src) || isMoevideoslink(embeds[i].src)) {
					var provider = "";
					var videoid = "";
					if (isVideobblink(embeds[i].src)) {
						provider = "bb";
						videoid = getVideobbID(embeds[i].src);
					} else if (isVideozerlink(embeds[i].src)) {
						provider = "vz";
						videoid = getVideozerID(embeds[i].src);
					} else if (isMixturelink(embeds[i].src)) {
						provider = "mi";
						videoid = getMixtureID(embeds[i].src);
					} else if (isPutlockerlink(embeds[i].src)) {
						provider = "pu";
						videoid = getPutlockerID(embeds[i].src);
					} else if (isNowvideolink(embeds[i].src)) {
						provider = "nv";
						videoid = getNowvideoID(embeds[i].src);
					} else if (isMoevideoslink(embeds[i].src)) {
						provider = "mo";
						videoid = getMoevideosID(embeds[i].src);
					} 
					var playornot = "";
					if (replacedvideoscount > 0) {
						playornot = "&dontplay=1";
					};
					
					
					
					if (replacedvideoscount == 0 && cacaowebAPIinstalled != 1) {
						if (cacao_addedvideostabs.indexOf(videoid) == -1) {
							cacao_addedvideostabs.push(videoid);
							var host = "127.0.0.1:4001";
							if (cacaowebisrunning != 1) {
								host = "watch.cacaoweb.org";
							}
							var newurl = "http://" + host + "/?play=1&provider=" + provider + "&videoid=" + videoid;
							openNewTab(newurl);
						}
					} else if (cacaowebisrunning == 1) { // in-page replacing only if cacaoweb is running
						if (provider == "bb") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/videobb/videobb.caml?videoid=" + videoid + playornot);
						} else if (provider == "vz") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/videozer/videozer.caml?videoid=" + videoid + playornot);
						} else if (provider == "mi") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/mixture/mixture.caml?videoid=" + videoid + playornot);
						} else if (provider == "pu") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/putlocker/putlocker.caml?videoid=" + videoid + playornot);
						} else if (provider == "nv") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/nowvideo/nowvideo.caml?videoid=" + videoid + playornot);
						} else if (provider == "mo") {
							embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/moevideos/moevideos.caml?videoid=" + videoid + playornot);
						} 
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
						
						replacedvideoscount = replacedvideoscount + 1;
					}
					
					foundvids = true;
				}
			}
			
			var iframes = docs[j].getElementsByTagName("iframe");
			for (var i = 0; i < iframes.length; i++) {
				//alert(iframes[i].src + " " + isPutlockerlink(iframes[i].src));
				if (isVideobblink(iframes[i].src) || isVideozerlink(iframes[i].src) || isMixturelink(iframes[i].src) ||
					isPutlockerlink(iframes[i].src) || isNowvideolink(iframes[i].src) || isMoevideoslink(iframes[i].src)) {
					var provider = "";
					var videoid = "";
					if (isVideobblink(iframes[i].src)) {
						provider = "bb";
						videoid = getVideobbID(iframes[i].src);
					} else if (isVideozerlink(iframes[i].src)) {
						provider = "vz";
						videoid = getVideozerID(iframes[i].src);
					} else if (isMixturelink(iframes[i].src)) {
						provider = "mi";
						videoid = getMixtureID(iframes[i].src);
					} else if (isPutlockerlink(iframes[i].src)) {
						provider = "pu";
						videoid = getPutlockerID(iframes[i].src);
					} else if (isNowvideolink(iframes[i].src)) {
						provider = "nv";
						videoid = getNowvideoID(iframes[i].src);
					} else if (isMoevideoslink(iframes[i].src)) {
						provider = "mo";
						videoid = getMoevideosID(iframes[i].src);
					} 
					if (cacao_addedvideostabs.indexOf(videoid) == -1) {
						cacao_addedvideostabs.push(videoid);
						var host = "127.0.0.1:4001";
						if (cacaowebisrunning != 1) {
							host = "watch.cacaoweb.org";
						}
						var newurl = "http://" + host + "/?play=1&provider=" + provider + "&videoid=" + videoid;
						openNewTab(newurl);
						foundvids = true;
					}
				}
			}
		}
		return foundvids;
	};

	function openNewTab(url) {
		window.open(url);
	}
	
	// get all documents of the current page
	function getDocuments(frame) {
		var documents = new Array();
		if (frame) {
			if (frame.document) {
				documents.push(frame.document);
			}
			for (var i = 0; i < frame.frames.length; i++) {
				documents = documents.concat(getDocuments(frame.frames[i]));
			}
		}
		return documents;
	}
	
	function findvideos() {		
		var cacaodiv = document.getElementById("cacaorunning"); 
		if (cacaodiv) { // find if cacaoweb is running by checking our DOM witness node
			cacaowebisrunning = 1;
		}
					
		// on ajoute une tab lorsque c'est une page d'un hébergeur bien connu, sans remplacer la vidéo
		// de cette façon l'utilisateur peut toujours regarder la vidéo directement s'il ne veut pas utiliser cacaoweb
		var loc = document.location.href;
		if (isVideobblink(loc) || isVideozerlink(loc) || isMixturelink(loc) || isPutlockerlink(loc) || 
			isNowvideolink(loc) || isMoevideoslink(loc)) {
			var provider = "";
			var videoid = "";
			if (isVideobblink(loc)) {
				provider = "bb";
				videoid = getVideobbID(loc);
			} else if (isVideozerlink(loc)) {
				provider = "vz";
				videoid = getVideozerID(loc);
			} else if (isMixturelink(loc)) {
				provider = "mi";
				videoid = getMixtureID(loc);
			} else if (isPutlockerlink(loc)) {
				provider = "pu";
				videoid = getPutlockerID(loc);
			} else if (isNowvideolink(loc)) {
				provider = "nv";
				videoid = getNowvideoID(loc);
			} else if (isMoevideoslink(loc)) {
				provider = "mo";
				videoid = getMoevideosID(loc);
			}
			
			if (provider != "") {
				var host = "127.0.0.1:4001";
				if (cacaowebisrunning != 1) {
					host = "watch.cacaoweb.org";
				}
				var newurl = "http://" + host + "/?play=1&provider=" + provider + "&videoid=" + videoid;
				if (cacao_addedvideostabs.indexOf(videoid) == -1) {
					cacao_addedvideostabs.push(videoid);
					openNewTab(newurl);
				}
			}
		} else if (cacaowebAPIinstalled != 1) {
			var docs = getDocuments(document.defaultView);
			//cacao_stickiframesListeners(docs);
			if (replaceVids(docs)) {
				// cacaoweb has replaced some videos in this page
			}
		}
		
	}
	
	function malware_protection() {
		var loc = document.location.href;
		
		// protection against malware: bring an alternative website to avoid websites known to distribute malware
		if (loc.indexOf("italiafilm.") > -1 || loc.indexOf("instreaming.tv") > -1 || loc.indexOf("film-stream.tv") > -1 || loc.indexOf("piratestreaming.") > -1
			|| loc.indexOf("filmsenzalimiti.it") > -1 || loc.indexOf("streamingfilm.it") > -1 || loc.indexOf("film-review.it") > -1 || loc.indexOf("cineblog01.com") > -1
			|| loc.indexOf("filmpertutti.tv") > -1 || loc.indexOf("bayapirata.com") > -1 || loc.indexOf("filmakers.org") > -1 || loc.indexOf("streamingfilmgratis.net") > -1
			|| loc.indexOf("robinfilm.com") > -1 || loc.indexOf("filmtoyou.com") > -1) {
			if (Math.floor(Math.random()*4) == 0) {
				var replacement1 = "http://papystreaming.com/it/";
				//var replacement2 = "http://streamingdb.net";
				if (cacao_replaced.indexOf(loc) == -1) {
					cacao_replaced.push(loc);
					var replacement;
					//if (Math.floor(Math.random() * 2) == 0) {
						replacement = replacement1;
					/*} else {
						replacement = replacement2;
					}*/
					openNewTab(replacement);
					//gBrowser.loadURI(replacement);
				}
			}
		}
		if (loc.indexOf("dpstream") > -1 || loc.indexOf("gigastreaming.com") > -1 || loc.indexOf("king-stream.com") > -1 || loc.indexOf("streamiz") > -1 || loc.indexOf("lookiz") > -1
			|| loc.indexOf("streaming-az.com") > -1 || loc.indexOf("nouveaufilms.com") > -1 || loc.indexOf("tv-replay.fr") > -1 || loc.indexOf("fifostream.tv") > -1
			|| loc.indexOf("mksniper.fr") > -1 || loc.indexOf("seriesnostop.com") > -1 || loc.indexOf("replay.fr") > -1
			|| loc.indexOf("emule-island.ru") > -1 || loc.indexOf("dpstreaming.org") > -1 || loc.indexOf("cinemay.com") > -1 || loc.indexOf("serieskiki.com") > -1
			|| loc.indexOf("ultimateshare.net") > -1 || loc.indexOf("filmze.com") > -1 || loc.indexOf("movienostop.com") > -1 || loc.indexOf("streamingdefilms.com") > -1) {
			var replacement = "http://papystreaming.com/fr/";
			if (Math.floor(Math.random()*4) == 0) {
				if (cacao_replaced.indexOf(loc) == -1) {
					cacao_replaced.push(loc);
					openNewTab(replacement);
					//gBrowser.loadURI(replacement);
				}
			}
		}
		if (loc.indexOf("cinetube.es") > -1 || loc.indexOf("seriespepito.com") > -1) {
			var replacement = "http://papystreaming.com/es/";
			if (Math.floor(Math.random()*4) == 0) {
				if (cacao_replaced.indexOf(loc) == -1) {
					cacao_replaced.push(loc);
					openNewTab(replacement);
					//gBrowser.loadURI(replacement);
				}
			}
		}
	}
	
	
	return {
		init: init,
		putmarker: putmarker,
		findvideos: findvideos,
		malware_protection: malware_protection
	}
	
} ();


cacaoweb.putmarker();
cacaoweb.init();
cacaoweb.malware_protection();
setTimeout(function () { cacaoweb.findvideos() }, 3000);
setInterval(function () { cacaoweb.findvideos() }, 10000);
