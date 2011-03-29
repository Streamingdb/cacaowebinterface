(* Written by me. This document is distributed under the terms of the recursive license *)

open Printf
module M = Mediautils
module T = Tcptransaction

(** foncteur de Swarming car c'est la que se connectent les viewers, foncteurs de Exchange pour gerer la DHT *)
module HTTP_Server ( E : Exchange.ExchangeInterface ) ( L : Tcplisteningsocket.TCPServerInterface ) ( A : Ads.AdsManagerInterface ) ( F : Fileswarming.FileSwarmerInterface )
             ( Test : Testing.TesterInterface ) ( V : Downloadmanager.DownloaderInterface ) ( BB : Downloadmanager.DownloaderInterface ) ( S : Platform.StorageInterface ) = 
struct
  type typeplayer = WMP | VLC | Other
  type connectionstate = Accepted | RequestReceived | HeadersSent | Terminated | ToErase
  type containertype = MP4 | FLV | Generic | Meta
  type typeswarmingrequest = Channel | File
  type mediatype = Audio | Video
  (*type swarming = 
      {
        mutable channelid: string;
        mutable currentprogramid: string option;
        mediatype: mediatype;
        typerequest: typeswarmingrequest;       
        mutable posinstream: int; (* only useful with player = WMP *)
        mutable justcutmetadata: bool; (* only useful with player = WMP *)
        mutable firstchunkid: int;
        launchplayer: typeplayer option;
      }*)
  type feedercategory = Ad | FileSwarming of (string * containertype) | Megavideo of (string * containertype) | MegavideoStatus of string | Videobb of (string * containertype)
  type connection =
      {
        socket: Unix.file_descr;
        packetstobewritten: string Queue.t;
        mutable feeder: feedercategory option;
        mutable browser: string;
        mutable player: typeplayer;
        mutable lasttimepacketwritten: float;
        timecreated: float;
        mutable timeterminated: float;
        mutable connectionstate: connectionstate;
      }

  type httprequest = 
      {
        requesttype: string;
        path: string list; (* le chemin de la requete *)
        file: string; (* le fichier demande (index.html, debug.caml, etc.) *)
        parameters: (string * string) list; (* les parametres passes dans l'url *)
        playerid: typeplayer;
        useragent: string; (* pour l'instant on ne fait que detecter si c'est Firefox *)
      }
  
  
  let timeoutStalledConnection = 3.0 *. 3600.0 (* temps maximum ou rien n'est envoye sur une connexion *)
  let timeoutChannelConnection = 25.0
  let keepAliveTimeout = 5.0
                         
  let timerDoTasks = ref 0.0
  let timerDoTasksInterval = 0.2
                         
  let connections = ref [] (* list assoc socket -> connectiondetails *)

  
  let query_string http_frame = (* transforme la chaine de caracteres en type httprequest *)
    try
      let pos1 = String.index http_frame ' ' in (* on prend l'espace qui doit etre apres le GET dans la frame http *)
      let httpmethod = Utils.prefix http_frame pos1 in
        (match httpmethod with
             ("GET" | "HEAD" | "POST" | "OPTIONS") -> 
           (*assert (printf "%s\n" http_frame; true);*)
           let posurl = pos1 + 1 in
           let posendurl = Utils.indexoffrom "HTTP" http_frame posurl in 
           let req = String.sub http_frame posurl (posendurl - 1- posurl) in
           let (url, parameters) = 
             if String.contains req '?' then 
               (let p = String.index req '?' in
                let params = Utils.split (Utils.suffix req (p + 1)) '&' in 
                  (Utils.prefix req  p, List.map (fun s -> let pos = String.index s '=' in (Utils.prefix s pos, Utils.suffix s (pos+1))) 
                                          (List.filter (fun s -> String.contains s '=') params)))
             else
               (req, []) in 
            let args = Array.of_list (Utils.split url '/') in (* le chemin *)
            let file = args.(Array.length args - 1) in 
            let path = List.map Utils.decode (match Array.to_list (Array.sub args 0 (Array.length args - 1)) with t :: q -> q | [] -> []) in 
            let playerid = if Utils.indexof "NSPlayer" http_frame > -1 then WMP else Other in
              (*assert(printf "parameters are ";  List.iter (fun (a, b) -> printf "%s = %s" a b) parameters; printf "\n"; true); *)
              (*assert (printf "player is %s\n" (match playerid with WMP -> "WMP" | VLC -> "VLC" | Other -> "Other"); true);*)
              Some { requesttype = httpmethod; path = path; file = file; parameters = parameters; playerid = playerid; 
                         useragent = if Utils.indexof "Firefox" http_frame > -1 then "Firefox" else "Unknown"; }
          | _ -> None)
    with _ -> None

  let http_playlistheader = "HTTP/1.1 200 OK\r\n" ^
                            (*"Keep-Alive: timeout=5, max=100\r\n" ^
                            "Connection: Keep-Alive\r\n" ^*)
                            "Content-type: audio/x-mpegurl\r\n"^
                            "Content-Length: "
                              
  let http_videoheader = "HTTP/1.1 200 OK\r\n" ^
               "Keep-Alive: timeout=5, max=100\r\n" ^ (* TODO: cette ligne est surement inutile *)
               "Connection: Keep-Alive\r\n" ^
               "Content-type: video/mpeg\r\n" ^
               "Content-Length: "  (* don't forget to put some value there, as WMP never starts otherwise *)
               (*"\r\n"*)
                              
  (*let http_audioheader = format_of_string "ICY 200 OK\r\nicy-name: %s\r\nContent-type: audio/mpeg\r\nicy-pub: 1\r\nicy-br: 128\r\n\r\n"*)
                           
  (*let http_mp4header = format_of_string "HTTP/1.1 200 OK\r\n\
Connection: Keep-Alive\r\n\
Content-type: video/mp4\r\n\
Content-Length: %Li\r\n\r\n"  *)
  
  let http_downloadheader = format_of_string "HTTP/1.1 200 OK\r\n\
Content-Type: %s\r\n\
Content-Length: %Li\r\n\
Content-Disposition: attachment; filename=\"%s\"\r\n\
Content-Transfer-Encoding: binary\r\n\
Accept-Ranges: bytes\r\n\r\n"  
                             
  let http_genericheader = format_of_string "HTTP/1.1 200 OK\r\n\
Content-Length: %Li\r\n\
Content-Disposition: attachment; filename=\"%s\"\r\n\
Content-Transfer-Encoding: binary\r\n\
Accept-Ranges: bytes\r\n\r\n"
                             
  let http_textheaders = format_of_string "HTTP/1.1 200 OK\r\n\
Vary: Accept-Encoding\r\n\
Content-Length: %i\r\n\
Connection: close\r\n\
Content-Type: text/%s; charset=utf-8\r\n\r\n"
                                             
let http_anyheaders = format_of_string "HTTP/1.1 200 OK\r\n\
Vary: Accept-Encoding\r\n\
Content-Length: %i\r\n\
Connection: close\r\n\
Content-Type: %s\r\n\r\n"
                                
  let http_xmlheaders = format_of_string "HTTP/1.1 200 OK\r\n\
Accept-Ranges: bytes\r\n\
Content-Length: %i\r\n\
Connection: close\r\n\
Content-Type: application/xml; charset=utf-8\r\n\r\n"
                                      
  let http_notfoundheaders = "HTTP/1.1 404 Not Found\r\n\
Content-Length: 0\r\n\
Connection: close\r\n\
Content-Type: text/html\r\n\r\n"

  let playlist host channel = (* pas terrible, seulement pour les enchainements de videos donc *)
    match host with
        Unix.ADDR_UNIX _ -> ""
      | Unix.ADDR_INET (addr, _) -> 
        let httpaddr = "http://" ^ (Unix.string_of_inet_addr addr) ^ ":" ^ (string_of_int !L.boundport) ^ "/" ^ channel ^ "/" in
        let m3ulist = ref "" in
          for i = 0 to 10 do
            m3ulist := !m3ulist ^ httpaddr ^ (string_of_int i) ^ ".mpg\r\n"
          done;
          !m3ulist
        
  let closeandclean conn tcptrans = assert(printf "%f, closing http client connection\n" (Unix.gettimeofday ()); true);
    if conn.connectionstate <> ToErase then
      ((match conn.feeder with 
            Some Megavideo _ -> V.terminateReader conn.socket
          | Some Videobb _ -> BB.terminateReader conn.socket
          | Some MegavideoStatus _ -> ()
          | Some Ad -> A.terminateReader conn.socket
          | Some FileSwarming _ -> F.terminateReader conn.socket
          | None -> ());
       T.closeandclean tcptrans;
       conn.connectionstate <- ToErase)

  
  let httprequesthandler conn tcptrans =
    let request = Mybuffer.contents tcptrans.T.currentread in 
    match query_string request with 
        Some req when req.requesttype = "OPTIONS" -> 
        assert(printf "received OPTIONS request, sending empty reply\n"; true);
        let emptyreply = sprintf http_textheaders 0 "html" in 
        T.senddata emptyreply tcptrans
      | Some { requesttype = req; path = path; file = file; parameters = parameters; playerid = player; useragent = useragent; } ->
        conn.connectionstate <- RequestReceived;
        if List.length path > 0 then (* requetes pour une channel *)
          (let channel = List.nth path 0 in
            (*assert(printf "received a request for channel = %s\n" channel; true);*)
            (*if not !E.networkinterfaceReady then
              (let msg = "The network interface not ready. Please connect your computer to the network." in 
                 ignore(Unix.send rsock msg 0 (String.length msg) []);
                 closeandclean rsock)
            else*)
              ((*conn.channelid <- Some channel;*) (* TODO *)
               conn.player <- player;
               (*Queue.clear conndetails.mediapacketstobewritten;*)
            match file with (* asking directly for the .m3u file should not happen in normal use *)
                (*("videolist.m3u" | "audiolist.m3u" | "playlist.mp3") as s -> 
             let mediatype = match s with 
                  "videolist.m3u" -> assert (printf "videolist request received\n"; true); Video
                | "audiolist.m3u" -> assert (printf "audiolist request received\n"; true); Audio
                | "playlist.mp3" -> assert (printf "audio playlist request received\n"; true); Audio
                | _ -> failwith "" in 
              let swarmingdetails = { channelid = channel; currentprogramid = None; (*mediapacketstobewritten = Queue.create ();*) mediatype = mediatype; posinstream = 0; 
                                            typerequest = Channel; justcutmetadata = false; firstchunkid = -1; launchplayer = None; } in 
                conn.feeder <- Some (Swarming swarmingdetails);
                if not (S.isConnectedToSwarm channel) then
                  S.joinChannel channel S.Content
              | s when String.length s >= 4 && Utils.suffix s 4 = ".mpg" -> 
              let swarmingdetails = { channelid = channel; currentprogramid = None; (*mediapacketstobewritten = Queue.create ();*) mediatype = Video; posinstream = 0; 
                                            typerequest = File; justcutmetadata = false; firstchunkid = -1; launchplayer = None; } in 
                conn.feeder <- Some (Swarming swarmingdetails)(*;
                if not (S.isConnectedToSwarm channel) then
                  S.joinChannel channel S.Content  *)*)
              | "playlist.smi" -> assert (printf "playlist.smi not supported\n"; true); 
                closeandclean conn tcptrans
              | "isvlcinstalled.html" -> 
                let b = string_of_bool (Platform.checkPlayer ()) in 
                T.senddata b tcptrans (* TODO: il faudrait envoyer des headers corrects ! et verifier la fermeture de la connexion *)
              | "download.caml" -> 
                if List.mem_assoc "downloadid" parameters then 
                  (let downloadid = List.assoc "downloadid" parameters in 
                   if channel = "file" then 
                     (assert (printf "%f, file download request received\n" (Unix.gettimeofday ()); true);
                      conn.feeder <- Some (FileSwarming (downloadid, MP4));
                      F.joinFileSwarm downloadid;
                      if not (F.createReader downloadid conn.socket Int64.zero) then closeandclean conn tcptrans)
                   else if channel = "megavideo" then 
                     (assert (printf "%f, megavideo download request received\n" (Unix.gettimeofday ()); true);
                      conn.feeder <- Some (Megavideo (downloadid, FLV));
                      V.joinSwarm downloadid Int64.zero;
                      V.createReader downloadid conn.socket)
                   else if channel = "videobb" then 
                     (assert (printf "%f, videobb download request received\n" (Unix.gettimeofday ()); true);
                      conn.feeder <- Some (Videobb (downloadid, FLV));
                      BB.joinSwarm downloadid Int64.zero;
                      BB.createReader downloadid conn.socket))
              | "delete.caml" -> 
                if List.mem_assoc "videoid" parameters then (* signifie que c'est pour du megavideo *)
                  (let videoid = List.assoc "videoid" parameters in 
                   if channel = "megavideo" then 
                     V.deleteDownloadedVideo videoid
                   else if channel = "videobb" then 
                     BB.deleteDownloadedVideo videoid)
                else if List.mem_assoc "fileid" parameters then (* signifie que c'est pour du filestreaming *)
                  (let fileid = List.assoc "fileid" parameters in 
                   F.deleteSwarm fileid);
                let data = "OK" in T.senddata ((sprintf http_textheaders (String.length data) "html") ^ data) tcptrans
              | ("runvideo.html" | "runaudio.html") -> assert (printf "%f, %s requested\n" (Unix.gettimeofday ()) file; true); 
                (*closeandclean conn tcptrans;
                let swarmingdetails = { channelid = channel; currentprogramid = None; (*mediapacketstobewritten = Queue.create ();*) mediatype = Video; posinstream = 0; 
                                            typerequest = Channel; justcutmetadata = false; firstchunkid = -1; launchplayer = Some VLC; } in 
                conn.feeder <- Some (Swarming swarmingdetails);
                if not (S.isConnectedToSwarm channel) then
                  S.joinChannel channel S.Content*)
              | "megavideo.caml" -> 
                if List.mem_assoc "videoid" parameters then 
                  (let paramvideoid = List.assoc "videoid" parameters in
                   let startposition = if List.mem_assoc "startposition" parameters then Int64.of_string (List.assoc "startposition" parameters) else Int64.zero in 
                   let pos = Utils.indexof "v=" paramvideoid in
                   let videoid = if pos > -1 then Utils.suffix paramvideoid (pos+2) else paramvideoid in
                   if String.length videoid > 10 then (* l'utilisateur a clairement rentre une mauvaise video *)
                     closeandclean conn tcptrans
                   else
                     (assert (printf "%f, received megavideo request for videoid %s and position %Li\n" (Unix.gettimeofday ()) videoid startposition; true);
                      conn.feeder <- Some (Megavideo (videoid, FLV));
                      conn.browser <- useragent;
                      V.joinSwarm videoid startposition;
                      V.createReader videoid conn.socket))
              | "videobb.caml" -> 
                if List.mem_assoc "videoid" parameters then 
                  (let videoid = List.assoc "videoid" parameters in
                   let startposition = if List.mem_assoc "startposition" parameters then Int64.of_string (List.assoc "startposition" parameters) else Int64.zero in 
                   if String.length videoid > 20 then (* l'utilisateur a clairement rentre une mauvaise video *)
                     closeandclean conn tcptrans
                   else
                     (assert (printf "%f, received videobb request for videoid %s and position %Li\n" (Unix.gettimeofday ()) videoid startposition; true);
                      conn.feeder <- Some (Videobb (videoid, FLV));
                      conn.browser <- useragent;
                      BB.joinSwarm videoid startposition;
                      BB.createReader videoid conn.socket))
              | "megavideostatus.caml" -> (* TODO: si rien ne se passe cette connection ne va jamais etre fermee *)
                if List.mem_assoc "videoid" parameters then 
                  (let paramvideoid = List.assoc "videoid" parameters in
                   let pos = Utils.indexof "v=" paramvideoid in
                   let videoid = if pos > -1 then Utils.suffix paramvideoid (pos+2) else paramvideoid in
                   assert (printf "%f, received request for megavideo status for videoid %s\n" (Unix.gettimeofday ()) videoid; true);
                   conn.feeder <- Some (MegavideoStatus videoid);
                   conn.browser <- useragent;
                   conn.timeterminated <- Unix.gettimeofday ())
              | unknownreq -> 
                (assert (printf "http request not understood: %s ; channel = %s\n" unknownreq channel; true); 
                 closeandclean conn tcptrans)))
       else
         ((match file with 
               "isrunning" -> 
               assert(printf "%f, isrunning request received\n" (Unix.gettimeofday ()); true);
               let script = "Cacaoweb.callbackIsRunning()" in 
               T.senddata ((sprintf http_anyheaders (String.length script) "application/javascript") ^ script) tcptrans
               (*T.senddata ((sprintf http_textheaders (String.length script) "html") ^ script) tcptrans*)
             | "version" -> 
               let version = string_of_int Parameters.version in 
               T.senddata ((sprintf http_textheaders (String.length version) "html") ^ version) tcptrans
             | "digest" -> 
               let digest = Utils.convertToHex (Parameters.mydigest) in 
               T.senddata ((sprintf http_textheaders (String.length digest) "html") ^ digest) tcptrans
             | "getdhtnetworkstatus" -> 
               let result = (match E.getDHTNetworkStatus () with E.NATNotCone -> "NATNotCone" | E.DHTNotConnected -> "DHTNotConnected" | E.DHTConnected -> "DHTConnected") in 
               let xmlmessage = "<?xml version=\"1.0\"?><results><isconnectedtodht>" ^ result ^ "</isconnectedtodht></results>" in 
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "gettcpnattype" ->
               let nattype = V.getNATtype () in 
               let xmlmessage = "<?xml version=\"1.0\"?><results><nattype>" ^ nattype ^ "</nattype></results>" in 
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "errors" -> (* integrer toutes les erreurs que l'on peut trouver dans parameters *)
               let result = 
                 if !Parameters.needupdate then 
                   "outdated" 
                 else if !Parameters.errornoudp then
                   "noudp"
                 else if not (S.isSpaceLeft ()) then 
                   "nospaceleft"
                 else if !Parameters.errorpermissioninsendorsendto then
                   "permissionproblem"
                 else if (match E.getDHTNetworkStatus () with E.NATNotCone -> true | (E.DHTNotConnected | E.DHTConnected) -> false) || V.getNATtype () = "Bad" then 
                   "badrouter"
                 else
                   "OK" in 
               let script = "callbackWarnings('" ^ result ^ "')" in 
               T.senddata ((sprintf http_textheaders (String.length script) "html") ^ script) tcptrans
             | "isfirefoxinstalled" -> 
               let result = string_of_bool (Platform.isFirefoxInstalled ()) in 
               T.senddata ((sprintf http_textheaders (String.length result) "html") ^ result) tcptrans
             (*| "statusrequest" -> if List.mem_assoc "channel" parameters then
               let channel = List.assoc "channel" parameters in 
               let (isinstallingplayer, bufferpercentage) = Downloadclient.isInstallingPlayer () in
                 let status =
                   if isinstallingplayer then
                     sprintf "Installing,%i" bufferpercentage
                   else if not (Platform.checkPlayer ()) then
                     "NoPlayerInstalled"
                   else
                     let channelfoundinDHT = E.getStoredInformation channel <> [] in
                     let connected = S.isConnectedToSwarm channel in
                     if not (S.isSwarmRequested channel || connected) then "Failed" 
                     else if connected then "Connected"
                     else if channelfoundinDHT then "Connecting" 
                     else "Searching" in
                 let script = "callbackchannelfollowup('" ^ channel ^ "','" ^ status ^ "')" in 
                 (*assert (printf "status for channel is %s\n" status; true);*)
                   T.senddata ((sprintf http_textheaders (string_of_int (String.length script)) "html") ^ script) tcptrans*)
              | "play.caml" -> 
                if List.mem_assoc "playurl" parameters then 
                  (let playurl = List.assoc "playurl" parameters in 
                   Platform.launchPlayer playurl);
                let xmlmessage = "<?xml version=\"1.0\"?><results>OK</results>" in 
                T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
              | "upload" -> 
                if List.mem_assoc "filepath" parameters then 
                  (let file = List.assoc "filepath" parameters in 
                   assert (printf "%f, upload file request received for file = %s (%s)\n" (Unix.gettimeofday ()) (Utils.decode file) file; true);
                   let b = F.createSeederOrUploaderSwarm (Platform.Storage.Upload (Utils.decode file)) in
                   Parameters.seeding := true;
                   let result = if b then "OK" else "NOK" in 
                   T.senddata ((sprintf http_textheaders (String.length result) "html") ^ result) tcptrans)
                else
                  let result = "NOK" in 
                  T.senddata ((sprintf http_textheaders (String.length result) "html") ^ result) tcptrans
             | "removeupload" -> 
                if List.mem_assoc "f" parameters then 
                  (let fileid = List.assoc "f" parameters in 
                   F.deleteSwarm fileid;
                   T.senddata ((sprintf http_textheaders 2 "html") ^ "OK") tcptrans)
             | "downloads" -> 
               let isplayerinstalled = Platform.checkPlayer () in 
               let downloads = (V.getDownloads ()) @ (BB.getDownloads ()) in 
               let filedownloads = F.getDownloadingFiles () in 
               let xmlplayerstatus = "<playerinstalled>" ^ (string_of_bool isplayerinstalled) ^ "</playerinstalled>" in 
               let xmlmegavideoitems = "<downloaditemslist>" ^ (List.fold_left (fun b (provider, videoid, (len, progress, title)) -> b ^ (sprintf "<downloaditem><videoid>%s\
</videoid><provider>%s</provider><length>%Li</length><progress>%Li</progress><title>" videoid provider len progress) ^ title ^ "</title></downloaditem>") "" downloads) ^ "</downloaditemslist>" in
                let xmlfileitems = "<fileitemslist>" ^ (List.fold_left (fun b (videoid, (len, progress, title)) -> b ^ (sprintf "<fileitem><fileid>%s</fileid><length>%Li</length>\
<progress>%Li</progress><title>%s</title></fileitem>" videoid len progress title)) "" filedownloads) ^ "</fileitemslist>" in
               let xmlmessage = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<results>" ^ xmlplayerstatus ^ xmlmegavideoitems ^ xmlfileitems ^ "</results>" in 
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "uploads" -> 
               let fileuploads = F.getUploadingFiles () in 
               let xmlfileitems = "<fileitemslist>" ^ (List.fold_left (fun b (fileid, (len, title), progress, bw) -> b ^ (sprintf "<fileitem><fileid>%s</fileid><length>%Li</length><progress>%i\
</progress><title>%s</title><bandwidth>%.2f</bandwidth></fileitem>" fileid len progress title bw)) "" fileuploads) ^ "</fileitemslist>" in
               let xmlmessage = "<?xml version=\"1.0\"?><results>" ^ xmlfileitems ^ "</results>" in 
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "openfiledialogforupload" -> 
               Platform.openFileDialog (); 
               let xmlmessage = "<?xml version=\"1.0\"?><results>OK</results>" in 
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "savefbinfo" ->
               if List.mem_assoc "name" parameters && List.mem_assoc "gender" parameters && List.mem_assoc "birthday" parameters then 
                 (let name = List.assoc "name" parameters in 
                  let gender = List.assoc "gender" parameters in 
                  let birthday = List.assoc "birthday" parameters in 
                  assert(printf "%f, name = %s ; gender = %s ; birthday = %s\n" (Unix.gettimeofday ()) (Utils.decode name) gender (Utils.decode birthday); true);
                  A.updatecurrentuserinfo (Utils.decode name) gender (Utils.decode birthday);
                  T.senddata ((sprintf http_anyheaders 0 "text/html") ^ "") tcptrans)
             | "ad" -> 
               assert (printf "%f, ad request received\n" (Unix.gettimeofday ()); true); (* TODO: gerer la langue aussi *)
               let result = match A.requestAd "en" with None -> "NOK" | Some (userid, token) -> sprintf "OKu=%Li&t=%Li" userid token in 
               T.senddata ((sprintf http_textheaders (String.length result) "html") ^ result) tcptrans
             | "getad" -> 
               assert (printf "%f, getad request received\n" (Unix.gettimeofday ()); true);
               if List.mem_assoc "token" parameters then 
                 (let token = try Int64.of_string (List.assoc "token" parameters) with _ -> Int64.zero in
                  (match A.getAd conn.socket token with 
                       Some len ->
                       conn.feeder <- Some Ad;
                       let headers = sprintf http_downloadheader "video/mp4" len "" in 
                       T.senddata headers tcptrans;
                       conn.connectionstate <- HeadersSent
                     | None -> closeandclean conn tcptrans))
               else
                 closeandclean conn tcptrans
             | "fileinfo" -> 
               if List.mem_assoc "f" parameters && List.mem_assoc "request" parameters then 
                 (let fileid = List.assoc "f" parameters in 
                  let request = List.assoc "request" parameters in 
                  if request = "title" then 
                    (assert(printf "%f, received request for title of file %s\n" (Unix.gettimeofday ()) fileid; true);
                     F.joinFileSwarmForMeta fileid;
                     conn.feeder <- Some (FileSwarming (fileid, Meta))))
             | ("index.html" | "index" | "") -> 
               if List.mem_assoc "f" parameters then 
                 (let fileid = String.uppercase (List.assoc "f" parameters) in 
                  if String.length fileid = 32 then 
                    (let startposition = if List.mem_assoc "startposition" parameters then Int64.of_string (List.assoc "startposition" parameters) else Int64.zero in 
                     assert (printf "%f, file request received for position %Li\n" (Unix.gettimeofday ()) startposition; true);
                     conn.player <- player;
                     conn.feeder <- Some (FileSwarming (fileid, Generic));
                     F.joinFileSwarm fileid;
                     if not (F.createReader fileid conn.socket startposition) then closeandclean conn tcptrans)
                  else
                    closeandclean conn tcptrans)
               else 
                 (assert (printf "%f, index page was sent\n" (Unix.gettimeofday ()); true);
                  T.senddata ((sprintf http_textheaders (String.length Htmlpages.indexpage) "html") ^ Htmlpages.indexpage) tcptrans)
             | "admin.html" -> 
               assert (printf "%f, admin page was sent\n" (Unix.gettimeofday ()); true);
               T.senddata ((sprintf http_textheaders (String.length Htmlpages.adminpage) "html") ^ Htmlpages.adminpage) tcptrans
             | "crossdomain.xml" -> 
               assert (printf "received request for crossdomain.xml\n"; true);
               let crossdomaintext = "<?xml version=\"1.0\"?>\n<!DOCTYPE cross-domain-policy SYSTEM\n\"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\">\
\n\n<cross-domain-policy>\n\t<site-control permitted-cross-domain-policies=\"master-only\"/>\n\t\
<allow-access-from domain=\"*\"/>\n\t<allow-http-request-headers-from domain=\"*\" headers=\"*\"/>\n</cross-domain-policy>" in 
               let data = (sprintf http_xmlheaders (String.length crossdomaintext)) ^ crossdomaintext in
               T.senddata data tcptrans
             | "exit.html" -> 
               let ad = Unix.getsockname conn.socket in
               (match ad with 
                    Unix.ADDR_INET(x, _) -> 
                    if Unix.string_of_inet_addr x = "127.0.0.1" then 
                      (assert (printf "exit command received from localhost, exiting\n"; true);
                       closeandclean conn tcptrans;
                       exit 0)
                  | _ -> ())
             | "uninstall.html" -> 
               let ad = Unix.getsockname conn.socket in
               (match ad with 
                    Unix.ADDR_INET(x, _) -> 
                    if Unix.string_of_inet_addr x = "127.0.0.1" then 
                      (assert (printf "uninstall command received from localhost, exiting\n"; true);
                       closeandclean conn tcptrans;
                       Platform.unInstall ();
                       exit 0)
                  | _ -> ())
             | "style.css" -> assert (printf "sending style page\n"; true);
                               T.senddata ((sprintf http_textheaders (String.length Htmlpages.style) "css") ^ Htmlpages.style) tcptrans
             | "languagestrings.js" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.languagestrings) "css") ^ Htmlpages.languagestrings) tcptrans
             | "player.swf" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.player) "swf") ^ Htmlpages.player) tcptrans
             | "bgpattern.png" -> assert (printf "sending bgpattern file\n"; true);
                               T.senddata ((sprintf http_textheaders (String.length Htmlpages.bgpattern) "png") ^ Htmlpages.bgpattern) tcptrans
             | "logo.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.logo) "png") ^ Htmlpages.logo) tcptrans
             | "tab.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.tab) "png") ^ Htmlpages.tab) tcptrans
             | "inputbox.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.inputbox) "png") ^ Htmlpages.inputbox) tcptrans
             | "launchbutton.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.launchbutton) "png") ^ Htmlpages.launchbutton) tcptrans
             | "playershadow.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.playershadow) "png") ^ Htmlpages.playershadow) tcptrans
             | "progressbar.gif" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.progressbar) "gif") ^ Htmlpages.progressbar) tcptrans
             | "progressbg_green.gif" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.progressbg_green) "gif") ^ Htmlpages.progressbg_green) tcptrans
             | "progressbg_red.gif" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.progressbg_red) "gif") ^ Htmlpages.progressbg_red) tcptrans
             | "progressbg_orange.gif" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.progressbg_orange) "gif") ^ Htmlpages.progressbg_orange) tcptrans
             | "jquery.progressbar.min.js" -> 
               T.senddata ((sprintf http_textheaders (String.length Htmlpages.jqueryprogressbar) "javascript") ^ Htmlpages.jqueryprogressbar) tcptrans
             | "VLC.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.vlcicon) "png") ^ Htmlpages.vlcicon) tcptrans
             | "b_drop.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.deleteicon) "png") ^ Htmlpages.deleteicon) tcptrans
             | "download.png" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.downloadicon) "png") ^ Htmlpages.downloadicon) tcptrans
             | "debug.caml" -> assert (printf "sending debug page\n"; true);
                                T.senddata ((sprintf http_textheaders (String.length Htmlpages.debugpage) "html") ^ Htmlpages.debugpage) tcptrans
             | "ping.caml" -> assert (printf "received ping request\n"; true);
               if List.mem_assoc "host" parameters then
                 E.sendPing (List.assoc "host" parameters);
               T.senddata ((sprintf http_xmlheaders 2) ^ "OK") tcptrans
             | "pongs.caml" -> (*assert (printf "pong request received\n"; true);*)
                let addpongs a (source, dest, roundtriptime) = 
                  a^"<pong><src>"^source^"</src><dest>"^dest^"</dest><roundtrip>"^(sprintf "%.3f" roundtriptime) ^ "</roundtrip></pong>" in
                let xmlmessage = (List.fold_left addpongs "<?xml version=\"1.0\"?><root>" !E.pongslist) ^ "</root>" in
                T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans;
                (*assert (printf "%i bytes written to http client\n" len; true)*)
                E.pongslist := []
             | "dhtkeypush.caml" -> 
               if List.mem_assoc "key" parameters && List.mem_assoc "value" parameters then
                 (let key = List.assoc "key" parameters in 
                  let value = List.assoc "value" parameters in 
                  assert(printf "%f, push request for key %s received from http client\n" (Unix.gettimeofday ()) key; true);
                  E.pushInformationInDHT key [E.Column ("test", [{ E.value = value; ttl = 120; }; ]); ]);
               T.senddata ((sprintf http_xmlheaders 2) ^ "OK") tcptrans
             | "dhtkeysearch.caml" -> 
               if List.mem_assoc "key" parameters then
                 (let key = List.assoc "key" parameters in 
                  assert(printf "%f, search request for key %s received from http client\n" (Unix.gettimeofday ()) key; true);
                  E.searchInformationInDHT key [E.Column ("test", E.Values); ]);
               T.senddata ((sprintf http_xmlheaders 2) ^ "OK") tcptrans
             | "tcpconnect.caml" -> 
               if List.mem_assoc "peer" parameters then 
                 (let peer = List.assoc "peer" parameters in 
                  assert(printf "%f, tcpconnect request received to peer %s from http client\n" (Unix.gettimeofday ()) peer; true);
                  Test.connecttopeer peer);
               T.senddata ((sprintf http_xmlheaders 2) ^ "OK") tcptrans
             | "tcpconnectresults.caml" -> 
               let results = Test.queryresults () in 
               let xmlmessage = "<?xml version=\"1.0\"?><root>" ^ (List.fold_left (fun b a -> b ^ "<datareceived>" ^ a ^ "</datareceived>") "" results) ^ "</root>" in
               T.senddata ((sprintf http_xmlheaders (String.length xmlmessage)) ^ xmlmessage) tcptrans
             | "favicon.ico" -> T.senddata ((sprintf http_textheaders (String.length Htmlpages.favicon) "ico") ^ Htmlpages.favicon) tcptrans
             | f -> 
               (assert (printf "file '%s' not found\n" f; true); 
                T.senddata http_notfoundheaders tcptrans));
                                                                   
         match file with 
             ("isrunning" | "version" | "errors" | "favicon.ico" | "crossdomain.xml" | "admin.html" | "savefbinfo" | "ad" | "style.css" | "bgpattern.png" | "play.caml") -> 
             conn.connectionstate <- Terminated;
             conn.timeterminated <- Unix.gettimeofday ()      
             | _ -> ())
      | None -> 
        (assert (printf "http request not recognized as valid request, request was %s\n" request; true);
         closeandclean conn tcptrans)
                       
  let processReceivedData tcptrans len = 
    (*assert (printf "%f, received %i bytes on http server\n" (Unix.gettimeofday ()) len; true);*)
    let conn = List.hd (List.filter (fun conn -> conn.socket = tcptrans.T.socket && conn.connectionstate <> ToErase) !connections) in 
    let buf = Mybuffer.contents tcptrans.T.currentread in
    (*assert (printf "%f, data is %s\n" (Unix.gettimeofday ()) buf; true);*)
    if Utils.indexof "\r\n\r\n" buf > -1 then 
      ((*assert (printf "%f, request received for %s, handling it\n" (Unix.gettimeofday ()) buf; true);*)
       httprequesthandler conn tcptrans;
       Mybuffer.clear tcptrans.T.currentread)
  
  let writeConnectionData conn = 
    match conn.connectionstate with 
        (Accepted | ToErase | HeadersSent | Terminated) -> ()
      | RequestReceived -> 
        (match conn.feeder with 
             (*Some (Swarming details) -> 
           if not conn.headerssent then 
             (if S.isConnectedToSwarm details.channelid then (* on est connecte au swarm lorsqu'on recoit tous les modulos *)
               (assert(printf "channel %s now connected in checkPendingChannelTransaction\n" details.channelid; true); 
                (match details.launchplayer with 
                     Some _ -> () (* launchPlayer req *) (* TODO *)
                   | None -> 
                     let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in 
                     (match details.mediatype with
                          Video -> 
                        let m3ulist = playlist (Unix.getsockname conn.socket) details.channelid in
                        let data = http_playlistheader ^ string_of_int (String.length m3ulist) ^ "\r\n\r\n" ^ m3ulist ^ "\r\n" in
                          T.senddata data tcptrans;
                          assert(printf "playlist header sent to http client\n"; true)
                        | Audio -> 
                          let requestaddr = "http://" ^ (match Unix.getsockname conn.socket with Unix.ADDR_INET (ad, _) -> Unix.string_of_inet_addr ad | _ -> "") ^ 
                              ":" ^ (string_of_int !L.boundport) ^ "/" ^ details.channelid ^ "/playlist.mp3\r\n\r\n" in
                          let data = http_playlistheader ^ (string_of_int (String.length requestaddr)) ^ "\r\n\r\n" ^ requestaddr in 
                            T.senddata data tcptrans);
                          conn.headerssent <- true)))
           else
           let data = 
           if not (Queue.is_empty details.mediapacketstobewritten) then 
             (let mediadetails = S.getMediaDetails details.channelid (match details.currentprogramid with None -> failwith "" | Some c -> c) in
              let packet = Queue.pop details.mediapacketstobewritten in
                if packet.S.chunkid = 1 && details.firstchunkid <> 1 then (* si nouvelle video de la playlist: on coupe *)
                  ((*closeandclean sock; *) (* TODO *)
                   "")
                else
                  if details.firstchunkid = -1 && packet.S.chunkid > 0 then (* on doit couper le premier chunk *)
                    let fullchunk = Queue.fold (fun a p -> a ^ (p.S.chunk)) packet.S.chunk details.mediapacketstobewritten in
                    let pos = Mediautils.cut_pos fullchunk mediadetails in
                      if pos > -1 then 
                        (assert (printf "first chunks cut at position %i, next bytes are %s\n" pos (String.sub fullchunk pos 4); true);
                         let firstchunk = ref packet.S.chunk in
                         let i = ref (String.length !firstchunk - 1) in
                           while !i < pos do 
                             let p = Queue.pop details.mediapacketstobewritten in
                               firstchunk := p.S.chunk; (* le firstchunk precedent est jete a la poubelle *)
                               i := !i + String.length p.S.chunk
                           done;
                           assert((if mediadetails.Mediautils.container_format = Mediautils.AVI then let fourcc = String.sub !firstchunk (String.length !firstchunk - 1 - (!i - pos)) 3 in 
                             if fourcc <> "00d" then (printf "%s : BAD CUT!\n" fourcc; flush stdout)); true);
                           details.firstchunkid <- packet.S.chunkid; 
                           details.posinstream <- !i - pos;
                           String.sub !firstchunk (String.length !firstchunk - 1 - (!i - pos)) (!i - pos + 1))
                      else (* on supprime ces paquets car on ne sait pas comment couper *)
                        (assert(printf "packets discarded in httpserver because unable to find synchronization in stream\n"; true);
                         Queue.clear details.mediapacketstobewritten; "")
                  else if conn.player = WMP && details.firstchunkid >= 1 && 
                               mediadetails.M.container_format = M.MP3Stream then (* on supprime les metadatas car WMP ne les comprend pas *)
                    (let i = ref ((mediadetails.Mediautils.media_size - (details.posinstream mod mediadetails.Mediautils.media_size)) mod mediadetails.Mediautils.media_size) in
                     (*printf "i = %i\n" !i;*)
                     let s = ref (String.sub packet.S.chunk 0 (if !i = 0 && details.justcutmetadata then (String.length packet.S.chunk) else (min (String.length packet.S.chunk) !i))) in 
                     let justcutmetadataflag = ref false in
                     (* TODO: supporter le cas ou la metadata s'etale sur plusieurs paquets *)
                     while !i < String.length packet.S.chunk && not details.justcutmetadata do
                       assert(printf "cutting metadata now, metaint = %i. value = %X\n" mediadetails.Mediautils.media_size (int_of_char packet.S.chunk.[!i]); true);
                       (*(try
                        printf "last = %X\n" (int_of_char packet.S.chunk.[!i-1]);
                        printf "next = %X\n" (int_of_char packet.S.chunk.[!i+1]);
                       with
                         _ -> ());*)
                       i := !i + 1 + (int_of_char packet.S.chunk.[!i]) * 16;
                       if !i < String.length packet.S.chunk then 
                         s := !s ^ (String.sub packet.S.chunk !i (min (String.length packet.S.chunk - !i) mediadetails.Mediautils.media_size)) 
                       else 
                         justcutmetadataflag :=  true;
                       i := !i + mediadetails.Mediautils.media_size
                     done;
                     details.justcutmetadata <- !justcutmetadataflag;
                     details.posinstream <- details.posinstream + String.length !s;
                     !s)
                  else 
                    packet.S.chunk) 
           else "" in 
             ignore(data)
             (*conndetails.firstchunkid > -1 ||
              (conndetails.feedertype = Some Swarming && 
                                                    (match conndetails.currentprogramid, conndetails.channelid with
                                                         Some prog, Some chan -> 
                                                    let mediadetails = S.getMediaDetails chan prog in
                                                      ((match mediadetails.M.container_format with (M.MP3 | M.AVI | M.MPG | M.ASF) -> true | _ -> false) || (* TODO: je n'aime pas *)
                                                                             (mediadetails.M.container_format = M.MP3Stream && 
                                                                                let queuesize = Queue.fold (fun a p -> String.length p.S.chunk + a) 0 conndetails.mediapacketstobewritten in
                                                                                 queuesize > 8192 && queuesize > mediadetails.M.media_size * 3))
                                                       | _ -> false))*)
             *)
           | Some (Megavideo (videoid, _)) -> 
             (match V.getVideoMetadata videoid with 
                Some (len, error, title) ->
                assert(printf "%f, megavideo %s now connected in checkPendingMegavideoTransaction, len = %s, title is %s\n" (Unix.gettimeofday ()) videoid (Int64.to_string len) title; true);
                if error = "" then 
                  (assert(printf "%f, writing video header\n" (Unix.gettimeofday ()); true);
                   let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in 
                   T.senddata (sprintf http_downloadheader "video/flv" len title) tcptrans;
                   conn.connectionstate <- HeadersSent)
                else
                  (assert(printf "%f, error %s in this video, closing http connection\n" (Unix.gettimeofday ()) error; true);
                   closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))
              | None -> assert(printf "%f, no metadata received yet for videoid %s\n" (Unix.gettimeofday ()) videoid; true))
           | Some MegavideoStatus videoid -> 
             (match V.getVideoMetadata videoid with
                  Some (_, error, _) ->
                  assert(printf "%f, megavideo %s status now received in checkPendingMegavideoStatusTransaction\n" (Unix.gettimeofday ()) videoid; true);
                  let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in 
                  if error = "" then 
                    (let status = (sprintf http_textheaders 2 "html") ^ "OK" in
                     assert(printf "%f, sending %s to httpclient for megavideo status\n" (Unix.gettimeofday ()) status; true);
                     T.senddata status tcptrans)
                  else
                    (assert(printf "sending megavideo error message in httpserver\n"; true);
                     let data = (sprintf http_textheaders (String.length error) "html") ^ error in
                     T.senddata data tcptrans);
                  conn.connectionstate <- Terminated;
                  conn.timeterminated <- Unix.gettimeofday ()
                | None -> ())
           | Some (Videobb (videoid, _)) -> 
             (match BB.getVideoMetadata videoid with 
                Some (len, error, title) ->
                assert(printf "%f, videobb %s now connected in checkPendingMegavideoTransaction, len = %s, title is %s\n" (Unix.gettimeofday ()) videoid (Int64.to_string len) title; true);
                if error = "" then 
                  (assert(printf "%f, writing video header\n" (Unix.gettimeofday ()); true);
                   let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in 
                   T.senddata (sprintf http_downloadheader "video/flv" len title) tcptrans;
                   conn.connectionstate <- HeadersSent)
                else
                  (assert(printf "%f, error %s in this video, closing http connection\n" (Unix.gettimeofday ()) error; true);
                   closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))
              | None -> assert(printf "%f, no metadata received yet for videoid %s\n" (Unix.gettimeofday ()) videoid; true))
           | Some FileSwarming (fileid, containertype) -> 
             if F.existsSwarm fileid then 
               (match F.getFileMetadata fileid with 
                    Some (filerealname, len) ->
                    assert(printf "%f, file swarming %s now connected, len = %s\n" (Unix.gettimeofday ()) fileid (Int64.to_string len); true);
                    assert(printf "writing header\n"; true);
                    let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in 
                    let headers = match containertype with 
                        MP4 -> sprintf http_downloadheader "video/mp4" len filerealname
                      | FLV -> sprintf http_downloadheader "video/flv" len filerealname
                      | Meta -> (sprintf http_textheaders (String.length filerealname) "html") ^ filerealname
                      | Generic -> sprintf http_genericheader len filerealname in 
                    T.senddata headers tcptrans;
                    conn.connectionstate <- HeadersSent;
                    if containertype = Meta then (* on fait ca juste pour que PHP puisse effectuer des requetes *)
                      (conn.connectionstate <- Terminated;
                       conn.timeterminated <- Unix.gettimeofday () +. 0.5 -. keepAliveTimeout)
                  | None -> ())
           | (Some Ad | None) -> ())

  (*let launchPlayer req = (* lance le player *)
    let url = "http://127.0.0.1:" ^ (string_of_int !L.boundport) ^ "/" ^ req.channelid ^ "/" ^ (match req.mediatype with Video -> "video" | Audio -> "audio") ^ ".mpg"(*"list.m3u"*) in 
      Platform.launchPlayer url*)

  (*let checkPendingChannelNoSocketTransaction trans = (* le player est alors lance automatiquement *)
    if S.isConnectedToSwarm trans.channel then (* on est connecte au swarm lorsqu'on recoit tous les modulos *)
      (assert(printf "channel %s now connected in checkPendingChannelNoSocketTransaction\n" trans.channel; true); 
       match trans.launchplayer with 
           Some _ -> launchPlayer trans;
                     pendingChannelNoSocketTransactions := List.filter (fun tr -> tr <> trans) !pendingChannelNoSocketTransactions
         | None -> () (* par configuration, ne doit pas arriver *));
    if Unix.gettimeofday () -. trans.timecreated > timeoutChannelConnection then 
      pendingChannelNoSocketTransactions := List.filter (fun t -> t <> trans) !pendingChannelNoSocketTransactions
 
  let checkPendingFileTransaction (rsock, req) = (* TODO: que fait on lorsqu'il y a timeout? *)
    if S.isConnectedToSwarm req.channel then
      (assert(printf "channel %s now connected in checkPendingFileTransaction\n" req.channel; true);
       let conndetails = List.hd (List.filter (fun conn -> conn.connectionsocket = rsock && conn.connectionstate <> ToErase) !connections) in
         let programid = S.getCurrentProgramID req.channel in
         conndetails.currentprogramid <- Some programid;
         S.addNewHttpReader rsock req.channel;
         let mediadetails = S.getMediaDetails (match conndetails.channelid with None -> failwith "" | Some c -> c) 
                                          (match conndetails.currentprogramid with None -> failwith "" | Some c -> c) in
         (match req.channeltype with
              Video -> 
                let header = Mediautils.rebuildheader mediadetails in
                let headerpieces = Utils.cutinsmalltcppieces header in (* le header peut etre trop gros pour un paquet tcp donc on le fait passer par petits bouts *)
                  assert(printf "writing video header\n"; true);
                  Queue.push { S.channel = req.channel; chunkid = -1; chunk = http_videoheader^(string_of_int (S.getRemainingVideoSize rsock))^"\r\n\r\n"; } conndetails.mediapacketstobewritten;
                  List.iter (fun chunk -> Queue.push { S.channel = req.channel; chunkid = 0; chunk = chunk } conndetails.mediapacketstobewritten) headerpieces
            | Audio -> 
                if String.length mediadetails.Mediautils.header > 4 && String.sub mediadetails.Mediautils.header 0 3 = "ICY" then (* cas ou la stream est une capture *)
                  Queue.push { S.channel = req.channel; chunkid = -1; chunk = mediadetails.Mediautils.header; } conndetails.mediapacketstobewritten
                else (* cas ou la stream est une concatenation de fichiers *)
                  Queue.push { S.channel = req.channel; chunkid = -1; chunk = sprintf http_audioheader req.channel; } conndetails.mediapacketstobewritten);
         pendingFileRequests := List.remove_assoc rsock !pendingFileRequests)*)

  (*let writetofile data = 
    let fd = Unix.openfile "./file.avi" [Unix.O_WRONLY; Unix.O_APPEND; Unix.O_CREAT] 0o644 in
    let oc = Unix.out_channel_of_descr fd in
      seek_out oc (out_channel_length oc);
      output oc data 0 (String.length data);
      close_out oc*)

  let isbusy () =
    !connections <> []

  let acceptedConnectionHandler sock = 
    assert(printf "%f, connection received on http server\n" (Unix.gettimeofday ()); true);
    connections := { socket = sock; browser = ""; feeder = None; player = Other; lasttimepacketwritten = 0.0; packetstobewritten = Queue.create (); 
                        timecreated = Unix.gettimeofday (); timeterminated = 0.0; connectionstate = Accepted; } :: !connections;
    T.addAcceptedTransaction sock processReceivedData

  let init () = 
    L.registerCallback acceptedConnectionHandler

  let doServer_tasks t = 
    if t -. !timerDoTasks > timerDoTasksInterval then
      (timerDoTasks := t;
       connections := List.filter (fun d -> d.connectionstate <> ToErase) !connections;
       List.iter writeConnectionData !connections;
       (* lorsqu'une connexion n'echange rien pendant 3 heures, elle est terminee *)
       List.iter (fun conn -> if t -. (max conn.lasttimepacketwritten conn.timecreated) > timeoutStalledConnection then 
                    closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions))) (* TODO: le hd se plante *)
         (List.filter (fun conn -> conn.connectionstate <> ToErase && match conn.feeder with Some (Megavideo _ | MegavideoStatus _) -> true | _ -> false) !connections);
       (* remplissage du buffer d'ecriture *)
       List.iter (fun conn -> match conn.feeder with 
                      Some Megavideo (videoid, _) -> 
                      let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in
                      if not (T.iswritequeuefull tcptrans) then 
                        (let l = V.getDataOfReader videoid conn.socket in 
                         List.iter (fun a -> T.senddata a tcptrans) l;
                         conn.lasttimepacketwritten <- Unix.gettimeofday ())
                    | Some Videobb (videoid, _) -> 
                      let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in
                      if not (T.iswritequeuefull tcptrans) then 
                        (let l = BB.getDataOfReader videoid conn.socket in 
                         List.iter (fun a -> T.senddata a tcptrans) l;
                         conn.lasttimepacketwritten <- Unix.gettimeofday ())
                    | Some FileSwarming (fileid, container) -> 
                      if container <> Meta then 
                        let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in
                        if not (T.iswritequeuefull tcptrans) then 
                          (let l = F.getDataOfReader fileid conn.socket in 
                           List.iter (fun a -> T.senddata a tcptrans) l;
                           conn.lasttimepacketwritten <- Unix.gettimeofday ())
                    (*| Some (Swarming details) -> ()
                      let res = S.writeChunksToHTTPBuffers details.channelid conn.socket details.mediapacketstobewritten in
                      (match res with 
                           (S.NoContiguous | S.ContiguousTooSmall | S.Error) -> conn.connectionstate <- ToErase (* TODO: bizarre! *)
                         | S.NewMedia -> 
                           conn.connectionstate <- ToErase; (* on supprime et on relance une transaction de player pour le nouveau media *)
                           (*pendingChannelNoSocketTransactions := { channel = (match details.channelid with None -> failwith "" | Some c -> c); 
                                                                       channeltype = details.mediatype; timecreated = Unix.gettimeofday (); 
                                                                          launchplayer = Some details.player; } :: !pendingChannelNoSocketTransactions*)
                         | _ -> ())*)
                    | Some Ad ->
                      let tcptrans = List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions) in
                      if not (T.iswritequeuefull tcptrans) then 
                        (let l = A.getDataOfReader conn.socket in 
                         List.iter (fun a -> T.senddata a tcptrans) l;
                         conn.lasttimepacketwritten <- Unix.gettimeofday ())
                    | (None | (Some (MegavideoStatus _))) -> ()) (List.filter (fun conn -> conn.connectionstate = HeadersSent) !connections);
       (* on ferme les sockets en HeadersSent correspondant a des feeders qui sont supprimes ou pour certaines autres raisons *)
       List.iter (fun conn -> 
                    (match conn.feeder with 
                         Some (Megavideo (videoid, _)) -> 
                         if not (V.existsSwarm videoid) then 
                           (assert (printf "megavideo swarm %s was removed, closing socket in httpsever\n" videoid; true); 
                            closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))
                       | Some (Videobb (videoid, _)) -> 
                         if not (BB.existsSwarm videoid) then 
                           (assert (printf "videobb swarm %s was removed, closing socket in httpsever\n" videoid; true); 
                            closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))
                       | Some MegavideoStatus _ -> 
                         if t -. conn.timecreated > timeoutChannelConnection then 
                           (assert(printf "timeout for megavideo status request\n"; true);
                            closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))
                       (*| Some (Swarming details) -> ()
                         if not (S.existSwarm details.channelid) then 
                           (assert (printf "closing http server socket bc swarm %s was removed\n" details.channelid; true);
                            closeandclean conn (List.hd (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)))*)
                       | (None | (Some (FileSwarming _ | Ad))) -> ())) (List.filter (fun conn -> conn.connectionstate = HeadersSent) !connections);
       (* on ferme les tcp transactions correspondant aux clients http qui ont ferme *)
       List.iter (fun conn -> if conn.connectionstate <> ToErase then 
                                 List.iter (fun tcptrans -> if T.gettransactionstatus tcptrans = T.Off then 
                                   (assert(printf "%f, transaction closed in tcptransaction, closing socket in httpserver\n" (Unix.gettimeofday ()); true);
                                    closeandclean conn tcptrans)) (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)) !connections;
       (* on ferme les connexions en timeout *)
       List.iter (fun conn -> if conn.connectionstate = Terminated then 
                                 List.iter (fun tcptrans -> if t -. conn.timeterminated > keepAliveTimeout then 
                                   (assert(printf "%f, http transaction timed out, closing socket in httpserver\n" (Unix.gettimeofday ()); true);
                                    closeandclean conn tcptrans)) (List.filter (fun tr -> tr.T.socket = conn.socket) !T.transactions)) !connections)

            
      
end
