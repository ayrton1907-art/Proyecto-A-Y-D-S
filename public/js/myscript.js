M.AutoInit();
jQuery(document).ready(function($) {
  $(function() {
    $.ajax({
      type: 'GET',
      url: 'http://localhost:9292/search_documents?element='+ document.getElementById("searchDocuments").value,
      success: function(response){
        var doc = JSON.parse(response);
        var dataDoc = {};
        for (var i = 0; i < doc.length; i++) {
          console.log(doc[i].name);
          dataDoc[doc[i].name] = null;
        }
        $('input.autocomplete').autocomplete({
          data: dataDoc,
          limit: 5, // The max amount of results that can be shown at once. Default: Infinity.
        });
      }
    });
  });
});
//
// jQuery(document).ready(function($) {
//   $(function() {
//     $.ajax({
//       type: 'GET',
//       url: 'http://localhost:9292/search_categories?element='+ document.getElementById("categories").value,
//       success: function(response){
//         var cat = JSON.parse(response);
//         var dataCat = {};
//         for (var i = 0; i < cat.length; i++) {
//           console.log(cat[i].name);
//           dataCat[cat[i].name] = null;
//         }
//         $('input.autocomplete').autocomplete({
//           data: dataCat,
//           limit: 5, // The max amount of results that can be shown at once. Default: Infinity.
//         });
//       }
//     });
//   });
// });






// // <!-- WebSocket -->
// jQuery(document).ready(function($){
//   $(document).ready(function() {
//       $('.mi-selector').select2();
//   });
// });
//
//
// // <!-- Esto era lo de WebSocket anterior no se si funciona o no... hablar con nico  -->
// window.onload = function(){
//   (function(){
//     var show = function(el){
//       return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
//     }(document.getElementById('msgs'));
//     var ws  = new WebSocket('ws://localhost:9292/miwebsoket');
//     ws.onopen = () => {console.log('conectado');}
//     ws.onerror = e => {console.log('error en la conexion', e);};
//     ws.onclose = () => {console.log('desconectado');};
//     ws.onmessage = function(m) {
//       show('websocket message: ' + m.data);
//       var msgs = document.getElementById('msgs');
//       };
//       var sender = function(f){
//         f.onsubmit = function(){
//           ws.send(msgs);
//           return true;
//         }
//         }(document.getElementById('form'));
//       })();
//     };
