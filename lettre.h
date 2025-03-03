#ifndef LETTRE_H
#define LETTRE_H

class Lettre
{
public:
    Lettre(char symb);
    char symb;
    int etat;
    void set_etat(int new_etat);
    int get_etat();
};

#endif // LETTRE_H
