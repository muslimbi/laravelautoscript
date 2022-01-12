@echo off
set projectname=hasan6

cd /D %~dp0
SET CURRENTDIR=%~dp0
SET PROJECTDIR=%CURRENTDIR%%projectname%\


call composer create-project --prefer-dist laravel/laravel %projectname%

echo Laravel Install Successfully
copy database.sqlite %projectname%\database\database.sqlite
mkdir %projectname%\resources\views\layouts
rem copy app.blade.php %projectname%\resources\views\layouts\app.blade.php

rem copy layouts %projectname%\resources\views\layouts

copy layouts\* %projectname%\resources\views\layouts

echo Database Copy Successfully


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
echo.DB_DATABASE=D:\laravel\%projectname%\database\database.sqlite>>"%PROJECTDIR%.env"

echo ENV file modify successfully

call composer require laravel/ui
call php artisan ui bootstrap --auth
echo Laravel UI Install Successfully

call composer require laravel/telescope
call php artisan telescope:install
echo Laravel Telescope Install Successfully


call composer require crestapps/laravel-code-generator --dev

echo Code Generator Install Successfully


php artisan resource-file:create Biography --fields="id,name,name:gender;options:male|female;html-type:select;data-type:enum,name:music_type;html-type:checkbox;options:country|pop|rock|jazz|rap,is_retired"
php artisan create:resources Biography --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create Animal --fields=id,name,description,is_active --translation-for=en,ar
php artisan create:resources Animal --with-soft-delete --models-per-page=15 --with-migration

php artisan resource-file:create AssetCategory --fields=id,name,description,is_active
php artisan create:resources AssetCategory --with-migration

php artisan migrate
php artisan serve


pause
