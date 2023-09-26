sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'fabboo/product/test/integration/FirstJourney',
		'fabboo/product/test/integration/pages/ProductsList',
		'fabboo/product/test/integration/pages/ProductsObjectPage',
		'fabboo/product/test/integration/pages/ReviewsObjectPage'
    ],
    function(JourneyRunner, opaJourney, ProductsList, ProductsObjectPage, ReviewsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('fabboo/product') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheProductsList: ProductsList,
					onTheProductsObjectPage: ProductsObjectPage,
					onTheReviewsObjectPage: ReviewsObjectPage
                }
            },
            opaJourney.run
        );
    }
);