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
			languagestrings['it']['cacaowebdownload'] = "Lancialo o Scaricalo da";
			languagestrings['it']['notloggedin'] = "Non sei loggato";
			languagestrings['it']['myaccount'] = "Mio Account";
			languagestrings['it']['cost'] = "Questo File Costa ";
			languagestrings['it']['credits'] = " crediti";
			languagestrings['it']['buy'] = "Compralo Adesso";
			languagestrings['it']['notenoughcredits'] = "Non hai abbastanza crediti, vai al tuo account per acquistarli";
			languagestrings['it']['watchpreview'] = "O puoi vedere un anteprima cliccando il tasto Play";
			languagestrings['it']['errorreadingfile'] = "C'è stato un errore guardare guardando questo video";
			languagestrings['it']['watchedwithcacaoweb'] = "Guardato con cacaoweb<br><a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['it']['errorStreamNotFound'] = "errore StreamNotFound (segnalalo su http://forum.cacaoweb.org)";
			languagestrings['it']['errorFileStructureInvalid'] = "errore FileStructureInvalid (segnalalo su http://forum.cacaoweb.org)";
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
			languagestrings['pl']['watchedwithcacaoweb'] = "Oglądałeś dzięki cacaoweb<br> <a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['pl']['errorStreamNotFound'] = "błąd StreamNotFound (zgłoś to na http://forum.cacaoweb.org)";
			languagestrings['pl']['errorFileStructureInvalid'] = "błąd FileStructureInvalid (zgłoś to na http://forum.cacaoweb.org)";
			languagestrings['pl']['filetimeout'] = "cacaoweb nie mógł znaleść pliku.<br>Proszę spróbuj ponownie później.";

		}
		public function getString(language:String, stringid:String):String {
			return languagestrings[language][stringid];
		}
	}
}