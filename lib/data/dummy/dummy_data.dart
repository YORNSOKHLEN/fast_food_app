import '../../features/shop/models/brand_model.dart';
import '../../features/shop/models/category_model.dart';
import '../../features/shop/models/product_model.dart';
import '../../features/shop/models/poster_model.dart';
import '../../utils/constants/image_strings.dart';

class YDummyData {
  // Banners have been replaced by posters. Use `YDummyData.posters` for poster data.

  /// - List of all Categories
  static final List<CategoryModel> categories = [
    // Main Categories (Featured)
    CategoryModel(
      id: '1',
      image: YImage.iconBurger,
      name: 'Burgers',
      isFeatured: true,
    ),
    CategoryModel(
      id: '2',
      image: YImage.iconPizza,
      name: 'Pizza',
      isFeatured: true,
    ),
    CategoryModel(
      id: '3',
      image: YImage.iconBeverage,
      name: 'Beverages',
      isFeatured: true,
    ),
    CategoryModel(
      id: '4',
      image: YImage.iconKhmerFood,
      name: 'Khmer Food',
      isFeatured: true,
    ),
    CategoryModel(
      id: '5',
      image: YImage.iconChineseFood,
      name: 'Chinese Food',
      isFeatured: true,
    ),
    CategoryModel(
      id: '6',
      image: YImage.iconStore,
      name: 'Korean Food',
      isFeatured: true,
    ),
  ];

  /// -- List of all Brands
  static final List<BrandModel> brands = [
    BrandModel(
      id: '1',
      image: YImage.burgerKingBrand,
      name: 'Burger King',
      productsCount: 265,
      isFeatured: true,
    ),
    BrandModel(
      id: '2',
      image: YImage.koiBrand,
      name: 'Koi',
      productsCount: 180,
      isFeatured: true,
    ),
  ];

  /// -- List of all Products
  static final List<ProductModel> products = [
    ProductModel(
      id: '001',
      title: 'Texas Double Whopper Burger',
      price: 10,
      isFeatured: true,
      thumbnail: YImage.texasDoubleWhopperBurger,
      description:
          'Two flame-grilled beef patties topped with crispy bacon, melted cheese, fresh lettuce, ripe tomatoes, crunchy pickles, onions, creamy mayo, and smoky BBQ sauce on a toasted sesame seed bun. Big, bold, and full of Texas-style flavor.',
      brand: BrandModel(
        id: '1',
        image: YImage.burgerKingBrand,
        name: 'Burger King',
        productsCount: 265,
        isFeatured: true,
      ),
      salePrice: 9,
      categoryId: '1',
    ),
    ProductModel(
      id: '002',
      title: 'Original Chicken Sandwich Burger',
      price: 12,
      isFeatured: true,
      thumbnail: YImage.originalChickenSandwichBurger,
      description:
          'A crispy, lightly breaded white-meat chicken patty topped with fresh lettuce and creamy mayonnaise, served on a soft sesame seed bun. Simple, crunchy, and satisfying.',
      brand: BrandModel(
        id: '1',
        image: YImage.burgerKingBrand,
        name: 'Burger King',
        productsCount: 265,
        isFeatured: true,
      ),
      salePrice: 10,
      categoryId: '1',
    ),
    ProductModel(
      id: '003',
      title: 'Whopper with Cheese Burger',
      price: 7,
      isFeatured: true,
      thumbnail: YImage.whopperWithCheeseBurger,
      description:
          'A flame-grilled beef patty topped with melted cheese, fresh lettuce, juicy tomatoes, onions, pickles, creamy mayonnaise, and ketchup, served on a toasted sesame seed bun. Classic, cheesy, and satisfying.',
      brand: BrandModel(
        id: '1',
        image: YImage.burgerKingBrand,
        name: 'Burger King',
        productsCount: 265,
        isFeatured: true,
      ),
      salePrice: 7,
      categoryId: '1',
    ),
    ProductModel(
      id: '004',
      title: 'Seafood Pizza ',
      price: 13,
      isFeatured: true,
      thumbnail: YImage.seafoodPizza,
      description:
          'A savory pizza topped with a rich tomato or creamy sauce, loaded with shrimp, squid, and other seafood, finished with melted mozzarella cheese and a sprinkle of herbs. Fresh, flavorful, and deliciously ocean-inspired.',
      brand: BrandModel(
        id: '1',
        image: YImage.burgerKingBrand,
        name: 'Burger King',
        productsCount: 265,
        isFeatured: true,
      ),
      salePrice: 10,
      categoryId: '2',
    ),
  ];

  /// -- List of all Posters
  static final List<PosterModel> posters = [
    // Original onboarding posters
    PosterModel(id: 'poster_1', imageUrl: YImage.poster1, active: true),
    PosterModel(id: 'poster_2', imageUrl: YImage.poster2, active: true),

    // // Converted banner posters (replacing old BannerModel entries)
    // PosterModel(
    //   id: 'poster_banner_1',
    //   imageUrl: YImage.onBoardingImage1,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_2',
    //   imageUrl: YImage.onBoardingImage2,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_3',
    //   imageUrl: YImage.onBoardingImage3,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_4',
    //   imageUrl: YImage.texasDoubleWhopperBurger,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_5',
    //   imageUrl: YImage.originalChickenSandwichBurger,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_6',
    //   imageUrl: YImage.whopperWithCheeseBurger,
    //   active: true,
    // ),
    // PosterModel(
    //   id: 'poster_banner_7',
    //   imageUrl: YImage.seafoodPizza,
    //   active: false,
    // ),
  ];
}
