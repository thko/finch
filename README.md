finch
=====

A database management system, intended to eschew the needless verbosity of SQL.

Example data definition:

    entity House (name string);
    entity Student (name string, year int, &House);
    entity QuidditchTeam (&House, year int,
        { Chaser1, Chaser2, Chaser3, Beater1, Beater2, Keeper, Seeker } &Student);
