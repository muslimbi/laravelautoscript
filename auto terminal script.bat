:: Name:     laravel-auto-setup-script
:: Purpose:  Set up a new laravel project and install useful default packages
:: Requires: PHP available from cli on current system
::           composer available from cli on current system
:: Author:   muslimbi@gmail.com
:: Revision: July 2022 - inital script


@echo off
rem Laravel Auto Script
set projectname=demoproject

cd /D %~dp0
SET CURRENTDIR=%~dp0
SET PROJECTDIR=%CURRENTDIR%%projectname%\


call composer create-project --prefer-dist laravel/laravel %projectname%
echo Laravel Install Successfully

rem copy database.sqlite %projectname%\database\database.sqlite
copy NUL %projectname%\database\database.sqlite
echo Database Copy Successfully

mkdir %projectname%\resources\views\layouts
rem copy layouts\* %projectname%\resources\views\layouts
rem copy layouts %projectname%\resources\views\layouts
copy app.blade.php %projectname%\resources\views\layouts\app.blade.php /Y
copy home.blade.php %projectname%\resources\views\home.blade.php /Y
copy welcome.blade.php %projectname%\resources\views\welcome.blade.php /Y
echo Copy app file

rem copy layouts %projectname%\resources\views\layouts
rem copy layouts\* %projectname%\resources\views\layouts
mkdir %projectname%\public\css
mkdir %projectname%\public\js
copy app.css %projectname%\public\css\app.css
copy app.js %projectname%\public\js\app.js



cd %projectname%

echo %PROJECTDIR%
echo %CURRENTDIR%
echo %projectname%
echo Now in project dirctory


@echo off &setlocal
set "search=localhost"
set "replace=localhost:8000"
set textfile=.env
set newfile=Output.txt
(for /f "delims=" %%i in (%textfile%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%search%=%replace%!"
    echo(!line!
    endlocal
))>"%newfile%"
del %textfile%
rename %newfile%  %textfile%

rem echo.APP_URL=http://localhost:8000>>"%PROJECTDIR%.env"
echo.DB_CONNECTION=sqlite>>"%PROJECTDIR%.env"
echo.DB_DATABASE=%PROJECTDIR%\database\database.sqlite>>"%PROJECTDIR%.env"
echo.FOREIGN_KEYS=ON>>"%PROJECTDIR%.env"
echo ENV file modify Successfully

call composer require laravel/ui
call php artisan ui bootstrap --auth
echo Laravel UI Install Successfully

call composer require barryvdh/laravel-debugbar --dev

call composer require laravel/telescope --dev
echo Laravel Telescope Install Successfully
php artisan migrate

call composer require barryvdh/laravel-ide-helper --dev 
php artisan clear-compiled
php artisan ide-helper:meta
:: php artisan ide-helper:models
php artisan ide-helper:generate

call composer require beyondcode/laravel-query-detector --dev
php artisan vendor:publish --provider=BeyondCode\QueryDetector\QueryDetectorServiceProvider

call composer require jamesmills/eloquent-uuid

call composer require spatie/laravel-activitylog
php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="migrations"
php artisan migrate
php artisan vendor:publish --provider="Spatie\Activitylog\ActivitylogServiceProvider" --tag="config"

call composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --tag="migrations"
php artisan migrate
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider" --tag="config"

call composer require laravelcollective/html

:: call composer require arcanedev/log-viewer --dev
:: php artisan log-viewer:publish
:: php artisan log-viewer:check
:: php artisan log-viewer:clear

call composer require crestapps/laravel-code-generator --dev

echo Code Generator Install Successfully

php artisan resource-file:create backurl --fields=id,name,description,is_active --translation-for=en,ar
php artisan create:resources backurl --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create Biography --fields="id,name,name:gender;options:male|female;html-type:select;data-type:enum,name:music_type;html-type:checkbox;options:country|pop|rock|jazz|rap,is_retired"
php artisan create:resources Biography --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create Animal --fields=id,name,description,is_active --translation-for=en,ar
php artisan create:resources Animal --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create AssetCategory --fields=id,name,description,is_active
php artisan create:resources AssetCategory --with-migration

php artisan resource-file:create Department --fields="id,name,image,is_active"
php artisan create:resources Department --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create quote_items --fields="id,quote_id,qty,unit,desc,price,is_active"
php artisan create:resources quote_items --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create bids --fields="id,quote_id,supplier_id,amount,message,status,is_active"
php artisan create:resources bids --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create quotes --fields="id,department_id,desc,status,approved_on,approved_by,assigned,is_active"
php artisan create:resources quotes --with-soft-delete --models-per-page=15 --with-migration



php artisan migrate

php artisan tinker

rem DB::table("backurls")->insert(["id"=>"1", "name"=>"biographies", "description"=>"Biography Menu"]);
rem DB::table("backurls")->insert(["id"=>"2", "name"=>"animals", "description"=>"animals Menu"]);
rem DB::table("backurls")->insert(["id"=>"3", "name"=>"asset_categories", "description"=>"asset ctg Menu"]);
rem exit

php artisan serve

rem add namespace at router 'namespace'=>'App\Http\Controllers',

pause
