// メニュー操作
// トグルリスナーを追加してクリックをリッスンする
document.addEventListener('turbo:load', function(){
  let hamburger = document.querySelector('#hamburger')
  hamburger.addEventListener('click', function(event){
    event.preventDefault();
    let menu = document.querySelector('#navbar-menu');
    menu.classList.toggle('collapse');
  });

  let account = document.querySelector('#account');
  account.addEventListener('click', function(event){
    event.preventDefault(); //アンカータグの機能を停止する。
    let menu = document.querySelector('#dropdown-menu');
    menu.classList.toggle('active'); //メニュー要素にactiveクラスを付与し表示させる。
  });
});