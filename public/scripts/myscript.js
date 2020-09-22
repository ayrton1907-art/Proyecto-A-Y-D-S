// <!-- Inicio de la -->
document.addEventListener('DOMContentLoaded', function() {
  M.AutoInit();
 });

// <!-- WebSocket -->
const ws  = new WebSocket('ws://localhost:9292/miwebsoket');
ws.onmessage = function(m) {
  window.location.reload();
};

// <!-- Esto era lo de WebSocket anterior no se si funciona o no... hablar con nico  -->
window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws  = new WebSocket('ws://localhost:9292/miwebsoket');
    ws.onopen = () => {console.log('conectado');}
    ws.onerror = e => {console.log('error en la conexion', e);};
    ws.onclose = () => {console.log('desconectado');};
    ws.onmessage = function(m) {
      show('websocket message: ' + m.data);
      var msgs = document.getElementById('msgs');
        msgs.innerHTML = '\
              <div class="col-lg-4 col-md-4 col-sm-3 col-xs-2">\
              <a id="buttonNotf" href="/notificaciones">Notificaciones</a>\
              </div>';
      };
      var sender = function(f){
        f.onsubmit = function(){
          ws.send(msgs);
          return true;
        }
        }(document.getElementById('form'));
      })();
    }
