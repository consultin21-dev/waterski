

import 'package:flutter/material.dart';

// import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:pdf/widgets.dart'
    as pw;

import 'package:printing/printing.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:fl_chart/fl_chart.dart';

import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';


List<Skieur> skieursGlobal = [];

String langue = "fr";

String t(String fr, String en, [String? it, String? es, String? de]) {
  if (langue == "en") return en;
  if (langue == "it") return it ?? en;
  if (langue == "es") return es ?? en;
  if (langue == "de") return de ?? en;
  return fr;
}

Future<void> sauvegarderDonnees() async {
  final box = Hive.box('waterski');

  await box.put(
    'skieurs',
    skieursGlobal.map((s) => s.toMap()).toList(),
  );
}

Future<void> chargerDonnees() async {
  final box = Hive.box('waterski');

  final data = box.get('skieurs');

  if (data == null) return;

  skieursGlobal = (data as List)
      .map((e) => Skieur.fromMap(
            Map<String, dynamic>.from(e),
          ))
      .toList();
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  

await Hive.initFlutter();

await Hive.openBox('waterski');

await chargerDonnees();

runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class Skieur {
  final String prenom;
  final String nom;
  final String naissance;
  final String telephone;
  final String email;

  int? unitesClub;

  String? numeroCarteClub;

    bool creditEnCours = false;

  List<SessionHistorique> historique = [];

  Skieur({
    required this.prenom,
    required this.nom,
    required this.naissance,
    required this.telephone,
    required this.email,

    this.unitesClub = 0,

    this.numeroCarteClub,

  });

Map<String, dynamic> toMap() {
  return {
    'prenom': prenom,
    'nom': nom,
    'naissance': naissance,
    'telephone': telephone,
    'email': email,
    'unitesClub': unitesClub,
    'numeroCarteClub': numeroCarteClub,
    'creditEnCours': creditEnCours,
    'historique': historique.map((h) => h.toMap()).toList(),
  };
}

factory Skieur.fromMap(Map map) {
  final skieur = Skieur(
    prenom: map['prenom'] ?? '',
    nom: map['nom'] ?? '',
    naissance: map['naissance'] ?? '',
    telephone: map['telephone'] ?? '',
    email: map['email'] ?? '',
    unitesClub: map['unitesClub'] ?? 0,
    numeroCarteClub: map['numeroCarteClub'],
  );

  skieur.creditEnCours = map['creditEnCours'] ?? false;

  skieur.historique = ((map['historique'] ?? []) as List)
      .map((h) => SessionHistorique.fromMap(h))
      .toList();

  return skieur;
}

}

class SessionHistorique {


  final DateTime venue;

  final String discipline;

  final String depart;

  final String arrivee;

  final String duree;

  final int tours;

  final String paiement;

  final double montant;

  final String observation;

  SessionHistorique({
    required this.venue,
    required this.discipline,
    required this.depart,
    required this.arrivee,
    required this.duree,
    required this.tours,
    required this.paiement,
    required this.montant,
    required this.observation,
  });

Map<String, dynamic> toMap() {
  return {
    'venue': venue.toIso8601String(),
    'discipline': discipline,
    'depart': depart,
    'arrivee': arrivee,
    'duree': duree,
    'tours': tours,
    'paiement': paiement,
    'montant': montant,
    'observation': observation,
  };
}

factory SessionHistorique.fromMap(Map map) {
  return SessionHistorique(
    venue: DateTime.parse(map['venue']),
    discipline: map['discipline'] ?? '',
    depart: map['depart'] ?? '',
    arrivee: map['arrivee'] ?? '',
    duree: map['duree'] ?? '',
    tours: map['tours'] ?? 0,
    paiement: map['paiement'] ?? '',
    montant: (map['montant'] ?? 0).toDouble(),
    observation: map['observation'] ?? '',
  );
}

}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🌊 Logo
            const Icon(
  Icons.waves,
  size: 120,
  color: Colors.blue,
),
            

            const SizedBox(height: 20),

            // ✨ slogan
            const Text(
              "Prépare tes sessions de ski nautique",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // ▶️ bouton
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
    );
  },
  child: const Text("Commencer"),
),

            
          ],
        ),
      ),
    );
  }
}
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  List<Skieur> skieurs = skieursGlobal;

  final rechercheController =
      TextEditingController();

  List<Skieur> resultatRecherche = [];

  final prenomController =
      TextEditingController();

  final nomController =
      TextEditingController();

  final naissanceController =
      TextEditingController();

  final telephoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

   Skieur? skieurSelectionne;

   bool get creditEnCoursSelectionne {
  return skieurSelectionne?.creditEnCours ?? false;
}

int get totalSessions {
  int total = 0;

  for (var skieur in skieurs) {
    total += skieur.historique.length;
  }

  return total;
}

int get totalCredits {
  return skieurs.where((s) => s.creditEnCours).length;
}

  @override
void initState() {
  super.initState();

 

  resultatRecherche = List.from(skieurs);
}

Widget boutonMenu({
  required IconData icon,
  required String texte,
  required Color couleur,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        texte,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
    ),
  );
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,

appBar: AppBar(
  backgroundColor: Colors.blue.shade900,
  title: const Text(
  "WATERSKI",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),
  actions: [
TextButton(
  onPressed: () {
    setState(() {
     if (langue == "fr") {
  langue = "en";
} else if (langue == "en") {
  langue = "it";
} else if (langue == "it") {
  langue = "es";
} else if (langue == "es") {
  langue = "de";
} else {
  langue = "fr";
} 
    });
  },
  child: Text(
    langue.toUpperCase(),
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),
    Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: creditEnCoursSelectionne ? Colors.red : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  ],
),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
  color: const Color(0xFFFFEB3B),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.blue.shade200,
    ),
  ),
  child: Column(
  children: [
  const Icon(
    Icons.waves,
    color: Colors.blue,
    size: 44,
  ),

  const SizedBox(height: 12),

  const Text(
    "WATER SKI APP",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: Color(0xFF0D47A1),
    ),
  ),

  const SizedBox(height: 20),

  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Column(
        children: [
          const Icon(Icons.people, color: Colors.blue, size: 30),
          Text(
            "${skieurs.length}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(t("Skieurs", "Skiers", "Sciatori", "Esquiadores", "Skifahrer")),
        ],
      ),

      Column(
        children: [
          const Icon(Icons.confirmation_number, color: Colors.blue, size: 30),
          Text(
            "$totalCredits",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
           Text(t("Crédits", "Credits", "Crediti", "Créditos", "Guthaben")),
        ],
      ),

      Column(
        children: [
          const Icon(Icons.calendar_month, color: Colors.blue, size: 30),
          Text(
            "$totalSessions",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
         Text(t("Sessions", "Sessions", "Sessioni", "Sesiones", "Sitzungen")),
        ],
      ),
    ],
  ),
],
),
),

boutonMenu(
  icon: Icons.bar_chart,
  texte: t(
  "Guide utilisateur",
  "User guide",
  "Guida utente",
  "Guía del usuario",
  "Benutzerhandbuch",
),
couleur: Colors.teal,
  
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GuidePage(),
      ),
    );
  },
),

const SizedBox(height: 12),

boutonMenu(
  icon: Icons.bar_chart,
  texte: t(
  "Statistiques",
  "Statistics",
  "Statistiche",
  "Estadísticas",
  "Statistiken",
),
  couleur: Colors.deepPurple,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatistiquesPage(),
      ),
    );
  },
),

const SizedBox(height: 12),

boutonMenu(
  icon: Icons.people,
  texte:t(
  "Présences",
  "Attendance",
  "Presenze",
  "Asistencias",
  "Anwesenheiten",
),
  couleur: Colors.orange,
  onPressed: () {
    final presences = <PresenceLigne>[];

    for (var skieur in skieursGlobal) {
      for (var session in skieur.historique) {
        presences.add(
          PresenceLigne(
            skieur: skieur,
            session: session,
          ),
        );
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PresencesPage(
          presences: presences,
        ),
      ),
    );
  },
),

const SizedBox(height: 12),

boutonMenu(
  icon: Icons.qr_code_scanner,
  texte:t(
  "Scanner carte",
  "Scan card",
  "Scansiona carta",
  "Escanear tarjeta",
  "Karte scannen",
),
  couleur: Colors.redAccent,
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerPage(),
      ),
    );

    if (result != null && result is Skieur) {
      setState(() {
        skieurSelectionne = result;
        prenomController.text = result.prenom;
        nomController.text = result.nom;
        naissanceController.text = result.naissance;
        telephoneController.text = result.telephone;
        emailController.text = result.email;
      });
    }
  },
),

const SizedBox(height: 12),

boutonMenu(
  icon: Icons.person_add,
  texte:t(
  "Nouveau skieur",
  "New skier",
  "Nuovo sciatore",
  "Nuevo esquiador",
  "Neuer Skifahrer",
),
  couleur: Colors.green,
  onPressed: () {
    setState(() {
      skieurSelectionne = null;
      prenomController.clear();
      nomController.clear();
      naissanceController.clear();
      telephoneController.clear();
      emailController.clear();
    });
  },
),

const SizedBox(height: 12),

boutonMenu(
  icon: Icons.delete_forever,
  texte: "RESET TEST",
  couleur: Colors.red,
  onPressed: () async {

    final box = Hive.box('waterski');

    await box.clear();

    skieursGlobal.clear();

    setState(() {
      skieurs.clear();
      resultatRecherche.clear();
      skieurSelectionne = null;

      prenomController.clear();
      nomController.clear();
      naissanceController.clear();
      telephoneController.clear();
      emailController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Base de test effacée"),
      ),
    );
  },
),

const SizedBox(height: 25),
          // Recherche
        // Recherche
Container(
  padding: const EdgeInsets.all(8),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.grey.shade300,
    ),
  ),

  child: Autocomplete<Skieur>(

    optionsBuilder: (TextEditingValue textEditingValue) {

      if (textEditingValue.text.isEmpty) {
        return const Iterable<Skieur>.empty();
      }

      return skieurs.where((skieur) {

        final recherche =
            textEditingValue.text.toLowerCase();

        return skieur.prenom
                .toLowerCase()
                .contains(recherche)

            ||

            skieur.nom
                .toLowerCase()
                .contains(recherche);

      });
    },

    displayStringForOption:
        (Skieur s) =>
            "${s.prenom} ${s.nom}",

    onSelected: (Skieur skieur) {

  setState(() {

    skieurSelectionne = skieur;

    prenomController.text =
        skieur.prenom;

    nomController.text =
        skieur.nom;

    naissanceController.text =
        skieur.naissance;

    telephoneController.text =
        skieur.telephone;

    emailController.text =
        skieur.email;

  });

},




    fieldViewBuilder:
        (
          context,
          controller,
          focusNode,
          onEditingComplete,
        ) {

      return TextField(

        controller: controller,
        focusNode: focusNode,

        decoration: InputDecoration(

          hintText:
t(
  "Rechercher un skieur",
  "Search skier",
  "Cerca sciatore",
  "Buscar un esquiador",
  "Skifahrer suchen",
),

          prefixIcon:
              const Icon(Icons.search),

          border:
              InputBorder.none,
        ),
      );
    },
  ),
),



          const SizedBox(height: 30),

          // Nouveau skieur
        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Text(
   t(
  "Nouveau Skieur",
  "New Skier",
  "Nuovo sciatore",
  "Nuevo esquiador",
  "Neuer Skifahrer",
),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

    const SizedBox(height: 10),

    ElevatedButton.icon(
  onPressed: skieurSelectionne == null
      ? null
      : () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoriquePage(
                skieur: skieurSelectionne!,
              ),
            ),
          );

          setState(() {});
        },
  icon: const Icon(Icons.history),
  label: Text(t(
  "Historique",
  "History",
  "Storico",
  "Historial",
  "Verlauf",
))
   ),
  ],
),
    
  

          const SizedBox(height: 20),

          TextField(
            controller: prenomController,
            decoration:  InputDecoration(
              labelText: t(
  "Prénom",
  "First name",
  "Nome",
  "Nombre",
  "Vorname",
),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: nomController,
            decoration:  InputDecoration(
              labelText: t(
  "Nom",
  "Last name",
  "Cognome",
  "Apellido",
  "Nachname",
),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: naissanceController,
            decoration:  InputDecoration(
              labelText: t(
  "Date de naissance",
  "Date of birth",
  "Data di nascita",
  "Fecha de nacimiento",
  "Geburtsdatum",
),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: telephoneController,
            decoration:  InputDecoration(
              labelText: t(
  "Téléphone",
  "Phone",
  "Telefono",
  "Teléfono",
  "Telefon",
),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: t(
  "Email",
  "Email",
  "Email",
  "Correo electrónico",
  "E-Mail",
),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

Row(

  mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

  children: [

    Text(
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - "
      "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",

      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    ElevatedButton.icon(

      onPressed: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (context) =>
                const StatistiquesPage(),
          ),
        );
      },

      icon:
          const Icon(Icons.bar_chart),

      label: Text(t(
  "Statistiques",
  "Statistics",
  "Statistiche",
  "Estadísticas",
  "Statistiken",
)),

      style:
          ElevatedButton.styleFrom(

        backgroundColor:
            Colors.deepPurple,

        foregroundColor:
            Colors.white,
      ),
    ),
  ],
),

const SizedBox(height: 30),

          const SizedBox(height: 30),

          // Bouton enregistrer
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(

             onPressed: () async {

             if (
                prenomController.text.trim().isEmpty &&
                nomController.text.trim().isEmpty &&
                skieurSelectionne == null
) {
  setState(() {
    skieurSelectionne = null;
  });

  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
t(
  "Veuillez sélectionner ou saisir un skieur",
  "Please select or enter a skier",
  "Seleziona o inserisci uno sciatore",
  "Seleccione o introduzca un esquiador",
  "Bitte wählen Sie einen Skifahrer aus oder geben Sie einen ein",
),
    ),
  ),
);

  return;
}

  Skieur skieurActuel;

  if (skieurSelectionne != null) {

    skieurActuel = skieurSelectionne!;

  } else {

    skieurActuel = Skieur(
      prenom: prenomController.text,
      nom: nomController.text,
      naissance: naissanceController.text,
      telephone: telephoneController.text,
      email: emailController.text,
    );

    if (!skieurs.any(
      (s) => s.email == skieurActuel.email,
    )) {

      skieurs.add(skieurActuel);

      await sauvegarderDonnees();

    }

    setState(() {
      resultatRecherche =
          List.from(skieurs);
    });
  }

  Navigator.push(
    context,

    MaterialPageRoute(
      builder: (_) =>
          DisciplinePage(
        skieur: skieurActuel,
      ),
    ),
  );
},

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),

              child: Text(
               t(
  "Enregistrer",
  "Save",
  "Salva",
  "Guardar",
  "Speichern",
), 
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(height: 40),

      


const SizedBox(height: 30),

],
),
),
);
}

}
class DisciplinePage extends StatelessWidget {

  final Skieur skieur;

  const DisciplinePage({
    super.key,
    required this.skieur,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

    appBar: AppBar(
  backgroundColor: Colors.blue.shade900,
  title: Text(
  t(
    "DISCIPLINES",
    "DISCIPLINES",
    "DISCIPLINE",
    "DISCIPLINAS",
    "DISZIPLINEN",
  ),
),

  actions: [
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacturationPage(
              skieur: skieur,
              discipline: "VENTE UNITÉS",
              debut: null,
              fin: null,
              duree: "00:00",
              tours: 0,
            ),
          ),
        );
      },
      child: Text(
  t(
    "PASSER",
    "SKIP",
    "SALTA",
    "OMITIR",
    "ÜBERSPRINGEN",
  ),
  style: const TextStyle(
    color: Colors.white,
  ),
),
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // 👤 Skieur
         Text(
        "${skieur.prenom} ${skieur.nom}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (skieur.creditEnCours)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 15),
    padding: const EdgeInsets.all(12),
    color: Colors.red,
    child: Text(
  t(
    "⚠ CRÉDIT EN COURS",
    "⚠ CREDIT PENDING",
    "⚠ CREDITO IN CORSO",
    "⚠ CRÉDITO PENDIENTE",
    "⚠ OFFENER KREDIT",
  ),
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),
  ),

            const SizedBox(height: 8),

              Text(
              skieur.naissance,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // 📅 date heure
            Text(
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - "
              "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

             Text(
  t(
    "Choisissez une discipline",
    "Choose a discipline",
    "Scegli una disciplina",
    "Elija una disciplina",
    "Wählen Sie eine Disziplin",
  ),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 25),

            disciplineButton(context, skieur, "BI-SKI", "BI-SKIING", "BI-SKI", "BI-SKI", "BI-SKI", Colors.blue),

const SizedBox(height: 15),

disciplineButton(context, skieur, "SLALOM", "SLALOM", "SLALOM", "SLALOM", "SLALOM", Colors.red),

const SizedBox(height: 15),

disciplineButton(context, skieur, "FIGURES", "TRICKS", "FIGURE", "FIGURAS", "FIGUREN", Colors.purple),

const SizedBox(height: 15),

disciplineButton(context, skieur, "WAKEBOARD", "WAKEBOARD", "WAKEBOARD", "WAKEBOARD", "WAKEBOARD", Colors.orange),

const SizedBox(height: 15),

disciplineButton(context, skieur, "SAUT", "JUMPING", "SALTO", "SALTO", "SPRUNG", Colors.green),
          ],
        ),
      ),
    );
  }

  
}
Widget disciplineButton(
  BuildContext context,
  Skieur skieur,
  String texteFr,
  String texteEn,
  String texteIt,
  String texteEs,
  String texteDe,
  Color couleur,
) {
  final discipline = t(
    texteFr,
    texteEn,
    texteIt,
    texteEs,
    texteDe,
  );

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionPage(
              skieur: skieur,
              discipline: discipline,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: couleur,
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        discipline,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class SessionPage extends StatefulWidget {

  final Skieur skieur;
  final String discipline;

  const SessionPage({
    super.key,
    required this.skieur,
    required this.discipline,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {

  DateTime? debut;
  DateTime? fin;

  int tours = 0;

  String get dureeSession {

    if (debut == null || fin == null) {
      return "00:00";
    }

    final duree = fin!.difference(debut!);

    final minutes = duree.inMinutes;

return "$minutes mn";


  }

 @override
Widget build(BuildContext context) {

  return Scaffold(
  resizeToAvoidBottomInset: true,

    backgroundColor: Colors.white,

    appBar: AppBar(
  backgroundColor: Colors.blue.shade900,
  title: Text(widget.discipline),

  actions: [
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacturationPage(
              skieur: widget.skieur,
              discipline: widget.discipline,
              debut: null,
              fin: null,
              duree: "00:00",
              tours: 0,
            ),
          ),
        );
      },
     child: Text(
        t(
  "PASSER",
  "SKIP",
  "SALTA",
  "OMITIR",
  "ÜBERSPRINGEN",
),
        style: const TextStyle(color: Colors.white),
      ), 
    ),
  ],
),

    body: SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),


    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        Text(
          "${widget.skieur.prenom} ${widget.skieur.nom}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          widget.skieur.naissance,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - "
          "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Text(
t(
  "Temps de session",
  "Session time",
  "Tempo della sessione",
  "Tiempo de la sesión",
  "Sitzungszeit",
),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            dureeSession,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (debut != null)
          Text(
            "${t(
  "Départ",
  "Start",
  "Partenza",
  "Salida",
  "Start",
)} : ${debut!.hour}:${debut!.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 18),
          ),

        if (fin != null)
           Text(
             "${t(
  "Arrivée",
  "Finish",
  "Arrivo",
  "Llegada",
  "Ankunft",
)} : ${fin!.hour}:${fin!.minute.toString().padLeft(2, '0')}",
             style: const TextStyle(fontSize: 18),
          ),

        const SizedBox(height: 20),

      Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton(
      onPressed: () {
        setState(() {
          debut = DateTime.now();
          fin = null;
        });
      },
      child: Text(
        t(
          "Départ",
          "Start",
          "Partenza",
          "Salida",
          "Start",
        ),
      ),
    ),

    ElevatedButton(
      onPressed: () {
        setState(() {
          fin = DateTime.now();
        });
      },
      child: Text(
        t(
          "Arrivée",
          "Finish",
          "Arrivo",
          "Llegada",
          "Ankunft",
        ),
      ),
    ),
  ],
),

        const SizedBox(height: 25),

           Text(
             t(
  "Nombre de tours",
  "Number of laps",
  "Numero di giri",
  "Número de vueltas",
  "Anzahl der Runden",
),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            "$tours",
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (tours > 0) tours--;
                });
              },
              child: const Text("-"),
            ),

            const SizedBox(width: 30),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  tours++;
                });
              },
              child: const Text("+"),
            ),
          ],
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,

          child: ElevatedButton(

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FacturationPage(
                    skieur: widget.skieur,
                    discipline: widget.discipline,
                    debut: debut,
                    fin: fin,
                    duree: dureeSession,
                    tours: tours,
                    
                  ),
                ),
              );

            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            

            child: Text(
              t(
  "Enregistrer la session",
  "Save session",
  "Salva la sessione",
  "Guardar la sesión",
  "Sitzung speichern",
),
              style: TextStyle(fontSize: 20),
            ),
          ),
         ),
          const SizedBox(height: 30),
         
        

        ],
     ),
   ),
);


}      

}

class FacturationPage extends StatefulWidget {

  final Skieur skieur;
  final String discipline;
  final DateTime? debut;
  final DateTime? fin;
  final String duree;
  final int tours;
  

  const FacturationPage({
    super.key,
    required this.skieur,
    required this.discipline,
    required this.debut,
    required this.fin,
    required this.duree,
    required this.tours,
    
  });

  @override
  State<FacturationPage> createState() => _FacturationPageState();
}

class _FacturationPageState extends State<FacturationPage> {

  final calculController = TextEditingController();

  final unitesController = TextEditingController();

  String resultat = "";

  int unitesAchetees = 0;

  void calculer() {

    try {

      String expression = calculController.text;

      expression = expression.replaceAll("x", "*");

      double value = 0;

      if (expression.contains("+")) {
        final parts = expression.split("+");
        value = double.parse(parts[0]) + double.parse(parts[1]);
      }

      else if (expression.contains("-")) {
        final parts = expression.split("-");
        value = double.parse(parts[0]) - double.parse(parts[1]);
      }

      else if (expression.contains("*")) {

  final parts = expression.split("*");

  unitesAchetees = int.parse(parts[0]);

  value =
      double.parse(parts[0]) *
      double.parse(parts[1]);
}

      else if (expression.contains("/")) {
        final parts = expression.split("/");
        value = double.parse(parts[0]) / double.parse(parts[1]);
      }
  
     else {
  value = double.parse(expression);
}  

      setState(() {
        resultat = value.toStringAsFixed(2);
      });

    } catch (e) {

      setState(() {
        resultat = "Erreur";
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
       title: Text(t(
  "FACTURATION",
  "BILLING",
  "FATTURAZIONE",
  "FACTURACIÓN",
  "ABRECHNUNG",
)), 
      ),

      body: SingleChildScrollView(
         padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "${widget.skieur.prenom} ${widget.skieur.nom}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            

            const SizedBox(height: 10),



            Text("${t(
  "Naissance",
  "Birth date",
  "Data di nascita",
  "Fecha de nacimiento",
  "Geburtsdatum",
)} : ${widget.skieur.naissance}"),

            Text("${t(
  "Discipline",
  "Discipline",
  "Disciplina",
  "Disciplina",
  "Disziplin",
)} : ${widget.discipline}"),

            const SizedBox(height: 20),

            if (widget.debut != null)
            Text(
                "${t(
  "Départ",
  "Start",
  "Partenza",
  "Salida",
  "Start",
)} : ${widget.debut!.hour}:${widget.debut!.minute.toString().padLeft(2, '0')}",
            ),

            if (widget.fin != null)
             Text(
                "${t(
  "Arrivée",
  "Finish",
  "Arrivo",
  "Llegada",
  "Ankunft",
)} : ${widget.fin!.hour}:${widget.fin!.minute.toString().padLeft(2, '0')}",
            ),

             Text("${t(
  "Temps réalisé",
  "Time achieved",
  "Tempo realizzato",
  "Tiempo realizado",
  "Erreichte Zeit",
)} : ${widget.duree}"),

             Text("${t(
  "Nombre de tours",
  "Number of laps",
  "Numero di giri",
  "Número de vueltas",
  "Anzahl der Runden",
)} : ${widget.tours}"),

            const SizedBox(height: 40),

Text(
  t(
  "Unités à créditer",
  "Units to credit",
  "Unità da accreditare",
  "Unidades a acreditar",
  "Gutzuschreibende Einheiten",
),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

TextField(
  controller: unitesController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
  labelText:t(
  "Nombre d'unités",
  "Number of units",
  "Numero di unità",
  "Número de unidades",
  "Anzahl der Einheiten",
),
  border: const OutlineInputBorder(),
),
),

const SizedBox(height: 30),

            Text(
  t(
  "Calculatrice",
  "Calculator",
  "Calcolatrice",
  "Calculadora",
  "Rechner",
),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 20),

            TextField(
              controller: calculController,
              decoration: InputDecoration(
                hintText: t(
  "Exemple : 25*3",
  "Example: 25*3",
  "Esempio: 25*3",
  "Ejemplo: 25*3",
  "Beispiel: 25*3",
),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: calculer,
    child: Text(
      t(
  "Calculer",
  "Calculate",
  "Calcola",
  "Calcular",
  "Berechnen",
),
    ),
  ),
),

const SizedBox(height: 20),

Center(
  child: Text(
    resultat,
    style: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
),

            const SizedBox(height: 20),

           SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReglementPage(
            skieur: widget.skieur,
            discipline: widget.discipline,
            duree: widget.duree,
            tours: widget.tours,
            paiement: "",
            unites: int.tryParse(unitesController.text) ?? 0,
            montant: double.tryParse(resultat) ?? 0,
            depart: widget.debut != null
                ? "${widget.debut!.hour}:${widget.debut!.minute.toString().padLeft(2, '0')}"
                : "",
            arrivee: widget.fin != null
                ? "${widget.fin!.hour}:${widget.fin!.minute.toString().padLeft(2, '0')}"
                : "",
          ),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      padding: const EdgeInsets.symmetric(vertical: 18),
    ),
    child: Text(
      t(
  "Taper règlement",
  "Enter payment",
  "Inserisci il pagamento",
  "Introducir el pago",
  "Zahlung eingeben",
),
      style: const TextStyle(fontSize: 20),
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}
class ReglementPage extends StatelessWidget {

  final Skieur skieur;
  final String discipline;
  final String duree;
  final int tours;
  final String paiement;
  final double montant;
  final int unites;
  final String depart;
  final String arrivee;


  const ReglementPage({
    super.key,
    required this.skieur,
    required this.discipline,
    required this.duree,
    required this.tours,
    required this.paiement,
    required this.montant,
    required this.unites,
    required this.depart,
    required this.arrivee,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
  backgroundColor: Colors.blue.shade900,
  title: Text(t(
  "Règlement",
  "Payment",
  "Pagamento",
  "Pago",
  "Zahlung",
)),
),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "${skieur.prenom} ${skieur.nom}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            paiementButton(
  context,
t(
  "ESPÈCE",
  "CASH",
  "CONTANTI",
  "EFECTIVO",
  "BARGELD",
),
  Colors.green,
  skieur,
  discipline,
  duree,
  tours,
  depart,
  arrivee,
  montant,
  unites,
),

const SizedBox(height: 15),

paiementButton(
  context,
  t(
  "CHÈQUE",
  "CHEQUE",
  "ASSEGNO",
  "CHEQUE",
  "SCHECK",
),
  Colors.orange,
  skieur,
  discipline,
  duree,
  tours,
  depart,
  arrivee,
  montant,
  unites,
),

            const SizedBox(height: 15),

            paiementButton(
            context,
           t(
  "CARTE BLEUE",
  "BANK CARD",
  "CARTA DI CREDITO",
  "TARJETA BANCARIA",
  "BANKKARTE",
),
           Colors.blue,
           skieur,
           discipline,
           duree,
           tours,
           depart,
           arrivee,
           montant,
           unites,
),

            const SizedBox(height: 15),

            paiementButton(
            context,
           t(
  "VIREMENT",
  "BANK TRANSFER",
  "BONIFICO",
  "TRANSFERENCIA",
  "BANKÜBERWEISUNG",
),
           Colors.purple,
           skieur,
           discipline,
           duree,
           tours,
           depart,
           arrivee,
           montant,
           unites,
),
            

            const SizedBox(height: 15),

            paiementButton(
            context,
            t(
  "CRÉDIT",
  "CREDIT",
  "CREDITO",
  "CRÉDITO",
  "GUTHABEN",
),
            Colors.red,
            skieur,
            discipline,
            duree,
            tours,
            depart,
            arrivee,
            montant,
            unites,
),

            const SizedBox(height: 15),

       clubButton(
  context,
  skieur,
  discipline,
  duree,
  tours,
  depart,
  arrivee,
),   

          ],
        ),
      ),
    );
  }
}
Widget paiementButton(
  BuildContext context,
  String texte,
  Color couleur,
  Skieur skieur,
  String discipline,
  String duree,
  int tours,
  String depart,
  String arrivee,
  double montant,
  int unites,
){

  return SizedBox(
    width: double.infinity,

    child: ElevatedButton(
  onPressed: () {

   if (texte == "CREDIT") {
  skieur.creditEnCours = true;
}

    ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      "${t(
  "Paiement enregistré",
  "Payment recorded",
  "Pagamento registrato",
  "Pago registrado",
  "Zahlung gespeichert",
)} : $texte",
    ),
  ),
);

    if (unites > 0) {
      skieur.unitesClub = (skieur.unitesClub ?? 0) + unites;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarteClubPage(
            skieur: skieur,
            discipline: discipline,
            duree: duree,
            tours: tours,
            depart: depart,
            arrivee: arrivee,
            montant: montant,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecapPage(
            skieur: skieur,
            discipline: discipline,
            duree: duree,
            tours: tours,
            paiement: texte,
            montant: montant,
            depart: depart,
            arrivee: arrivee,
          ),
        ),
      );
    }
  },

  style: ElevatedButton.styleFrom(
    backgroundColor: couleur,
    padding: const EdgeInsets.symmetric(vertical: 20),
  ),

  child: Text(
    texte,
    style: const TextStyle(
      fontSize: 22,
      color: Colors.white,
    ),
  ),
),
  );
}
Widget clubButton(
  BuildContext context,
  Skieur skieur,
  String discipline,
  String duree,
  int tours,
  String depart,
  String arrivee,
)
{

  return SizedBox(
    width: double.infinity,

    child: ElevatedButton(

      onPressed: () {

        
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CarteClubPage(
      skieur: skieur,
      discipline: discipline,
      duree: duree,
      tours: tours,
      depart: depart,
      arrivee: arrivee,
      montant: 0,
    ),
  ),
);

      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),

      child:  Text(
        t(
  "CARTE CLUB",
  "CLUB CARD",
  "CLUB CARD",
  "CLUB CARD",
  "CLUB CARD",
),
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    ),
  );
}



    
class CarteClubPage extends StatefulWidget {
  final Skieur skieur;
  final String discipline;
  final String duree;
  final int tours;
  final String depart;
  final String arrivee;
  final double montant;

  const CarteClubPage({
    super.key,
    required this.skieur,
    required this.discipline,
    required this.duree,
    required this.tours,
    required this.depart,
    required this.arrivee,
    required this.montant,
  });

  @override
  State<CarteClubPage> createState() => _CarteClubPageState();
}

class _CarteClubPageState extends State<CarteClubPage> {

late int unites;
late int unitesDepart;

@override
void initState() {

  super.initState();

  widget.skieur.unitesClub ??= 10;

unites = widget.skieur.unitesClub!;
unitesDepart = unites;

}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
  backgroundColor: Colors.blue.shade900,
  title: Text(t("CARTE CLUB", "CLUB CARD")),
),

      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "${widget.skieur.prenom} ${widget.skieur.nom}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),


            const SizedBox(height: 20),

             Center(
              child: Text(
t(
  "Scanner une carte",
  "Scan a card",
  "Scansiona una carta",
  "Escanear una tarjeta",
  "Karte scannen",
),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
           
           
const SizedBox(height: 20),

SizedBox(
  width: double.infinity,

  child: ElevatedButton(

onPressed: () async {

  final result = await Navigator.push(

    context,

    MaterialPageRoute(
      builder: (context) =>
          const ScannerPage(),
    ),
  );

  if (
      result != null &&
      result is Skieur
     ) {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) =>
          CarteClubPage(
  skieur: result,
  discipline: widget.discipline,
  duree: widget.duree,
  tours: widget.tours,
  depart: widget.depart,
  arrivee: widget.arrivee,
  montant: widget.montant,
),  
      ),
    );
  }


else if (result is String) {
  widget.skieur.numeroCarteClub = result;

if (!skieursGlobal.contains(widget.skieur)) {
  skieursGlobal.add(widget.skieur);
}

await sauvegarderDonnees();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
content: Text(
  "${t(
  "Carte attribuée à",
  "Card assigned to",
  "Carta assegnata a",
  "Tarjeta asignada a",
  "Karte zugewiesen an",
)} ${widget.skieur.prenom} ${widget.skieur.nom}",
),
      
    ),
  );
}

},
child: Text(t(
  "Scanner une carte",
  "Scan a card",
  "Scansiona una carta",
  "Escanear una tarjeta",
  "Karte scannen",
))
  ),
),
            const SizedBox(height: 40),

            Text(
  t(
  "Unités restantes",
  "Remaining units",
  "Unità rimanenti",
  "Unidades restantes",
  "Verbleibende Einheiten",
),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "$unites",
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 30),

                       Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                   onPressed: () async {
                   setState(() {
                   if (unites > 0) {
                   unites--;
           }

    widget.skieur.unitesClub = unites;
  });

  await sauvegarderDonnees();
},
                  child: const Text("-1"),
                ),

const SizedBox(width: 30),

ElevatedButton(
  onPressed: () async {
    setState(() {
      unites++;
      widget.skieur.unitesClub = unites;
    });

  await sauvegarderDonnees();

  },
  child: const Text("+1"),
),
],

),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
onPressed: () {
  final int unitesRestantes = unites;
final int unitesConsommees = unitesDepart - unitesRestantes;

if (unitesConsommees == 0 && widget.montant == 0) {
  Navigator.pop(context);
  return;
}

setState(() {
  widget.skieur.unitesClub = unitesRestantes;
});

  Navigator.push(
      context,
      MaterialPageRoute(
builder: (context) => RecapPage(
  skieur: widget.skieur,
  discipline: widget.discipline,
  duree: widget.duree,
  tours: widget.tours,
  paiement: (
    unitesConsommees < 0
        ? "CARTE CLUB\n\n"
          "Crédit : ${unitesRestantes - unitesDepart} unité(s)\n"
          "Restant : $unitesRestantes unités"
        : "CARTE CLUB\n\n"
          "Départ : $unitesDepart unités\n"
          "Consommé : $unitesConsommees unités\n"
          "Restant : $unitesRestantes unités"
  ),
  montant: widget.montant,
  depart: widget.depart,
  arrivee: widget.arrivee,
),
      ),

    );
  
},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(vertical: 18),
    ),
    child: Text(
  t(
  "Valider",
  "Confirm",
  "Conferma",
  "Validar",
  "Bestätigen",
),
  style: const TextStyle(fontSize: 20),
),

  ),
),

          ],
        ),
      ),
    ),
  );
}              

}



class RecapPage extends StatefulWidget {

  final Skieur skieur;
  final String discipline;
  final String duree;
  final int tours;
  final String paiement;

  final String depart;
  final String arrivee;
  
  final double montant;

  const RecapPage({
    super.key,

    required this.skieur,
    required this.discipline,
    required this.duree,
    required this.tours,
    required this.paiement,
    
    required this.montant,

    this.depart = "",
    this.arrivee = "",
    
  });

  @override
  State<RecapPage> createState() => _RecapPageState();
}



class _RecapPageState extends State<RecapPage> {

  final observationController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(t(
  "RÉCAPITULATIF",
  "SUMMARY",
  "RIEPILOGO",
  "RESUMEN",
  "ZUSAMMENFASSUNG",
)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "${widget.skieur.prenom} ${widget.skieur.nom}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "${t(
  "Date de naissance",
  "Birth date",
  "Data di nascita",
  "Fecha de nacimiento",
  "Geburtsdatum",
)} : ${widget.skieur.naissance}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              "${t(
  "Discipline",
  "Discipline",
  "Disciplina",
  "Disciplina",
  "Disziplin",
)} : ${widget.discipline}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t(
  "Durée session",
  "Session duration",
  "Durata della sessione",
  "Duración de la sesión",
  "Sitzungsdauer",
)} : ${widget.duree}",
              style: const TextStyle(fontSize: 20),
            ),
            
            Text(
               "${t(
  "Départ",
  "Start",
  "Partenza",
  "Salida",
  "Start",
)} : ${widget.depart}",
              style: const TextStyle(fontSize: 20),
            ),

             Text(
               "${t(
  "Arrivée",
  "Finish",
  "Arrivo",
  "Llegada",
  "Ankunft",
)} : ${widget.arrivee}",
               style: const TextStyle(fontSize: 20),
            ),


            Text(
              "${t(
  "Tours réalisés",
  "Completed laps",
  "Giri effettuati",
  "Vueltas realizadas",
  "Gefahrene Runden",
)} : ${widget.tours}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t(
  "Paiements",
  "Payments",
  "Pagamenti",
  "Pagos",
  "Zahlungen",
)} : ${widget.paiement}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t(
  "Montant",
  "Amount",
  "Importo",
  "Importe",
  "Betrag",
)} : ${widget.montant.toStringAsFixed(2)} €",
             style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 40),



            Text(
              t(
  "Observations sportives",
  "Coaching notes",
  "Osservazioni sportive",
  "Observaciones deportivas",
  "Sportliche Beobachtungen",
),
              
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: observationController,
              maxLines: 8,

              decoration: InputDecoration(
                   hintText:t(
  "Travailler la tension des bras pour la prochaine séance",
  "Work on arm tension for the next session",
  "Lavorare sulla tensione delle braccia per la prossima sessione",
  "Trabajar la tensión de los brazos para la próxima sesión",
  "An der Armspannung für die nächste Einheit arbeiten",
),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(



      onPressed: () async {   

  widget.skieur.historique.add(

    SessionHistorique(

      venue: DateTime.now(),

      discipline: widget.discipline,

      duree: widget.duree,

      tours: widget.tours,

      paiement: widget.paiement,

      montant: widget.montant,

      observation:
          observationController.text,

      depart: widget.depart,

      arrivee: widget.arrivee,
    ),
  );

  await sauvegarderDonnees();

  ScaffoldMessenger.of(context)
      .showSnackBar(

    SnackBar(
      content: Text(
    t(
  "Session enregistrée",
  "Session saved",
  "Sessione salvata",
  "Sesión guardada",
  "Sitzung gespeichert",
),
       
     )
    ),
  );

  Navigator.pushAndRemoveUntil(

    context,

    MaterialPageRoute(

      builder: (context) =>

      HistoriquePage(
        skieur: widget.skieur,
      ),
    ),

    (route) => false,
  );

},



                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),

    child: 
      Text(
        t(
  "Terminer la session",
  "End session",
  "Termina la sessione",
  "Finalizar la sesión",
  "Sitzung beenden",
),
                  
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoriquePage extends StatefulWidget {

  final Skieur skieur;

  const HistoriquePage({
    super.key,
    required this.skieur,
  });

  @override
  State<HistoriquePage> createState() =>
      _HistoriquePageState();
}

class _HistoriquePageState
    extends State<HistoriquePage> {

  DateTime? dateDebut;
  DateTime? dateFin;

List<SessionHistorique> get sessionsFiltrees {
  return widget.skieur.historique.where((s) {
    final sessionDate = DateTime(s.venue.year, s.venue.month, s.venue.day);

    if (dateDebut != null) {
      final debut = DateTime(dateDebut!.year, dateDebut!.month, dateDebut!.day);

      if (sessionDate.isBefore(debut)) {
        return false;
      }
    }

    if (dateFin != null) {
      final fin = DateTime(dateFin!.year, dateFin!.month, dateFin!.day);

      if (sessionDate.isAfter(fin)) {
        return false;
      }
    }

    return true;
  }).toList();
}

Future<void> exporterHistoriquePDF() async {

  final pdf = pw.Document();

  

  pdf.addPage(

    pw.MultiPage(

      build: (context) => [

        pw.Text(
          t(
  "DOSSIER CLIENT",
  "CUSTOMER FILE",
  "SCHEDA CLIENTE",
  "FICHA DEL CLIENTE",
  "KUNDENAKTE",
),
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height:20),

        pw.Text(
          "${widget.skieur.prenom} ${widget.skieur.nom}",
        ),

        pw.Text(widget.skieur.naissance),

        pw.Text(widget.skieur.telephone),

        pw.Text(widget.skieur.email),

        pw.SizedBox(height:20),

        pw.Text(
          t(
  "Historique des sessions",
  "Session history",
  "Storico delle sessioni",
  "Historial de sesiones",
  "Sitzungsverlauf",
),
          style: pw.TextStyle(
            fontSize:18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        ...sessionsFiltrees.map(

          (s)=> pw.Container(

            margin:
                const pw.EdgeInsets.only(
                    bottom:10),

            child: pw.Column(

              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

              children:[

                pw.Text(
                  s.discipline,
                  style: pw.TextStyle(
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  "${s.venue.day}/"
                  "${s.venue.month}/"
                  "${s.venue.year}",
                ),

                pw.Text(
                  "Tours : ${s.tours}",
                ),

                pw.Column(
  crossAxisAlignment:
      pw.CrossAxisAlignment.start,

  children: [

    pw.Text(
      "Discipline : ${s.discipline}",
    ),

    pw.Text(
      "Date : "
      "${s.venue.day}/"
      "${s.venue.month}/"
      "${s.venue.year}",
    ),

    pw.Text(
      "Départ : ${s.depart}",
    ),

    pw.Text(
      "Arrivée : ${s.arrivee}",
    ),

    pw.Text(
      "Durée : ${s.duree}",
    ),

    pw.Text(
      "Tours : ${s.tours}",
    ),

    pw.Text(
      "Paiement : ${s.paiement}",
    ),

    pw.Text(
      "Montant : "
      "${s.montant.toStringAsFixed(2)} EUR",
    ),

    pw.Text(
      "Observation : "
      "${s.observation}",
    ),

    pw.Divider(),
  ],
),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  await Printing.sharePdf(

    bytes: await pdf.save(),

    filename:
        "${widget.skieur.nom}_historique.pdf",
  );
}

@override
Widget build(BuildContext context) {

  



Map<String,int> disciplines = {};

Map<String,int> paiements = {};



for (var s in sessionsFiltrees) {

  

  disciplines[s.discipline] =
      (disciplines[s.discipline] ?? 0) + 1;

  paiements[s.paiement] =
      (paiements[s.paiement] ?? 0) + 1;

if (!s.paiement.toUpperCase().contains('CRÉDIT') &&
    !s.paiement.toUpperCase().contains('CREDIT')) {
  
}
}

  return Scaffold(




      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(
  t(
    "DOSSIER CLIENT",
    "CUSTOMER FILE",
    "SCHEDA CLIENTE",
    "FICHA DEL CLIENTE",
    "KUNDENAKTE",
  ),
),
        ),
      

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(
              "${widget.skieur.prenom} ${widget.skieur.nom}",

              style: const TextStyle(
                fontSize: 28,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            Text(widget.skieur.naissance),

            Text(widget.skieur.telephone),

            Text(widget.skieur.email),

            if (widget.skieur.creditEnCours)
  Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 15),
    child: ElevatedButton(
      onPressed: () async {
        setState(() {
          widget.skieur.creditEnCours = false;
        });

       await sauvegarderDonnees();

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      child: Text(
      t(
  "Crédit",
  "Credit",
  "Credito",
  "Crédito",
  "Guthaben",
),
   ),
    
  ),
  ),

            const SizedBox(height: 30),



      Text(
  t(
  "Historique",
  "History",
  "Storico",
  "Historial",
  "Verlauf",
),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),
if (dateDebut != null || dateFin != null)
  Text(
    "Filtre : "
    "${dateDebut == null ? "" : "${dateDebut!.day}/${dateDebut!.month}/${dateDebut!.year}"}"
    " - "
    "${dateFin == null ? "" : "${dateFin!.day}/${dateFin!.month}/${dateFin!.year}"}",
  ),
Text(
  "${t(
    "Sessions affichées",
    "Displayed sessions",
    "Sessioni visualizzate",
    "Sesiones mostradas",
    "Angezeigte Sitzungen",
  )} : ${sessionsFiltrees.length}",
),
Row(

  children: [

    Expanded(

      child: ElevatedButton(

        onPressed: () async {

          final date =
              await showDatePicker(

            context: context,

            initialDate:
            dateDebut ?? DateTime.now(),

            firstDate:
                DateTime(2020),

            lastDate:
                DateTime(2100),
          );

          if (date != null) {

            setState(() {
              dateDebut = date;
            });

          }
        },

        child: Text(

          dateDebut == null

          ? t(
  "Date début",
  "Start date",
  "Data di inizio",
  "Fecha de inicio",
  "Startdatum",
)

          : "${dateDebut!.day}/"
            "${dateDebut!.month}/"
            "${dateDebut!.year}",
        ),
      ),
    ),

    const SizedBox(width: 10),

    Expanded(

      child: ElevatedButton(

        onPressed: () async {

          final date =
              await showDatePicker(

            context: context,

            initialDate:
            dateFin ?? dateDebut ?? DateTime.now(),

            firstDate:
                DateTime(2020),

            lastDate:
                DateTime(2100),
          );

          if (date != null) {

            setState(() {
              dateFin = date;
            });

          }
        },

        child: Text(

          dateFin == null

          ? t(
  "Date fin",
  "End date",
  "Data di fine",
  "Fecha de fin",
  "Enddatum",
)

          : "${dateFin!.day}/"
            "${dateFin!.month}/"
            "${dateFin!.year}",
        ),
      ),
    ),
  ],
),

SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(

    onPressed: () {

      Navigator.push(

        context,

        MaterialPageRoute(
          builder: (context) =>
            StatistiquesSkieurPage(
               skieur: widget.skieur,
               sessions: sessionsFiltrees,
          ),  
        ),
      );
    },

    icon: const Icon(
      Icons.bar_chart,
    ),

    label:  Text(
      t(
  "Statistiques générales",
  "General statistics",
  "Statistiche generali",
  "Estadísticas generales",
  "Allgemeine Statistiken",
),
    ),

    style:
        ElevatedButton.styleFrom(

      backgroundColor:
          Colors.deepPurple,

      foregroundColor:
          Colors.white,
    ),
  ),
),

const SizedBox(height:10),

SizedBox(
  width: double.infinity,

  child: ElevatedButton.icon(

    onPressed: () async {
      await exporterHistoriquePDF();
    },

    icon: const Icon(
      Icons.picture_as_pdf,
    ),

    label: Text(
  t(
  "Exporter historique PDF",
  "Export history PDF",
  "Esporta storico PDF",
  "Exportar historial PDF",
  "PDF-Verlauf exportieren",
),
),

    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
  ),
),

const SizedBox(height:10),



const SizedBox(height: 20),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,

  child: ElevatedButton(

    onPressed: () {

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(
          builder: (context) =>
              const MenuPage(),
        ),

        (route) => false,
      );
    },

child: Text(
  t(
  "Retour à l'accueil",
  "Back to home",
  "Torna alla home",
  "Volver al inicio",
  "Zurück zur Startseite",
),
   ),
  ),
),




Expanded(

              child:
              ListView.builder(

                itemCount:
                 sessionsFiltrees.length,

                itemBuilder:
                (context,index){

                 final s =
                  sessionsFiltrees[index]; 

                  return Card(

                    child: ListTile(

                      title: Text(
                        s.discipline,
                      ),

                      subtitle: Text(

"${s.venue.day}/"
"${s.venue.month}/"
"${s.venue.year}\n"

"${s.duree}\n"

"${t(
  "Départ",
  "Departure",
  "Partenza",
  "Salida",
  "Abfahrt",
)} : ${s.depart}\n"

"${t(
  "Arrivée",
  "Arrival",
  "Arrivo",
  "Llegada",
  "Ankunft",
)} : ${s.arrivee}\n"

"${t(
  "Tours",
  "Laps",
  "Giri",
  "Vueltas",
  "Runden",
)} : ${s.tours}\n"

"${t(
  "Paiement",
  "Payment",
  "Pagamento",
  "Pago",
  "Zahlung",
)} : ${s.paiement}\n"

"${t(
  "Montant",
  "Amount",
  "Importo",
  "Importe",
  "Betrag",
)} : ${s.montant.toStringAsFixed(2)} €\n"

"${t(
  "Observation",
  "Observation",
  "Osservazione",
  "Observación",
  "Beobachtung",
)} : ${s.observation}",
),



                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PresenceLigne {
  final Skieur skieur;
  final SessionHistorique session;

  PresenceLigne({
    required this.skieur,
    required this.session,
  });
}

   class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {

  bool dejaScanne = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
  t(
    "SCAN QR",
    "QR SCAN",
    "SCANSIONE QR",
    "ESCANEAR QR",
    "QR-SCAN",
  ),
),
      ),

      body: MobileScanner(
        onDetect: (capture) {

    if (dejaScanne) return;

setState(() {
  dejaScanne = true;
});

  final code =
      capture.barcodes.first.rawValue;
  
  if (code == null) return;

          
          for (var skieur in skieursGlobal) {

            if (skieur.numeroCarteClub == code) {

              Navigator.pop(
                context,
                skieur,
              );

              return;
            }
          }

          Navigator.pop(
  context,
  code,
);
        },
      ),
    );
  }
}
class StatistiquesPage extends StatefulWidget {

  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() =>
      _StatistiquesPageState();
}

class _StatistiquesPageState
    extends State<StatistiquesPage> {

  DateTime? dateDebut;
  DateTime? dateFin;

final GlobalKey disciplinesChartKey = GlobalKey();
final GlobalKey paiementsChartKey = GlobalKey();

Future<Uint8List> captureChart(GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;

  final image = await boundary.toImage(pixelRatio: 2);
  final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

  Future<void> exporterStatistiquesSaisonPDF() async {
  final pdf = pw.Document();

  final disciplinesImage =
    pw.MemoryImage(await captureChart(disciplinesChartKey));

  final paiementsImage =
    pw.MemoryImage(await captureChart(paiementsChartKey));

  int totalSkieurs = skieursGlobal.length;
  int totalTours = 0;
  double totalCA = 0;

  Map<String, int> disciplines = {};
  Map<String, int> paiements = {};

  for (var skieur in skieursGlobal) {
    for (var s in skieur.historique) {
      if (dateDebut != null && s.venue.isBefore(dateDebut!)) {
        continue;
      }

      if (dateFin != null &&
          s.venue.isAfter(dateFin!.add(const Duration(days: 1)))) {
        continue;
      }

      totalTours += s.tours;
      if (!s.paiement.toUpperCase().contains('CRÉDIT') &&
          !s.paiement.toUpperCase().contains('CREDIT')) {
      totalCA += s.montant;
      }
      
      if (s.discipline != "VENTE UNITÉS") {
        disciplines[s.discipline] =
            (disciplines[s.discipline] ?? 0) + 1;
      }

      final paiementCourt = s.paiement.split('\n').first;
      paiements[paiementCourt] =
          (paiements[paiementCourt] ?? 0) + 1;
    }
  }

  final int totalDisciplines =
      disciplines.values.fold(0, (a, b) => a + b);

  final int totalPaiements =
      paiements.values.fold(0, (a, b) => a + b);

final skieursVenuMap = <String, Skieur>{};

for (var skieur in skieursGlobal) {
  for (var s in skieur.historique) {
    if (dateDebut != null && s.venue.isBefore(dateDebut!)) {
      continue;
    }

    if (dateFin != null &&
        s.venue.isAfter(dateFin!.add(const Duration(days: 1)))) {
      continue;
    }

    final cle = "${skieur.prenom}-${skieur.nom}-${skieur.naissance}";
    skieursVenuMap[cle] = skieur;
  }
}






  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          "WATER SKI APP",
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 10),

        pw.Text(
          "STATISTIQUES SAISON",
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 20),

        pw.Text("Skieurs saison : $totalSkieurs"),
        pw.Text("Tours réalisés : $totalTours"),
        pw.Text("CA saison : ${totalCA.toStringAsFixed(2)} EUR"),

        

        pw.SizedBox(height: 20),

        pw.Text(
          "Disciplines",
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        ...disciplines.entries.map((e) {
          final pourcentage =
              totalDisciplines == 0 ? 0 : (e.value / totalDisciplines * 100);

          return pw.Text(
            "${e.key} : ${pourcentage.toStringAsFixed(0)} %",
          );
        }),

        pw.SizedBox(height: 20),

        pw.Image(
       disciplinesImage,
       height: 160,
        ),

        pw.SizedBox(height: 20),

        pw.Text(
          "Paiements",
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        ...paiements.entries.map((e) {
          final pourcentage =
              totalPaiements == 0 ? 0 : (e.value / totalPaiements * 100);

            

          return pw.Text(
            "${e.key} : ${pourcentage.toStringAsFixed(0)} %",
          );
        }),
      
       pw.SizedBox(height: 20),

       pw.Image(
       paiementsImage,
       height: 160, 
        ),

      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: "statistiques_saison.pdf",
  );
}

  @override
  Widget build(BuildContext context) {

    int totalSkieurs = skieursGlobal.length;

    int totalTours = 0;

    int totalSessions = 0;

Map<String,int> disciplines = {};

Map<String,int> paiements = {};

double totalCA = 0;



    for (var skieur in skieursGlobal) {

    

  for (var s in skieur.historique) {

    if (
      dateDebut != null &&
      s.venue.isBefore(dateDebut!)
    ) {
      continue;
    }

    if (
      dateFin != null &&
      s.venue.isAfter(
        dateFin!.add(
          const Duration(days:1),
        ),
      )
    ) {
      continue;
    }

   

    totalSessions++;

    totalTours += s.tours;

    if (s.discipline != "VENTE UNITÉS") {
  disciplines[s.discipline] =
      (disciplines[s.discipline] ?? 0) + 1;
}

    final paiementCourt = s.paiement.split('\n').first;

    paiements[paiementCourt] =
       (paiements[paiementCourt] ?? 0) + 1;

    if (!s.paiement.toUpperCase().contains('CRÉDIT') &&
        !s.paiement.toUpperCase().contains('CREDIT')) {
     totalCA += s.montant;
   }
  }


}
final int totalDisciplines =
    disciplines.values.fold(0, (a, b) => a + b);

final int totalPaiements =
    paiements.values.fold(0, (a, b) => a + b);

    final skieursVenuMap = <String, Skieur>{};

for (var skieur in skieursGlobal) {
  for (var s in skieur.historique) {
    if (dateDebut != null && s.venue.isBefore(dateDebut!)) {
      continue;
    }

    if (dateFin != null &&
        s.venue.isAfter(dateFin!.add(const Duration(days: 1)))) {
      continue;
    }

    final cle = "${skieur.prenom}-${skieur.nom}-${skieur.naissance}";
    skieursVenuMap[cle] = skieur;
  }
}



final presences = <PresenceLigne>[];

for (var skieur in skieursGlobal) {
  for (var s in skieur.historique) {
    if (dateDebut != null && s.venue.isBefore(dateDebut!)) {
      continue;
    }

    if (dateFin != null &&
        s.venue.isAfter(dateFin!.add(const Duration(days: 1)))) {
      continue;
    }

    presences.add(
      PresenceLigne(
        skieur: skieur,
        session: s,
      ),
    );
  }
}

presences.sort(
  (a, b) => a.session.venue.compareTo(b.session.venue),
);

final couleurs = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.teal,
];

Widget legendeCouleur(Color couleur, String texte) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texte,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    ),
  );
}

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          t(
  "STATISTIQUES SAISON",
  "SEASON STATISTICS",
  "STATISTICHE STAGIONE",
  "ESTADÍSTICAS DE TEMPORADA",
  "SAISONSTATISTIKEN",
),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(

          children: [

            Row(

  children:[

    Expanded(

      child: ElevatedButton(

        onPressed: () async {

          final date =
              await showDatePicker(

            context: context,

            initialDate:
                DateTime.now(),

            firstDate:
                DateTime(2020),

            lastDate:
                DateTime(2100),
          );

          if(date != null){

            setState(() {
              dateDebut = date;
            });

          }
        },

        child: Text(

          dateDebut == null

          ? t(
  "Début",
  "Start",
  "Inizio",
  "Inicio",
  "Beginn",
)

          : "${dateDebut!.day}/"
            "${dateDebut!.month}/"
            "${dateDebut!.year}",
        ),
      ),
    ),

    const SizedBox(width:10),

    Expanded(

      child: ElevatedButton(

        onPressed: () async {

          final date =
              await showDatePicker(

            context: context,

            initialDate:
                DateTime.now(),

            firstDate:
                DateTime(2020),

            lastDate:
                DateTime(2100),
          );

          if(date != null){

            setState(() {
              dateFin = date;
            });

          }
        },

        child: Text(

          dateFin == null

          ?t(
  "Fin",
  "End",
  "Fine",
  "Fin",
  "Ende",
)

          : "${dateFin!.day}/"
            "${dateFin!.month}/"
            "${dateFin!.year}",
        ),
      ),
    ),
  ],
),

const SizedBox(height:20),

            Text(
  "${t(
  "Skieurs enregistrés",
  "Registered skiers",
  "Sciatori registrati",
  "Esquiadores registrados",
  "Registrierte Skifahrer",
)} : $totalSkieurs",
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Text(
"${t(
  "Sessions réalisées",
  "Completed sessions",
  "Sessioni effettuate",
  "Sesiones realizadas",
  "Durchgeführte Sitzungen",
)} : $totalSessions",
),

            const SizedBox(height: 20),

            Text(
              "${t(
  "Tours réalisés",
  "Completed laps",
  "Giri effettuati",
  "Vueltas realizadas",
  "Gefahrene Runden",
)} : $totalTours",
            ),

           const SizedBox(height: 20),

Text(
"${t(
  "CA saison",
  "Season revenue",
  "Fatturato stagione",
  "Ingresos de la temporada",
  "Saisonumsatz",
)} : ${totalCA.toStringAsFixed(2)} EUR",
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
 const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PresencesPage(
            presences: presences,
          ),
        ),
      );
    },
    icon: const Icon(Icons.people),
    label: Text(t(
  "Liste des présences",
  "Attendance list",
  "Elenco delle presenze",
  "Lista de asistencias",
  "Anwesenheitsliste",
)),
  ),
),

const SizedBox(height: 20),


  Text(
  t(
  "Disciplines",
  "Disciplines",
  "Discipline",
  "Disciplinas",
  "Disziplinen",
),
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 220,
  child: RepaintBoundary(
    key: disciplinesChartKey,
    child: PieChart(
      PieChartData(
        centerSpaceRadius: 55,
        sections: disciplines.entries.map((e) {
          final pourcentage =
              totalDisciplines == 0
                  ? 0
                  : (e.value / totalDisciplines * 100);

          final couleur = couleurs[
              disciplines.keys.toList().indexOf(e.key) %
              couleurs.length];

          return PieChartSectionData(
            color: couleur,
            value: e.value.toDouble(),
            title: "${pourcentage.toStringAsFixed(0)}%",
            radius: 45,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    ),
  ),
),

const SizedBox(height: 20),

...disciplines.entries.map((e) {
  final pourcentage =
      totalDisciplines == 0
          ? 0
          : (e.value / totalDisciplines * 100);

  final couleur = couleurs[
      disciplines.keys.toList().indexOf(e.key) %
      couleurs.length];

  return legendeCouleur(
    couleur,
    "${e.key} : ${pourcentage.toStringAsFixed(0)} %",
  );
}),

const SizedBox(height: 20),


  Text(
  t(
  "Paiements",
  "Payments",
  "Pagamenti",
  "Pagos",
  "Zahlungen",
),
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

SizedBox(
  height: 220,
  child: RepaintBoundary(
    key: paiementsChartKey,
    child: PieChart(
      PieChartData(
        centerSpaceRadius: 55,
        sections: paiements.entries.map((e) {
          final pourcentage =
              totalPaiements == 0
                  ? 0
                  : (e.value / totalPaiements * 100);

          final couleur = couleurs[
              paiements.keys.toList().indexOf(e.key) %
              couleurs.length];

          return PieChartSectionData(
            color: couleur,
            value: e.value.toDouble(),
            title: "${pourcentage.toStringAsFixed(0)}%",
            radius: 45,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    ),
  ),
),


          const SizedBox(height: 20),


...paiements.entries.map((e) {
  final pourcentage =
      totalPaiements == 0
          ? 0
          : (e.value / totalPaiements * 100);

  final couleur = couleurs[
      paiements.keys.toList().indexOf(e.key) %
      couleurs.length];

  return legendeCouleur(
    couleur,
    "${e.key} : ${pourcentage.toStringAsFixed(0)} %",
  );
}),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      await exporterStatistiquesSaisonPDF();
    },
    icon: const Icon(Icons.picture_as_pdf),
    label: Text(
    t(
  "Exporter statistiques PDF",
  "Export statistics PDF",
  "Esporta statistiche PDF",
  "Exportar estadísticas PDF",
  "Statistiken als PDF exportieren",
),
  ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}

class StatistiquesSkieurPage extends StatelessWidget {
  final Skieur skieur;
  final List<SessionHistorique> sessions;

  const StatistiquesSkieurPage({
    super.key,
    required this.skieur,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    int totalTours = 0;
    Map<String, int> disciplines = {};
    Map<String, int> paiements = {};
    double totalCA = 0;

      for (var s in sessions) {
      totalTours += s.tours;

      if (s.discipline != "VENTE UNITÉS") {
        disciplines[s.discipline] =
            (disciplines[s.discipline] ?? 0) + 1;
      }

      paiements[s.paiement] =
          (paiements[s.paiement] ?? 0) + 1;

      if (!s.paiement.toUpperCase().contains('CRÉDIT') &&
          !s.paiement.toUpperCase().contains('CREDIT')) {
        totalCA += s.montant;
      }
    }

    return Scaffold(

      appBar: AppBar(
        backgroundColor:
            Colors.deepPurple,

        title: Text(
t(
  "STATISTIQUES SKIEUR",
  "SKIER STATISTICS",
  "STATISTICHE SCIATORE",
  "ESTADÍSTICAS DEL ESQUIADOR",
  "SKIFAHRER-STATISTIKEN",
),
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: ListView(

          children:[

            Text(
              "${skieur.prenom} ${skieur.nom}",

              style:
              const TextStyle(

                fontSize:28,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(skieur.naissance),

            Text(skieur.telephone),

            Text(skieur.email),

            const SizedBox(height:30),

            Text(
              "${t(
  "Tours",
  "Laps",
  "Giri",
  "Vueltas",
  "Runden",
)} : $totalTours",
            ),

            Text(
              "${t(
  "CA",
  "Revenue",
  "Fatturato",
  "Ingresos",
  "Umsatz",
)} : ${totalCA.toStringAsFixed(2)} EUR",
            ),

            const SizedBox(height:20),

            Text(
  t(
    "Disciplines",
    "Disciplines",
    "Discipline",
    "Disciplinas",
    "Disziplinen",
  ),
),

            ...disciplines.entries.map(
               (e) => Text(
                  "${e.key} : ${e.value}",
              ),
            ),

            const SizedBox(height:20),

            Text(
             t(
  "Paiements",
  "Payments",
  "Pagamenti",
  "Pagos",
  "Zahlungen",
), 
            ),

            ...paiements.entries.map(
              (e)=>Text(
                e.key,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PresencesPage extends StatelessWidget {
  final List<PresenceLigne> presences;

  const PresencesPage({
    super.key,
    required this.presences,
  });

  Future<void> exporterPresencesPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "WATER SKI APP",
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(
            "LISTE DES PRÉSENCES",
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text("Nombre de présences : ${presences.length}"),

          pw.SizedBox(height: 20),

          ...presences.map((p) {
            final skieur = p.skieur;
            final session = p.session;

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "${skieur.prenom} ${skieur.nom}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text("Naissance : ${skieur.naissance}"),
                  pw.Text(
                    "Date : ${session.venue.day}/${session.venue.month}/${session.venue.year}",
                  ),
                  pw.Text("Discipline : ${session.discipline}"),
                  pw.Text("Arrivée : ${session.depart}"),
                  pw.Text("Départ : ${session.arrivee}"),
                  pw.Text("Durée : ${session.duree}"),
                  pw.Text("Tours : ${session.tours}"),
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "presences.pdf",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
           t(
  "PRÉSENCES",
  "ATTENDANCE",
  "PRESENZE",
  "ASISTENCIAS",
  "ANWESENHEITEN",
),
         )
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: exporterPresencesPDF,
                icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                 t(
  "Exporter présences PDF",
  "Export attendance PDF",
  "Esporta presenze PDF",
  "Exportar asistencias PDF",
  "Anwesenheiten als PDF exportieren",
),
               ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: presences.length,
              itemBuilder: (context, index) {
                final p = presences[index];
                final skieur = p.skieur;
                final session = p.session;

                return Card(
                  child: ListTile(
                    title: Text(
                      "${skieur.prenom} ${skieur.nom} - ${skieur.naissance}",
                    ),
                    subtitle: Text(
                      "${t(
  "Date",
  "Date",
  "Data",
  "Fecha",
  "Datum",
)} : ${session.venue.day}/${session.venue.month}/${session.venue.year}\n"
                        "${t(
  "Discipline",
  "Discipline",
  "Disciplina",
  "Disciplina",
  "Disziplin",
)} : ${session.discipline}\n"
            "${t(
  "Départ",
  "Departure",
  "Partenza",
  "Salida",
  "Abfahrt",
)} : ${session.depart}\n"
"${t(
  "Arrivée",
  "Arrival",
  "Arrivo",
  "Llegada",
  "Ankunft",
)} : ${session.arrivee}"            
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  Future<void> exporterGuidePDF() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
t(
  "WATER SKI APP - GUIDE UTILISATEUR",
  "WATER SKI APP - USER GUIDE",
  "WATER SKI APP - GUIDA UTENTE",
  "WATER SKI APP - GUÍA DEL USUARIO",
  "WATER SKI APP - BENUTZERHANDBUCH",
),
          style: pw.TextStyle(
            fontSize: 18,
            height: 1.5,
),
        ),

        pw.SizedBox(height: 20),

       ...t(
  """
1. Nouveau skieur

Saisissez :
- Nom
- Prénom
- Date de naissance
- Téléphone
- E-mail

Puis cliquez sur Enregistrer.

2. Choisir une discipline

Sélectionnez :
- BI-SKI
- SLALOM
- FIGURES
- WAKEBOARD
- SAUT

3. Temps de session

Enregistrez :
- Heure de départ
- Heure d'arrivée
- Nombre de tours

Puis cliquez sur Enregistrer la session.

4. Facturation

Utilisez la calculatrice intégrée.

Exemple :
10 x 5 = 50 EUR

Puis cliquez sur Taper règlement.

5. Règlement

Choisissez :
- Espèces
- Chèque
- Carte bancaire
- Virement
- Crédit
- Carte Club

6. Récapitulatif

Ajoutez une observation si nécessaire puis cliquez sur :

Terminer la session.

La session est enregistrée dans l'historique du client.



GESTION DU CRÉDIT

- Un voyant rouge apparaît.
- Le montant n'est pas comptabilisé dans le chiffre d'affaires.



RÉGULARISATION D'UN CRÉDIT

Lorsqu'une session ou un achat d'unités est enregistré en Crédit :

- Le crédit apparaît dans le dossier client.
- Un voyant rouge apparaît sur la page d'accueil.
- Le montant n'est pas comptabilisé dans le chiffre d'affaires.



RÈGLEMENT D'UN CRÉDIT

1. Depuis la page d'accueil, saisir le nom du client.

2. Ouvrir le dossier client.

3. Accéder à l'Historique.

4. Cliquer sur Crédit réglé.

- Le voyant rouge disparaît.
- Le voyant passe au vert.

5. Revenir à la page d'accueil.

6. Rechercher à nouveau le client.

7. Vérifier les coordonnées affichées.

DISCIPLINE

- Cliquer sur PASSER pour aller à facturation



FACTURATION

1. Saisir le montant à régulariser.
2. Cliquer sur Taper règlement.



RÈGLEMENT

Choisir le mode de paiement :

- Espèces
- Chèque
- Carte bancaire
- Virement



RÉCAPITULATIF

1. Vérifier les informations affichées.
2. Ajouter une observation si nécessaire.
3. Cliquer sur Terminer la session.



DOSSIER CLIENT

Le crédit est alors marqué comme réglé.

Le montant est intégré :

- Au chiffre d'affaires
- Aux statistiques
- Aux exports PDF
- Le voyant de suivi passe au vert.

Puis revenir à l'accueil.



CARTE CLUB

- 1 tour = 1 unité.
- Recharge possible à tout moment.

CRÉATION ET CHARGEMENT D'UNE CARTE

1. Créer un nouveau skieur.
2. Saisir :
   - Nom
   - Prénom
   - Date de naissance
   - Téléphone
   - E-mail
3. Cliquer sur Enregistrer.

DISCIPLINE

Cliquer sur PASSER.

FACTURATION

1. Saisir le nombre d'unités à créditer.

Exemple :
60 unités

2. Calculer le montant.

Exemple :
60 x 5 EUR = 300 EUR

3. Cliquer sur Taper règlement.



RÈGLEMENT

Choisir :
- Espèces
- Chèque
- Carte bancaire
- Virement
- Crédit



CARTE CLUB

1. Vérifier le nombre d'unités affiché.
2. Scanner une carte.
3. Vérifier l'attribution.
4. Cliquer sur VALIDER.



RÉCAPITULATIF

- Paiement effectué
- Montant réglé
- Unités chargées
- Unités restantes

Cliquer sur Terminer la session.



DOSSIER CLIENT

- Historique client
- Statistiques
- Exports PDF

Retour à l'accueil.

""",
  """
QUICK USER GUIDE

1. New skier

Enter:
- Last name
- First name
- Birth date
- Phone
- E-mail

Then press Save.

2. Choose a discipline

Select:
- BI-SKI
- SLALOM
- TRICKS
- WAKEBOARD
- JUMP

3. Session time

Record:
- Start time
- Finish time
- Number of laps

Then press Save session.

4. Billing

Use the built-in calculator.

Example:
10 x 5 = 50 EUR

Then press Enter payment.

5. Payment

Choose:
- Cash
- Check
- Credit card
- Bank transfer
- Credit
- Club Card

6. Summary

Add a note if needed then click:

End session.

The session is saved in the customer's history.

CREDIT MANAGEMENT

- A red indicator appears.
- The amount is not included in revenue.

CREDIT SETTLEMENT

When a session or unit purchase is recorded as Credit:

- The credit appears in the customer file.
- A red indicator appears on the home page.
- The amount is not included in revenue.

PAYING A CREDIT

1. From the home page, enter the customer's name.

2. Open the customer file.

3. Open History.

4. Click Credit paid.

- The red indicator disappears.
- The indicator turns green.

5. Return to the home page.

6. Search for the customer again.

7. Verify the displayed information.

DISCIPLINE

- Click SKIP to go to Billing.

BILLING

1. Enter the amount to settle.
2. Click Enter payment.

PAYMENT

Choose the payment method:

- Cash
- Check
- Credit card
- Bank transfer

SUMMARY

1. Verify the displayed information.
2. Add a note if necessary.
3. Click End session.

CUSTOMER FILE

The credit is now marked as paid.

The amount is included in:

- Revenue
- Statistics
- PDF exports

The indicator turns green.

Return to the home page.

CLUB CARD

- 1 lap = 1 unit.
- Recharge possible at any time.

CREATING AND LOADING A CARD

1. Create a new skier.
2. Enter:
   - Last name
   - First name
   - Birth date
   - Phone
   - E-mail
3. Click Save.

DISCIPLINE

Click SKIP.

BILLING

1. Enter the number of units to load.

Example:
60 units

2. Calculate the amount.

Example:
60 x 5 EUR = 300 EUR

3. Click Enter payment.

PAYMENT

Choose:

- Cash
- Check
- Credit card
- Bank transfer
- Credit

CLUB CARD

1. Verify the displayed number of units.
2. Scan a card.
3. Verify assignment.
4. Click VALIDATE.

SUMMARY

- Payment completed
- Amount paid
- Units loaded
- Units remaining

Click End session.

CUSTOMER FILE

- Customer history
- Statistics
- PDF exports

Return to home page.

USING A CLUB CARD

When a skier already has a Club Card:

1. Scan the card.

2. Verify the displayed information:

- Last name
- First name
- Birth date
- Phone
- E-mail

3. Click Save.

DISCIPLINE

Select a discipline:

- BI-SKI
- SLALOM
- TRICKS
- WAKEBOARD
- JUMP

The application opens the Session Time page.

SESSION TIME

Enter:

- Start time
- Finish time
- Number of laps completed

Then click Save session.

BILLING

Verify the number of laps.

Click Enter payment.

PAYMENT

Choose:

- Club Card

CLUB CARD

1. Verify remaining units.
2. Scan the card.
3. Units are manually deducted by the instructor or coach.
4. Click VALIDATE.

SUMMARY

The summary displays:

- Discipline
- Number of laps
- Units used
- Units remaining

Click End session.

CUSTOMER FILE

The session is saved in:

- Customer history
- Statistics
- PDF exports

Return to the home page.

HISTORY

View individual records:

- Sessions
- Payments
- Amounts
- Notes

STATISTICS

View collective statistics:

- Skiers
- Sessions
- Laps
- Revenue
- Attendance

PDF export available.
""",
).split('\n').map((ligne) {
  if (ligne.trim().isEmpty) {
    return pw.SizedBox(height: 12);
  }

  return pw.Text(
    ligne,
    style: pw.TextStyle(
      fontSize: 11,
    ),
  );
}),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: "guide_utilisateur.pdf",
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
  t(
    "GUIDE UTILISATEUR",
    "USER GUIDE",
    "GUIDA UTENTE",
    "GUÍA DEL USUARIO",
    "BENUTZERHANDBUCH",
  ),
),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

  SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () async {
      await exporterGuidePDF();
    },
    icon: const Icon(Icons.picture_as_pdf),
    label: Text(

  t(
    "Exporter guide PDF",
    "Export guide PDF",
    "Esporta guida PDF",
    "Exportar guía PDF",
    "Benutzerhandbuch als PDF exportieren",
  ),
),

style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
),

const SizedBox(height: 20),
   

    Text(
      t(
         """
1. Nouveau skieur

Saisissez :
• Nom
• Prénom
• Date de naissance
• Téléphone
• E-mail

Puis cliquez sur Enregistrer.

2. Choisir une discipline

Sélectionnez :
• BI-SKI
• SLALOM
• FIGURES
• WAKEBOARD
• SAUT

3. Temps de session

Enregistrez :
• Heure de départ
• Heure d'arrivée
• Nombre de tours

Puis cliquez sur Enregistrer la session.

4. Facturation

Utilisez la calculatrice intégrée.

Exemple :
10 x 5 = 50 €

Puis cliquez sur Taper règlement.

5. Règlement

Choisissez :
• Espèces
• Chèque
• Carte bancaire
• Virement
• Crédit
• Carte Club

6. Récapitulatif

Ajoutez une observation si nécessaire puis cliquez sur :

Terminer la session.

La session est enregistrée dans l'historique du client.

GESTION DU CRÉDIT

• Un voyant rouge apparaît.
• Le montant n'est pas comptabilisé dans le chiffre d'affaires.

RÉGULARISATION D'UN CRÉDIT

Lorsqu'une session ou un achat d'unités est enregistré en Crédit :

• Le crédit apparaît dans le dossier client.
• Un voyant rouge apparaît sur la page d'accueil.
• Le montant n'est pas comptabilisé dans le chiffre d'affaires.

RÈGLEMENT D'UN CRÉDIT

1. Depuis la page d'accueil, saisir le nom du client.

2. Ouvrir le dossier client.

3. Accéder à l'Historique.

4. Cliquer sur Crédit réglé.

• Le voyant rouge disparaît.

• Le voyant passe au vert.

5. Revenir à la page d'accueil.

6. Rechercher à nouveau le client.

7. Vérifier les coordonnées affichées.

DISCIPLINE


• Cliquer sur PASSER pour aller à facturation

FACTURATION

1. Saisir le montant à régulariser.
2. Cliquer sur Taper règlement.

RÈGLEMENT

Choisir le mode de paiement :

• Espèces
• Chèque
• Carte bancaire
• Virement

RÉCAPITULATIF

1. Vérifier les informations affichées.
2. Ajouter une observation si nécessaire.
3. Cliquer sur Terminer la session.

DOSSIER CLIENT

Le crédit est alors marqué comme réglé.

Le montant est intégré :

• Au chiffre d'affaires
• Aux statistiques
• Aux exports PDF
• Le voyant de suivi passe au vert.

Puis revenir à l'accueil.


CARTE CLUB

• 1 tour = 1 unité.
• Recharge possible à tout moment.

CRÉATION ET CHARGEMENT D'UNE CARTE

1. Créer un nouveau skieur.
2. Saisir :
   - Nom
   - Prénom
   - Date de naissance
   - Téléphone
   - E-mail
3. Cliquer sur Enregistrer.

DISCIPLINE

Cliquer sur PASSER.

FACTURATION

1. Saisir le nombre d'unités à créditer.

Exemple :
60 unités

2. Calculer le montant.

Exemple :
60 x 5 € = 300 €

3. Cliquer sur Taper règlement.

RÈGLEMENT

Choisir :
• Espèces
• Chèque
• Carte bancaire
• Virement
• Crédit

CARTE CLUB

1. Vérifier le nombre d'unités affiché.
2. Scanner une carte.
3. Vérifier l'attribution.
4. Cliquer sur VALIDER.

RÉCAPITULATIF

• Paiement effectué
• Montant réglé
• Unités chargées
• Unités restantes

Cliquer sur Terminer la session.

DOSSIER CLIENT

• Historique client
• Statistiques
• Exports PDF

Retour à l'accueil.

UTILISATION D'UNE CARTE CLUB

Lorsqu'un skieur possède déjà une Carte Club :

1. Scanner la carte.

2. Vérifier les informations affichées :
   - Nom
   - Prénom
   - Date de naissance
   - Téléphone
   - E-mail

3. Cliquer sur Enregistrer.

DISCIPLINE

Sélectionner la discipline :

• BI-SKI
• SLALOM
• FIGURES
• WAKEBOARD
• SAUT

L'application passe à la page Temps de session.

TEMPS DE SESSION

Saisir :

• Heure de départ
• Heure d'arrivée
• Nombre de tours réalisés

Puis cliquer sur Enregistrer la session.

FACTURATION

Vérifier le nombre de tours enregistrés.

Cliquer sur Taper règlement.

RÈGLEMENT

Choisir :

• Carte Club


CARTE CLUB

1. Vérifier le nombre d'unités restantes.
2. Scanner la carte.
3. Les unités consommées sont déduites manuellement par vous : ( moniteur ou coach)
4. Cliquer sur VALIDER.

RÉCAPITULATIF

Le récapitulatif affiche :

• Discipline
• Nombre de tours
• Unités consommées
• Unités restantes

Cliquer sur Terminer la session.

DOSSIER CLIENT

La session est enregistrée dans :

• L'historique du client
• Les statistiques
• Les exports PDF

Puis revenir à l'accueil.

HISTORIQUE

Consultation des dossiers individuels :
• Sessions
• Paiements
• Montants
• Observations

STATISTIQUES

Consultation des statistiques collectives:
• Skieurs
• Sessions
• Tours
• Chiffre d'affaires
• Présences

Export PDF disponible.
""",
       """
QUICK USER GUIDE

1. New skier

Enter:
• Last name
• First name
• Date of birth
• Phone
• E-mail

Then click Save.

2. Choose a discipline

Select:
• BI-SKI
• SLALOM
• TRICKS
• WAKEBOARD
• JUMP

3. Session time

Record:
• Start time
• Finish time
• Number of laps

Then click Save session.

4. Billing

Use the built-in calculator.

Example:
10 x 5 = 50 €

Then click Enter payment.

5. Payment

Choose:
• Cash
• Cheque
• Credit card
• Bank transfer
• Credit
• Club Card

6. Summary

Add a note if necessary, then click:

End session.

The session is saved in the customer history.

CREDIT MANAGEMENT

• A red indicator appears.
• The amount is not included in the revenue.

CREDIT SETTLEMENT

When a session or a unit purchase is recorded as Credit:

• The credit appears in the customer file.
• A red indicator appears on the home page.
• The amount is not included in the revenue.

PAYMENT OF A CREDIT

1. From the home page, enter the customer's name.

2. Open the customer file.

3. Go to History.

4. Click Credit paid.

• The red indicator disappears.
• The indicator turns green.

5. Return to the home page.

6. Search for the customer again.

7. Check the displayed information.

DISCIPLINE

• Click SKIP to go to billing.

BILLING

1. Enter the amount to settle.
2. Click Enter payment.

PAYMENT

Choose the payment method:

• Cash
• Cheque
• Credit card
• Bank transfer

SUMMARY

1. Check the displayed information.
2. Add a note if necessary.
3. Click End session.

CUSTOMER FILE

The credit is then marked as paid.

The amount is included in:

• Revenue
• Statistics
• PDF exports
• The tracking indicator turns green.

Then return to the home page.

CLUB CARD

• 1 lap = 1 unit.
• Recharge possible at any time.

CREATING AND LOADING A CARD

1. Create a new skier.
2. Enter:
   - Last name
   - First name
   - Date of birth
   - Phone
   - E-mail
3. Click Save.

DISCIPLINE

Click SKIP.

BILLING

1. Enter the number of units to credit.

Example:
60 units

2. Calculate the amount.

Example:
60 x 5 € = 300 €

3. Click Enter payment.

PAYMENT

Choose:
• Cash
• Cheque
• Credit card
• Bank transfer
• Credit

CLUB CARD

1. Check the number of units displayed.
2. Scan a card.
3. Check the assignment.
4. Click VALIDATE.

SUMMARY

• Payment completed
• Amount paid
• Units loaded
• Remaining units

Click End session.

CUSTOMER FILE

• Customer history
• Statistics
• PDF exports

Return to the home page.

USING A CLUB CARD

When a skier already has a Club Card:

1. Scan the card.

2. Check the displayed information:
   - Last name
   - First name
   - Date of birth
   - Phone
   - E-mail

3. Click Save.

DISCIPLINE

Select the discipline:

• BI-SKI
• SLALOM
• TRICKS
• WAKEBOARD
• JUMP

The application opens the Session time page.

SESSION TIME

Enter:

• Start time
• Finish time
• Number of laps completed

Then click Save session.

BILLING

Check the number of laps recorded.

Click Enter payment.

PAYMENT

Choose:

• Club Card

CLUB CARD

1. Check the number of remaining units.
2. Scan the card.
3. The units used are deducted manually by you: instructor or coach.
4. Click VALIDATE.

SUMMARY

The summary displays:

• Discipline
• Number of laps
• Units used
• Remaining units

Click End session.

CUSTOMER FILE

The session is saved in:

• Customer history
• Statistics
• PDF exports

Then return to the home page.

HISTORY

View individual files:
• Sessions
• Payments
• Amounts
• Notes

STATISTICS

View collective statistics:
• Skiers
• Sessions
• Laps
• Revenue
• Attendance

PDF export available.
""",

"""
GUIDA RAPIDA

1. Nuovo sciatore

Inserire:
- Cognome
- Nome
- Data di nascita
- Telefono
- E-mail

Quindi fare clic su Salva.

2. Scegliere una disciplina

Selezionare:
- BI-SKI
- SLALOM
- FIGURE
- WAKEBOARD
- SALTO

3. Tempo della sessione

Registrare:
- Ora di partenza
- Ora di arrivo
- Numero di giri

Quindi fare clic su Salva la sessione.

4. Fatturazione

Utilizzare la calcolatrice integrata.

Esempio:
10 x 5 = 50 EUR

Quindi fare clic su Inserisci pagamento.

5. Pagamento

Scegliere:
- Contanti
- Assegno
- Carta bancaria
- Bonifico
- Credito
- Carta Club

6. Riepilogo

Aggiungere un'osservazione se necessario, quindi fare clic su:

Termina la sessione.

La sessione viene salvata nello storico del cliente.

GESTIONE DEL CREDITO

- Compare una spia rossa.
- L'importo non viene conteggiato nel fatturato.

REGOLARIZZAZIONE DI UN CREDITO

Quando una sessione o un acquisto di unita viene registrato come Credito:

- Il credito compare nella scheda cliente.
- Compare una spia rossa nella pagina iniziale.
- L'importo non viene conteggiato nel fatturato.



PAGAMENTO DI UN CREDITO

1. Dalla pagina iniziale inserire il nome del cliente.

2. Aprire la scheda cliente.

3. Aprire lo Storico.

4. Fare clic su Credito saldato.

- La spia rossa scompare.
- La spia diventa verde.

5. Tornare alla pagina iniziale.

6. Cercare nuovamente il cliente.

7. Verificare le informazioni visualizzate.

DISCIPLINA

- Fare clic su SALTA per passare alla Fatturazione.

FATTURAZIONE

1. Inserire l'importo da regolarizzare.

2. Fare clic su Inserisci pagamento.

PAGAMENTO

Scegliere il metodo di pagamento:

- Contanti
- Assegno
- Carta bancaria
- Bonifico

RIEPILOGO

1. Verificare le informazioni visualizzate.

2. Aggiungere una osservazione se necessario.

3. Fare clic su Termina la sessione.

SCHEDA CLIENTE

Il credito viene contrassegnato come saldato.

L'importo viene incluso in:

- Fatturato
- Statistiche
- Esportazioni PDF

- La spia di controllo diventa verde.

Quindi tornare alla pagina iniziale.



CARTA CLUB

- 1 giro = 1 unita.
- Ricarica possibile in qualsiasi momento.

CREAZIONE E RICARICA DI UNA CARTA

1. Creare un nuovo sciatore.

2. Inserire:
- Cognome
- Nome
- Data di nascita
- Telefono
- E-mail

3. Fare clic su Salva.

DISCIPLINA

Fare clic su SALTA.

FATTURAZIONE

1. Inserire il numero di unita da accreditare.

Esempio:
60 unita

2. Calcolare l'importo.

Esempio:
60 x 5 EUR = 300 EUR

3. Fare clic su Inserisci pagamento.

PAGAMENTO

Scegliere:

- Contanti
- Assegno
- Carta bancaria
- Bonifico
- Credito

CARTA CLUB

1. Verificare il numero di unita visualizzate.

2. Scansionare una carta.

3. Verificare l'assegnazione.

4. Fare clic su CONFERMA.

RIEPILOGO

- Pagamento effettuato
- Importo pagato
- Unita caricate
- Unita rimanenti

Fare clic su Termina la sessione.

SCHEDA CLIENTE

- Storico cliente
- Statistiche
- Esportazioni PDF

Tornare alla pagina iniziale.



UTILIZZO DI UNA CARTA CLUB

Quando uno sciatore possiede gia una Carta Club:

1. Scansionare la carta.

2. Verificare le informazioni visualizzate:
- Cognome
- Nome
- Data di nascita
- Telefono
- E-mail

3. Fare clic su Salva.

DISCIPLINA

Selezionare la disciplina:

- BI-SKI
- SLALOM
- FIGURE
- WAKEBOARD
- SALTO

L'applicazione apre la pagina Tempo della sessione.

TEMPO DELLA SESSIONE

Inserire:

- Ora di partenza
- Ora di arrivo
- Numero di giri effettuati

Quindi fare clic su Salva la sessione.

FATTURAZIONE

Verificare il numero di giri registrati.

Fare clic su Inserisci pagamento.

PAGAMENTO

Scegliere:

- Carta Club

CARTA CLUB

1. Verificare il numero di unita rimanenti.

2. Scansionare la carta.

3. Le unita consumate vengono detratte manualmente dal monitore o dal coach.

4. Fare clic su CONFERMA.

RIEPILOGO

Il riepilogo visualizza:

- Disciplina
- Numero di giri
- Unita consumate
- Unita rimanenti

Fare clic su Termina la sessione.

SCHEDA CLIENTE

La sessione viene registrata in:

- Storico del cliente
- Statistiche
- Esportazioni PDF

Quindi tornare alla pagina iniziale.

STORICO

Consultazione delle schede individuali:

- Sessioni
- Pagamenti
- Importi
- Osservazioni

STATISTICHE

Consultazione delle statistiche generali:

- Sciatori
- Sessioni
- Giri
- Fatturato
- Presenze

Esportazione PDF disponibile.


""",
"""

GUIA RAPIDA

1. Nuevo esquiador

Introducir:
- Apellido
- Nombre
- Fecha de nacimiento
- Telefono
- E-mail

Luego hacer clic en Guardar.

2. Elegir una disciplina

Seleccionar:
- BI-SKI
- SLALOM
- FIGURAS
- WAKEBOARD
- SALTO

3. Tiempo de sesion

Registrar:
- Hora de salida
- Hora de llegada
- Numero de vueltas

Luego hacer clic en Guardar la sesion.

4. Facturacion

Usar la calculadora integrada.

Ejemplo:
10 x 5 = 50 EUR

Luego hacer clic en Introducir el pago.

5. Pago

Elegir:
- Efectivo
- Cheque
- Tarjeta bancaria
- Transferencia
- Credito
- Tarjeta Club

6. Resumen

Anadir una observacion si es necesario, luego hacer clic en:

Finalizar la sesion.

La sesion se guarda en el historial del cliente.

GESTION DEL CREDITO

- Aparece un indicador rojo.
- El importe no se contabiliza en los ingresos.

REGULARIZACION DE UN CREDITO

Cuando una sesion o una compra de unidades se registra como Credito:

- El credito aparece en la ficha del cliente.
- Aparece un indicador rojo en la pagina de inicio.
- El importe no se contabiliza en los ingresos.



PAGO DE UN CREDITO

1. Desde la pagina de inicio introducir el nombre del cliente.

2. Abrir la ficha del cliente.

3. Abrir el Historial.

4. Hacer clic en Credito pagado.

- El indicador rojo desaparece.
- El indicador pasa a verde.

5. Volver a la pagina de inicio.

6. Buscar de nuevo al cliente.

7. Verificar la informacion mostrada.

DISCIPLINA

- Hacer clic en OMITIR para pasar a Facturacion.

FACTURACION

1. Introducir el importe a regularizar.

2. Hacer clic en Introducir el pago.

PAGO

Elegir el metodo de pago:

- Efectivo
- Cheque
- Tarjeta bancaria
- Transferencia

RESUMEN

1. Verificar la informacion mostrada.

2. Anadir una observacion si es necesario.

3. Hacer clic en Finalizar la sesion.

FICHA DEL CLIENTE

El credito queda marcado como pagado.

El importe se integra en:

- Ingresos
- Estadisticas
- Exportaciones PDF

- El indicador de seguimiento pasa a verde.

Luego volver a la pagina de inicio.



TARJETA CLUB

- 1 vuelta = 1 unidad.
- Recarga posible en cualquier momento.

CREACION Y RECARGA DE UNA TARJETA

1. Crear un nuevo esquiador.

2. Introducir:
- Apellido
- Nombre
- Fecha de nacimiento
- Telefono
- E-mail

3. Hacer clic en Guardar.

DISCIPLINA

Hacer clic en OMITIR.

FACTURACION

1. Introducir el numero de unidades a acreditar.

Ejemplo:
60 unidades

2. Calcular el importe.

Ejemplo:
60 x 5 EUR = 300 EUR

3. Hacer clic en Introducir el pago.

PAGO

Elegir:

- Efectivo
- Cheque
- Tarjeta bancaria
- Transferencia
- Credito

TARJETA CLUB

1. Verificar el numero de unidades mostradas.

2. Escanear una tarjeta.

3. Verificar la asignacion.

4. Hacer clic en VALIDAR.

RESUMEN

- Pago efectuado
- Importe pagado
- Unidades cargadas
- Unidades restantes

Hacer clic en Finalizar la sesion.

FICHA DEL CLIENTE

- Historial del cliente
- Estadisticas
- Exportaciones PDF

Volver a la pagina de inicio.



USO DE UNA TARJETA CLUB

Cuando un esquiador ya dispone de una Tarjeta Club:

1. Escanear la tarjeta.

2. Verificar la informacion mostrada:
- Apellido
- Nombre
- Fecha de nacimiento
- Telefono
- E-mail

3. Hacer clic en Guardar.

DISCIPLINA

Seleccionar la disciplina:

- BI-SKI
- SLALOM
- FIGURAS
- WAKEBOARD
- SALTO

La aplicacion abre la pagina Tiempo de sesion.

TIEMPO DE SESION

Introducir:

- Hora de salida
- Hora de llegada
- Numero de vueltas realizadas

Luego hacer clic en Guardar la sesion.

FACTURACION

Verificar el numero de vueltas registradas.

Hacer clic en Introducir el pago.

PAGO

Elegir:

- Tarjeta Club

TARJETA CLUB

1. Verificar el numero de unidades restantes.

2. Escanear la tarjeta.

3. Las unidades consumidas se descuentan manualmente por el monitor o el entrenador.

4. Hacer clic en VALIDAR.

RESUMEN

El resumen muestra:

- Disciplina
- Numero de vueltas
- Unidades consumidas
- Unidades restantes

Hacer clic en Finalizar la sesion.

FICHA DEL CLIENTE

La sesion se registra en:

- Historial del cliente
- Estadisticas
- Exportaciones PDF

Luego volver a la pagina de inicio.

HISTORIAL

Consulta de los registros individuales:

- Sesiones
- Pagos
- Importes
- Observaciones

ESTADISTICAS

Consulta de las estadisticas generales:

- Esquiadores
- Sesiones
- Vueltas
- Ingresos
- Asistencias

Exportacion PDF disponible.



""",

"""

KURZANLEITUNG

1. Neuer Skifahrer

Eingeben:
- Nachname
- Vorname
- Geburtsdatum
- Telefon
- E-Mail

Dann auf Speichern klicken.

2. Disziplin auswahlen

Auswahlen:
- BI-SKI
- SLALOM
- FIGUREN
- WAKEBOARD
- SPRUNG

3. Sitzungszeit

Erfassen:
- Startzeit
- Ankunftszeit
- Anzahl der Runden

Dann auf Sitzung speichern klicken.

4. Abrechnung

Den integrierten Rechner verwenden.

Beispiel:
10 x 5 = 50 EUR

Dann auf Zahlung eingeben klicken.

5. Zahlung

Auswahlen:

- Bargeld
- Scheck
- Bankkarte
- Uberweisung
- Guthaben
- Clubkarte

6. Zusammenfassung

Falls erforderlich eine Bemerkung hinzufugen und dann auf

Sitzung beenden

klicken.

Die Sitzung wird im Kundenverlauf gespeichert.

VERWALTUNG DES GUTHABENS

- Eine rote Anzeige erscheint.
- Der Betrag wird nicht im Umsatz berucksichtigt.

AUSGLEICH EINES GUTHABENS

Wenn eine Sitzung oder ein Kauf von Einheiten als Guthaben gespeichert wird:

- Das Guthaben erscheint in der Kundenakte.
- Eine rote Anzeige erscheint auf der Startseite.
- Der Betrag wird nicht im Umsatz berucksichtigt.



ZAHLUNG EINES GUTHABENS

1. Auf der Startseite den Namen des Kunden eingeben.

2. Die Kundenakte offnen.

3. Den Verlauf offnen.

4. Auf Guthaben bezahlt klicken.

- Die rote Anzeige verschwindet.
- Die Anzeige wird grun.

5. Zur Startseite zuruckkehren.

6. Den Kunden erneut suchen.

7. Die angezeigten Informationen prufen.

DISZIPLIN

- Auf UBERSPRINGEN klicken, um zur Abrechnung zu gehen.

ABRECHNUNG

1. Den auszugleichenden Betrag eingeben.

2. Auf Zahlung eingeben klicken.

ZAHLUNG

Die Zahlungsart auswahlen:

- Bargeld
- Scheck
- Bankkarte
- Uberweisung

ZUSAMMENFASSUNG

1. Die angezeigten Informationen prufen.

2. Falls erforderlich eine Bemerkung hinzufugen.

3. Auf Sitzung beenden klicken.

KUNDENAKTE

Das Guthaben wird als bezahlt markiert.

Der Betrag wird einbezogen in:

- Umsatz
- Statistiken
- PDF-Exporte

- Die Kontrollanzeige wird grun.

Dann zur Startseite zuruckkehren.



CLUBKARTE

- 1 Runde = 1 Einheit.
- Aufladen jederzeit moglich.

ERSTELLUNG UND AUFLADUNG EINER KARTE

1. Einen neuen Skifahrer erstellen.

2. Eingeben:
- Nachname
- Vorname
- Geburtsdatum
- Telefon
- E-Mail

3. Auf Speichern klicken.

DISZIPLIN

Auf UBERSPRINGEN klicken.

ABRECHNUNG

1. Die Anzahl der gutzuschreibenden Einheiten eingeben.

Beispiel:
60 Einheiten

2. Den Betrag berechnen.

Beispiel:
60 x 5 EUR = 300 EUR

3. Auf Zahlung eingeben klicken.

ZAHLUNG

Auswahlen:

- Bargeld
- Scheck
- Bankkarte
- Uberweisung
- Guthaben

CLUBKARTE

1. Die angezeigte Anzahl der Einheiten prufen.

2. Eine Karte scannen.

3. Die Zuordnung prufen.

4. Auf BESTATIGEN klicken.

ZUSAMMENFASSUNG

- Zahlung erfolgt
- Betrag bezahlt
- Einheiten geladen
- Verbleibende Einheiten

Auf Sitzung beenden klicken.

KUNDENAKTE

- Kundenverlauf
- Statistiken
- PDF-Exporte

Zur Startseite zuruckkehren.



VERWENDUNG EINER CLUBKARTE

Wenn ein Skifahrer bereits eine Clubkarte besitzt:

1. Die Karte scannen.

2. Die angezeigten Informationen prufen:
- Nachname
- Vorname
- Geburtsdatum
- Telefon
- E-Mail

3. Auf Speichern klicken.

DISZIPLIN

Eine Disziplin auswahlen:

- BI-SKI
- SLALOM
- FIGUREN
- WAKEBOARD
- SPRUNG

Die Anwendung offnet die Seite Sitzungszeit.

SITZUNGSZEIT

Eingeben:

- Startzeit
- Ankunftszeit
- Anzahl der gefahrenen Runden

Dann auf Sitzung speichern klicken.

ABRECHNUNG

Die Anzahl der aufgezeichneten Runden prufen.

Auf Zahlung eingeben klicken.

ZAHLUNG

Auswahlen:

- Clubkarte

CLUBKARTE

1. Die verbleibende Anzahl der Einheiten prufen.

2. Die Karte scannen.

3. Die verbrauchten Einheiten werden manuell vom Trainer oder Coach abgezogen.

4. Auf BESTATIGEN klicken.

ZUSAMMENFASSUNG

Die Zusammenfassung zeigt:

- Disziplin
- Anzahl der Runden
- Verbrauchte Einheiten
- Verbleibende Einheiten

Auf Sitzung beenden klicken.

KUNDENAKTE

Die Sitzung wird gespeichert in:

- Kundenverlauf
- Statistiken
- PDF-Exporten

Dann zur Startseite zuruckkehren.

VERLAUF

Anzeige der einzelnen Kundenakten:

- Sitzungen
- Zahlungen
- Betrage
- Bemerkungen

STATISTIKEN

Anzeige der Gesamtstatistiken:

- Skifahrer
- Sitzungen
- Runden
- Umsatz
- Anwesenheiten

PDF-Export verfugbar.



""",
      ),
      style: const TextStyle(
            fontSize: 18,
            height: 1.5,
     ),
    ),

    
  ],
),
      ),
    );
  }
}
