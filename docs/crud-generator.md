# CRUD Generator — LaravelAutoScript v2

The generic CRUD generator scaffolds full resource stacks for models across all application layers.

## Command Usage
```bash
laravelautoscript crud --name Product --fields "name:string,price:decimal,description:text,is_active:boolean" --project ./my-app
```

## Generated Layers
- Model (`app/Models/Product.php`)
- Migration (`database/migrations/xxxx_xx_xx_create_products_table.php`)
- Factory (`database/factories/ProductFactory.php`)
- Controller (`app/Http/Controllers/ProductController.php`)
- Form Requests (`app/Http/Requests/StoreProductRequest.php`, `UpdateProductRequest.php`)
- Resource / Policy
- Admin Resource (scaffolded according to selected admin panel, e.g. Filament resource)
