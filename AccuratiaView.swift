import SwiftUI // for Views og sånt

// View-en
struct AccuratiaView: View {
    @State private var whoWon = 0 // viser hvem som vant. Er 0 hvis ingen har vunnet, 1 hvis den ene spilleren vant og 2 hvis den andre spilleren vant
    @State private var shouldClick = false // holder styr på om det er meningen at man skal trykke eller ikke
    @State private var startTime = Date() // setter start tiden til hva enn tiden er akkurat nå. Dette vil bli brukt for å finne ut om den rette mengde tid har gått for å gjøre skjermen rød og å gjøre slik at det er meningen at man skal trykke
    @State private var delay = Int.random(in: 2...5) // setter en tilfeldig mengde tid mellom 2 og 5 sekunder som skal forestille hvor lang tid man skal vente. Blir brukt til kalkulasjoner med når man skal trykke.
    @State private var timer: Timer? // trengs for at vi skal kunne skru timeren av og på
    @State private var score1 = 0 // scoren til den ene spilleren
    @State private var score2 = 0 // scoren til den andre spilleren
    
    // det er her selve programmet starter, altså det man kan se på skjermen
    var body: some View {
        // Det er fint å ha en VStack rundt alt i body-en sin, fordi ellers kan man ofte ende opp med flere Views på øverste nivå av body-en. Det som skjer da, er at det kommer ikke noen errors, (fordi det står "some View", som betyr at den støtter flere,) men det blir rart når man kjører den gjennom en Preview, siden den bruker også "some View". Da blir det en visning for hvert View på øverste nivå, istedenfor å vise hele structen. Previews er nyttige for mens man jobber med programmet, fordi da kan man se hvordan det ser ut uten å måtte kjøre appen hver gang.
        VStack {
            if whoWon == 0 { // hvis whoWon == 0, som betyr at ingen har vunnet ennå:
                VStack { // alt her er inni en VStack, bare fordi jeg vil at tingene skal stå oppå hverandre
                    HStack { // De første slike tingene er Scorene, og de har jeg ved siden av hverandre, altså inni en HStack
                        Text(String(score1)) // score1, til den ene spilleren
                        Text(String(score2)) // score2, til den andre
                    }
                    HStack { // resten av tingene på skjermen er på den andre linjen i VStacken, og de er også ved siden av hverandre, altså inni en HStack.
                        
                        // knappen for den blå spilleren (venstre)
                        Button { // det er en knapp for hver side, som lar deg trykke når du ser at det blir rødt, og som får deg til å tape hvis du trykker for tidlig
                            // her inne er det som skjer etter du har trykket
                            if shouldClick { // denne skjekker om det var meningen at du skulle trykke
                                whoWon = 1 // hvis det var, så vinner du
                            } else { // ellers:
                                whoWon = 2 // så taper du
                            }
                        } label: { // dette er hvordan knappen ser ut:
                            Rectangle() // knappen har utsende til et rektangel
                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at kvadratet tar opp så mye plass som den kan
                                .tint(.blue) // farger den blå
                        }
                        
                        Color((shouldClick) ? .red : .yellow) // setter fargen i midten til å bytte utifra om shouldClick er på eller ikke
                        
                        // knappen for den grønne spilleren (høyre)
                        Button {
                            if shouldClick { // denne skjekker om det var meningen at du skulle trykke
                                whoWon = 2 // hvis det var, så vinner du
                            } else { // ellers:
                                whoWon = 1 // så taper du
                            }
                        } label: {  // dette er hvordan knappen ser ut:
                            Rectangle() // knappen har utsende til et rektangel
                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at kvadratet tar opp så mye plass som den kan
                                .tint(.green) // farger den grønn
                        }
                    }
                    //.background(Color((shouldClick) ? .red : .yellow))
                }
                .onAppear { // når VStacken over kommer til syne (den VStacken som er under if-setningen som passer på at spillet pågår), så betyr det at enten, så trykket du in på spillet, eller så trykket du «Play Again» knappen, og i begge tilfellene skal den gjøre det under:
                     Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in // setter en timer som kjører kode hvert sekund
                        if Int((Date().timeIntervalSince(startTime))) - delay >= 0{ // det som skjer hvert sekund, er at den skjekker om delay-tiden har blitt oppnådd, og hvis den har:
                            shouldClick = true // gjør slik at det er meningen at man skal trykke
                        }
                    }
                }
                .onDisappear { // når VStacken forsvinner, så betyr det at en av spillerene vant. I det tilfelle så kjøres koden under:
                    timer?.invalidate() // timeren blir skrudd av, slik at den ikke gjør noe i bakgrunnen mens slutt skjermen er på, og slik at den kan trygt bli skrudd på igjen når de velger å spille igjen.
                }
            } else { // ellers, altså hvis noen har vunnet:
                VStack { // så vil alt være inni en VStack, fordi tingene skal være under hverandre
                    if whoWon == 1 { // hvis det var den blå spilleren som vant:
                        Color.blue // så blir skjermen blå
                    } else { // ellers: (hvis den grønne vant)
                        Color.green // så blir skjermen grønn
                    }
                    Button { // dette er en knapp, fordi du kan trykke på den. Knapper trenger ikke å være en figur, så de kan også være tekst, slik det er her.
                        
                        // gjør slik at neste runde kan skje, med å resette tids-elementene
                        startTime = Date() // setter start tiden til nå
                        delay = Int.random(in: 2...5) // og så setter delay tiden til en tilfeldig tall mellom 2 og 5 sekunder
                        
                        shouldClick = false // gjør slik at det ikke er meningen at du skal trykke lenger, slik at midt fargen kan bli gul, og ikke rød med en gang
                        
                        // så gjør den noe litt fancy her, hvor den trenger ikke engang å vite hvem som vant, men istedenfor bare bruker matte på en slik måte at scoren til en spiller blir plusset med 1 hvis de vant, og med 0 hvis ikke.
                        score1 = score1 + (whoWon - 2 ) * -1 // når det var spiller 1 som vant, så vil whoWon være 1, som skal bety +1, og hvis den tapte vil whoWon være 2, som skal bety 0. Måten jeg gjorde dette på, var med å ta whoWon tallet -2, slik at hvis den er 1 så blir det -1, og hvis det var 2, så blir det 0. Det jeg gjør så, er å gange dette tallet med -1, slik at hvis det var -1 så blir det 1 og hvis det var 0 så blir det fortsatt 0. Nå som jeg har dette tallet, så kan jeg legge det til scoren: 1 hvis vant, 0 hvis tapte.
                        score2 = score2 + whoWon - 1 // med score2 er det mye enklere, for da er whoWon tallet 1 mer enn hvor mye scoren skal adderer med. Derfor bare plusser jeg den med whoWon - 1.
                        whoWon = 0 // til slutt resetter den variabelen for hvem som vant, slik at spillet kan bli spilt igjen, og if-setningen vil oppdage at spillet er ikke over lenger.
                    } label: { // hvordan knappen ser ut:
                        Text("Play Again") // litt tekst som sier «Play again»
                    }
                }
            }
        }
        .onAppear { // når Viewet kommer til syne:
            musicPlayerInst.song = nil // Den stopper sangen som spiller
            if musicPlayerInst.shouldPlayMusic == true { // hvis det er meningen at musikk skal spille:
                musicPlayerInst.song = "Accuratia OST" // spiller sangen til dette spillet
                songDataInst.previousSong = "Accuratia OST" // noterer ned at denne sangen er den sangen som skal spille hvis lyden blir skrudd av og på igjen
            } else { // hvis det er IKKE meningen at musikk skal spille:
                songDataInst.previousSong = "Accuratia OST" // så noterer den ned at dette er sangen som skal spille når musikken blir skrudd på igjen
            }
        }
    }
}
