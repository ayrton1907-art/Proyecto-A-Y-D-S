var nombre = document.getElementById('nombre');

function enviarFormulario(){
  var mensajeError = [];
  if (nombre.value === null || nombre.value === ""){
    M.toast({html: 'No ingresó un nombre!', classes: 'rounded'});
  }
  else if (nombre.value.length < 3){
    M.toast({html: 'Nombre demasiado corto!', classes: 'rounded'});
  }
  else if (nombre.value.length > 50){
    M.toast({html: 'Nombre demasiado largo!', classes: 'rounded'});
  }
  else {
    enviar();
  }
  return false;
}
