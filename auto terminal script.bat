@echo off

set projectname=hasan6
composer create-project --prefer-dist laravel/laravel %projectname%
copy database.sqlite %projectname%\database\database.sqlite

cd %projectname%

echo DB_CONNECTION=sqlite
echo DB_DATABASE=D:\laravel\%projectname%\database\database.sqlite

composer require laravel/ui
php artisan ui bootstrap
php artisan ui bootstrap --auth


composer require crestapps/laravel-code-generator --dev

// app/Providers/AppServiceProvider.php register()

//if ($this->app->runningInConsole()) {
//    $this->app->register('CrestApps\CodeGenerator\CodeGeneratorServiceProvider');
//}


php artisan resource-file:create Biography --fields=name,age,biography,sport,gender,colors,is_retired,photo,range,month --translation-for=en,ar
php artisan create:resources Biography --with-form-request --with-soft-delete --models-per-page=15 --with-migration
php artisan create:resources Biography --with-form-request --with-soft-delete --models-per-page=15 --with-migration --fields=name,age,biography,sport,gender,colors,is_retired,photo,range,month --translation-for=en,ar

php artisan resource-file:create AssetCategory --fields=name,age,biography,sport,gender,colors,is_retired,photo,range,month --translation-for=en,ar
php artisan create:resources AssetCategory --with-form-request --with-soft-delete --models-per-page=15 --with-migration
php artisan create:resources AssetCategory --with-form-request --with-soft-delete --models-per-page=15 --with-migration --fields=name,age,biography,sport,gender,colors,is_retired,photo,range,month --translation-for=en,ar

php artisan migrate
php artisan serve


