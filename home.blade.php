@extends('layouts.app')
<?php $adminmenus = DB::table('backurls')->get(); ?>

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Dashboard') }}
					@foreach ($adminmenus as $adminmenu)
						<a href={{$adminmenu->name}} >{{$adminmenu->name}} | </a>
					@endforeach
				</div>
				
                <div class="card-body">
                    @if (session('status'))
                        <div class="alert alert-success" role="alert">
                            {{ session('status') }}
                        </div>
                    @endif

                    {{ __('You are logged in!') }}
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
