import SwiftUI // for Views og sånt

// View-en
struct GridchaserView: View {
    // for å kunne lage grid 
    let rowLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)
    
    // listene med booleans som viser om man skal trykke der eller ikke 
    @State var rightBoard = [Bool](repeating: false, count: 24)
    @State var leftBoard = [Bool](repeating: false, count: 24)
    
    // Brukes for å sjekke om listene er like og for å finne ut hvem som vant
    @State private var firstClick = true // brukes for å passe på at det har blitt trykket før det sjekker om listene er like
    @State private var correspondingButtonPressed = false // for å sjekke om det har blitt trykket likt
    @State private var lastClicked = 2 // for å sjekke hvem som trykket sist, fordi hvis de er like, så vil den som trykket sist ha vunnet. 2 betyr ingen, 1 betyr spiller 1, og 0 betyr spiler 0.
    
    // teller hvor mange ganger vunnet
    @State private var score1 = 0 
    @State private var score2 = 0
    
    // Brukes for å finne ut om man har lov til å trykke
    @State private var lastClickTimeLeft = Date()
    @State private var lastClickTimeRight = Date()
    
    @State private var safeZoneNum = 0 // for å få toppen og bunnen til å bytte
    
    let customColor = UIColor(red: 0.2, green: 1.0, blue: 0.6, alpha: 1.0) // lager en egen farge som er en lys grønnfarge. Denne skal brukes til safe zone for den grønne spilleren
    
    @State private var showInstructions: Bool = false // om den skal vise teksten som sier hvordan å spille spillet eller ikke
    @State private var boardDimensions: CGFloat = UIScreen.main.bounds.width * 0.95 // hvor stort brettet er, for når jeg bruker .frame senere i programmet
    
    // selve programmet, i guess:
    var body: some View {
        VStack { // denne trengs for at igjen-knappen er under vinn-skjermen når det skjer 
            if !correspondingButtonPressed { // hvis noen ikke har vunnet ennå
                VStack { // slik at score er under brettet
                    HStack { // slik at brettene er ved siden av hverandre
                        HStack { 
                            // Venstre brett
                            LazyHGrid(rows: rowLayout, spacing: 0) { // det brukes en LazyHGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                                ForEach(0..<24, id: \.self) { i in // en ForEach loop er for når man skal vise mange like ting på skjermen, eller ting som er nesten like.
                                    
                                    // lager en knapp
                                    Button { // alle rutene på brettet er knapper, fordi noe skal skje når man trykker på dem.
                                        let now1 = Date() // setter tiden
                                        let timeInterval1 = now1.timeIntervalSince(lastClickTimeLeft) // timeInterval1 er tiden siden sist trykk
                                        
                                        // disse hjelper meg å passe på logikken, unngå errors og gjøre slik at du ikke kan gå fra den ene siden av mappet til den andre
                                        var ip8 = false // true hvis spilleren er til høyre for ruten
                                        var im8 = false // true hvis spilleren er til venstre for ruten
                                        var ip1 = false // true hvis spilleren er under ruten
                                        var im1 = false // true hvis spilleren er under ruten
                                        
                                        // logikken for å få de variablene over til å representere det jeg sa de skulle være:
                                        if (i+8) < leftBoard.count { 
                                            ip8 = leftBoard[i+8]
                                        } else {
                                            ip8 = false
                                        }
                                        if (i-8) >= 0 {
                                            im8 = leftBoard[i-8]
                                        } else {
                                            im8 = false
                                        }
                                        if (i+1) < leftBoard.count {
                                            ip1 = leftBoard[i+1]
                                        } else {
                                            ip1 = false
                                        }
                                        if (i-1) >= 0 {
                                            im1 = leftBoard[i-1]
                                        } else {
                                            im1 = false
                                        }
                                        
                                        // if setningen som passer på at man kan flytte seg til den ruten som ble trykket på.
                                        if timeInterval1 > 0.5 && ((ip8 || im8 || ip1 || im1) || ((leftBoard == [Bool](repeating: false, count: 24)) && !rightBoard[i])) && (i % 8 != 7 || safeZoneNum == 0) && (i % 8 != 0 || safeZoneNum == 1) {
                                            lastClicked = 1 // hvis man kan, så blir lastClicked satt til 1, som reprisenterer denne spilleren. brukes for å finen ut hvem som vant
                                            leftBoard = [Bool](repeating: false, count: 24) // brettet blir satt til helt blankt
                                            leftBoard[i] = true // og så blir den nye ruten valgt
                                            if rightBoard[i] == leftBoard[i] { // skjekker om spillerene er oppå hverandre
                                                correspondingButtonPressed = true // hvis de er, så settes denne variabelen til true, som betyr at spilelt er over, og if setningen skal bruke denne.
                                            }
                                        }
                                        lastClickTimeLeft = now1 // setter tiden av sist trykk til nå, slik at neste trykk kan bli passet på at den ikke er for tidlig
                                    } label: { // dette er hvordan ruten ser ut:
                                        if leftBoard[i] { // hvis spilleren er der (den grønne)
                                            Rectangle() // knappene har utsende til et rektangel
                                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                                .tint(.yellow) // farger den gul
                                        } else if rightBoard[i] { // ellers, hvis ruten er okkupert av den andre spilleren
                                            Rectangle() // knappene har utsende til et rektangel
                                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                                .tint(.blue) // farger den blå
                                        } else if i % 8 == 7 && safeZoneNum == 0 || i % 8 == 0 && safeZoneNum == 1 { // ellers, hvis det er en av de 3 på bunnen og det er de på bunnen som er grønne eller hvis det er en av de 3 på toppen og det er de på toppen som er de grønne:
                                            Rectangle() // knappene har utsende til et rektangel
                                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                                .tint(Color(customColor)) // farges med den grønnfargen
                                    } else if i % 8 == 7 && safeZoneNum == 1 || i % 8 == 0 && safeZoneNum == 0 { // ellers, hvis ruten er en av de 3 på toppen og det er de på toppen som er blå eller hvis det er en av de på bunnen som blå:
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(.teal) // farges med den blåfargen
                                        } else { // ellers:
                                            Rectangle() // knappene har utsende til et rektangel
                                                .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                                .tint(.green) // farger den grønn
                                        }
                                    }
                                    .padding(1) // de har litt mellomrom mellom dem
                                }
                            }
                        }
                        // Høyre brett
                        LazyHGrid(rows: rowLayout, spacing: 0) { // det brukes en LazyHGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                            ForEach(0..<24, id: \.self) { i in // en ForEach loop er for når man skal vise mange like ting på skjermen, eller ting som er nesten like.
                                // lager en knapp
                                Button { // alle rutene på brettet er knapper, fordi noe skal skje når man trykker på dem.
                                    let now2 = Date() // setter tiden
                                    let timeInterval2 = now2.timeIntervalSince(lastClickTimeRight) // timeInterval2 er tiden siden sist trykk
                                    
                                    var ip8 = false // true hvis spilleren er til høyre for ruten
                                    var im8 = false // true hvis spilleren er til venstre for ruten
                                    var ip1 = false // true hvis spilleren er under ruten
                                    var im1 = false // true hvis spilleren er under ruten
                                    
                                    // logikken for å få de variablene over til å representere det jeg sa de skulle være:
                                    if (i+8) < rightBoard.count {
                                        ip8 = rightBoard[i+8]
                                    } else {
                                        ip8 = false
                                    }
                                    if (i-8) >= 0 {
                                        im8 = rightBoard[i-8]
                                    } else {
                                        im8 = false
                                    }
                                    if (i+1) < rightBoard.count {
                                        ip1 = rightBoard[i+1]
                                    } else {
                                        ip1 = false
                                    }
                                    if (i-1) >= 0 {
                                        im1 = rightBoard[i-1]
                                    } else {
                                        im1 = false
                                    }
                                    
                                    // if setningen som passer på at man kan flytte seg til den ruten som ble trykket på.
                                    if timeInterval2 > 0.5 && ((ip8 || im8 || ip1 || im1) || ((rightBoard == [Bool](repeating: false, count: 24)) &&  !leftBoard[i])) && (i % 8 != 7 || safeZoneNum == 1) && (i % 8 != 0 || safeZoneNum == 0) {
                                        lastClicked = 0 // hvis man kan, så blir lastClicked satt til 0, som reprisenterer denne spilleren. brukes for å finen ut hvem som vant
                                        rightBoard = [Bool](repeating: false, count: 24) // brettet blir satt til helt blankt
                                        rightBoard[i] = true // og så blir den nye ruten valgt
                                        if rightBoard[i] == leftBoard[i] { // skjekker om spillerene er oppå hverandre
                                            correspondingButtonPressed = true // hvis de er, så settes denne variabelen til true, som betyr at spilelt er over, og if setningen skal bruke denne.
                                        }
                                    }
                                    lastClickTimeRight = now2 // setter tiden av sist trykk til nå, slik at neste trykk kan bli passet på at den ikke er for tidlig
                                } label: { // dette er hvordan ruten ser ut:
                                    if rightBoard[i] { // hvis spilleren er der (den grønne)
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(.red) // farger den rød
                                    } else if leftBoard[i] { // ellers, hvis ruten er okkupert av den andre spilleren
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(.green) // farger den grønn
                                    } else if i % 8 == 7 && safeZoneNum == 0 || i % 8 == 0 && safeZoneNum == 1 { // ellers, hvis det er en av de 3 på bunnen og det er de på bunnen som er grønne eller hvis det er en av de 3 på toppen og det er de på toppen som er de grønne:
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(Color(customColor)) // farges med den grønnfargen
                                    } else if i % 8 == 7 && safeZoneNum == 1 || i % 8 == 0 && safeZoneNum == 0 { // ellers, hvis ruten er en av de 3 på toppen og det er de på toppen som er blå eller hvis det er en av de på bunnen som blå:
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(.teal) // farges med den blåfargen
                                    } else { // ellers:
                                        Rectangle() // knappene har utsende til et rektangel
                                            .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                            .tint(.blue) // farger den blå
                                    }
                                }
                                .padding(1) // litt mellomrom mellom dem
                            }
                        }
                    }
                    .frame(alignment: .center) // formatering
                    HStack { // scorene skal være ved siden av hverandre
                        Text(String(score1)) // scoren for spiller 1
                        Text(String(score2)) // scoren for spiller 2
                    }
                    if showInstructions { // kjører koden under hvis det er meningen at instruksjoner skal vises
                        ScrollView { // alt er inni en ScrollView slik at man kan skrolle nedover for å se hele teksten
                            Button { // denne knappen lar deg bli kvitt instruksjonene når du er ferdig
                                showInstructions = false // da blir bare variabelen oppdatert og programmet vil gjøre resten
                                boardDimensions = UIScreen.main.bounds.width * 0.95 // gjør brettet større
                            } label: { // hvordan knappen ser ut:
                                Text("Hide instructions") // bare litt tekst som sier hva den gjør
                            }
                            Text("How to play:\nStart by placing down your character anywhere on the map\nYou can move to squares horizontally or vertically from your position\nYou win by moving on to your opponent's character's square\nThe top and bottom of the map are safe zones, which you can only move into if they are your color\nThere is a delay between when you can click again after moving to a square") // masse tekst spredt utover flere linjer som forklarer hovedaspektene med spillet
                        }
                    } else { // ellers, altså hvis teksten ikke skal være synlig:
                        Button { // lager en knapp:
                            showInstructions = true // oppdaterer showInstructions til true når den blir trykket på slik at denne knappen byttes ut med teksten
                            boardDimensions = UIScreen.main.bounds.width * 0.45 // gjør brettet mindre
                        } label: { // slik knappen ser ut:
                            //Spacer()
                            VStack{
                                HStack { // to ting som er ved siden av hverandre:
                                    Text("How to play") // litt tekst
                                    Image(systemName: "questionmark.circle.fill") // og så et symbol
                                }
                                //Spacer()
                            }
                        }
                     }
                }
                .frame(width: boardDimensions, height: (boardDimensions-UIScreen.main.bounds.width * 0.05)) // setter størrelsen på de to brettene som en helhet
            } else { // ellers, hvis spillet ikke pågår,) og det er da ferdig:
                if lastClicked == 0 { // hvis den forrige som trykket var den blå spilleren:
                    Color.blue // så blir skjermen blå
                } else if lastClicked == 1 { // ellers, hvis det var den grønne som trykket sist (og da vant):
                    Color.green // så blir skjermen grønn
                }
                // dette er en knapp, fordi du kan trykke på den. Knapper trenger ikke å være en figur, så de kan også være tekst, slik det er her.
                Button { // "Play Again" knappen
                    
                    // gjør slik at spillet kan starte på nytt
                    
                    correspondingButtonPressed = false
                    
                    // resetter brettene
                    rightBoard = [Bool](repeating: false, count: 24) 
                    leftBoard = [Bool](repeating: false, count: 24)
                    
                    // så gjør den noe litt fancy her, hvor den trenger ikke engang å vite hvem som vant, men istedenfor bare bruker matte på en slik måte at scoren til en spiller blir plusset med 1 hvis de vant, og med 0 hvis ikke.
                    score2 = score2 + 1-lastClicked // når det var spiller 1 som vant, så vil lastClicked være 0, som skal bety +1, og hvis den tapte vil lastClicked være 1, som skal bety 0. Måten jeg gjorde dette på, var med å ta 1 - lastClicked tallet . Da blir det riktig
                    score1 = score1 + lastClicked // med score2 er det mye enklere, for da er lastClicked tallet det samme som hva som scoren skal plusses med.             
                } label: { // dette er hvordan knappen ser ut:
                    Text("Play Again") // litt tekst som sier «Play again»
                }
                .tint(.orange) // og så er den farget oransje
            }
        }
        .onAppear { // når Viewet kommer til syne:
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in // så setter den en timer som aktiverer hver 5 sekunder
                safeZoneNum = (safeZoneNum == 0) ? 1 : 0 // får safeZoneNum til å bytte mellom 0 og 1, som får toppen og bunnen til å bytte
            }
            musicPlayerInst.song = nil // Den stopper sangen som spiller
            if musicPlayerInst.shouldPlayMusic == true { // hvis det er meningen at musikk skal spille:
                musicPlayerInst.song = "Gridchaser OST" // spiller sangen til dette spillet
                songDataInst.previousSong = "Gridchaser OST" // noterer ned at denne sangen er den sangen som skal spille hvis lyden blir skrudd av og på igjen
            } else { // hvis det er IKKE meningen at musikk skal spille:
                songDataInst.previousSong = "Gridchaser OST" // så noterer den ned at dette er sangen som skal spille når musikken blir skrudd på igjen
            }
        }
    }
}
