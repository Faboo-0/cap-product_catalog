using {com.fabboo as fabboo} from '../db/schema';
using {com.training as training} from '../db/training';

// service ProductService {
//     entity ProductEntity        as projection on fabboo.materials.Products;
//     entity SupplierEntity       as projection on fabboo.sales.Suppliers;
//     entity UnitOfMeasuresEntity as projection on fabboo.materials.UnitOfMeasures;
//     entity DimensionUnitEntity  as projection on fabboo.materials.DimensionUnit;
//     entity CategoryEntity       as projection on fabboo.materials.Categories;
//     entity SalesDataEntity      as projection on fabboo.sales.SalesData;
//     entity ReviewEntity         as projection on fabboo.materials.ProductReview;
//     entity CurrencyEntity       as projection on fabboo.materials.Currencies;
//     entity MonthEntity          as projection on fabboo.sales.Months;
//     //entity Order                as projection on fabboo.Order;
//     //entity OrderItem            as projection on fabboo.OrderItem;
// }

service ProductService {
    entity Products          as
        select from fabboo.reports.Products {
            ID,
            Name          as ProductName     @mandatory,
            Description                      @mandatory,
            ImageUrl,
            ReleaseDate,
            DiscontinuedDate,
            Price                            @mandatory,
            Height,
            Width,
            Depth,
            Quantity                         @(
                mandatory,
                assert.range: [
                    0.00,
                    20.00
                ]
            ),
            UnitOfMeasure as ToUnitOfMeasure @mandatory,
            Currency      as ToCurrency      @mandatory,
            Currency.ID as CurrencyId,
            Category      as ToCategory      @mandatory,
            Category.ID as CategoryId,
            Category.Name as Category        @mandatory,
            DimensionUnit as ToDimensionUnit,
            SalesData,
            Supplier,
            Reviews,
            Rating,
            StockAvailability,
            ToStockAvailability
        };

    entity Supplier          as
        select from fabboo.sales.Suppliers {
            ID,
            Name,
            Email,
            Phone,
            Fax,
            Product as ToProduct
        };

    @readonly
    entity Reviews           as
        select from fabboo.materials.ProductReview {
            ID,
            Name,
            Rating,
            Comment,
            Product as ToProduct
        };

    @readonly
    entity SalesData         as
        select from fabboo.sales.SalesData {
            ID,
            DeliveryDate,
            Revenue,
            Currency.ID               as CurrencyKey,
            DeliveryMonth.ID          as DeliveryMonthId,
            DeliveryMonth.Description as DeliveryMonth,
            Product                   as ToProduct
        };

    @readonly
    entity StockAvailability as
        select from fabboo.materials.StockAvailability {
            ID,
            Description
        };

    @readonly
    entity VH_Categories     as
        select from fabboo.materials.Categories {
            ID   as Code,
            Name as Text

        };

    @readonly
    entity VH_Currencies     as
        select from fabboo.materials.Currencies {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_UnitOfMeasure  as
        select from fabboo.materials.UnitOfMeasures {
            ID          as Code,
            Description as Text
        };

    /*@readonly
    entity VH_DimensionUnits as
        select from fabboo.materials.DimensionUnit {
            ID          as Code,
            Description as Text

        };*/

    entity VH_DimenionUnits  as
        select
            ID          as Code,
            Description as Text
        from fabboo.materials.DimensionUnit
}

service MyService {

    entity SuppliersProduct  as
        select from fabboo.materials.Products[Name = 'Pink Lemonade']{
            *,
            Name,
            Description,
            Supplier.Adress
        }
        where
            Supplier.Adress.PostalCode = 98074;

    entity SuppliersToSales  as
        select
            Supplier.Email,
            Category.Name,
            SalesData.Currency.ID,
            SalesData.Currency.Description
        from fabboo.materials.Products;

    entity FiltroEnfix       as
        select Supplier[Name = 'Exotic Liquids'].Phone from fabboo.materials.Products
        where
            Products.Name = 'Pink Lemonade';

    entity FiltroJoin        as
        select Phone from fabboo.materials.Products
        left join fabboo.sales.Suppliers as sup
            on(
                sup.ID = Products.Supplier.ID
            )

            and sup.Name = 'Exotic Liquids'
        where
            Product.Name = 'Pink Lemonade'
}

service Reports {
    entity ProductReview     as projection on fabboo.reports.AverageRating;

    entity EntityCasting     as
        select
            cast(
                Price as       Integer
            )     as Price,
            Price as Price02 : Integer
        from fabboo.materials.Products;

    entity EntityExists      as
        select Name from fabboo.materials.Products
        where
            exists Supplier[Name = 'Exotic Liquids'];
}
