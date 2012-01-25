
var cacaoweb = {
	cacao_addedvideostabs : [],
	cacao_replaced : [],
	prefManager : null,
	stringsBundle : null,
	cacaowebisrunning : -1,
	cacaowebAPIinstalled : -1,
	
	init : function () {
		this.prefManager = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);
		var stringBundleService = Components.classes["@mozilla.org/intl/stringbundle;1"].getService(Components.interfaces.nsIStringBundleService);
		stringsBundle = stringBundleService.createBundle("chrome://cacaoweb/locale/cacaoweb.properties");
		var firstRun = this.prefManager.getIntPref("extensions.cacaoweb.firstRun"); 
    	if(firstRun) {
    		this.prefManager.setIntPref("extensions.cacaoweb.firstRun", 0);    
			setTimeout(function () { gBrowser.selectedTab = gBrowser.addTab("http://www.cacaoweb.org/firstrunaddon.php"); }, 1000); 
    	}
		/* check if cacaoweb is running on the host machine */
		setTimeout(function () {
				var isrunningscript = window.content.document.getElementById('isrunningscript');
				if (!isrunningscript) {
					cacaoweb.cacaowebAPIinstalled = 0;
					if (window.content.document.body) {
						var thebody = window.content.document.body;
						var scriptblock = window.content.document.getElementById('isrunning'); 
						if (scriptblock) {
							//thebody.removeChild(scriptblock);
						} else {
							// check if cacaoweb is running
							var docscript = window.content.document.createElement("script");
							docscript.type = 'text/javascript';
							docscript.innerHTML = 'var Cacaoweb = { callbackIsRunning: function () { var cacaodiv = document.createElement("div"); cacaodiv.id = "cacaorunning"; document.body.appendChild(cacaodiv); } };'
							thebody.appendChild(docscript);
							
							var script = window.content.document.createElement("script");
							script.id = 'isrunning';
							script.src = 'http://127.0.0.1:4001/isrunning';
							script.type = 'text/javascript';
							thebody.appendChild(script);
						}
					}
				} else {
					cacaoweb.cacaowebAPIinstalled = 1;
				}
			}, 1000);
	},
	
	isMegavideolink : function(link) {
		return (link.indexOf("megavideo.com/") > -1 && (link.indexOf("/v/") > -1 || link.indexOf("v=") > -1));
	},
	getMegavideoID : function(link) {
		var ff = link.split("v=");
		if (!ff[1]) {
			ff = link.split("/e/");
			if (!ff[1]) {
				ff = link.split("/v/");
			}
		}
		return ff[1].substring(0, 8);
	},
	
	isVideobblink : function(link) {
		return (link.indexOf("videobb.com/") > -1 && (link.indexOf("video/") > -1 || link.indexOf("v=") > -1 || 
				link.indexOf("/e/") > -1 || link.indexOf("/v/") > -1 || link.indexOf("/embed/") > -1));
	},
	getVideobbID : function(link) {
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
	},
	
	isVideozerlink : function(link) {
		return (link.indexOf("videozer.com/") > -1 && (link.indexOf("video/") > -1 || link.indexOf("v=") > -1 || 
				link.indexOf("/e/") > -1 || link.indexOf("/v/") > -1 || link.indexOf("/embed/") > -1));
	},
	getVideozerID : function(link) {
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
	},
	
	isMixturelink : function(link) {
		return (link.indexOf("mixturecloud.com/") > -1 && (link.indexOf("video=") > -1 || link.indexOf("/video/") > -1));
	},
	getMixtureID : function(link) {
		var ff = link.split("video=");
		if (!ff[1]) {
			ff = link.split("/video/");
		}
		return ff[1].substring(0, 6);;
	},
	
};  

function cacao_openNewTab(url) {
	gBrowser.selectedTab = gBrowser.addTab(url);
}

function cacao_replaceVids(docs) {
	var foundvids = false;
	var replacedvideoscount = 0;
    for (var j = 0; j < docs.length; j++) {
        var embeds = docs[j].getElementsByTagName("embed");
        for (var i = 0; i < embeds.length; i++) {
            if (cacaoweb.isMegavideolink(embeds[i].src) || cacaoweb.isVideobblink(embeds[i].src) || 
					cacaoweb.isVideozerlink(embeds[i].src) || cacaoweb.isMixturelink(embeds[i].src)) {
				var provider = "";
				var videoid = "";
				if (cacaoweb.isMegavideolink(embeds[i].src)) {
					provider = "mv";
					videoid = cacaoweb.getMegavideoID(embeds[i].src);
				} else if (cacaoweb.isVideobblink(embeds[i].src)) {
					provider = "bb";
					videoid = cacaoweb.getVideobbID(embeds[i].src);
				} else if (cacaoweb.isVideozerlink(embeds[i].src)) {
					provider = "vz";
					videoid = cacaoweb.getVideozerID(embeds[i].src);
				} else if (cacaoweb.isMixturelink(embeds[i].src)) {
					provider = "mi";
					videoid = cacaoweb.getMixtureID(embeds[i].src);
				}
				var playornot = "";
				if (replacedvideoscount > 0) {
					playornot = "&dontplay=1";
				};
				
				
				if (cacaoweb.cacaowebisrunning == 1) {
					if (replacedvideoscount == 0 && cacaoweb.cacaowebAPIinstalled != 1) {
						if (cacaoweb.cacao_addedvideostabs.indexOf(videoid) == -1) {
							cacaoweb.cacao_addedvideostabs.push(videoid);
							var newurl = "http://content.cacaoweb.org/play.php?videoid=" + videoid;
								newurl = "http://127.0.0.1:4001/?play=1&provider=" + provider + "&videoid=" + videoid;
							cacao_openNewTab(newurl);
						}
					} else if (provider == "mv") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/megavideo/megavideo.caml?videoid=" + videoid + playornot);
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
					} else if (provider == "bb") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/videobb/videobb.caml?videoid=" + videoid + playornot);
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
					} else if (provider == "vz") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/videozer/videozer.caml?videoid=" + videoid + playornot);
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
					} else if (provider == "mi") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/mixture/mixture.caml?videoid=" + videoid + playornot);
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
					}
					
					replacedvideoscount = replacedvideoscount + 1;
				}
				
				foundvids = true;
            }
        }
    }
	return foundvids;
}

// get all documents of the current page
function cacao_getDocuments(frame) {
	var documents = new Array();
	if(frame) {
		if(frame.document) {
			documents.push(frame.document);
		}
		for(var i = 0; i < frame.frames.length; i++) {
			documents = documents.concat(cacao_getDocuments(frame.frames[i]));
		}
	}
	return documents;
}



function cacao_findvideos(event) {
    if (!window.content) {
        return false;
    }
	
	var cacaodiv = window.content.document.getElementById("cacaorunning"); 
	if (cacaodiv) {
		cacaoweb.cacaowebisrunning = 1;
	}
				
	// on ajoute une tab lorsque c'est une page d'un hébergeur bien connu, sans remplacer la vidéo
	// de cette façon l'utilisateur peut toujours regarder la vidéo directement s'il ne veut pas utiliser cacaoweb
	var loc = window.content.document.location.href;
	if (cacaoweb.isMegavideolink(loc) || cacaoweb.isVideobblink(loc) || cacaoweb.isVideozerlink(loc)) {
		var provider = "";
		var videoid = "";
		if (cacaoweb.isMegavideolink(loc)) {
			provider = "mv";
			videoid = cacaoweb.getMegavideoID(loc);
		} else if (cacaoweb.isVideobblink(loc)) {
			provider = "bb";
			videoid = cacaoweb.getVideobbID(loc);
		} else if (cacaoweb.isVideozerlink(loc)) {
			provider = "vz";
			videoid = cacaoweb.getVideozerID(loc);
		}
		
		if (provider != "") {
			var newurl = "http://content.cacaoweb.org/play.php?videoid=" + videoid;
			if (cacaoweb.cacaowebisrunning == 1) {
				newurl = "http://127.0.0.1:4001/?play=1&provider=" + provider + "&videoid=" + videoid;
			}
			if (cacaoweb.cacao_addedvideostabs.indexOf(videoid) == -1) {
				cacaoweb.cacao_addedvideostabs.push(videoid);
				cacao_openNewTab(newurl);
			}
		}
	} else if (cacaoweb.cacaowebAPIinstalled != 1) {
		var docs = cacao_getDocuments(content.document.defaultView);
		//cacao_stickiframesListeners(docs);
		if (cacao_replaceVids(docs)) {
			// cacaoweb has replaced some videos in this page
		}
	}
	
	// malware protection : open an alternative website when the user is brought to a websites featuring malware
	if (loc.indexOf("italia-film.com") > -1 || loc.indexOf("filmgratis.tv") > -1 || loc.indexOf("film-stream.tv") > -1 || loc.indexOf("piratestreaming.com") > -1) {
		var replacement = "http://www.streamingdb.net/";
		if (cacaoweb.cacao_replaced.indexOf(replacement) == -1) {
			cacaoweb.cacao_replaced.push(replacement);
			cacao_openNewTab(replacement);
		}
	}
	if (loc.indexOf("gigastreaming.com") > -1 || loc.indexOf("king-stream.com") > -1) {
		var replacement = "http://www.dpstream.net/";
		if (cacaoweb.cacao_replaced.indexOf(replacement) == -1) {
			cacaoweb.cacao_replaced.push(replacement);
			cacao_openNewTab(replacement);
		}
	}
	
}


function cacao_statusiconClickHandler() {
	content.document.defaultView.location.reload();
	cacao_openNewTab("http://127.0.0.1:4001/");
}




window.addEventListener("DOMContentLoaded", function () {
	cacaoweb.init ();
	setTimeout(cacao_findvideos, 2000);
    /*if (typeof gBrowser != "undefined") {
        if (typeof gBrowser.tabContainer != "undefined") {
            gBrowser.tabContainer.addEventListener("load", cacao_findvideos, true);
            gBrowser.tabContainer.addEventListener("TabSelect", cacao_findvideos, true);
        }
    } else {
        window.addEventListener("load", cacao_findvideos, true);
    }*/
}, true);

