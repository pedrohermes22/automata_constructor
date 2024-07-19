%{
    #include <iostream>
    #include <string>
    #include <list>
    #include <map>

    typedef struct transition_struct
    {
        char symbol;
        std::string target;
    } Transition;

    extern char* yytext;
    extern int yylex();
    std::list<char> symbols;
    bool stop = false;
    std::string errorState;
    std::map<std::string, std::list<Transition>> map;

    void yyerror(std::string s);
    void AddSymbol(char c);
    void AddState(std::string s, char c, std::string t);
%}

%union
{
    int ival;
    char *sval;
    char cval;
}

%token <sval> KW_ERROR
%token <sval> ARROW
%token <sval> ID
%token <cval> SYMBOL
%token <cval> ':' ';' '(' ')'
%token <sval> END
%token <sval> NUM_RANGE
%token <sval> CHAR_RANGE_L
%token <sval> CHAR_RANGE_U
%token <sval> KW_ACCEPT

%start Program

%%

Program
    : KW_ERROR ':' ID ';'
        {
            errorState = $3;
            YYACCEPT;
        }
    | KW_ACCEPT ':' ID ';'
        {
            std::list<Transition> l;
            map[$3] = l;
            YYACCEPT;
        }
    | ID '(' SYMBOL ')' ARROW ID ';'
        {
            AddSymbol($3);
            AddState($1, $3, $6);
            YYACCEPT;
        }
    | ID '(' NUM_RANGE ')' ARROW ID ';'
        {
            for (char c = '0'; c <= '9'; c++)
            {
                AddSymbol(c);
                AddState($1, c, $6);
            }

            YYACCEPT;
        }
    | ID '(' CHAR_RANGE_L ')' ARROW ID ';'
        {
            for (char c = 'a'; c <= 'z'; c++)
            {
                AddSymbol(c);
                AddState($1, c, $6);
            }

            YYACCEPT;
        }
    | ID '(' CHAR_RANGE_U ')' ARROW ID ';'
        {
            for (char c = 'A'; c <= 'Z'; c++)
            {
                AddSymbol(c);
                AddState($1, c, $6);
            }

            YYACCEPT;
        }
    | END { stop = true; YYACCEPT; }
;

%%

int main()
{
    while (!stop)
        yyparse();

    for (auto it = map.begin(); it != map.end(); it++)
    {
        std::cout
            << it->first
            << " = { ";

        for (const auto e: symbols)
        {
            bool found = false;

            for (auto it2 = it->second.begin(); it2 != it->second.end(); it2++)
            {
                if (it2->symbol == e)
                {
                    std::cout
                        << it2->target
                        << ", ";
                    
                    found = true;
                    continue;
                }
            }

            if (!found)
                std::cout << "0, ";
        }

        std::cout
            << " },\n";
    }

    return 0;
}

void yyerror(std::string s)
{
    std::cout << s << std::endl;
}

void AddSymbol(char c)
{
    for (auto it = symbols.begin(); it != symbols.end(); it++)
    {
        if (*it == c)
            return;
    }

    symbols.push_back(c);
}

void AddState(std::string s, char c, std::string t)
{
    Transition __t = {c, t};

    if (map.find(s) == map.end())
    {
        std::list<Transition> l;
        l.push_back(__t);
        map[s] = l;
    }

    else
        map[s].push_back(__t);
}
