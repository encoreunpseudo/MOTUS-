#include "mot.h"

Mot::Mot(std::string expression) {
    transfomer_expression_vecteur(expression);
    longueur = expression.length();
    etat = false;
}

void Mot::transfomer_expression_vecteur(std::string expression) {
    exp_etat.clear();
    for (char c : expression) {
        exp_etat.push_back(Lettre(c));
    }
}

void Mot::update_mot(std::string mot_soumis) {
    if (mot_soumis.length() != longueur) {
        return;
    }

    bool mot_trouve = true;
    for (size_t i = 0; i < longueur; i++) {
        if (mot_soumis[i] == exp_etat[i].symb) {
            exp_etat[i].etat = 2; 
        } else {
            mot_trouve = false;
            exp_etat[i].etat = 0; 
            
            
            for (size_t j = 0; j < longueur; j++) {
                if (mot_soumis[i] == exp_etat[j].symb) {
                    exp_etat[i].etat = 1; 
                    break;
                }
            }
        }
    }
    
    etat = mot_trouve;
}

void Mot::afficher(){
    
}