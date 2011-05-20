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
			languagestrings['en']['errorStreamNotFound'] = "error StreamNotFound (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['filetimeout'] = "cacaoweb could not find this video.<br>Please try again later.";
			
			languagestrings['es'] = new Dictionary();
			languagestrings['es']['cacaowebnotrunning'] = "cacaoweb no está instalado";
			languagestrings['es']['cacaowebdownload'] = "Descargar";
			languagestrings['es']['notloggedin'] = "No has iniciado sesión";
			languagestrings['es']['myaccount'] = "Mi cuenta";
			languagestrings['es']['cost'] = "Este archivo cuesta ";
			languagestrings['es']['credits'] = " créditos";
			languagestrings['es']['buy'] = "Compra ahora";
			languagestrings['es']['notenoughcredits'] = "No tienes suficientes créditos, ve a tu cuenta para añadir más.";
			languagestrings['es']['watchpreview'] = "O puedes ver un adelanto pulsando el botón de reproducir";
			languagestrings['es']['errorreadingfile'] = "hubo un error reproduciendo este archivo";
			languagestrings['es']['errorStreamNotFound'] = "error StreamNotFound (informa de esto en http://forum.cacaoweb.org)";
			languagestrings['es']['errorFileStructureInvalid'] = "error FileStructureInvalid (informa de esto en http://forum.cacaoweb.org)";
			languagestrings['es']['filetimeout'] = "cacaoweb no pudo encontrar este vídeo.<br>Por favor, prueba más tarde.";

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
			languagestrings['it']['errorStreamNotFound'] = "error StreamNotFound (report it on http://forum.cacaoweb.org)";
			languagestrings['it']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on http://forum.cacaoweb.org)";
			languagestrings['it']['filetimeout'] = "cacaoweb non riesce a trovare il video.<br>Ricarica la pagina per riprovare!";

			languagestrings['pl'] = new Dictionary();
			languagestrings['pl']['cacaowebnotrunning'] = "cacaoweb nie jest zainstalowany";
			languagestrings['pl']['cacaowebdownload'] = "Pobierz";
			languagestrings['pl']['notloggedin'] = "Nie jesteś zalogowany";
			languagestrings['pl']['myaccount'] = "Moje konto";
			languagestrings['pl']['cost'] = "Ten plik kosztuje ";
			languagestrings['pl']['credits'] = " kredytów";
			languagestrings['pl']['buy'] = "Kup teraz";
			languagestrings['pl']['notenoughcredits'] = "Nie masz wystarczająco dużo kredytów, idź do swojego konta, aby doładować kredyty";
			languagestrings['pl']['watchpreview'] = "Albo możesz zobaczyć podgląd naciskając przycisk play";
			languagestrings['pl']['errorreadingfile'] = "wystąpił błąd w pliku";
			languagestrings['pl']['errorStreamNotFound'] = "błąd StreamNotFound (zgłoś to na http://forum.cacaoweb.org)";
			languagestrings['pl']['errorFileStructureInvalid'] = "błąd FileStructureInvalid (zgłoś to na http://forum.cacaoweb.org)";
			languagestrings['pl']['filetimeout'] = "cacaoweb nie mógł znaleść pliku.<br>Proszę spróbuj ponownie później.";

		}
		public function getString(language:String, stringid:String):String {
			return languagestrings[language][stringid];
		}
	}
}