package {
	import flash.utils.*;
	
	public class LanguageStrings {
		
		var languagestrings:Dictionary = new Dictionary();
		
		public function LanguageStrings() {
			languagestrings['en'] = new Dictionary();
			languagestrings['en']['pleasewait'] = "Please wait while loading...";
			languagestrings['en']['cacaowebnotrunning'] = "cacaoweb is not installed";
			languagestrings['en']['cacaowebdownload'] = "Download";
			languagestrings['en']['pleaselogin'] = "Please register or log in to continue";
			languagestrings['en']['myaccount'] = "My account";
			languagestrings['en']['premium'] = "Watch videos on cacaoweb with no limits, become premium now from only 5€!";
			languagestrings['en']['premiumbuy'] = "Buy";
			languagestrings['en']['nopremiumbuy'] = "No, thanks";
			languagestrings['en']['cost'] = "This file costs ";
			languagestrings['en']['credits'] = " credits";
			languagestrings['en']['buy'] = "Watch now";
			languagestrings['en']['notenoughcredits'] = "You don't have enough credits, go to your account to add credits";
			languagestrings['en']['watchpreview'] = "Buy now or watch a preview by hitting the play button";
			languagestrings['en']['errorreadingfile'] = "there was an error playing this file";
			languagestrings['en']['errorStreamNotFound'] = "error StreamNotFound (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['errorFileStructureInvalid'] = "error FileStructureInvalid (report it on http://forum.cacaoweb.org)";
			languagestrings['en']['filetimeout'] = "cacaoweb could not find this video.<br>Please try again later.";
			
			languagestrings['es'] = new Dictionary();
			languagestrings['es']['pleasewait'] = "Espera, por favor...";
			languagestrings['es']['cacaowebnotrunning'] = "cacaoweb no está instalado";
			languagestrings['es']['cacaowebdownload'] = "Descargar";
			languagestrings['es']['pleaselogin'] = "Please register or log in to continue";
			languagestrings['es']['myaccount'] = "Mi cuenta";
			languagestrings['es']['premium'] = "Watch videos on cacaoweb with no limits, become premium now from only 5€!";
			languagestrings['es']['premiumbuy'] = "Buy";
			languagestrings['es']['nopremiumbuy'] = "No, thanks";
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
			languagestrings['fr']['pleasewait'] = "Merci de patienter pendant le chargement...";
			languagestrings['fr']['cacaowebnotrunning'] = "cacaoweb n'est pas installé";
			languagestrings['fr']['cacaowebdownload'] = "Télécharger";
			languagestrings['fr']['pleaselogin'] = "Merci de vous identifier ou vous enregistrer pour continuer";
			languagestrings['fr']['myaccount'] = "Mon compte";
			languagestrings['fr']['premium'] = "Regardez vos videos sur cacaoweb sans limite, devenez membre premium, à partir de 5€!";
			languagestrings['fr']['premiumbuy'] = "Acheter";
			languagestrings['fr']['nopremiumbuy'] = "Non merci";
			languagestrings['fr']['cost'] = "This file coûte ";
			languagestrings['fr']['credits'] = " crédits";
			languagestrings['fr']['buy'] = "Lancer";
			languagestrings['fr']['notenoughcredits'] = "Vous n'avez pas assez de crédits, aller sur votre compte pour ajouter des crédits";
			languagestrings['fr']['watchpreview'] = "Achetez ou regardez un extrait en cliquant sur le bouton de lecture";
			languagestrings['fr']['errorreadingfile'] = "une erreur s'est produite pendant la lecture de ce media";
			languagestrings['fr']['errorStreamNotFound'] = "erreur StreamNotFound<br>(rapporter le problème sur http://forum.cacaoweb.org)";
			languagestrings['fr']['errorFileStructureInvalid'] = "erreur FileStructureInvalid<br>(rapporter le problème sur http://forum.cacaoweb.org)";
			languagestrings['fr']['filetimeout'] = "cacaoweb n'a pas pu trouver cette vidéo.<br>Vous pouvez réessayer ultérieurement.";

			languagestrings['it'] = new Dictionary();
			languagestrings['it']['pleasewait'] = "Attendere prego...";
			languagestrings['it']['cacaowebnotrunning'] = "cacaoweb non è in esecuzione";
			languagestrings['it']['cacaowebdownload'] = "Scaricalo da";
			languagestrings['it']['pleaselogin'] = "Registrati o fai il Login per continuare";
			languagestrings['it']['myaccount'] = "Mio Account";
			languagestrings['it']['premium'] = "Watch videos on cacaoweb with no limits, become premium now from only 5€!";
			languagestrings['it']['premiumbuy'] = "Buy";
			languagestrings['it']['nopremiumbuy'] = "No, thanks";
			languagestrings['it']['cost'] = "Questo File Costa ";
			languagestrings['it']['credits'] = " crediti";
			languagestrings['it']['buy'] = "Compralo Adesso";
			languagestrings['it']['notenoughcredits'] = "Non hai abbastanza crediti, vai sul tuo account per acquistarli";
			languagestrings['it']['watchpreview'] = "O puoi vedere un anteprima cliccando il tasto Play";
			languagestrings['it']['errorreadingfile'] = "C'è stato un errore guardando questo video";
			languagestrings['it']['watchedwithcacaoweb'] = "Guardato con cacaoweb<br><a href='http://www.cacaoweb.org/'>www.cacaoweb.org</a>";
			languagestrings['it']['errorStreamNotFound'] = "errore StreamNotFound (segnalalo su http://forum.cacaoweb.org)";
			languagestrings['it']['errorFileStructureInvalid'] = "errore FileStructureInvalid (segnalalo su http://forum.cacaoweb.org)";
			languagestrings['it']['filetimeout'] = "cacaoweb non riesce a trovare il video.<br>Ricarica la pagina per riprovare!";

			languagestrings['pl'] = new Dictionary();
			languagestrings['pl']['pleasewait'] = "Proszę czekaj...";
			languagestrings['pl']['cacaowebnotrunning'] = "Cacaoweb nie jest zainstalowany";
			languagestrings['pl']['cacaowebdownload'] = "Pobierz";
			languagestrings['pl']['pleaselogin'] = "Please register or log in to continue";
			languagestrings['pl']['premium'] = "Watch videos on cacaoweb with no limits, become premium now from only 5€!";
			languagestrings['pl']['premiumbuy'] = "Buy";
			languagestrings['pl']['nopremiumbuy'] = "No, thanks";
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