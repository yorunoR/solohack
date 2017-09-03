
app = angular.module('myApp', ['ui.bootstrap','ngTouch','ngAnimate'])


app.config([ '$httpProvider', function( $httpProvider ){
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
}]);

//$(document).on('ready page:load', function(){
$(document).on('turbolinks:load', function(){
    console.log("setup");
    angular.bootstrap(document.body, ['myApp']);
    console.log('boot');
});

