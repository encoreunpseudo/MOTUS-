#ifndef MOT_H
#define MOT_H
#include "lettre.h"

#include<iostream>
#include<vector>

class Mot
{
public:
    Mot(std::string expression);
    std::vector<Lettre> exp_etat;
    int longueur;
    bool etat;
    void update_mot(std::string mot_soumis);
    void afficher();
private:
    void transfomer_expression_vecteur(std::string expression);
    

};

#endif // MOT_H
