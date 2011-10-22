
var cacaoweb = {
	cacao_addedvideostabs : [],
	prefManager : null,
	stringsBundle : null,
	cacaowebisrunning : 'Unknown',
	cacaowebAPIinstalled : 'Unknown',
	
	init : function () {
		this.prefManager = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);
		var stringBundleService = Components.classes["@mozilla.org/intl/stringbundle;1"].getService(Components.interfaces.nsIStringBundleService);
		stringsBundle = stringBundleService.createBundle("chrome://cacaoweb/locale/cacaoweb.properties");
		var firstRun = this.prefManager.getIntPref("extensions.cacaoweb.firstRun"); 
    	if(firstRun) {
    		this.prefManager.setIntPref("extensions.cacaoweb.firstRun", 0);    
			setTimeout(function () { gBrowser.selectedTab = gBrowser.addTab("http://www.cacaoweb.org/firstrunaddon.php"); }, 1000); 
    	}
		setTimeout(function () {
				var isrunningscript = window.content.document.getElementById('isrunningscript');
				if (!isrunningscript) {
					cacaoweb.cacaowebAPIinstalled = 'No';
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
					cacaoweb.cacaowebAPIinstalled = 'Yes';
				}
			}, 1000);
	}
};  

 

function cacao_replaceVids(docs, replace) {
	var foundvids = false;
	var replacedvideoscount = 0;
    for (var j = 0; j < docs.length; j++) {
        var embeds = docs[j].getElementsByTagName("embed");
        for (var i = 0; i < embeds.length; i++) {
            if (embeds[i].src != "" && (embeds[i].src.indexOf("megavideo.com", 0) > -1 || embeds[i].src.indexOf("videobb.com/", 0) > -1)) {
				if (replace) {
					var provider = "";
					var videoid = "";
					if (embeds[i].src.indexOf("megavideo.com", 0) > -1) {
						provider = "megavideo";
						ff = embeds[i].src.split("v=");
						if (!ff[1]) {
							ff = embeds[i].src.split("/e/");
							ff = embeds[i].src.split("/v/");
						}
						videoid = ff[1].substring(0, 8);
					} else if (embeds[i].src.indexOf("videobb.com", 0) > -1) {
						provider = "videobb";
						ff = embeds[i].src.split("video/");
						if (!ff[1]) {
							ff = embeds[i].src.split("v=");
						}
						if (!ff[1]) {
							ff = embeds[i].src.split("/e/");
						}
						videoid = ff[1].substring(0, 12);
					}
					var playornot = "";
					if (replacedvideoscount > 0) {
						playornot = "&dontplay=1";
					};
					
					if (replacedvideoscount == 0 && cacaoweb.cacaowebAPIinstalled != 'Yes' && provider == "megavideo") { 
						if (cacaoweb.cacao_addedvideostabs.indexOf(videoid) == -1) {
							cacaoweb.cacao_addedvideostabs.push(videoid);
							var newurl = "http://content.cacaoweb.org/play.php?videoid=" + videoid;
							if (cacaoweb.cacaowebisrunning == 'Ok') {
								newurl = "http://127.0.0.1:4001/?play=1&provider=mv&videoid=" + videoid;
							}
							gBrowser.selectedTab = gBrowser.addTab(newurl);
						}
					} else if (provider == "megavideo") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/megavideo/megavideo.caml?videoid=" + videoid + playornot);
						embeds[i].src = 'http://127.0.0.1:4001/player.swf';
					} else if (provider == "videobb") {
						embeds[i].setAttribute("flashvars", "file=http://127.0.0.1:4001/videobb/videobb.caml?videoid=" + videoid + playornot);
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
function cacao_removeAlert() {
    if (window.content.document.getElementById("alrBox")) {
        window.content.document.body.removeChild(window.content.document.getElementById("alrBox"));
    }
}
function cacao_makeAlert(playing) {	
			
    bd = window.content.document.body;
    var embeds = window.content.document.getElementsByTagName("embed");
    for (e = 0; e < embeds.length; e++) {
        embeds[e].setAttribute("wmode", "opaque");
        embeds[e].src = embeds[e].src;
    }
    cacao_removeAlert();
	
	// the box
    alrBox = document.createElement("div");
    alrBox.setAttribute("id", "alrBox");
    alrBox.setAttribute("style", "z-index:99995;position:fixed;right:10px;color:#FFF;font-size:11px;font-family:Arial;bottom:10px;width:300px;height:166px;opacity:0.95;background:transparent url('chrome://cacaoweb/skin/ff_box.png') no-repeat 0px 0px;");
    bd.appendChild(alrBox);
    lbox = window.content.document.getElementById("alrBox");
	
	// text
    alr = document.createElement("div");
    alr.setAttribute("id", "alertText_");
	alr.setAttribute("width", "110px");
    alr.setAttribute("style", "color:#BBB;margin-left:130px; margin-top:32px; margin-right:5px;");
	
	// launch button
	alrbtn = document.createElement("div");
	alrbtn.setAttribute("id", "alertbtn_");
	alrbtn.addEventListener("click", function () {
		var docs = cacao_getDocuments(content.document.defaultView);
		//cacao_stickiframesListeners(docs);
		cacaoweb.prefManager.setBoolPref("extensions.cacaoweb.automaticReplace", true);
		cacao_replaceVids(docs, cacaoweb.prefManager.getBoolPref("extensions.cacaoweb.automaticReplace"));
		cacao_removeAlert();
		//cacao_opencacaowebTab("");
	}, true);
	alrbtn.setAttribute("style", "z-index:99999;text-align:center;position:fixed;right:60px;bottom:100px;width:127px;height:17px;line-height:17px;cursor:pointer;color:#CCC;font-size:11px;font-family:Arial;background:transparent url('chrome://cacaoweb/skin/ff_btn.png') no-repeat;");
	//var sb = document.getElementById("cacaoweb-string-bundle");
	//alrbtn.appendChild(document.createTextNode(sb.GetStringFromName('watchwithcacaoweb')));
	alrbtn.appendChild(document.createTextNode(stringsBundle.GetStringFromName('watchwithcacaoweb')));
	
	// TV image
	alrtv = document.createElement("div");
	alrtv.addEventListener("click", function () { cacao_opencacaowebTab(""); }, true);
	alrtv.setAttribute("id", "tv_img");
	
	// close area
	alrcls = document.createElement("div");
    alrcls.setAttribute("id", "alertclose_");
    alrcls.addEventListener("click", cacao_removeAlert, true);
    alrcls.setAttribute("style", "z-index:99999;position:fixed;right:22px;bottom:80px;width:30px;height:30px;cursor:pointer;no-repeat;");
	
	
	alrdisable = document.createElement("div");
    alrdisable.setAttribute("id", "alertdisable_");
    alrdisable.setAttribute("style", "z-index:99999;text-align:center;position:fixed;right:120px;bottom:20px;width:160px;height:20px;line-height:14px;cursor:pointer;color:#777;font-size:10px;font-family:Arial;");
    alrdisable.addEventListener("click", function () {
        cacaoweb.prefManager.setBoolPref("extensions.cacaoweb.showAlert", false);
        cacao_removeAlert();
    }, true);
    alrdisable.appendChild(document.createTextNode(stringsBundle.GetStringFromName("disable")));
	
	alrauto = document.createElement("div");
    alrauto.setAttribute("id", "alertauto_");
    alrauto.setAttribute("style", "z-index:99999;text-align:center;position:fixed;right:50px;bottom:42px;width:135px;height:20px;line-height:14px;cursor:pointer;color:#C0C0C0;font-size:10px;font-family:Arial;");
    alrauto.addEventListener("click", function () {
        cacaoweb.prefManager.setBoolPref("extensions.cacaoweb.automaticReplace", false);
		content.document.defaultView.location.reload();
    }, true);
    alrauto.appendChild(document.createTextNode(stringsBundle.GetStringFromName('noauto')));
    
	
	if (playing) {
		alr.appendChild(document.createTextNode(stringsBundle.GetStringFromName('isplaying')));
		alrtv.setAttribute("style", "z-index:99990;position:fixed;right:190px;bottom:90px;width:64px;height:64px;cursor:pointer;opacity:0.6;background:transparent url('chrome://cacaoweb/skin/tv-64.png') no-repeat;");
		lbox.appendChild(alrauto);
	} else {
		lbox.appendChild(alrbtn);
		alrtv.setAttribute("style", "z-index:99990;position:fixed;right:190px;bottom:90px;width:64px;height:64px;cursor:pointer;opacity:0.6;background:transparent url('chrome://cacaoweb/skin/tv-64-off.png') no-repeat;");
	}
	lbox.appendChild(alrcls);
	lbox.appendChild(alrtv);
	lbox.appendChild(alrdisable);
    lbox.appendChild(alr);
}

function cacao_opencacaowebTab(videoid) {
	if (videoid == "") {
		gBrowser.selectedTab = gBrowser.addTab("http://local.cacaoweb.org:4001/");
	} else {
		gBrowser.selectedTab = gBrowser.addTab("http://local.cacaoweb.org:4001/");
	}
}

function cacao_findvideos(event) {
    if (!window.content) {
        return false;
    }
	
	var cacaodiv = window.content.document.getElementById("cacaorunning"); 
	if (cacaodiv) {
		cacaoweb.cacaowebisrunning = 'Ok';
	}
	
    /*if (cacaoweb.cacao_notraversing) {
        return false;
    } else {*/
        var loc = window.content.document.location.href;
        prv = window.content.document.createElement("div");
        prv.id = "_cacao_updateIcon_";
        if (window.content.document.body) {
            window.content.document.body.appendChild(prv);
        }
		if (!window.content.document.getElementById("_cacao_alertShown_")) {
            pdrv = window.content.document.createElement("input");
            pdrv.id = "_cacao_alertShown_";
            pdrv.type = "hidden";
            if (window.content.document.body) {
                window.content.document.body.appendChild(pdrv);
            }
        }
		
		function cacao_showAlert(kindArgs) {
			var exec = "";
			if (!window.content.document.getElementById("_cacao_alertShown_")) {
				return (new Array);
			}
			if (window.content.document.getElementById("_cacao_alertShown_").value == kindArgs) {
				return (new Array);
			}
			window.content.document.getElementById("_cacao_alertShown_").value = kindArgs;
			window.content.document.body.appendChild(prv);
			if (kindArgs == "megavideo") {
				exec = "mv";
				document.getElementById("cacao_mgttext").setAttribute("status", "has_items");
			} else {
				exec = "";
			}
			if (exec != "") {
				cacao_makeAlert(cacaoweb.prefManager.getBoolPref("extensions.cacaoweb.automaticReplace"));
			}
		}
		
		
		if ((loc.indexOf("megavideo.com", 0) > -1 && loc.indexOf("v=", 0) > -1) || 
				loc.indexOf("videobb.com/video/", 0) > -1) {
			var videoid = "";
			var provider = "";
			if (loc.indexOf("megavideo.com", 0) > -1) {
				provider = "mv";
				videoid = loc.substr(loc.indexOf("v=", 0) + 2);
			} else if (loc.indexOf("videobb.com/video/", 0) > -1) {
				provider = "bb";
				videoid = loc.substr(loc.indexOf("video/", 0) + 6);
			}
			//alert(cacaoweb.cacao_addedvideostabs.indexOf(videoid));
			if (cacaoweb.cacao_addedvideostabs.indexOf(videoid) == -1) {
				cacaoweb.cacao_addedvideostabs.push(videoid);
				cacao_showAlert("megavideo");
				var newurl = "http://content.cacaoweb.org/play.php?videoid=" + videoid;
				if (cacaoweb.cacaowebisrunning == 'Ok') {
					newurl = "http://127.0.0.1:4001/?play=1&provider=" + provider + "&videoid=" + videoid;
				}
				gBrowser.selectedTab = gBrowser.addTab(newurl);
			}
        } else if (cacaoweb.cacaowebAPIinstalled != 'Yes') {
            if (cacaoweb.prefManager.getBoolPref("extensions.cacaoweb.showAlert")) {
				var docs = cacao_getDocuments(content.document.defaultView);
				//cacao_stickiframesListeners(docs);
				if (cacao_replaceVids(docs, cacaoweb.prefManager.getBoolPref("extensions.cacaoweb.automaticReplace"))) {
					cacao_showAlert("megavideo");
				} else {
					document.getElementById("cacao_mgttext").setAttribute("status", "no_items");
					cacao_showAlert(false, false);
				}
            } else {
                document.getElementById("cacao_mgttext").setAttribute("status", "no_items");
                cacao_showAlert(false, false);
            }
        }
		
    //}
}


function cacao_statusiconClickHandler() {
	cacaoweb.prefManager.setBoolPref("extensions.cacaoweb.showAlert", true);
	content.document.defaultView.location.reload();
	cacao_opencacaowebTab("http://local.cacaoweb.org:4001/");
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

