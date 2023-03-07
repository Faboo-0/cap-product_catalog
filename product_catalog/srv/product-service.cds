using {com.fabboo as fabboo} from '../db/schema';

service ProductService {
    entity ProductSrv as projection on fabboo.Product;
}