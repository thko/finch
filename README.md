finch
=====

A database management system, intended to eschew the needless verbosity of SQL.

Example data definition:

    entity House (name string(15));
    entity Student (name string(45), year int, &House);
    entity QuidditchTeam (&House, year int,
        { Chaser1, Chaser2, Chaser3, Beater1, Beater2, Keeper, Seeker } &Student);

Example record selection: select each team that's ever played for Gryffindor.

    *\ House.name, Student.year:       -- select all fields (*) except for some (\ House, ...)
        QuidditchTeam () Student () House -- () is the join operator
        | House.name == 'Gryffindor';  -- optional condition follows | symbol

The full grammar is yet to be defined. In either case, the statement should compile to SQL:

    SELECT year, Chaser1, Chaser2, Chaser3, Beater1, Beater2, Keeper, Seeker, Student.name
    FROM QuidditchTeam
    JOIN Student ON QuidditchTeam.Student = Student.pk
    JOIN House ON Student.House = House.pk
    WHERE House.name = 'Gryffindor';

It's not obvious why the fourth line isn't `JOIN House ON QuidditchTeam.House = House.pk`.
The `()` operator is a little ambigious that way. There are a few ways around this:

-Naming the

    entity QuidditchTeam (teamHouse &House, year int, ...);
    Student (name string(45), year int, studentHouse &House);
    
    *\ House.name, Student.year:
        QuidditchTeam (teamHouse) House (QuidditchTeam@Student)
        | House.name = 'Gryffindor';
