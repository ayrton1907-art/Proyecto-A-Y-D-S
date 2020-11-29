// <!-- Inicio de la -->
M.AutoInit();

// <!-- WebSocket -->
const ws  = new WebSocket('ws://localhost:9292/miwebsoket');
window.onload = function(){
  (function(){
    var show = function(el){
      return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
    }(document.getElementById('msgs'));
    var ws  = new WebSocket('ws://localhost:9292/miwebsoket');
    ws.onopen = () => {console.log('conectado');}
    ws.onerror = e => {console.log('error en la conexion', e);};
    ws.onclose = () => {console.log('desconectado');};
    ws.onmessage = () => {
      console.log('RECIBIO');
      setTimeout("recibir()",500);
    }
  })();
}

function enviar(){
  var msgs = 'mensaje recibido';
  ws.send(msgs);
}

function recibir(){
  console.log("ENVIO");
  location.reload(true);
}
