import SwiftUI // importerer denne slik at Views og sånt funker

// View-en
struct StrategoclickView: View { 
    let columnLayout = Array(repeating: GridItem(.flexible()), count: 3) // for å kunne lage grid
    
    // fargelistene for de 2 spillerene, som viser hvilken farge hver rute skal ha
    @State private var colors = [Color.blue, .blue, .blue, .blue, .red, .blue, .blue, .blue, .blue]  // til spiller 1/venstre spiller/blå spiller
    @State private var colors2 = [Color.green, .green, .green, .green, .yellow, .green, .green, .green, .green] // til spiller 2/høyre spiller/grønn spiller
    
    // scorene til de to spillerene, som viser hvor mange ganger de har trykket
    @State private var score = 0 // til spiller 1
    @State private var score2 = 0 // til spiller 2
    
    @State private var whoWon = 0 // viser hvem som vant. Er 0 hvis ingen har vunnet, 1 hvis den ene spilleren vant og 2 hvis den andre spilleren vant
    @State private var pleaseEnd = false // hvis det er slik at den ønsker at spillet skal bli ferdig, men begge har like høy score, så setter den denne variabelen til true slik at hele brettet blir slik at når noen trykker, så vinner de
    
    // ultiScorene holder styr på hvor mange spill de har vunnet, og ikke bare antall trykk.
    @State private var ultiScore1 = 0 // til spiller 1
    @State private var ultiScore2 = 0 // til spiller 2
    
    // det som er på skjermen, skjer inni her:
    var body: some View {
        
        // Det er fint å ha en VStack rundt alt i body-en sin, fordi ellers kan man ofte ende opp med flere Views på øverste nivå av body-en. Det som skjer da, er at det kommer ikke noen errors, (fordi det står "some View", som betyr at den støtter flere,) men det blir rart når man kjører den gjennom en Preview, siden den bruker også "some View". Da blir det en visning for hvert View på øverste nivå, istedenfor å vise hele structen. Previews er nyttige for mens man jobber med programmet, fordi da kan man se hvordan det ser ut uten å måtte kjøre appen hver gang. I tillegg til dette vil en VStack gjøre slik at «Play Again» knappen kommer under fargen som viser hvem som vant.
        VStack { 
            if whoWon != 0 { // hvis noen har vunnet:
                if whoWon == 2 { // hvis spiller 2 har vunnet:
                    Color.green // så blir skjermen grønn
                } else { // ellers (altså hvis spiller 1 har vunnet):
                    Color.blue // blir skjermen blå
                }
                // dette er en knapp, fordi du kan trykke på den. Knapper trenger ikke å være en figur, så de kan også være tekst, slik det er her.
                Button {
                     colors = [Color.blue, .blue, .blue, .blue, .red, .blue, .blue, .blue, .blue]  // resetter venstre brett
                    colors2 = [Color.green, .green, .green, .green, .yellow, .green, .green, .green, .green] // resetter høyre brett
                    
                    self.pleaseEnd = false // setter pleaseEnd til false, slik at neste spill kan starte uten at den med en gang blir ferdig når noen trykker.
                    
                    // så gjør den noe litt fancy her, hvor den trenger ikke engang å vite hvem som vant, men istedenfor bare bruker matte på en slik måte at scoren til en spiller blir plusset med 1 hvis de vant, og med 0 hvis ikke.
                    ultiScore1 = ultiScore1 + (whoWon - 2 ) * -1 // når det var spiller 1 som vant, så vil whoWon være 1, som skal bety +1, og hvis den tapte vil whoWon være 2, som skal bety 0. Måten jeg gjorde dette på, var med å ta whoWon tallet -2, slik at hvis den er 1 så blir det -1, og hvis det er 2, så blir det 0. Det jeg gjør så, er å gange dette tallet med -1, slik at hvis det var -1 så blir det 1 og hvis det var 0 så blir det fortsatt 0. Nå som jeg har dette tallet, så kan jeg legge det til scoren: 1 hvis vant, 0 hvis tapte.
                    ultiScore2 = ultiScore2 + whoWon - 1 // med score2 er det mye enklere, for da er whoWon tallet 1 mer enn hvor mye scoren skal adderes med. Derfor bare plusser jeg den med whoWon - 1.                        
                    // setter score 1 og 2 til 0 slik at neste spill kan starte med helt nye tall
                    score = 0
                    score2 = 0
                    
                    whoWon = 0 // til slutt resetter den variabelen for hvem som vant, slik at spillet kan bli spilt igjen, og if-setningen vil oppdage at spillet er ikke over lenger.
                } label: { // dette er hvordan knappen ser ut:
                    Text("Play Again") // litt tekst som sier «Play again»
                }
            } else { // ellers, altså hvis spillet fortsatt pågår:
                HStack { // denne HStacken gjør slik at de to brettene med sine scores og wins kommer ved siden av hverandre
                    VStack { // dette er for det første brettet, og den gjør slik at wins og score kommer over og under brettet
                        Text("Wins: \(ultiScore1)") // her vises hvor mange ganger spilleren har vunnet
                        if pleaseEnd { // hvis den er uavgjort på slutten slik at alle rutene er lov å trykke på
                            Text("Click anywhere to win!") // så står det over at du kan trykke hvor som helst for å vinne
                        }
                        LazyVGrid(columns: columnLayout) { // det brukes en LazyVGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                            ForEach (0..<9, id: \.self) {     i in // en ForEach loop er for når man skal vise mange like ting på skjermen, eller ting som er nesten like.
                                
                                // lager en knapp
                                Button { // alle rutene på brettet er knapper, fordi noe skal skje når man trykker på dem.
                                    if colors[i] == Color.red {  // dette er det venstre brettet til den blå spilleren, så hvis den er rød:
                                        score += 1 // så skal scoren plusses med 1
                                        if pleaseEnd { // men hvis pleaseEnd er true, så betyr det jo at de nettop vant derfor:
                                            whoWon = 1 // oppdaterer den variabelen slik at spiller 1 vant
                                        }
                                    } else { // ellers: (hvis den er blå, altså det er ikke den vi skal trykke på)
                                        if score < 0 { // jeg vil at det skal ikke være altfor vanskelig å komme seg opp til et positivt tall, så derfor gjør jeg slik at hvis scoren er mindre enn 0 og man trykket feil:
                                            score -= 1 // så mister man bare 1 score.
                                        } else { // ellers (altså hvis det er et positivt tall eller 0)
                                            score -= 10 // så vil scoren subtraheres med 10
                                        }
                                    }
                                } label: { // dette er hvordan knappen ser ut:
                                    RoundedRectangle(cornerRadius: 4) // den er et rektangel, med rundete hjørner.
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // de er laget til å være så store de kan være, mens de samtidig er kvadrater
                                        .foregroundColor(colors[i]) // fargen deres er fargen på listen som tilsvarer denne ruten
                                }
                            }
                        }
                        Text("Score: \(score)") // under brettet står scoren, som er antall trykk
                    } // dette her er slutten på VStacken
                    VStack {  // så nå begynner neste VStack, som er neste kombinasjon med brett og score. Denne ligger inni HStacken, som vil si at den ligger ved siden av den andre
                        Text("Wins: \(ultiScore2)") // // her vises hvor mange ganger spilleren har vunnet
                        if pleaseEnd { // hvis den er uavgjort på slutten slik at alle rutene er lov å trykke på
                            Text("Click anywhere to win!") // så står det over at du kan trykke hvor som helst for å vinne
                        }
                        LazyVGrid(columns: columnLayout) { // det brukes en LazyVGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                            ForEach (0..<9, id: \.self) { i in // en ForEach loop er for når man skal vise mange like ting på skjermen, eller ting som er nesten like.
                                
                                // lager en knapp
                                Button { // alle rutene på brettet er knapper, fordi noe skal skje når man trykker på dem.
                                    if colors2[i] == Color.yellow { // dette er det høyre brettet til den grønne spilleren, så hvis den er gul:
                                        score2 += 1 // så skal scoren plusses med 1
                                        if pleaseEnd { // men hvis pleaseEnd er true, så betyr det jo at de nettop vant derfor:
                                            whoWon = 2 // oppdaterer den variabelen slik at spiller 2 vant
                                        }
                                    } else { // ellers (hvis den er grønn, altså det er ikke den vi skal trykke på)
                                        if score2 < 0 { // jeg vil at det skal ikke være altfor vanskelig å komme seg opp til et positivt tall, så derfor gjør jeg slik at hvis scoren er mindre enn 0 og man trykket feil:
                                            score2 -= 1 // så mister man bare 1 score.
                                        } else { // ellers (altså hvis det er et positivt tall eller 0)
                                            score2 -= 10 // så vil scoren subtraheres med 10
                                        }
                                    }
                                } label: { // dette er hvordan knappen ser ut:
                                    RoundedRectangle(cornerRadius: 4) // den er et rektangel, med rundete hjørner.
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // de er laget til å være så store de kan være, mens de samtidig er kvadrater
                                        .foregroundColor(colors2[i]) // fargen deres er fargen på listen som tilsvarer denne 
                                }
                            }
                        }
                        Text("Score: \(score2)") // under brettet står den scoren, som er antall trykk
                    } // dette er slutten på den andre VStacken
                } // og dette er slutten på HStacken rundt dem
                .onAppear { // når HStacken kommer til syne, 
                    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in // så setter den en timer som aktiverer etter 5 seknder
                        // begge listene blir shufflet, slik at der hvor du skal trykke endrer seg til et tilfeldig sted                    
                        colors.shuffle()
                        colors2.shuffle()
                        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in // så setter den igjen en timer som aktiverer etter 5 sekunder
                            // begge listene blir shufflet, slik at der hvor du skal trykke endrer seg til et tilfeldig sted                    
                            colors.shuffle()
                            colors2.shuffle()
                            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in // så setter den enda en timer som aktiverer etter 5 sekunder
                                // begge listene blir shufflet for siste gang                    
                                colors.shuffle()
                                colors2.shuffle()
                                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in // så blir den siste timeren satt
                                    if score > score2 { // når den er ferdig, skjekker den hvem som vant
                                        whoWon = 1 // hvis spiller 1 vant, så blir whoWon oppdatert til det
                                    } else if score < score2 { // hvis spiller 2 vant:
                                        whoWon = 2 // så blir whoWon oppdatert til det
                                    } else { // ellers, hvis uavgjort
                                        pleaseEnd = true // så setter den denne variabelen til true, som betyr at den neste som trykker på brettet sitt vinner
                                        
                                        // gjør at begge brettene blir helt fylt med en farge, slik at det skal være lettere for dem å vinne fort
                                        colors = [Color](repeating: .red, count: 9)
                                        colors2 = [Color](repeating: .yellow, count: 9)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.65, height: UIScreen.main.bounds.height * 0.75)
            }
        }
        .onAppear { // når Viewet kommer til syne:
            musicPlayerInst.song = nil // Den stopper sangen som spiller
            if musicPlayerInst.shouldPlayMusic == true { // hvis det er meningen at musikk skal spille:
                musicPlayerInst.song = "StrategoClick OST" // spiller sangen til dette spillet
                songDataInst.previousSong = "StrategoClick OST" // noterer ned at denne sangen er den sangen som skal spille hvis lyden blir skrudd av og på igjen
            } else { // hvis det er IKKE meningen at musikk skal spille:
                songDataInst.previousSong = "StrategoClick OST" // så noterer den ned at dette er sangen som skal spille når musikken blir skrudd på igjen
            }
        }
    }
}

