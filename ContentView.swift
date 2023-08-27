// importer
import SwiftUI // for Views og sånt
import AVFoundation // for å kunne spille musikk i bakgrunnen. All musikk-spillingen foregår her, og alle de andre Swift Filene bare komuniserer bort til denne

// en struct
struct SongData { // En måte å referere til en felles variabel mellom Swift Filer og structs og Views, er med å lage en struct som variabelen er i. Da kan man både endre på den og finne ut hva den inneholder alle steder i programmet.  
    var previousSong: String = "8-bit music" // holder styr på hvilken sang skal spilles hvis lyden  blir skrudd på.
}

var songDataInst = SongData() // hvis jeg hadde brukt selve structen SongData for å få tilgang til variabelen, så ville alle bare lage sine egne kopier av den, og det hadde ikke gått. Derfor må jeg ha en instance av SongData som alle kan referere til, og som startet med verdien inni SongData. Jeg bruker var istedenfor let, fordi jeg endrer på verdier inni den, som tells som å endre på den.

// denne structen er der hvor det faktisk spilles av musikken. NB: musikken ser ikke ut til å spille når jeg ikke hadde hodetelefoner på, så du trenger kanskje bluetooth. idk hvorfor 
struct MusicPlayer {
    private var audioPlayer: AVAudioPlayer? // vi lager en variabel som vi kan bruke til å kontrollere selve sang-spillingen.
    
    var shouldPlayMusic: Bool = false // denne variabelen kan endres fra utsiden, og er om det skal spilles musikk.
    
    var song: String? { // Her setter vi variabelen song med verdien "String?". forskjellen på "String" og "String?" er at hvis det er et spørsmålstegn der, så kan den også ha verdien nil, som betyr at ingen sang skal spilles. Hvis den hadde vært en "String", så hadde den ikke kunne hatt verdien nil, fordi det er ikke en string. 
        didSet { // dette skjer hver gang variabelen får en verdi.
            if let song = song, shouldPlayMusic { // sjekker om at song verdien er ikke nil og at det er meningen at den skal spille musikk 
                // url her er som url på nettet. Det lar oss få tilgang til en fil. Der er det ofte en https fil, mens her er det en mp3 fil, som er den filen med navnet som vi har i song variabelen. Og så guard er for sikkerhets skyld, for det kan oppstå store problemer hvis song verdien ikke er gyldig. 
                guard let url = Bundle.main.url(forResource: song, withExtension: "mp3") else {
                    return 
                }
                
                do { // "do", gjør ikke noe spesielt i seg selv, men den gjør slik at vi kan feste en "catch" etterpå som stopper errors 
                    // Her spiller den sangen
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.numberOfLoops = -1 // -1 betyr, i dette tilfelle, uendelig
                    self.audioPlayer?.play()
                    
                    // hvis noe går feil, så gjør den slik at programmet ikke crasher, men istedenfor bare printer error-meldingen inn i console.
                } catch {
                    print("Error playing music: \(error.localizedDescription)") 
                }
            } else {
                // stopper musikken
                self.audioPlayer?.stop()
                self.audioPlayer = nil
            }
        }
    }
}

var musicPlayerInst = MusicPlayer() // her lager jeg en insans av structen MusicPlayer, for samme grunn som på linje 10.

struct CreditsView: View { // Viewen som viser creditsene til musikk som jeg brukte. Det sto no copyright på alle, men de fleste ønsket også å ha credits. Der sto det ting jeg kunne copy paste inn i descriptionen av en yt video, og dette er ikke en yt video, men jeg tror denne boksen er nært nok.
    var body: some View { // bodyen av viewen. Det er her det skjer
        ScrollView { // alt inni en ScrollView, slik at man kan scrolle.
            Text("\nMusic: (scroll)\n8-bit music in the menu: \nParadrizzle by Sulyya \n\nGridchaser Soundtrack: \nBlack Lotus by Karl Casey @ White Bat Audio \n\nAccuratia Soundtrack: \nTensions Run High by Soundridemusic \nLink to Video: https://www.youtube.com/watch?v=Ly9H63SLJJo \n\nStrategoClick Soundtrack: \nTrack: Assassin by Rafael Krux \nMusic Promoted by Sound Lab Music: https://bit.ly/39P8cAO \n\nElementorum Soundtrack: \nNaglfar, Ship of the Dead by Vindsvept \nLink: https://www.youtube.com/watch?v=CmH04dW98TY") // credits. bruker \n for som en måte å trykke enter i teksten
        }
        .frame(width: 150, height: 50) // hvor stort område den er
    }
}

// selve structen
struct ContentView: View {
    @State private var music = false // om vi har valgt å ha på musikk eller ikke
    @State private var currentOrientation = UIDevice.current.orientation
    
    // body-en: Det vi faktisk ser på skjermen
    var body: some View {
        VStack {
            if currentOrientation.isLandscape {
                // Alt er inni en NavigationView, slik at hvis man er på mobil eller split screen, så skal en NavigationLink få den til å dekke ContentView med den nye Viewen, og det vil komme en tilbakeknapp i top høyre hjørne. Hvis det er på iPad og hel skjerm, så vil ContentView være på venstre side, og mesteparten av skjermen, i midten og til høyre, være den nye Viewen.
                NavigationView {
                    // jeg bruker List til å vise flere forskjellige Views, som er i dette tilfelle NavigationLinks. Da kommer det også en grå boks rundt dem og de får automatisk et lite pil-ikon ved siden av dem. Alt i alt ser det bare bedre ut.
                    List {
                        // Her er lenkene til alle de forskjellige spillene
                        
                        // Gridchaser
                        NavigationLink(destination: GridchaserView()) {
                            Image("Gridchaser logo")
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Accuratia
                        NavigationLink(destination: AccuratiaView()) {
                            Image("Accuratia logo")
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Strategoclick
                        NavigationLink(destination: StrategoclickView()) {
                            Image("Strategoclick logo")
                                .resizable()
                                .scaledToFit()
                        }
                        
                        // Elementorum
                        NavigationLink(destination: ElementorumView()) {
                            Image("Elementorum logo")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    // ting som vises på toppen
                    .navigationBarItems(
                        leading: CreditsView(), // leading betyr til venstre
                        trailing: Button { // trailing betyr til høyre
                            music.toggle() // skrur musikk av og på
                            if music { // hvis musikk er på, så vil den spille musikken og notere at den spilles
                                musicPlayerInst.shouldPlayMusic = true
                                musicPlayerInst.song = songDataInst.previousSong
                            } else { // ... ellers vil den notere den nåværende musikken, slik at den kan bli spilt når musikken blir skrudd på igjen og skru den musikken av
                                songDataInst.previousSong = musicPlayerInst.song ?? "8-bit music"
                                musicPlayerInst.song = nil
                                musicPlayerInst.shouldPlayMusic = false
                            }
                        } label: {
                            // hvordan symbolet ser ut utifra om musikken er på eller ikke
                            if music {
                                Image(systemName: "speaker.wave.2.fill") // lyd på symbolet
                            } else {
                                Image(systemName: "speaker.slash.fill") // lyd av symbolet
                            }
                        }
                    )
                }
            } else {
                Text("Please keep the screen in landscape mode! (sorry)")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            currentOrientation = UIDevice.current.orientation
        }
    }
}
extension UIDeviceOrientation {
    var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }
}
