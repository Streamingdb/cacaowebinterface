

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
			(link.indexOf("/video/") > -1 || link.indexOf("/file/") > -1));
	}
	function getPutlockerID(link) {
		var ff = link.split("/file/");
		if (!ff[1]) {
			ff = link.split("/video/");
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
					isPutlockerlink(embeds[i].src) || isMoevideoslink(embeds[i].src)) {
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
						} 
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
						
						replacedvideoscount = replacedvideoscount + 1;
					}
					
					foundvids = true;
				}
			}
		}
		return foundvids;
	};

	function openNewTab(url) {
		window.open(url);
	};
	
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
	};

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
		
	};
	
	
	return {
		init: init,
		findvideos: findvideos
	}
	
} ();  


cacaoweb.init ();
//cacao_protection();
setTimeout(function () { cacaoweb.findvideos() }, 2000);

