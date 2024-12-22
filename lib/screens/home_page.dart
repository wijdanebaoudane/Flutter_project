import 'package:flutter/material.dart';
import 'fruits_page.dart'; // Import the FruitsPage widget
import 'register_page.dart'; 
import 'package:baoudane_app/screens/Llm_page.dart';// Import the RegisterPage widget
import 'package:baoudane_app/screens/llm_speech.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _logout() {
    // Logique de déconnexion (par exemple : navigation vers la page de connexion)
    print("Déconnexion de l'utilisateur");
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/image.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Wijdane baoudane',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'baoudane@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Covide Tracker'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Fruits Classifier'),
              onTap: () {
                // Navigate to FruitsPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FruitsPage()),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Assistant'),
              onTap: () {
                // Navigate to FruitsPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AssistantPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('LLM Wijdane'),
              onTap: () {
                // Navigate to FruitsPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LlmPage()),
                );
              },
            ),
            Divider(color: Colors.grey.shade300),
            ListTile(
              leading: const Icon(Icons.settings),
              trailing: const Icon(Icons.arrow_forward_ios),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(color: Colors.grey.shade300),
            // Add a ListTile for the "Inscription" item
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Inscription'),
              onTap: () {
                // Navigate to RegisterPage
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur la page d\'accueil!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
