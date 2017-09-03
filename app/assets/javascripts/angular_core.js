app.controller('checkController',['$window', '$timeout', '$scope', '$http', 'utils',
                          function($window,   $timeout,   $scope,   $http,   utils){

  console.log('check p');

  $scope.num = 3;
  $scope.user_list = [];
  $scope.expr = "and";

  $scope.divide = function(){
    var list = $scope.words.split(/\r\n|\r|\n/);
    $scope.word_list = _.filter(list, function(word){
      return word !== "";
    });
  }

  $scope.f_send_words = function(){
    var post_data = $.param({
      'words': $scope.word_list,
      'expr': $scope.expr,
      'num': $scope.num,
    });
    $http({
      url: utils.root_url() + 'search',
      method: 'POST',
      data: post_data,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).success(function(data) {
      $scope.user_list = data.response;
      $scope.f_all_targets();
      //if( typeof(callback) == "function" ){
      //  callback();
      //}
      console.log($scope.targets);
    });
  }

  $scope.targets = []
  $scope.f_all_targets = function(){
    $scope.targets = _.map($scope.user_list, function(data){
      return data.user.id;
    })
    $scope.datas = {}
    _.each($scope.user_list, function(data){
      $scope.datas[data.user.id] = { 
        name: data.user.name,
        at: data.name,
        text: data.text,
        profile: data.user.description
      }
    })
  }
  $scope.f_reset_targets = function(){
    $scope.targets = [];
    $scope.datas = {}
  }
  $scope.f_add_targets = function(data){
    $scope.targets.push(data.user.id);
    $scope.datas[data.user.id] = { 
      name: data.user.name,
      at: data.name,
      text: data.text,
      profile: data.user.description
    }
  }
  $scope.f_rm_targets = function(data){
    for(i=0; i<$scope.targets.length; i++){
      if($scope.targets[i] === data.user.id){
        $scope.targets.splice(i, 1);
      }
    }
    delete $scope.datas[data.user.id];
  }

  $scope.f_follow = function(){
    var post_data = $.param({
      'users': $scope.targets,
      'datas': $scope.datas
    });
    $http({
      url: utils.root_url() + 'follow',
      method: 'POST',
      data: post_data,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).success(function(data) {
      $scope.f_reset_targets();
      $scope.user_list = [];
      swal("完了", "フォローしました", "success");
    });
  }

  $scope.delete_list = []; 
  $scope.f_users = function(){
    var post_data = $.param({
      'num': $scope.targets,
    });
    $http({
      url: utils.root_url() + 'users',
      method: 'POST',
      data: post_data,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).success(function(data) {
      $scope.delete_list = data.response;
    });
  }

  $scope.f_delete = function(){
    var del = _.map($scope.delete_list, function(data){
      return data.user_id
    })
    var post_data = $.param({
      'del': del
    });
    $http({
      url: utils.root_url() + 'delete',
      method: 'POST',
      data: post_data,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).success(function(data) {
      $scope.delete_list = [];
      swal("完了", data.response + "人のフォロー解除しました", "success");
    });
  }

}]);

app.constant('utils', {
/*
  'visit': function(page, anima) {
    console.log('visit:'+ mode);
    if(mode==='web'){
      Turbolinks.visit(page);
    }else{
      anima = anima || 'fade';
      app.navi.resetToPage(page + '.html', {animation: anima} )
    }
  },*/
  'root_url': function() {
    return ROOT_URL
  }

});
