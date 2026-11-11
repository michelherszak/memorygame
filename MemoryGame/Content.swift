import Foundation

/// All word pools are our own. Games draw from them at random and avoid recent picks.
enum Content {
    static var shopping: [String] { Lang.isGerman ? shoppingDE : shoppingEN }
    static var firstNames: [String] { Lang.isGerman ? firstDE : firstEN }
    static var lastNames: [String] { Lang.isGerman ? lastDE : lastEN }

    /// Female first names from both pools, so faces can match the name.
    static let femaleFirstNames: Set<String> = [
        "Rosa", "Ruth", "Rita", "Bettina", "Britta", "Carla", "Dora", "Elke", "Frieda", "Greta",
        "Hanna", "Ida", "Jana", "Karin", "Lena", "Marta", "Nele", "Olga", "Paula", "Silke",
        "Tilda", "Ulla", "Vera", "Wanda",
        "Rose", "Amy", "Beth", "Carol", "Ellen", "Edith", "Fiona", "Grace", "Helen", "Iris",
        "Jane", "Karen", "Laura", "Mary", "Nora", "Olive", "Sarah", "Tessa", "Una", "Wendy"
    ]

    private static let shoppingDE = [
        "Honig", "Batterien", "Lauch", "Zahnseide", "Kerzen", "Linsen", "Briefmarken", "Zitronen",
        "Seife", "Kaffee", "Butter", "Streichhölzer", "Haferflocken", "Tomaten", "Backpapier", "Joghurt",
        "Zwiebeln", "Glühbirne", "Reis", "Pflaster", "Olivenöl", "Mehl", "Gurke", "Schwamm",
        "Paprika", "Nudeln", "Salz", "Taschentücher", "Bananen", "Quark", "Walnüsse", "Spülmittel",
        "Karotten", "Tee", "Essig", "Klebeband", "Erdbeeren", "Senf", "Müllbeutel", "Brot",
        "Eier", "Zimt", "Shampoo", "Kartoffeln", "Marmelade", "Alufolie", "Birnen", "Käse",
        "Pfeffer", "Zahnpasta", "Spinat", "Mandeln", "Schnur", "Milch", "Ingwer", "Servietten",
        "Kürbis", "Rosinen", "Handcreme", "Äpfel", "Knoblauch", "Hefe", "Radieschen", "Kakao",
        "Wäscheklammern", "Trauben", "Petersilie", "Zucker", "Bohnen", "Sahne", "Kichererbsen", "Blumenerde",
        "Pilze", "Basilikum", "Waschmittel", "Feigen", "Brokkoli", "Vanille", "Geschenkpapier", "Mais"
    ]

    private static let shoppingEN = [
        "Honey", "Batteries", "Leeks", "Dental floss", "Candles", "Lentils", "Stamps", "Lemons",
        "Soap", "Coffee", "Butter", "Matches", "Oats", "Tomatoes", "Baking paper", "Yogurt",
        "Onions", "Light bulb", "Rice", "Plasters", "Olive oil", "Flour", "Cucumber", "Sponge",
        "Peppers", "Pasta", "Salt", "Tissues", "Bananas", "Cream cheese", "Walnuts", "Dish soap",
        "Carrots", "Tea", "Vinegar", "Tape", "Strawberries", "Mustard", "Bin bags", "Bread",
        "Eggs", "Cinnamon", "Shampoo", "Potatoes", "Jam", "Tin foil", "Pears", "Cheese",
        "Pepper", "Toothpaste", "Spinach", "Almonds", "String", "Milk", "Ginger", "Napkins",
        "Pumpkin", "Raisins", "Hand cream", "Apples", "Garlic", "Yeast", "Radishes", "Cocoa",
        "Clothes pegs", "Grapes", "Parsley", "Sugar", "Beans", "Cream", "Chickpeas", "Potting soil",
        "Mushrooms", "Basil", "Detergent", "Figs", "Broccoli", "Vanilla", "Wrapping paper", "Corn"
    ]

    private static let firstDE = [
        "Rosa", "Ruth", "Rita", "Anton", "Arne", "Albert", "Bettina", "Britta", "Bernd", "Carla",
        "Clemens", "Dora", "Dieter", "Elke", "Emil", "Erik", "Frieda", "Felix", "Greta", "Gustav",
        "Hanna", "Heiko", "Ida", "Ingo", "Jana", "Jonas", "Karin", "Kurt", "Lena", "Lutz",
        "Marta", "Moritz", "Nele", "Nils", "Olga", "Oskar", "Paula", "Peter", "Silke", "Sven",
        "Tilda", "Timo", "Ulla", "Uwe", "Vera", "Volker", "Wanda", "Willi"
    ]

    private static let lastDE = [
        "Lindner", "Lehmann", "Lange", "Lenz", "Brandt", "Becker", "Busch", "Dietrich", "Engel", "Fuchs",
        "Graf", "Haas", "Hahn", "Jung", "Kaiser", "Keller", "Krüger", "Kuhn", "Moser", "Nowak",
        "Otto", "Pohl", "Roth", "Sauer", "Seidel", "Simon", "Sommer", "Stein", "Thiele", "Vogel",
        "Voigt", "Winter", "Wolf", "Ziegler", "Albrecht", "Baumann", "Ernst", "Franke", "Horn", "Köhler"
    ]

    private static let firstEN = [
        "Rose", "Ruth", "Rita", "Alan", "Arthur", "Amy", "Beth", "Brian", "Bruce", "Carol",
        "Colin", "Dora", "David", "Ellen", "Eric", "Edith", "Fiona", "Frank", "Grace", "Gavin",
        "Helen", "Hugh", "Iris", "Ian", "Jane", "Jack", "Karen", "Keith", "Laura", "Leo",
        "Mary", "Mark", "Nora", "Neil", "Olive", "Oscar", "Paula", "Peter", "Sarah", "Simon",
        "Tessa", "Tom", "Una", "Victor", "Vera", "Walter", "Wendy", "Will"
    ]

    private static let lastEN = [
        "Lambert", "Lawson", "Lane", "Lloyd", "Baker", "Barnes", "Brooks", "Dalton", "Ellis", "Fox",
        "Grant", "Hayes", "Hunt", "Jennings", "Kemp", "Knight", "Marsh", "Nash", "Osborne", "Page",
        "Reed", "Shaw", "Stone", "Sutton", "Tanner", "Vance", "Wade", "Webb", "West", "Wood",
        "York", "Abbott", "Bishop", "Cross", "Finch", "Frost", "Hale", "Pike", "Rhodes", "Swift"
    ]
}

struct Technique: Identifiable {
    let id: String
    let title: String
    let body: String
    let exampleParts: [String]
    let example: String
    let tip: String
    let useFor: String
    let game: GameKind

    static var all: [Technique] {
        [
            Technique(
                id: "story",
                title: t("Der Geschichten-Trick", "The story trick"),
                body: t("Einzelne Wörter vergisst man schnell. Eine verrückte kleine Geschichte bleibt hängen. Verbinde jedes Ding mit dem nächsten.",
                        "Single words fade fast. A crazy little story sticks. Link each thing to the next one."),
                exampleParts: [t("Brot", "Bread"), t("Schlüssel", "Key"), t("Regenschirm", "Umbrella")],
                example: t("Ein riesiges Brot schließt mit einem goldenen Schlüssel einen Regenschirm auf, aus dem es Brötchen regnet.",
                           "A giant loaf of bread uses a golden key to unlock an umbrella, and bread rolls rain out of it."),
                tip: t("Je bunter, übertriebener und lustiger das Bild, desto besser hält es.",
                       "The more colourful, exaggerated and funny the picture, the better it holds."),
                useFor: t("Für Listen", "For lists"),
                game: .shopping
            ),
            Technique(
                id: "chunk",
                title: t("Bündeln", "Chunking"),
                body: t("Zehn einzelne Ziffern sind zu viel für den Kopf. Drei kleine Päckchen sind leicht. Teile lange Zahlen in Gruppen und merk dir die Gruppen.",
                        "Ten single digits are too many to hold. Three small packs are easy. Split long numbers into groups and remember the groups."),
                exampleParts: ["4915", "730", "268"],
                example: t("Aus 4915730268 wird 4915 · 730 · 268. Vielleicht erinnert dich 730 an halb acht?",
                           "4915730268 becomes 4915 · 730 · 268. Maybe 730 reminds you of half past seven?"),
                tip: t("Such in jeder Gruppe etwas Bekanntes: eine Uhrzeit, ein Jahr, eine Hausnummer.",
                       "Look for something familiar in each group: a time, a year, a house number."),
                useFor: t("Für Zahlen", "For numbers"),
                game: .code
            ),
            Technique(
                id: "nameimage",
                title: t("Das Name-Bild", "The name picture"),
                body: t("Namen sind schwer, weil sie nichts bedeuten. Gib ihnen ein Bild und hänge es an etwas Auffälliges im Gesicht.",
                        "Names are hard because they mean nothing. Give them a picture and hang it on something striking in the face."),
                exampleParts: [t("Herr Becker", "Mr Baker"), t("große Brille", "big glasses")],
                example: t("Herr Becker backt Brezeln, und seine Brille ist aus zwei Brezeln gebogen.",
                           "Mr Baker bakes pretzels, and his glasses are bent out of two pretzels."),
                tip: t("Erst das Auffällige suchen: Haare, Brille, Bart. Dann den Namen als Bild daran befestigen.",
                       "First find what stands out: hair, glasses, beard. Then attach the name to it as a picture."),
                useFor: t("Für Namen", "For names"),
                game: .faces
            ),
            Technique(
                id: "palace",
                title: t("Der Gedächtnispalast", "The memory palace"),
                body: t("Dein Kopf merkt sich Orte besonders gut. Geh in Gedanken durch deine Wohnung und leg an jeder Stelle ein Ding ab.",
                        "Your mind is very good with places. Walk through your home in your head and put one thing down at each spot."),
                exampleParts: [t("Haustür", "Front door"), t("Flur", "Hallway"), t("Küche", "Kitchen")],
                example: t("An der Haustür klebt Honig, im Flur rollen Zitronen, in der Küche brennen hundert Kerzen.",
                           "Honey sticks to the front door, lemons roll down the hallway, a hundred candles burn in the kitchen."),
                tip: t("Nimm immer denselben Weg. Beim Abrufen läufst du ihn einfach noch einmal ab.",
                       "Always take the same route. To recall, you simply walk it again."),
                useFor: t("Für Listen", "For lists"),
                game: .shopping
            )
        ]
    }
}
