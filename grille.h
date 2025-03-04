#ifndef GRILLE_H
#define GRILLE_H

#include "mot.h"
#include <string>
#include <vector>
#include <stdexcept>

// Exception pour un mot invalide
class MotInvalideException : public std::exception {
public:
    const char* what() const noexcept override;
};

// Exception pour un dépassement du nombre de tentatives
class DepassementTentativesException : public std::exception {
public:
    const char* what() const noexcept override;
};

class Grille {
public:
    Grille(const std::string& dictionnaire_path = "dictionnaire.txt", int tentatives_max = 6);
    
    bool nouvelle_partie();
    bool soumettre_mot(const std::string& mot_soumis);
    
    int get_tentatives_restantes() const;
    int get_tentatives_max() const;
    std::string get_mot_a_deviner() const;
    const std::vector<Mot>& get_historique() const;
    
    bool est_gagnee() const;
    bool est_perdue() const;
    void afficher() const;
    int get_score() const;
    
    bool est_mot_valide(const std::string& mot) const;
    
private:
    std::vector<std::string> dictionnaire;
    std::vector<Mot> historique;
    std::string mot_a_deviner;
    int tentatives_max;
    int tentatives_actuelles;
    bool partie_en_cours;
    int score;
    
    bool charger_dictionnaire(const std::string& chemin);
    std::string selectionner_mot_aleatoire();
    void mettre_a_jour_score(const Mot& tentative);
};

#endif // GRILLE_H