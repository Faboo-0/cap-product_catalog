namespace com.fabboo;

using {
    cuid,
    managed
} from '@sap/cds/common';


type Name : String(50);

type Adress {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3)

}

context materials {
    entity Products : cuid {
        //key ID               : UUID;
        Name             : localized String not null;
        Description      : localized String;
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now;
        DiscontinuedDate : DateTime;
        Price            : Decimal(16, 2);
        Height           : type of Price;
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to sales.Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnit;
        Category         : Association to Categories;
        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReview
                               on Reviews.Product = $self;
    }

    entity Categories {
        key ID   : String(1);
            Name : localized String;
    }

    entity StockAvailability {
        key ID          : Integer;
            Description : localized String;
    }

    entity Currencies {
        key ID          : String(3);
            Description : localized String;
    }

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : localized String;
    }

    entity DimensionUnit {
        key ID          : String(2);
            Description : localized String;
    }

    entity ProductReview : cuid {
        //key Name    : UUID;
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products;
    }

    entity SelProducts   as select from Products;
    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as projection on Products {
        *
    };

    entity ProjProducts3 as projection on Products {
        ReleaseDate,
        Name
    };

    extend Products {
        PriceCondition     : String(2);
        PriceDetermination : String(3);
    }
}

context sales {
    entity Order : cuid {
        //key ID         : UUID;
        Date       : Date;
        Customer   : String;
        OrderItems : Composition of many OrderItem
                         on OrderItems.Order = $self;
    }

    entity OrderItem : cuid {
        //key ID      : UUID;
        Order   : Association to Order;
        Product : Association to materials.Products;
    }

    entity Suppliers : cuid {
        //key ID      : UUID;
        Name    : materials.Products:Name;
        Adress  : Adress;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    }


    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    }

    entity SalesData : cuid {
        //key ID            : UUID;
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to Months;
    }

    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelPoducts2  as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products
        left join materials.ProductReview
            on Products.Name = ProductReview.Name
        {
            Rating,
            Products.Name,
            sum(Price) as TotalPrice
        }
        group by
            Rating,
            Products.Name
        order by
            Rating;
}

context reports {
    entity AverageRating as
        select from fabboo.materials.ProductReview {
            Product.ID  as ProductId,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;

    entity Products      as
        select from fabboo.materials.Products
        mixin {
            ToStockAvailability : Association to fabboo.materials.StockAvailability
                                      on ToStockAvailability.ID = $projection.StockAvailability;
            ToAverageRating     : Association to AverageRating
                                      on ToAverageRating.ProductId = ID;
        }
        into {
            *,
            ToAverageRating.AverageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
            when Quantity
            > 0 then 2
            else 1 end as StockAvailability : Integer,
            ToStockAvailability
        }
}
