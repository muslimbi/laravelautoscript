# CRUD & Domain Module Generator — LaravelAutoScript v2

The generator suite scaffolds full resource stacks for models and entire domain modules (User/Permissions, Products & Categories, Employees, Orders, Customers) across all application layers.

## 1. Domain Module Scaffolder
Quickly scaffold pre-configured business domain modules complete with Models, Migrations, Factories, Controllers, Requests, and Admin Resources (e.g. Filament Resources).

```bash
# Interactive Selection
node scripts/platform-builder.js scaffold

# Direct Module Scaffolding
node scripts/platform-builder.js scaffold user-permissions
node scripts/platform-builder.js scaffold products-categories
node scripts/platform-builder.js scaffold employees
node scripts/platform-builder.js scaffold orders
node scripts/platform-builder.js scaffold customers
```

### Available Domain Modules:
- **`user-permissions`**: Spatie Roles & Permissions integration (`spatie/laravel-permission`), Role & Permission models/migrations, and User management stack.
- **`products-categories`**: Product catalog with `Category` (name, slug, parent_id) and `Product` (category_id, name, sku, price, stock, active status).
- **`employees`**: HR directory module with `Department` (name, code) and `Employee` (name, email, phone, position, hire date, salary, status).
- **`orders`**: E-commerce order processing module with `Order` and `OrderItem` structures.
- **`customers`**: CRM contact & account management module with `Customer` models and admin resources.

---

## 2. Generic CRUD Generator
Scaffold a custom resource model with specified field definitions:

```bash
laravelautoscript crud --name Product --fields "name:string,price:decimal,description:text,is_active:boolean" --project ./my-app
```

## Generated Layers
- Model (`app/Models/Product.php`)
- Migration (`database/migrations/xxxx_xx_xx_create_products_table.php`)
- Factory (`database/factories/ProductFactory.php`)
- Controller (`app/Http/Controllers/ProductController.php`)
- Form Requests (`app/Http/Requests/StoreProductRequest.php`, `UpdateProductRequest.php`)
- Admin Resource (scaffolded according to selected admin panel, e.g., Filament resource)

