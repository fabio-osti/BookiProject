String removeAccents(String str) {

  var withAccent = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutAccent = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz'; 

  for (int i = 0; i < withAccent.length; i++) {      
    str = str.replaceAll(withAccent[i], withoutAccent[i]);
  }

  return str;
}

bool isNullOrEmpty(String? str) => str == null || str.isEmpty;