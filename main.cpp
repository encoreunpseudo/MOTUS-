#include "grille.h"
#include <iostream>

int main() {
    try {
        // Création d'une grille avec un dictionnaire
        Grille grille("dictionnaire.txt", 6);
        
        std::cout << "Bienvenue dans Motus !" << std::endl;
        grille.afficher();
        
        std::string mot_soumis;
        while (!grille.est_gagnee() && !grille.est_perdue()) {
            std::cout << "Entrez un mot : ";
            std::cin >> mot_soumis;
            
            try {
                grille.soumettre_mot(mot_soumis);
            } catch (const MotInvalideException& e) {
                std::cerr << "Erreur : " << e.what() << std::endl;
            } catch (const DepassementTentativesException& e) {
                std::cerr << "Erreur : " << e.what() << std::endl;
                break;
            }
            
            grille.afficher();
        }
        
        if (grille.est_gagnee()) {
            std::cout << "Bravo, vous avez trouvé le mot !" << std::endl;
        } else {
            std::cout << "Dommage ! Le mot était : " << grille.get_mot_a_deviner() << std::endl;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "Erreur : " << e.what() << std::endl;
    }
    
    return 0;
}
