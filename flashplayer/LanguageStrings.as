package {
	import flash.utils.*;
	
	public class LanguageStrings {
		
		var languagestrings:Dictionary = new Dictionary();
		
		public function LanguageStrings() {
			languagestrings['en'] = new Dictionary();
			languagestrings['en']['cacaowebnotrunning'] = "cacaoweb is not running!<br>Download it at <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['en']['errorreadingfile'] = "there was an error playing this file";
			languagestrings['en']['watchedwithcacaoweb'] = "watched with cacaoweb<br> <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['en']['errorStreamNotFound'] = "error StreamNotFound (report it on forum.cacaoweb.org)";
			languagestrings['en']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on forum.cacaoweb.org)";
			languagestrings['en']['filetimeout'] = "cacaoweb could not find this video.<br>Please try again later.";

			languagestrings['fr'] = new Dictionary();
			languagestrings['fr']['cacaowebnotrunning'] = "cacaoweb n'est pas lancé!<br>Téléchargez le sur <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['fr']['errorreadingfile'] = "une erreur s'est produite pendant la lecture de ce media";
			languagestrings['fr']['watchedwithcacaoweb'] = "proposé par cacaoweb<br> <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['fr']['errorStreamNotFound'] = "erreur StreamNotFound<br>(rapporter le problème sur forum.cacaoweb.org)";
			languagestrings['fr']['errorFileStructureInvalid'] = "erreur FileStructureInvalid<br>(rapporter le problème sur forum.cacaoweb.org)";
			languagestrings['fr']['filetimeout'] = "cacaoweb n'a pas pu trouver cette vidéo.<br>Vous pouvez réessayer ultérieurement.";

			languagestrings['it'] = new Dictionary();
			languagestrings['it']['cacaowebnotrunning'] = "cacaoweb non è in esecuzione.<br>Scaricarlo a <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['it']['errorreadingfile'] = "c'è stato un errore guardare questo flusso";
			languagestrings['it']['watchedwithcacaoweb'] = "guardato con cacaoweb<br><a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['it']['errorStreamNotFound'] = "error StreamNotFound (report it on forum.cacaoweb.org)";
			languagestrings['it']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on forum.cacaoweb.org)";
			languagestrings['it']['filetimeout'] = "cacaoweb non riesce a trovare il video.<br>Ricarica la pagina per riprovare!";

		}
		public function getString(language:String, stringid:String):String {
			return languagestrings[language][stringid];
		}
	}
}