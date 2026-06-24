
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

String t(String fr, String en) {
  return langue == "en" ? en : fr;
}

String tr(String key) {
  return traductions[key]?[langue] ??
      traductions[key]?["fr"] ??
      key;
}

final Map<String, Map<String, String>> traductions = {
  "lang_fr": {
    "fr": "FR",
    "en": "FR",
    "it": "FR",
    "es": "FR",
    "de": "FR",
  },
  "lang_en": {
    "fr": "EN",
    "en": "EN",
    "it": "EN",
    "es": "EN",
    "de": "EN",
  },
  "lang_it": {
    "fr": "IT",
    "en": "IT",
    "it": "IT",
    "es": "IT",
    "de": "IT",
  },
};

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
    PopupMenuButton<String>(
  onSelected: (value) {
    setState(() {
      langue = value;
    });
  },
  itemBuilder: (context) => const [
    PopupMenuItem(
      value: "fr",
      child: Text("FR"),
    ),
    PopupMenuItem(
      value: "en",
      child: Text("EN"),
    ),
    PopupMenuItem(
      value: "it",
      child: Text("IT"),
    ),
  ],
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
          const Text("Skieurs"),
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
          const Text("Crédits"),
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
          const Text("Sessions"),
        ],
      ),
    ],
  ),
],
),
),

boutonMenu(
  icon: Icons.menu_book,
  texte: t("Guide utilisateur", "User Guide"),
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
  texte: t("Statistiques", "Statistics"),
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
  texte: t("Présences", "Attendance"),
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
  texte: t("Scanner carte", "Scan card"),
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
  texte: t("Nouveau skieur", "New skier"),
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
            t("Rechercher un skieur", "Search skier"),

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
  t("Nouveau Skieur", "New Skier"),
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
  label: Text(t("Historique", "History"))
   ),
  ],
),
    
  

          const SizedBox(height: 20),

          TextField(
            controller: prenomController,
            decoration:  InputDecoration(
              labelText: t("Prénom", "First name"),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: nomController,
            decoration:  InputDecoration(
              labelText: t("Nom", "Last name"),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: naissanceController,
            decoration:  InputDecoration(
              labelText: t("Date de naissance", "Date of birth"),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: telephoneController,
            decoration:  InputDecoration(
              labelText: t("Téléphone", "Phone"),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: t("Email", "Email"),
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

      label: Text(t("Statistiques", "Statistics")),

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
    const SnackBar(
      content: Text("Veuillez sélectionner ou saisir un skieur"),
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
                t("Enregistrer", "Save"),
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
  t("DISCIPLINES", "DISCIPLINES"),
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
        t("PASSER", "SKIP"),
        style: TextStyle(color: Colors.white),
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
    child: const Text(
      "⚠ CRÉDIT EN COURS",
      textAlign: TextAlign.center,
      style: TextStyle(
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
              t("Choisissez une discipline", "Choose a discipline"),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            disciplineButton(context, skieur, "BI-SKI", "BI-SKIING", Colors.blue),

            const SizedBox(height: 15),

            disciplineButton(context, skieur, "SLALOM", "SLALOM", Colors.red),

            const SizedBox(height: 15),

            disciplineButton(context, skieur, "FIGURES", "TRICKS", Colors.purple),

            const SizedBox(height: 15),

            disciplineButton(context, skieur, "WAKEBOARD", "WAKEBOARD", Colors.orange),

            const SizedBox(height: 15),

            disciplineButton(context, skieur, "SAUT", "JUMPING", Colors.green),
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
  Color couleur,
) {
  final discipline = t(texteFr, texteEn);

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
        t("PASSER", "SKIP"),
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
          t("Temps de session", "Session time"),
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
            "${t("Départ", "Start")} : ${debut!.hour}:${debut!.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 18),
          ),

        if (fin != null)
           Text(
             "${t("Arrivée", "Finish")} : ${fin!.hour}:${fin!.minute.toString().padLeft(2, '0')}",
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
              child: Text(t("Départ", "Start")),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  fin = DateTime.now();
                });
              },
              child: Text(t("Arrivée", "Finish")),
            ),
          ],
        ),

        const SizedBox(height: 25),

           Text(
             t("Nombre de tours", "Number of laps"),
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
              t("Enregistrer la session", "Save session"),
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
       title: Text(t("FACTURATION", "BILLING")), 
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

            Text("${t("Naissance", "Birth date")} : ${widget.skieur.naissance}"),
            Text("${t("Discipline", "Discipline")} : ${widget.discipline}"),

            const SizedBox(height: 20),

            if (widget.debut != null)
            Text(
                "${t("Départ", "Start")} : ${widget.debut!.hour}:${widget.debut!.minute.toString().padLeft(2, '0')}",
            ),

            if (widget.fin != null)
             Text(
                "${t("Arrivée", "Finish")} : ${widget.fin!.hour}:${widget.fin!.minute.toString().padLeft(2, '0')}",
            ),

             Text("${t("Temps réalisé", "Time achieved")} : ${widget.duree}"),

             Text("${t("Nombre de tours", "Number of laps")} : ${widget.tours}"),

            const SizedBox(height: 40),

Text(
  t("Unités à créditer", "Units to credit"),
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
  labelText: t("Nombre d'unités", "Number of units"),
  border: const OutlineInputBorder(),
),
),

const SizedBox(height: 30),

            Text(
  t("Calculatrice", "Calculator"),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
),

            const SizedBox(height: 20),

            TextField(
              controller: calculController,
              decoration: InputDecoration(
                hintText: t("Exemple : 25*3", "Example: 25*3"),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

      SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: calculer,
    child: Text(
      t("Calculer", "Calculate"),
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
      t("Taper règlement", "Enter payment"),
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
  title: Text(t("Règlement", "Payment")),
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
  t("ESPÈCE", "CASH"),
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
  t("CHEQUE", "CHECK"),
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
           t("CARTE BLEUE", "CREDIT CARD"),
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
           t("VIREMENT", "BANK TRANSFER"),
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
            t("CREDIT", "CREDIT"),
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
      "${t("Paiement enregistré", "Payment saved")} : $texte",
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
        t("CARTE CLUB", "CLUB CARD"),
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
                t("Scanner une carte", "Scan a card"),
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
  "${t("Carte attribuée à", "Card assigned to")} ${widget.skieur.prenom} ${widget.skieur.nom}",
),
      
    ),
  );
}

},
child: Text(t("Scanner une carte", "Scan a card"))
  ),
),
            const SizedBox(height: 40),

            Text(
  t("Unités restantes", "Remaining units"),
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
  t("VALIDER", "VALIDATE"),
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
        title: Text(t("RÉCAPITULATIF", "SUMMARY")),
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
              "${t("Date de naissance", "Date of birth")} : ${widget.skieur.naissance}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            Text(
              "${t("Discipline", "Discipline")} : ${widget.discipline}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t("Durée session", "Session duration")} : ${widget.duree}",
              style: const TextStyle(fontSize: 20),
            ),
            
            Text(
               "${t("Départ", "Start")} : ${widget.depart}",
              style: const TextStyle(fontSize: 20),
            ),

             Text(
               "${t("Arrivée", "Finish")} : ${widget.arrivee}",
               style: const TextStyle(fontSize: 20),
            ),


            Text(
              "${t("Tours réalisés", "Completed laps")} : ${widget.tours}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t("Paiement", "Payment")} : ${widget.paiement}",
              style: const TextStyle(fontSize: 20),
            ),

            Text(
              "${t("Montant", "Amount")} : ${widget.montant.toStringAsFixed(2)} €",
             style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 40),

            Text(
              t("Observations sportives", "Coaching notes"),
              
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
                   hintText: t(
                   "Exemple : travailler la tension des bras pour la prochaine séance...",
                   "Example: work on arm tension for the next session...",
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
    t("Session enregistrée", "Session saved"),
       
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
        t("Terminer la session", "End session"),
                  
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
          "DOSSIER CLIENT",
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
          "Historique des sessions",
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
        title: Text(t("DOSSIER CLIENT", "CUSTOMER FILE")),
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
      t("CRÉDIT RÉGLÉ", "CREDIT PAID"),
   ),
    
  ),
  ),

            const SizedBox(height: 30),



      Text(
  t("Historique", "History"),
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
  "Sessions affichées : ${sessionsFiltrees.length}",
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

          ? t("Date début", "Start date")

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

          ? t("Date fin", "End date")

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
      t("Statistiques générales", "General statistics"),
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
  t("Exporter historique PDF", "Export history PDF"),
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
  t("Retour accueil", "Back to home"),
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

"${t("Départ", "Departure")} : ${s.depart}\n"

"${t("Arrivée", "Arrival")} : ${s.arrivee}\n"

"${t("Tours", "Laps")} : ${s.tours}\n"

"${t("Paiement", "Payment")} : ${s.paiement}\n"

"${t("Montant", "Amount")} : ${s.montant.toStringAsFixed(2)} €\n"

"${t("Observation", "Observation")} : ${s.observation}",
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
        title: const Text("SCAN QR"),
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
          t("STATISTIQUES SAISON", "SEASON STATISTICS"),
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

          ? t("Début", "Start")

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

          ? t("Fin", "End")

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
  "${t("Skieurs enregistrés", "Registered skiers")} : $totalSkieurs",
  style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Text(
"${t("Sessions réalisées", "Completed sessions")} : $totalSessions",
),

            const SizedBox(height: 20),

            Text(
              "${t("Tours réalisés", "Completed laps")} : $totalTours",
            ),

           const SizedBox(height: 20),

Text(
"${t("CA saison", "Season revenue")} : ${totalCA.toStringAsFixed(2)} EUR",
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
    label: Text(t("Liste des présences", "Attendance list")),
  ),
),

const SizedBox(height: 20),


  Text(
  t("Disciplines", "Disciplines"),
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
  t("Paiements", "Payments"),
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
    t("Exporter statistiques PDF", "Export statistics PDF"),
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

        title: const Text(
          "STATISTIQUES SKIEUR",
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
              "Tours : $totalTours",
            ),

            Text(
              "CA : ${totalCA.toStringAsFixed(2)} EUR",
            ),

            const SizedBox(height:20),

            const Text(
              "Disciplines",
            ),

            ...disciplines.entries.map(
               (e) => Text(
                  "${e.key} : ${e.value}",
              ),
            ),

            const SizedBox(height:20),

            const Text(
              "Paiements",
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
           t("PRÉSENCES", "ATTENDANCE"),
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
                 t("Exporter présences PDF", "Export attendance PDF"),
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
                      "${t("Date", "Date")} : ${session.venue.day}/${session.venue.month}/${session.venue.year}\n"
                        "${t("Discipline", "Discipline")} : ${session.discipline}\n"
                        "${t("Arrivée", "Arrival")} : ${session.depart}\n"
                        "${t("Départ", "Departure")} : ${session.arrivee}"
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
          t("GUIDE UTILISATEUR", "USER GUIDE"),
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
      t("Exporter guide PDF", "Export guide PDF"),
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