%{
#include <stdio.h>
char stare[2];
char *character_curent;
int nrChar = 0;
int nrVariable = 0;
int nrElements = 0;
int countState = 0;
char var_value;
char *var[10];
char *stack[10];
int nrStates = 0;
char* previous_state;
int type = 0, determinist = 0;
int nrQ = 0;
char *firstDot;
char *secondDot;
%}
FILE *yyin;
variable "variable"
alfabet "alphabet"
stack_alfabet "stack_alphabet" 
ignore "[ :{}],->/&"
semicolon "}"
states "states"
final_states "final_states"
initial_state "initial_state"
automat_name "automata_language"
state_form "q"[0-9]+
%s ALFABET ALFABET_STACK NR_STATES FINAL_STATES INITIAL_STATE READ_TRANSITION PROCESS_TRANSITION VARIABLE PROCESS_TRANSITION_STACK READ_TRANSITION_STACK
%%
<INITIAL>{variable} {BEGIN (VARIABLE);} /*Daca avem declarate variabile atunci vom merge in starea variable in care vom salva datele acelei variabile*/
<INITIAL>{alfabet}+ {BEGIN (ALFABET);} /*Daca avem textul specific varibilei alfabet, mergem in starea in care vom salva si afisa alfabetul acestui automat*/
<INITIAL>{stack_alfabet}+ {BEGIN (ALFABET_STACK);} /*Daca avem textul specific varibilei stack_alfabet, mergem in starea in care vom salva si afisa alfabetul automatului cu stiva*/
<INITIAL>{automat_name}[0-9]+ {printf("Nume automat: %s\n", yytext); BEGIN(INITIAL);} /*Daca avem textul specific varibilei automat_name, mergem in starea in care vom salva si afisa numele automatului*/
<INITIAL>{states} {BEGIN(NR_STATES);} /*Daca avem textul specific varibilei states vom merge in starea in care vom numara starile corespunzatoare automatului*/
<INITIAL>{final_states} {BEGIN(FINAL_STATES);}/*Daca avem textul specific varibilei final_states vom merge in starea in care vom afisa starile finale corespunzatoare automatului*/
<INITIAL>{initial_state} {BEGIN(INITIAL_STATE);}/*Daca avem textul specific varibilei initial_state vom merge in starea in care vom numara afisa starea initiala a automatului*/
<INITIAL>{state_form} {strcpy(stare, yytext); BEGIN(READ_TRANSITION);}/*Daca vom gasi un pattern specific variabilei state_form, vom incepe citirea tranzitiilor si afisarea acestora*/
<VARIABLE>{ignore}+ {} /*Daca avem spatii sau caractere irelevante pentru noi, acestea vor fi ignorate*/
<VARIABLE>[a-z] {var[nrChar] = malloc(yyleng);
				 strcpy(var[nrChar], yytext); nrChar++;} /*Daca avem variabila, salvam pentru fiecare variabila, valorile asignate */
<VARIABLE>[\n] {BEGIN(INITIAL);}
<ALFABET>{ignore}+ {}
<ALFABET>[a-z, ]+{semicolon}[ ;] {printf("Alfabet: {%s\n", yytext); BEGIN(INITIAL);}  /*Afisarea alfabetului*/
<ALFABET>[\n] {BEGIN (INITIAL);}
<ALFABET_STACK>[a-zA-Z0-9, ]+{semicolon}[ ;] {type = 1; printf("Stack Alfabet: {%s\n", yytext);  BEGIN(READ_TRANSITION_STACK);}  /*Afisarea alfabetului stivei*/
<NR_STATES>[a-z][0-9]+ {nrStates++; BEGIN(NR_STATES);} /*Contorizarea numarului de stari*/
<NR_STATES>{ignore}+ {}
<NR_STATES>[\n] {printf("Numar stari: %d\n", nrStates); BEGIN(INITIAL);} /*La final, se afiseaza numarul de stari si se reinitializeaza pentru urmatorul automat*/
<INITIAL_STATE>{ignore} {}
<INITIAL_STATE>{state_form}+[ ;] {printf("Stare initiala: %s\n", yytext); BEGIN(INITIAL); } /*Afisarea starii intiale*/
<INITIAL_STATE>[\n] {BEGIN(INITIAL);}
<FINAL_STATES>{ignore}+ {}
<FINAL_STATES>[a-z0-9,; ]+{semicolon}[ ;] {printf("Stari finale: {%s\n", yytext); BEGIN(INITIAL);} /*Afisarea starii finale*/
<FINAL_STATES>[\n] {BEGIN(INITIAL);}
<READ_TRANSITION>{ignore}+ {}
<READ_TRANSITION>[\n] {BEGIN(PROCESS_TRANSITION);}
<READ_TRANSITION_STACK>{ignore}+ {}
<READ_TRANSITION_STACK>[\n] {BEGIN(PROCESS_TRANSITION_STACK);}
<PROCESS_TRANSITION>[a-z] {
							character_curent = malloc(yyleng);
							strcpy(character_curent, yytext);
							BEGIN(PROCESS_TRANSITION);} /*Se salveaza intr-un vector de char-uri* fiecare elent dintr-o singura tranzitie. ex: y -> q0 => pe pozitia 0 se afla y, pe
pozitia 1 se afla q0*/
<PROCESS_TRANSITION>{ignore} {}
<PROCESS_TRANSITION>[a-z0-9]+ {
				for (int i = 1; i < nrChar - 1; i++){
					for (int j = i + 1; j < nrChar; j++) {
						if (strcmp(var[i], var[j]) == 0) {determinist = 1;}
					}
				}
				if (strcmp(character_curent, var[0]) == 0) {
					for (int i = 1; i < nrChar; i++){
						printf("	m(%s,%s) = %s\n", stare, var[i], yytext);}
				}
				else {
				printf("	m(%s,%s) = %s\n", stare, character_curent, yytext);}
				countState++;
				if (countState == nrStates){
					if(determinist == 1) {printf("Tipul automatului: Finit nedeterminist\n\n");}
					else {printf("Tipul automatului: Finit determinist\n\n");}
					nrStates = 0;
					countState = 0;
				}
				BEGIN(INITIAL);} /*Se afiseaza tranzitia corespunzatoare unui singur rand si se va merge mai departe*/
<PROCESS_TRANSITION_STACK>[a-zA-Z0-9]+ { 
					stack[nrElements]=malloc(yyleng);
					strcpy(stack[nrElements], yytext);
					nrElements++; 
					BEGIN(PROCESS_TRANSITION_STACK);} /*Se salveaza intr-un vector de char-uri* fiecare elent dintr-o singura tranzitie. ex: y -> q0 => pe pozitia 0 se afla y, pe
pozitia 1 se afla q0*/
<PROCESS_TRANSITION_STACK>[ ->(/&] {}
<PROCESS_TRANSITION_STACK>[;][\n] {
					if (strcmp(stack[3], "e")==0){
						determinist = 0;
						printf("	m(%s, %s, %s) = (%s, %s)\n", stack[0], stack[1], stack[2], stack[3], stack[4]);
					}
					else{
						printf("	m(%s, %s, %s) = (%s, %s&%s)\n", stack[0], stack[1], stack[2], stack[5], stack[3], stack[4]);}
					nrElements = 1;
					BEGIN(PROCESS_TRANSITION_STACK);}
[\t\n] {}
. {}
%%
int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
}
