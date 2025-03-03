#include "lettre.h"

Lettre::Lettre(char symb) {
    this->symb = symb;
    this->etat = 0; 
}

void Lettre::set_etat(int new_etat) {
    this->etat = new_etat;
}

int Lettre::get_etat() {
    return this->etat;
}