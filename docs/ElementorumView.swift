import SwiftUI // importerer denne slik at Views og sånt funker

// har en funksjon som lager startposisjonen av brettet. Brukes når spillet starter og når ny runde starter.
func colorList(num1: Int, num2: Int, rim: Bool) -> [Color] {
    /*
     num1: hvor den blå/røde vil være
     num2: hvor den grønne/gule vil være
     rim: om den lager listen for kantene av firkantene (om det er for ownership og ikke elements)
     */
    var colors: [Color] // gjør denne bare slik at det ikke blir en error
    if rim { // hvis det er ownership, eller på kanten, så vil det være disee fargene
        colors = Array(repeating: Color.black, count: 100) // setter listen til 100 svarte
        colors[num1] = Color.blue // så setter den ene til blå ...
        colors[num2] = Color.green // ... og den andre til grønn
    } else { // ellers (hvis det er elements, eller i midten) vil det være disse
        // samme logikk her som over, bare forskjellige farger
        colors = Array(repeating: Color.gray, count: 100)
        colors[num1] = Color.red
        colors[num2] = Color.yellow
    }
    return colors // returnerer listen
}

struct ElementorumView: View {
    // Brukes for å lage grids
    let columnLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 10) // til brettet
    let rowLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 1) // til element-velgeren over brettet
    
    // De store listene. Jeg valgte tallene 31 og 87 fordi de er ganske langt fra hverandre, men ikke helt intill kanten. 
    @State private var elements: [Color] = colorList(num1: 31, num2: 87, rim: false) // alle elementene. 
    @State private var ownership: [Color] = colorList(num1: 31, num2: 87, rim: true) // alle som viser hvem som eier rutene.
    
    // hver spiller har et tall som representerer hvilket element de bruker. De starter på 4 og 5, som er blå og grønn. Disse er veldig dårlige, og det eneste de kan gjøre er å vinne spillet og å lage ruter som du kan plassere flere ruter fra. 
    @State private var blueNum: Int = 4
    @State private var greenNum: Int = 5
    
    // viser hvor mange ganger hver spiller har vunnet. Blir vist over element-velginging delen.
    @State private var score1 = 0 
    @State private var score2 = 0
    
    // liste over elementene (eller fargene som representerer dem)
    @State private var elementColors: [Color] = [.orange, .teal, .brown, Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)), .blue, .green]
    
    @State private var whoWon = 0 // viser hvem som vant. Er 0 hvis ingen har vunnet, 1 hvis den ene spilleren vant og 2 hvis den andre spilleren vant
    
    // liste over listene som viser hvilket andre elementer hvert element kan ta. Den blå kan ikke ta rød, fordi det hadde vært bortkastet, siden den eneste røde er eid av den blå. Og samme med grønn og gul. Rekkefølgen på listene (hvilket elementer de forestiller) er den samme som i listen av elementer. Dette er slik at jeg kan bruke blueNum og greenNum for å referere til begge listene.
    @State private var elementTakes: [[Color]] = [[.orange, .brown, Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)), .gray, .green, .blue, .yellow, .red], [.orange, .teal, .gray, .green, .blue, .yellow, .red], [.orange, .gray, .green, .blue, .yellow, .red], [.teal, Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)), .gray, .green, .blue, .yellow, .red], [.gray, .yellow], [.gray, .red]]
    @State private var showInstructions: Bool = false // om den skal vise teksten som sier hvordan å spille spillet eller ikke
    var body: some View { // det var alle variablene, og her kommer det man kan se på skjermen:
        // Det er fint å ha en VStack rundt alt i body-en sin, fordi ellers kan man ofte ende opp med flere Views på øverste nivå av body-en. Det som skjer da, er at det kommer ikke noen errors, (fordi det står "some View", som betyr at den støtter flere,) men det blir rart når man kjører den gjennom en Preview, siden den bruker også "some View". Da blir det en visning for hvert View på øverste nivå, istedenfor å vise hele structen. Previews er nyttige for mens man jobber med programmet, fordi da kan man se hvordan det ser ut uten å måtte kjøre appen hver gang.
        VStack {
            if checkForWinner() == 0 { // denne delen er for når spillet kjører (ingen har vunnet ennå)
                ZStack { // gjør slik at teksten går bortover og så starter på ny linje hvis det er slik at den tar for mye plass. Dette er det vi ser overalt på nettet og i apper, som for eksempel i word
                    if showInstructions { // kjører koden under hvis det er meningen at instruksjoner skal vises
                        ScrollView { // alt er inni en ScrollView slik at man kan skrolle nedover for å se hele teksten
                            Button { // denne knappen lar deg bli kvitt instruksjonene når du er ferdig
                                showInstructions = false // da blir bare variabelen oppdatert og programmet vil gjøre resten
                            } label: { // hvordan knappen ser ut:
                                Text("Hide instructions") // bare litt tekst som sier hva den gjør
                            }
                            Text("How to play:\nYou can place a tile next to (horizontally or vertically) one of your existing tiles\nYou can select the element you want to use with the buttons above your board\nThe inside of a square is its element, and the border shows which of the two players owns the tile\nYou win by placing a tile at the opponents base, which has a special color and is easy to spot\nThe way the elements can take each other form many different combinations, but the main rules are:\n\tfire is agressive\n\twater can block fire\n\tEarth is defensive\n\tWind can move diagonally, which lets you move with it faster\n\tAll elements can take themselves, exept for earth\nThe recommended strategy is to create a defense with defensive elements and then attack with agressive elements") // masse teekst spredt utover flere linjer som forklarer hovedaspektene med spillet
                        }
                        .padding(2)
                        //.padding(8) // jeg satte faktisk denne paddingen slik at på den vanlige skjeremstørrelsen i hvert fall, så vil litt av teksten bare være halvt synlig når du trykker på "How to play" slik at man kan enklere forstå at det er meningen at man skal scrolle
                    } else { // ellers, altså hvis teksten ikke skal være synlig:
                        Button { // lager en knapp:
                            showInstructions = true // oppdaterer showInstructions til true når den blir trykket på slik at denne knappen byttes ut med teksten
                        } label: { // slik knappen ser ut:
                            HStack { // to ting som er ved siden av hverandre:
                                Text("How to play") // litt tekst
                                Image(systemName: "questionmark.circle.fill") // og så et symbol
                            }
                        }
                        Text("\n\n\n") // for at det ikke skal være rett over brettene, legger jeg til noen linjer for mellomrom
                    }
                }
                HStack (spacing: 200) { // slik at de to sidene er til siden for hverandre, og ikke nedover
                    VStack { // selv om sidene ligger vannrett for hverandre, så er hver av dem fortsatt satt opp nedover. Derfor er det en VStack her.
                        Text("Score: \(score1)") // scoren til spiller1 (blå spiller)
                        
                        // De 4 kvadratene over brettet som lar deg velge elementet du vil bruke
                        LazyHGrid(rows: rowLayout, spacing: 0) { // det brukes en LazyHGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                            ForEach (0..<4, id: \.self) { alternatives in // bruker en ForEach loop når man skal vise mange ting som er like (eller nesten like)
                                
                                // lager en knapp
                                Button {
                                    blueNum = alternatives // blueNum blir satt til tallet for hvilket element det er
                                } label: {
                                    Rectangle() // knappen har utsende til et rektangel
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                        .tint(elementColors[alternatives]) // farger den i fargen av hvilket element det er
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.1)
                        // setter størrelsen til en spesifikt størelse i forhold til skjermen
                        // her lages selve brettet
                        LazyVGrid(columns: columnLayout, spacing: 0) { // Det er en LazyVGrid
                            ForEach (0..<100, id: \.self) { i in // bruker en ForEach loop når man skal vise mange ting som er like (eller nesten like)  
                                
                                // selve hver kvadrat på brettet er laget slikt:
                                Button { // de er knapper, fordi man kan trykke på dem og noe skal skje
                                    // alt inni her er det som skjer når denne ruten blir trykket på
                                    
                                    // noen variabler for å finne ut hvilken rad og kollone denne ruten er i. Dette lar meg passe på at ikke toppen og bunnen er koblet eller høyre og ventre. I tilleg kunne det gitt en error (IndexError heter det i Python, men her er det bare "the requested index was outside the bounds of the array") hvis man plasserte en brikke på den nederste raden, for da kunne den bli spurt om ownership[(tall høyere enn 99)]
                                    let row = i / 10
                                    let col = i % 10
                                    
                                    /*
                                     Denne gigantiske if setningen skjekker 2 ting: 
                                     1. Ruten er ved siden av en av de andre rutene på samme lag, eller på skrått for en av de andre rutene på samme lag hvis elementet er vind
                                     2. Elementet kan ta elementet som er på ruten
                                     */
                                    if (((row > 0 && ownership[i - 10] == .blue) || (row < 9 && ownership[i + 10] == .blue) || (col > 0 && ownership[i - 1] == .blue) || (col < 9 && ownership[i + 1] == .blue)) || (elementColors[blueNum] == Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)) && ((row > 0 && col > 0 && ownership[i - 11] == .blue) || (row > 0 && col < 9 && ownership[i - 9] == .blue) || (row < 9 && col < 9 && ownership[i + 11] == .blue) || (row < 9 && col > 0 && ownership[i + 9] == .blue)))) && ((elementTakes[blueNum].contains(elements[i])) && ownership[i] != .blue) {
                                        // hvis alt dette er sant, vil hvem som eier den bli byttet, og elementete blir forandret
                                        ownership[i] = .blue
                                        if elements[i] != .yellow { // funksjonen som tester om noen har vunnet skjekker om elementet er en av rød eller gul, og så ser om den er eid (altså blitt tatt av) det andre laget. Derfor må elementet ikke skiftes hvis det er gul
                                            elements[i] =  elementColors[blueNum] // ellers blir elementet skiftet til elementet som er valgt
                                        }
                                    }
                                } label: { // hvordan kvadratene ser ut
                                    Rectangle() // de er egentlig rektangler ...
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                        .foregroundColor(elements[i]) // insiden er farget som elementet
                                        .border(ownership[i], width: 3) // utsiden er farget som hvem som eier den
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.26, height: UIScreen.main.bounds.height * 0.5)
                        // setter størrelsen til en spesifikt størelse i forhold til skjermen
                    }
                    
                    //Rectangle()
                     //   .frame(width: UIScreen.main.bounds.width * 0.3)
                     //   .foregroundColor(Color.clear)
                    
                    // Og så her er akkurat det samme bare for den andre siden. Jeg kommer til å bare kopiere kommentarene over
                    
                    VStack { // selv om sidene ligger vannrett for hverandre, så er hver av dem fortsatt satt opp nedover. Derfor er det en VStack her. 
                        Text("Score: \(score2)") // scoren til spiller1 (blå spiller)
                        
                        // De 4 kvadratene over brettet som lar deg velge elementet du vil bruke
                        LazyHGrid(rows: rowLayout, spacing: 0) { // det brukes en LazyHGrid (lazy fordi den lager bare det som er på skjermen, som er en god vane å ha, selv om det kanskje ikke gjelder akkurat i dette tilfelle)
                            ForEach (0..<4, id: \.self) { alternatives in // bruker en ForEach loop når man skal vise mange ting som er like (eller nesten like)
                                
                                // lager en knapp
                                Button {
                                    greenNum = alternatives // greenNum blir satt til tallet for hvilket element det er
                                } label: {
                                    Rectangle() // knappen har utsende til et rektangel
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                        .tint(elementColors[alternatives]) // farger den i fargen av hvilket element det er
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.1)
                        // setter størrelsen til en spesifikt størelse i forhold til skjermen
                        
                        // her lages selve brettet
                        LazyVGrid(columns: columnLayout, spacing: 0) { // Det er en LazyVGrid
                            ForEach (0..<100, id: \.self) { i in // bruker en ForEach loop når man skal vise mange ting som er like (eller nesten like)  
                                
                                // selve hver kvadrat på brettet er laget slikt:
                                Button { // de er knapper, fordi man kan trykke på dem og noe skal skje
                                    // alt inni her er det som skjer når denne ruten blir trykket på
                                    
                                    // noen variabler for å finne ut hvilken rad og kollone denne ruten er i. Dette lar meg passe på at ikke toppen og bunnen er koblet eller høyre og ventre. I tilleg kunne det gitt en error (IndexError heter det i Python, men her er det bare "the requested index was outside the bounds of the array") hvis man plasserte en brikke på den nederste raden, for da kunne den bli spurt om ownership[(tall høyere enn 99)]
                                    let row = i / 10
                                    let col = i % 10
                                    
                                    /*
                                     Denne gigantiske if setningen skjekker 2 ting: 
                                     1. Ruten er ved siden av en av de andre rutene på samme lag, eller på skrått for en av de andre rutene på samme lag hvis elementet er vind
                                     2. Elementet kan ta elementet som er på ruten
                                     */
                                    if (((row > 0 && ownership[i - 10] == .green) || (row < 9 && ownership[i + 10] == .green) || (col > 0 && ownership[i - 1] == .green) || (col < 9 && ownership[i + 1] == .green)) || (elementColors[greenNum] == Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)) && ((row > 0 && col > 0 && ownership[i - 11] == .green) || (row > 0 && col < 9 && ownership[i - 9] == .green) || (row < 9 && col < 9 && ownership[i + 11] == .green) || (row < 9 && col > 0 && ownership[i + 9] == .green)))) && elementTakes[greenNum].contains(elements[i]) && ownership[i] != .green {
                                        // hvis alt dette er sant, vil hvem som eier den bli byttet, og elementete blir forandret
                                        ownership[i] = .green
                                        if elements[i] != .red { // funksjonen som tester om noen har vunnet skjekker om elementet er en av rød eller gul, og så ser om den er eid (altså blitt tatt av) det andre laget. Derfor må elementet ikke skiftes hvis det er rød
                                            elements[i] =  elementColors[greenNum]
                                        }
                                    }
                                } label: { // hvordan kvadratene ser ut
                                    Rectangle() // de er egentlig rektangler ...
                                        .aspectRatio(1.0, contentMode: ContentMode.fit) // denne linjen gjør slik at de er kvadrater som tar opp så mye plass de kan
                                        .foregroundColor(elements[i]) // insiden er farget som elementet
                                        .border(ownership[i], width: 3) // utsiden er farget som hvem som eier den
                                }
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.26, height: UIScreen.main.bounds.height * 0.5)
                        // setter størrelsen til en spesifikt størelse i forhold til skjermen
                    }
                }
            } else { // ellers, hvis noen har vunnet ...
                (checkForWinner() == 1) ? Color.blue : Color.green // ... så blir hele skjermen fargen til vinneren,
                Button { // og det kommer en knapp ...
                    score1 = (checkForWinner() == 1) ? score1 + 1 : score1 // hvis spiller 1 vant, så blir score1 plusset med 1
                    score2 = (checkForWinner() == 2) ? score2 + 1 : score2 // hvis spiller 2 vant, så blir score2 plusset med 1
                    // og som resetter elementene og brettet.
                    blueNum = 4 // blueNum blir satt til 4, som er det blå elementet
                    greenNum = 5 // greenNum blir satt til 5, som er det grønne elementet
                    elements = colorList(num1: 31, num2: 87, rim: false) // elementene er vanlige igjen ...
                    ownership = colorList(num1: 31, num2: 87, rim: true) // ... og det er da ownership også.
                } label: { // hvordan knappen ser ut
                    Text("Play again") // det er bare tekst hvor det står "Play again"
                }
            }
        }
        .onAppear { // når Viewet kommer til syne:
            musicPlayerInst.song = nil // Den stopper sangen som spiller
            if musicPlayerInst.shouldPlayMusic == true { // hvis det er meningen at musikk skal spille:
                musicPlayerInst.song = "Elementorum OST" // spiller sangen til dette spillet
                songDataInst.previousSong = "Elementorum OST" // noterer ned at denne sangen er den sangen som skal spille hvis lyden blir skrudd av og på igjen
            } else { // hvis det er IKKE meningen at musikk skal spille:
                songDataInst.previousSong = "Elementorum OST" // så noterer den ned at dette er sangen som skal spille når musikken blir skrudd på igjen
            }
        }
    }
    
    // dette er en funksjon som er brukt til å finne ut om noen har vunnet og som brukes i den store if-setningen som står over hele programmet
    func checkForWinner() -> Int { // den skal returnere en Int. 0 = ingen har vunnet ennå, 1 = spiller 1 har vunnet, 2 = spiller 2 har vunnet)  
        for i in (0..<ownership.count) { // går gjennom alle rutene på brettet for å skjekke om noen har klart å ta motstanderen
            if ownership[i] == Color.blue && elements[i] == Color.yellow { // hvis en rute (eller egentlig denne ruten som skjekkes her) er farget som den blå spilleren, men har innsiden av gul, som betyr at den var startruten til grønn, så skal den:
                return 1 // returnere 1, som betyr at spiller 1 har vunnet, eller den blå spilleren
            } else if ownership[i] == Color.green && elements[i] == Color.red { // samme logikk som over, hvor hvis denne ruten er eid av grønn og innsiden er rød, så har grønn vunnet, for rød var startfargen til blå og dette er da startruten til blå som har blitt tatt av grønn
                return 2 // returnerer 2 forå vise at grønn vant
            }
        }
        return 0 // hvis den går helt gjennom loopen men ingen av rutene betyr at en spiller har vunnet, så vil den returnere 0, som betyr at ingen har vunnet ennå og if-setningen til forstå det og la spillet fortsette
    }
}
