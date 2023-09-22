namespace com.training;

using {Country} from '@sap/cds/common';

entity Course {
    key ID            : UUID;
        StudentCourse : Association to many StudentCourse
                            on StudentCourse.Course = $self;
}

entity Student {
    key ID            : UUID;
        StudentCourse : Association to many StudentCourse
                            on StudentCourse.Student = $self;
}

entity StudentCourse {
    key ID      : UUID;
        Course  : Association to Course;
        Student : Association to Student
}

/*
type EmailsAddresses_01 : array of {
    kind  : String;
    email : String;
}

type EmailsAddresses_02 {
    kind  : String;
    email : String;
}

entity Car {
    ID                 : UUID;
    name               : String;
    virtual discount_1 : Decimal;
    virtual discount_2 : Decimal;
}

entity Emails {
    email_01 :      EmailsAddresses_01;
    email_02 : many EmailsAddresses_02;
    email_03 : many {
        kind  : String;
        email : String;
    }
}

type Gender             : String enum {
    male;
    female;
}



/*
entity ParamProducts(pName : String)     as
    select from Products {
        Name,
        Price,
        Quantity
    }
    where
        Name = : pName;

entity ProjParamProducts(pName : String) as projection
on Products where Name = : pName
*/

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
        Country     : Country;
        Status      : String(1);
}
