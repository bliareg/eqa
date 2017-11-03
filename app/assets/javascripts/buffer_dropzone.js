window.addEventListener("paste", pasteHandler);

function pasteHandler(e) {
// если поддерживается event.clipboardData (Chrome)
  if (!e.clipboardData || !myDropzone) return;
  // получаем все содержимое буфера
  var items = e.clipboardData.items;
  if (items) {
     // находим изображение
     for (var i = 0; i < items.length; i++) {
        if (items[i].kind == 'file') {
           // представляем изображение в виде файла
           var blob = items[i].getAsFile();
           blob.name = 'file.' + blob.type.match(/[a-z]+$/)
           myDropzone.addFile(blob);
        }
     }
  }
}