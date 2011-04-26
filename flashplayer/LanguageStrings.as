package {
	import flash.utils.*;
	
	public class LanguageStrings {
		
		var languagestrings:Dictionary = new Dictionary();
		
		public function LanguageStrings() {
			languagestrings['en'] = new Dictionary();
			languagestrings['en']['cacaowebnotrunning'] = "cacaoweb is not installed";
			languagestrings['en']['cacaowebdownload'] = "Download";
			languagestrings['en']['notloggedin'] = "You are not logged in";
			languagestrings['en']['myaccount'] = "My account";
			languagestrings['en']['cost'] = "This file costs ";
			languagestrings['en']['credits'] = " credits";
			languagestrings['en']['buy'] = "Buy now";
			languagestrings['en']['notenoughcredits'] = "You don't have enough credits, go to your account to add credits";
			languagestrings['en']['watchpreview'] = "Or you can watch a preview by hitting the play button";
			languagestrings['en']['errorreadingfile'] = "there was an error playing this file";
			languagestrings['en']['watchedwithcacaoweb'] = "watched with cacaoweb<br> <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['en']['errorStreamNotFound'] = "error StreamNotFound (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['filetimeout'] = "cacaoweb could not find this video.<br>Please try again later.";

			languagestrings['fr'] = new Dictionary();
			languagestrings['fr']['cacaowebnotrunning'] = "cacaoweb n'est pas installé";
			languagestrings['fr']['cacaowebdownload'] = "Télécharger";
			languagestrings['fr']['notloggedin'] = "Vous ne vous êtes pas identifié";
			languagestrings['fr']['myaccount'] = "Mon compte";
			languagestrings['fr']['cost'] = "This file coûte ";
			languagestrings['fr']['credits'] = " crédits";
			languagestrings['fr']['buy'] = "Acheter";
			languagestrings['fr']['notenoughcredits'] = "Vous n'avez pas assez de crédits, aller sur votre compte pour ajouter des crédits";
			languagestrings['fr']['watchpreview'] = "Ou vous pouvez regardez un extrait en cliquant sur le bouton de lecture";
			languagestrings['fr']['errorreadingfile'] = "une erreur s'est produite pendant la lecture de ce media";
			languagestrings['fr']['watchedwithcacaoweb'] = "proposé par cacaoweb<br> <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['fr']['errorStreamNotFound'] = "erreur StreamNotFound<br>(rapporter le problème sur http://forum.cacaoweb.org)";
			languagestrings['fr']['errorFileStructureInvalid'] = "erreur FileStructureInvalid<br>(rapporter le problème sur http://forum.cacaoweb.org)";
			languagestrings['fr']['filetimeout'] = "cacaoweb n'a pas pu trouver cette vidéo.<br>Vous pouvez réessayer ultérieurement.";

			languagestrings['it'] = new Dictionary();
			languagestrings['it']['cacaowebnotrunning'] = "cacaoweb non è in esecuzione";
			languagestrings['it']['cacaowebdownload'] = "Scaricarlo";
			languagestrings['it']['notloggedin'] = "You are not logged in";
			languagestrings['it']['myaccount'] = "My account";
			languagestrings['it']['cost'] = "This file costs ";
			languagestrings['it']['credits'] = " credits";
			languagestrings['it']['buy'] = "Buy now";
			languagestrings['it']['notenoughcredits'] = "You don't have enough credits, go to your account to add credits";
			languagestrings['it']['watchpreview'] = "Or you can watch a preview by hitting the play button";
			languagestrings['it']['errorreadingfile'] = "c'è stato un errore guardare questo flusso";
			languagestrings['it']['watchedwithcacaoweb'] = "guardato con cacaoweb<br><a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['it']['errorStreamNotFound'] = "error StreamNotFound (report it on http://forum.cacaoweb.org)";
			languagestrings['it']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on http://forum.cacaoweb.org)";
			languagestrings['it']['filetimeout'] = "cacaoweb non riesce a trovare il video.<br>Ricarica la pagina per riprovare!";

		}
		public function getString(language:String, stringid:String):String {
			return languagestrings[language][stringid];
		}
	}
}