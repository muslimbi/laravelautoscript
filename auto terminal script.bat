@echo off
rem Laravel Auto Script
set projectname=demoproject

cd /D %~dp0
SET CURRENTDIR=%~dp0
SET PROJECTDIR=%CURRENTDIR%%projectname%\


call composer create-project --prefer-dist laravel/laravel %projectname%
echo Laravel Install Successfully

copy database.sqlite %projectname%\database\database.sqlite
echo Database Copy Successfully

mkdir %projectname%\resources\views\layouts
copy app.blade.php %projectname%\resources\views\layouts\app.blade.php
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
rem DB_DATABASE=D:\laravel\%projectname%\database\database.sqlite>>"%PROJECTDIR%.env"
echo.DB_DATABASE=database\database.sqlite>>"%PROJECTDIR%.env"

echo ENV file modify Successfully

call composer require laravel/ui
call php artisan ui bootstrap --auth
echo Laravel UI Install Successfully

call composer require laravel/telescope
call php artisan telescope:install
echo Laravel Telescope Install Successfully
php artisan migrate

call composer require crestapps/laravel-code-generator --dev

echo Code Generator Install Successfully


php artisan resource-file:create Biography --fields="id,name,name:gender;options:male|female;html-type:select;data-type:enum,name:music_type;html-type:checkbox;options:country|pop|rock|jazz|rap,is_retired"
php artisan create:resources Biography --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create Animal --fields=id,name,description,is_active --translation-for=en,ar
php artisan create:resources Animal --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create AssetCategory --fields=id,name,description,is_active
php artisan create:resources AssetCategory --with-migration

php artisan migrate

php artisan tinker 
DB::table("backurls")->insert(["id"=>"1", "name"=>"biographies", "description"=>"Biography Menu"]);
DB::table("backurls")->insert(["id"=>"2", "name"=>"animals", "description"=>"animals Menu"]);
DB::table("backurls")->insert(["id"=>"3", "name"=>"asset_categories", "description"=>"asset_categories Menu"]);


php artisan serve

rem add namespace at router 'namespace'=>'App\Http\Controllers',

pause
