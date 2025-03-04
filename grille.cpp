#include "grille.h"
#include "mot.h"
#include "lettre.h"
#include <iostream>
#include <fstream>
#include <algorithm>
#include <stdexcept>

// Définition des exceptions
const char* MotInvalideException::what() const noexcept {
    return "Le mot soumis est invalide (longueur incorrecte ou non présent dans le dictionnaire).";
}

const char* DepassementTentativesException::what() const noexcept {
    return "Nombre maximal de tentatives atteint. Partie terminée.";
}

Grille::Grille(const std::string& dictionnaire_path, int tentatives_max) : tentatives_max(tentatives_max), tentatives_actuelles(0), partie_en_cours(false), score(0) {
    if (!charger_dictionnaire(dictionnaire_path)) {
        throw std::runtime_error("Impossible de charger le dictionnaire.");
    }
    nouvelle_partie();
}

bool Grille::charger_dictionnaire(const std::string& chemin) {
    std::ifstream fichier(chemin);
    if (!fichier.is_open()) {
        return false;
    }
    std::string mot;
    while (fichier >> mot) {
        dictionnaire.push_back(mot);
    }
    return true;
}

std::string Grille::selectionner_mot_aleatoire() {
    if (dictionnaire.empty()) {
        throw std::runtime_error("Le dictionnaire est vide.");
    }
    srand(time(nullptr));
    return dictionnaire[rand() % dictionnaire.size()];
}

bool Grille::nouvelle_partie() {
    mot_a_deviner = selectionner_mot_aleatoire();
    tentatives_actuelles = 0;
    historique.clear();
    partie_en_cours = true;
    return true;
}

bool Grille::soumettre_mot(const std::string& mot_soumis) {
    if (!partie_en_cours) {
        throw std::logic_error("Aucune partie en cours.");
    }
    if (tentatives_actuelles >= tentatives_max) {
        throw DepassementTentativesException();
    }
    if (!est_mot_valide(mot_soumis)) {
        throw MotInvalideException();
    }
    Mot tentative(mot_soumis);
    tentative.update_mot(mot_a_deviner);
    historique.push_back(tentative);
    tentatives_actuelles++;
    mettre_a_jour_score(tentative);
    if (tentative.est_trouve()) {
        partie_en_cours = false;
        return true;
    }
    return false;
}

bool Grille::est_mot_valide(const std::string& mot) const {
    return (mot.length() == mot_a_deviner.length() && std::find(dictionnaire.begin(), dictionnaire.end(), mot) != dictionnaire.end());
}

void Grille::mettre_a_jour_score(const Mot& tentative) {
    if (tentative.est_trouve()) {
        score += (tentatives_max - tentatives_actuelles) * 10;
    }
}

bool Grille::est_gagnee() const {
    return !partie_en_cours && !historique.empty() && historique.back().est_trouve();
}

bool Grille::est_perdue() const {
    return !partie_en_cours && !est_gagnee();
}

void Grille::afficher() const {
    std::cout << "Mot à deviner: " << std::string(mot_a_deviner.length(), '_') << std::endl;
    for (const auto& mot : historique) {
        mot.afficher();
    }
    std::cout << "Tentatives restantes: " << get_tentatives_restantes() << "\n";
}

int Grille::get_tentatives_restantes() const {
    return tentatives_max - tentatives_actuelles;
}

int Grille::get_tentatives_max() const {
    return tentatives_max;
}

std::string Grille::get_mot_a_deviner() const {
    return mot_a_deviner;
}

const std::vector<Mot>& Grille::get_historique() const {
    return historique;
}

int Grille::get_score() const {
    return score;
}
